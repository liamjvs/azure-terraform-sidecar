param(
  [string]$ado_org,
  [string]$ado_project,
  [string]$ado_service_connection_name,
  [string]$ado_agent_pool_vmss_id,
  [string]$ado_agent_pool_name,
  [string]$subscription_name,
  [string]$vmss_operator_name
)

Write-Verbose "Organisation: $ado_org" -Verbose
Write-Verbose "Project: $ado_project" -Verbose
Write-Verbose "Endpoint Name: $ado_service_connection_name" -Verbose
Write-Verbose "VMSS Azure Id: $ado_agent_pool_vmss_id" -Verbose
Write-Verbose "Service Principal Name: $vmss_operator_name" -Verbose
Write-Verbose "Subscription Name: $subscription_name" -Verbose

$vmss_sp = az ad app list --output json --query "[?displayName=='$($vmss_operator_name)']" | ConvertFrom-Json -Depth 10
if (!$vmss_sp) {
  $vmss_sp = az ad sp create-for-rbac --name $vmss_operator_name --role "Virtual Machine Contributor" --scopes $ado_agent_pool_vmss_id --json-auth --output json --only-show-errors | ConvertFrom-Json -Depth 10
} else {
  if($vmss_sp.Length -gt 1){
    Write-Error "Found too many Service Principals"
    throw "Found too many Service Principals"
  }
  # Read existing keys
  $keys = az rest --method get --url https://graph.microsoft.com/v1.0/applications/$($vmss_sp.id) `
          --query "passwordCredentials[?displayName=='rbac'].{name:displayName,id:keyId}" `
          | ConvertFrom-Json -Depth 10
    foreach($key in $keys){
        Write-Verbose ("Removing key with displayName {0}" -f $key.name) -Verbose
        @{ keyId = $key.id } | ConvertTo-Json -Depth 10 | Out-File -FilePath payload.json -Encoding ascii -Force
        az rest --method post --url https://graph.microsoft.com/v1.0/applications/$($vmss_sp.id)/removePassword --body "@payload.json" --only-show-errors
    }
  
  Write-Verbose ("Creating key with displayName" -f $sp.name) -Verbose
  @{ passwordCredential = @{ displayName = "rbac" }} | ConvertTo-Json -Depth 10 | Out-File -FilePath "payload.json" -Encoding ascii -Force
  $output = az rest --method post --url https://graph.microsoft.com/v1.0/applications/$($vmss_sp.id)/addPassword --body "@payload.json" --only-show-errors
  $vmss_sp_object = $output | ConvertFrom-Json -depth 10
  $vmss_sp = @{
    clientId = $vmss_sp.appId
    clientSecret = $vmss_sp_object.secretText
    subscriptionId = $ado_agent_pool_vmss_id.Split("/")[2]
    displayName = $vmss_operator_name
    tenantId = $(az account show --query "tenantId")
  }
}

if($env:ADO_CLIENT_ID -and $env:ADO_TENANT_ID -and $env:ADO_CLIENT_SECRET){
  Write-Verbose "Logging out of Service Connection" -Verbose
  az logout
  Write-Verbose "Logging into Azure DevOps Service Connection" -Verbose
  az login --service-principal --username $env:ADO_CLIENT_ID --password $env:ADO_CLIENT_SECRET --tenant $env:ADO_TENANT_ID --allow-no-subscriptions --only-show-errors
  Write-Verbose "Successfully Logged into Azure DevOps Service Connection" -Verbose
}

$projects_uri = "$($ado_org)_apis/projects?api-version=7.1-preview.4"
Write-Verbose "Trying for projects: $projects_uri" -Verbose
$ado_projects = az rest --uri $projects_uri --method get --resource '499b84ac-1321-427f-aa17-267ca6975798' --output json
Write-Verbose ("Projects: {0}" -f ($ado_projects | ConvertFrom-Json -Depth 10 | ConvertTo-Json -Compress)) -Verbose
$ado_projectsObject = $ado_projects | ConvertFrom-Json -Depth 10
$ado_projectTargetObject = $ado_projectsObject.value | where-object { $_.name -eq $ado_project }

if (!$ado_projectTargetObject) {
  Write-Error "Project Not Found"
}
$ado_project_id = $ado_projectTargetObject.id

# Search for service connection
$service_connections_uri = "$($ado_org)$($ado_project)/_apis/serviceendpoint/endpoints?api-version=7.1-preview.4"
Write-Verbose "Trying for service connections: $service_connections_uri" -Verbose
$service_endpoints = az rest --uri $service_connections_uri --method get --resource '499b84ac-1321-427f-aa17-267ca6975798' --output json
Write-Verbose ("Service Connections: {0}" -f ($service_endpoints | ConvertFrom-Json -Depth 10 | ConvertTo-Json -Compress)) -Verbose
$service_endpoints_search = ($service_endpoints | ConvertFrom-Json -Depth 10)

if ($service_endpoints_search) {
  if ($service_endpoints_search.value | where-object { $_.name -eq $ado_service_connection_name }) {
    Write-Verbose "Service Connection Already Exists" -Verbose
    $service_endpoints_object = $service_endpoints_search.value | where-object { $_.name -eq $ado_service_connection_name }
  }
  # To-DO: Write logic where Service Endpoint exists and we need to push the new secret
}

if (!$service_endpoints_object) {
  $payload = @{
    data = @{
      subscriptionId = "$($vmss_sp.subscriptionId)"
      subscriptionName = "$subscription_name"
      environment = "AzureCloud"
      scopeLevel = "Subscription"
      creationMode = "Manual"
    }
    name = $ado_service_connection_name
    type = "AzureRM"
    url = "https://management.azure.com/"
    authorization = @{
      parameters = @{
        tenantid = $vmss_sp.tenantId
        serviceprincipalid = $vmss_sp.clientId
        authenticationType = "spnKey"
        serviceprincipalkey = $vmss_sp.clientSecret
      }
      scheme = "ServicePrincipal"
    }
    isShared = false
    isReady = true
    serviceEndpointProjectReferences = @(
      @{
        projectReference = @{
          id = $ado_project_id
          name = $ado_project
        }
        name = $ado_service_connection_name
      }
    )
  } | ConvertTo-Json -Compress -Depth 10
  $payload | Out-File -FilePath payload.json -Encoding ascii -Force
  Write-Verbose ("Payload for Service Endpoint: {0}" -f ($payload.replace($vmss_sp.clientSecret, "*"))) -Verbose
  
  $service_connection_uri = "$($ado_org)_apis/serviceendpoint/endpoints?api-version=7.1-preview.4"
  Write-Verbose ("Trying to create service endpoint: {0}" -f $service_connection_uri) -Verbose
  
  $service_endpoints_response = az rest --uri $service_connection_uri --method post --resource "499b84ac-1321-427f-aa17-267ca6975798" --output json --body "@payload.json"
  $service_endpoints_object = $service_endpoints_response | ConvertFrom-Json -Depth 10
}

$elastic_pools_uri = "$($ado_org)_apis/distributedtask/elasticpools?api-version=7.0"
Write-Verbose ("Trying for elastic pools: {0}" -f $elastic_pools_uri) -Verbose
$elastic_pools = az rest --uri $elastic_pools_uri --method get --resource '499b84ac-1321-427f-aa17-267ca6975798' --output json
Write-Verbose ("Elastic Pools: {0}" -f ($elastic_pools | ConvertFrom-Json -Depth 10 | ConvertTo-Json -Compress)) -Verbose
$elastic_pools_object = $elastic_pools | ConvertFrom-Json -Depth 10

# Check if the VMSS is already registered
if (!($elastic_pools_object.value | Where-Object { $_.azureId -eq $ado_agent_pool_vmss_id })) {
  Write-Verbose "VMSS is not registered"
  Write-Verbose "Sleep for 30; let Azure DevOps Service Connection be ready" -Verbose
  Start-Sleep -Seconds 30
  $pool_name = $ado_service_connection_name
  $authorizeAllPipelines = $false
  $autoProvisionProjectPools = $false
  $agent_pool_uri = "$($ado_org)_apis/distributedtask/elasticpools?poolName={0}&authorizeAllPipelines={1}&autoProvisionProjectPools={2}&projectId={3}&api-version=7.0"
  $agent_pool_uri = $agent_pool_uri -f $pool_name, $authorizeAllPipelines, $autoProvisionProjectPools, $ado_project_id
  Write-Verbose ("Trying to register VMSS: {0}" -f $agent_pool_uri) -Verbose
  $payload = @{
    agentInteractiveUI = $false
    azureId = $ado_agent_pool_vmss_id
    desiredIdle = 0
    maxCapacity = 10
    maxSavedNodeCount = 0
    osType = 1
    recycleAfterEachUse = $true
    serviceEndpointId    = $($service_endpoints_object.id)
    serviceEndpointScope = $ado_project_id
    timeToLiveMinutes    = 15
  }
  $payload_json = $payload | ConvertTo-Json -Compress -Depth 10
  Write-Debug ("Payload: {0}" -f ($payload_json))
  Out-File -FilePath payload.json -Encoding ascii -Force -InputObject $payload_json
  $out = az rest --uri $agent_pool_uri --method post --resource '499b84ac-1321-427f-aa17-267ca6975798' --output json --body '@payload.json'
  Write-Debug $out
  Write-Verbose "Successfully Register VMSS" -Verbose
} else {
  Write-Verbose "Failed to Register VMSS - VMSS is already registered" -Verbose
}