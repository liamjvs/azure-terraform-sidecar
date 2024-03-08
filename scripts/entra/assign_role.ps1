param(
    [string]$object_id,
    [string[]]$graph_permissions
)

Import-Module ./funcs/approle_assignments.ps1 -Force

$out = New-AppRoleAssignments -object_id $object_id -app_role_display_names $graph_permissions
Write-Output "Role assignments: $out"