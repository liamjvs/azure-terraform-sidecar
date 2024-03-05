param(
    [string]$object_id,
    [string]$graph_permission
)

Import-Module ./funcs/approle_assignments.ps1 -Force

$role_exists = Get-AppRoleAssignment -object_id $object_id -app_role_display_name $graph_permission

if ($role_exists) {
    Write-Output "Role $graph_permission already assigned to $object_id"
} else {
    Write-Error "Role $graph_permission not assigned to $object_id"
}