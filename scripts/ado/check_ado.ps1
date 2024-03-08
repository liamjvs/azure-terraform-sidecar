# Description: Checks if the ADOServiceConnection has access to the project, agent pool and service connections.

param(
    [string]$service_connection,
    [string]$ado_project,
    [string]$ado_org
)

Import-Module ./funcs/project.ps1 -Force
Import-Module ./funcs/service_connection.ps1 -Force
Import-Module ./funcs/agent_pool.ps1 -Force

$projects_object = Get-ProjectObject -ado_org $ado_org -ado_project $ado_project
if (!$projects_object) {
    Write-Error ("The Service Connection '{0}' does not have access to the project." -f $service_connection)
} else {
    Write-Verbose ("The Service Connection '{0}' has access to the project." -f $service_connection) -Verbose
}
$project_id = $projects_object.id
Write-Verbose "Project Id: $project_id" -Verbose

Write-Verbose "Getting ADO unique Service Principal ID" -Verbose
$service_principal = Get-ServicePrincipalObject -ado_org $ado_org -service_principal_id $env:servicePrincipalId
if ($service_principal) {
    Write-Verbose "Found Service Principal: $($service_principal.displayName) with ADO ID $($service_principal.id) and Entra Application ID $($service_principal.applicationId)" -Verbose
} else {
    Write-Error "Could not find Service Principal with applicationId: $($env:servicePrincipalId)"
}

$agent_pool_security = Get-AgentPoolSecurity -ado_org $ado_org -user_id $service_principal.id -project_id $project_id
$agent_pool_identity = $agent_pool_security | where-object { $_.role.allowPermissions -ge 33 }

if (!$agent_pool_identity) {
    Write-Error "The Service Connection does not have Creator or above to the project Agent Pools."
} else {
    Write-Verbose "The Service Connection does have Creator or above to the project Agent Pool." -Verbose
}

$service_connections_object = Get-ServiceConnectionSecurity -ado_org $ado_org -user_id $service_principal.id -project_id $project_id |
                            Where-Object { $_.role.allowPermissions -ge 3 }

if (!$service_connections_object) {
    Write-Error "The ADOServiceConnection does not have access to the service connections."
} else {
    Write-Verbose "The ADOServiceConnection has access to the service connections." -Verbose
}