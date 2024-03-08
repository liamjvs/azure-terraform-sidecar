param(
    [string]$object_id,
    [string]$app_id,
    [string]$graph_permission
)

Import-Module ./funcs/approle_assignments.ps1 -Force

if(!$object_id) {
    Write-Verbose "Object Id not provided. Getting object id from current context."
    if($app_id){
        $object_Id =  az ad sp show --id $app_id -o tsv --query "id"
    }
    Write-Output "Object Id: $object_id"
}

$role_exists = Get-AppRoleAssignment -object_id $object_id -app_role_display_name $graph_permission

if ($role_exists) {
    Write-Output "Role $graph_permission already assigned to $object_id"
} else {
    Write-Error "Role $graph_permission not assigned to $object_id"
}