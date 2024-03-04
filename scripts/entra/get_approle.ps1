param(
    [string]$object_id,
    [string]$graph_permission
)

Import-Module ./funcs/approle_assignments.ps1 -Force

$existing_roles = Get-AppRoleAssignments -object_id $object_id
if ($existing_roles | Where-Object { $_.value -eq $graph_permission }) {
    Write-Output "Role $graph_permission already assigned to $object_id"
} else {
    Write-Error "Role $graph_permission not assigned to $object_id"
}