param(
    [string]$tenant_id,
    [string]$object_id,
    [string[]]$graph_permissions
)

Import-Module ./funcs/approle_assignments.ps1 -Force

# Check if logged in to Azure
if (!$tenant_id) {
    Write-Verbose "Tenant ID not provided, fetching from Azure account"
    $tenant_id = az account show --query "tenantId" -o tsv
}
Write-Verbose "Tenant ID: $tenant_id"

$existing_roles = Get-AppRoleAssignments -object_id $object_id

$uri = "https://graph.microsoft.com/v1.0/servicePrincipals/$object_id/appRoleAssignedTo"
Write-Verbose "Assigning roles to $object_id"
Write-Verbose "URI: $uri"

$graph_app_id = "00000003-0000-0000-c000-000000000000"
$graph_id = az ad sp show --id $graph_app_id --query "{id: id, appRoles: appRoles[?allowedMemberTypes[0]=='Application'].{value: value, id: id}}" -o json | ConvertFrom-Json -Depth 10

$filtered_roles = $graph_id.appRoles | Where-Object { $_.value -in $graph_permissions }

foreach($role in $filtered_roles) {
    if($existing_roles | Where-Object { $_.appRoleId -eq $role.id })
    {
        Write-Warning "Role $($role.value) already assigned to $object_id"
    } else {
        $role_assignment = @{
            "principalId" = $object_id
            "resourceId" = $graph_id.id
            "appRoleId" = $role.id
        } | ConvertTo-Json -Depth 10 -Compress | Out-File -FilePath "payload.json" -Force
        Write-Verbose "Payload: $role_assignment"
        try {
            Write-Verbose "Assigning role $($role.value) to $object_id"
            $out = az rest --method POST --uri $uri --body "@payload.json" --output json --resource $graph_app_id
            Write-Verbose "Role $($role.value) assigned to $object_id"
        } catch {
            Write-Warning $_.Exception.Message
        } finally {
            Remove-Item -Path "payload.json" -Force
        }
    }
}