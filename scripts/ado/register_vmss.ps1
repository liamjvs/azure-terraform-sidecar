param(
  [string]$ado_org,
  [string]$ado_project,
  [string]$ado_service_connection_name,
  [string]$ado_agent_pool_vmss_id,
  [string]$ado_agent_pool_name,
  [string]$subscription_name,
  [string]$vmss_operator_name
)

Import-Module funcs/project.ps1 -Force
Import-Module funcs/service_connection.ps1 -Force
Import-Module funcs/agent_pool.ps1 -Force

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

# Get Project Object
$ado_projectTargetObject = Get-ProjectObject -ado_org $ado_org -ado_project $ado_project

if (!$ado_projectTargetObject) {
  Write-Error "Project Not Found"
}
$ado_project_id = $ado_projectTargetObject.id

# Search for service connection
$service_endpoints_search = Get-ServiceConnections -ado_org $ado_org -ado_project $ado_project

if ($service_endpoints_search) {
  if ($service_endpoints_search.value | where-object { $_.name -eq $ado_service_connection_name }) {
    Write-Verbose "Service Connection Already Exists" -Verbose
    $service_endpoints_object = $service_endpoints_search.value | where-object { $_.name -eq $ado_service_connection_name }
  }
  # To-Do: Write logic where Service Endpoint exists and we need to push the new secret
}

if (!$service_endpoints_object) {
  Write-Verbose "Creating Service Connection" -Verbose
  $service_endpoints_object = New-ServiceConnection -ado_org $ado_org -ado_project $ado_project  -ado_service_connection_name $ado_service_connection_name -subscription_name $subscription_name -subscription_id $vmss_sp.subscriptionId -service_principal_id $vmss_sp.clientId -service_principal_secret $vmss_sp.clientSecret -tenant_id $vmss_sp.tenantId
  Write-Verbose ("Service Connection: {0}" -f ($service_endpoints_object | ConvertTo-Json -Compress)) -Verbose
} else {
  Write-Verbose "Service Connection Already Exists" -Verbose
}

$elastic_pools_object = Get-AgentPools -ado_org $ado_org

# Check if the VMSS is already registered
if (!($elastic_pools_object.value | Where-Object { $_.azureId -eq $ado_agent_pool_vmss_id })) {
  Write-Verbose "VMSS is not registered"
  Write-Verbose "Sleep for 30; let Azure DevOps Service Connection be ready" -Verbose
  Start-Sleep -Seconds 30
  $out = New-AgentPool -pool_name $ado_service_connection_name -ado_org $ado_org -ado_project_id $ado_project_id -ado_agent_pool_vmss_id $ado_agent_pool_vmss_id -service_endpoints_object_id $service_endpoints_object.id
  Write-Verbose "Successfully Register VMSS" -Verbose
} else {
  Write-Verbose "Failed to Register VMSS - VMSS is already registered" -Verbose
}