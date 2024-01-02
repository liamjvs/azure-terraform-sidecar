param(
  [string]$ado_org,
  [string]$ado_project,
  [string]$ado_service_connection_name,
  [string]$ado_agent_pool_vmss_id,
  [string]$ado_agent_pool_name,
  [string]$subscription_name,
  [string]$ado_service_connection,
  [string]$vmss_operator_name
)

Write-Verbose "Organisation: $ado_org" -Verbose
Write-Verbose "Project: $ado_project" -Verbose
Write-Verbose "Endpoint Name: $ado_service_connection_name" -Verbose
Write-Verbose "VMSS Azure Id: $ado_agent_pool_vmss_id" -Verbose
Write-Verbose "Service Principal Name: $vmss_operator_name" -Verbose
Write-Verbose "Subscription Name: $subscriptionName" -Verbose

$vmss_sp = az ad app list --output json --query "[?displayName=='$($vmss_operator_name)']" | ConvertFrom-Json -Depth 10
if ($vmss_sp -eq $null) {
  $vmss_sp = az ad sp create-for-rbac --name $vmss_operator_name --role "Virtual Machine Contributor" --scopes $ado_agent_pool_vmss_id --json-auth --output json | convertfrom-json -Depth 10
} else {
  if($spObject.Length -gt 1){
    Write-Error "Found too many Service Principals"
    throw "Found too many Service Principals"
  }
  # Read existing keys
  $keys = az rest --method get --url https://graph.microsoft.com/v1.0/applications/$($vmss_sp.id) `
          --query "passwordCredentials[?displayName=='rbac'].{name:displayName,id:keyId}" `
          | ConvertFrom-Json -Depth 10
    foreach($key in $keys){
        Write-Verbose ("Removing key with displayName {0}" -f $key.name)
        $payload = @{ keyId = $key.id } | ConvertTo-Json -Depth 10 | Out-File -FilePath payload.json -Encoding ascii -Force
        az rest --method post --url https://graph.microsoft.com/v1.0/applications/$($spObject.id)/removePassword --body $payload --headers $headers
    }
  
  Write-Verbose ("Creating key with displayName" -f $sp.name)
  $payload = @{ passwordCredential = @{ displayName = "rbac" }} | ConvertTo-Json -Depth 10
  $headers = @{ "Content-Type" = "application/json" } | ConvertTo-Json -Depth 10
  $output = az rest --method post --url https://graph.microsoft.com/v1.0/applications/$($spObject.id)/addPassword --body $payload --headers $headers
  $outputObj = $output | ConvertFrom-Json -depth 10
  $vmss_sp = @{
    clientId = $spObject.appId
    clientSecret = $outputObj.secretText
    subscriptionId = $ado_agent_pool_vmss_id.Split("/")[2]
    displayName = $spName
    tenantId = $(az account show --query "tenantId")
  }
}

if( "${{ parameters.ADOServiceConnection }}" -ne "" ){
  Write-Verbose "Logging out of Service Connection"
  az logout
  Write-Verbose "Logging into Service Connection ${{ parameters.ADOServiceConnection }}"
  az login --service-principal --username "$(ADO_CLIENT_ID)" --password "$(ADO_CLIENT_SECRET)" --tenant "$(ADO_TENANT_ID)"
}

$accessToken = az account get-access-token --resource '499b84ac-1321-427f-aa17-267ca6975798' --query 'accessToken' --output tsv

$uri = "https://dev.azure.com/$ado_org/_apis/projects?api-version=7.1-preview.4"
Write-Verbose "Trying for projects: $uri" -Verbose
$ado_projects = az rest --uri $uri --method get --resource '499b84ac-1321-427f-aa17-267ca6975798' --output json
Write-Verbose ("Projects: {0}" -f ($ado_projects | ConvertFrom-Json -Depth 10 | ConvertTo-Json -Compress)) -Verbose
$ado_projectsObject = $ado_projects | ConvertFrom-Json -Depth 10
$ado_projectTargetObject = $ado_projectsObject.value | where-object { $_.name -eq $ado_project }

if ($ado_projectTargetObject -eq $null) {
  Write-Error "Project Not Found"
}
$ado_projectId = $ado_projectTargetObject.id

# Search for service connection
$uri = "https://dev.azure.com/$ado_org/$ado_project/_apis/serviceendpoint/endpoints?api-version=7.1-preview.4"
Write-Verbose "Trying for service connections: $uri" -Verbose
$serviceEndpoints = az rest --uri $uri --method get --resource '499b84ac-1321-427f-aa17-267ca6975798' --output json
Write-Verbose ("Service Connections: {0}" -f ($serviceEndpoints | ConvertFrom-Json -Depth 10 | ConvertTo-Json -Compress)) -Verbose
$serviceEndpointsSearch = ($serviceEndpoints | ConvertFrom-Json -Depth 10)

if ($serviceEndpointsSearch -ne $null) {
  if (($serviceEndpointsSearch.value | where-object { $_.name -eq $ado_service_connection_name }) -ne $null) {
    Write-Verbose "Service Connection Already Exists" -Verbose
    $serviceEndpointObject = $serviceEndpointsSearch.value | where-object { $_.name -eq $ado_service_connection_name }
  }
}

if ($serviceEndpointObject -eq $null) {
  $payload = @{
    data = @{
      subscriptionId = "$($spObject.subscriptionId)"
      subscriptionName = "$subscriptionName"
      environment = "AzureCloud"
      scopeLevel = "Subscription"
      creationMode = "Manual"
    }
    name = $ado_service_connection_name
    type = "AzureRM"
    url = "https://management.azure.com/"
    authorization = @{
      parameters = @{
        tenantid = $spObject.tenantId
        serviceprincipalid = $spObject.clientId
        authenticationType = "spnKey"
        serviceprincipalkey = $spObject.clientSecret
      }
      scheme = "ServicePrincipal"
    }
    isShared = false
    isReady = true
    serviceEndpointProjectReferences = @(
      @{
        projectReference = @{
          id = $ado_projectId
          name = $ado_project
        }
        name = $ado_service_connection_name
      }
    )
  } | ConvertTo-Json -Compress -Depth 10
  $payload | Out-File -FilePath payload.json -Encoding ascii -Force
  Write-Verbose ("Payload for Service Endpoint: {0}" -f ($payload.replace($spObject.clientSecret, "*"))) -Verbose
  
  $uri = "https://dev.azure.com/$ado_org/_apis/serviceendpoint/endpoints?api-version=7.1-preview.4"
  Write-Verbose ("Trying to create service endpoint: {0}" -f $uri) -Verbose
  
  $serviceEndpointResponse = az rest --uri $uri --method post --resource '499b84ac-1321-427f-aa17-267ca6975798' --output json --body '@payload.json'
  $serviceEndpointObject = $serviceEndpointResponse | ConvertFrom-Json -Depth 10
}

$ElasticPoolsUrl = "https://dev.azure.com/$ado_org/_apis/distributedtask/elasticpools?api-version=7.0"
Write-Verbose ("Trying for elastic pools: {0}" -f $ElasticPoolsUrl) -Verbose
$ElasticPools = az rest --uri $ElasticPoolsUrl --method get --resource '499b84ac-1321-427f-aa17-267ca6975798' --output json
Write-Verbose ("Elastic Pools: {0}" -f ($ElasticPools | ConvertFrom-Json -Depth 10 | ConvertTo-Json -Compress)) -Verbose
$ElasticPoolsObject = $ElasticPools | ConvertFrom-Json -Depth 10

# Check if the VMSS is already registered
if (($ElasticPoolsObject.value | Where-Object { $_.azureId -eq $ado_agent_pool_vmss_id }) -eq $null) {
  Write-Verbose "VMSS is not registered"
  Write-Verbose "Sleep for 30; let Azure DevOps Service Connection be ready" -Verbose
  Start-Sleep -Seconds 30
  $poolname = $ado_service_connection_name
  $authorizeAllPipelines = $false
  $autoProvisionProjectPools = $false
  $uri = "https://dev.azure.com/$ado_org/_apis/distributedtask/elasticpools?poolName={0}&authorizeAllPipelines={1}&autoProvisionProjectPools={2}&projectId={3}&api-version=7.0" -f $poolname, $authorizeAllPipelines, $autoProvisionProjectPools, $ado_projectId
  Write-Verbose ("Trying to register VMSS: {0}" -f $uri) -Verbose
  $payload = @{
    agentInteractiveUI = $false
    azureId = $ado_agent_pool_vmss_id
    desiredIdle = 0
    maxCapacity = 10
    maxSavedNodeCount = 0
    osType = 1
    recycleAfterEachUse = $true
    serviceEndpointId    = $($serviceEndpointObject.id)
    serviceEndpointScope = $($serviceEndpointObject.serviceEndpointProjectReferences[0].projectReference.id)
    timeToLiveMinutes    = 15
  }
  $payloadJson = $payload | ConvertTo-Json -Compress -Depth 10
  Write-Verbose ("Payload: {0}" -f ($payloadJson)) -Verbose
  Out-File -FilePath payload.json -Encoding ascii -Force -InputObject $payloadJson
  $NewPool = az rest --uri $uri --method post --resource '499b84ac-1321-427f-aa17-267ca6975798' --output json --body '@payload.json'
  Write-Verbose "Successfully Register VMSS" -Verbose
} else {
  Write-Verbose "Failed to Register VMSS - VMSS is already registered" -Verbose
}