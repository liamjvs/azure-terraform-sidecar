# Description: Checks if the ADOServiceConnection has access to the project, agent pool and service connections.

param(
    [string]$service_connection,
    [string]$ado_project,
    [string]$ado_org
)

$projects_uri = "$ado_org/_apis/projects?api-version=7.1-preview.4"
$agent_pool_uri = "$ado_org/_apis/securityroles/scopes/distributedtask.globalagentqueuerole/roleassignments/resources/{0}"
$service_connection_uri = "$ado_org/_apis/securityroles/scopes/distributedtask.project.serviceendpointrole/roleassignments/resources/{0}"
$ado_graph_app = "499b84ac-1321-427f-aa17-267ca6975798"

Write-Verbose "Trying if Service Connection has access to ADO projects: $projects_uri" -Verbose
$projects = az rest --uri $projects_uri --method get --resource $ado_graph_app --output json
$projects_object = $projects | ConvertFrom-Json -Depth 10 | Select-Object -ExpandProperty value | Where-Object { $_.name -eq $ado_project }
if ($null -eq $projects_object) {
    Write-Error ("The Service Connection '{0}' does not have access to the project." -f $service_connection)
} else {
    Write-Verbose ("The Service Connection '{0}' has access to the project." -f $service_connection) -Verbose
}

$project_id = $projects_object.id
Write-Verbose "Project Id: $project_id" -Verbose
$agent_pool_uri = $agent_pool_uri -f $project_id
Write-Verbose "Trying for Agent Pools: $agent_pool_uri" -Verbose
$agent_pools = az rest --uri $agent_pool_uri --method get --resource $ado_graph_app --output json
$agent_pool_identity = $agent_pools | ConvertFrom-Json -Depth 10 | Select-Object -ExpandProperty value | `
                        where-object { $_.identity.displayName -eq $service_connection -and (($_.role.allowPermissions -ge 33)) } 

if ($null -eq $agent_pool_identity) {
    Write-Error "The Service Connection does not have Creator or above to the project Agent Pools."
} else {
    Write-Verbose "The Service Connection does have Creator or above to the project Agent Pool." -Verbose
}


$service_connection_uri = $service_connection_uri -f $project_id
Write-Verbose "Trying for Service Connections: $service_connection_uri" -Verbose
$service_connections = az rest --uri $service_connection_uri --method get --resource $ado_graph_app --output json
$service_connections_object = $service_connections | 
                            ConvertFrom-Json -Depth 10 | 
                            Select-Object -ExpandProperty value | 
                            Where-Object { $_.identity.displayName -eq $service_connection -and (($_.role.allowPermissions -ge 3)) }

if ($null -eq $service_connections_object) {
    Write-Error "The ADOServiceConnection does not have access to the service connections."
} else {
    Write-Verbose "The ADOServiceConnection has access to the service connections." -Verbose
}