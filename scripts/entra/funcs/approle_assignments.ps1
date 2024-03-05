function Get-AppRoleAssignments {
    param (
        [Parameter(Mandatory=$true)][string]$object_id
    )

    Write-Verbose "Getting current app role assignments for $object_id"
    $uri = "https://graph.microsoft.com/v1.0/servicePrincipals/$object_id/appRoleAssignments"
    Write-Verbose "URI: $uri"
    $out = az rest --uri $uri --method GET --resource "https://graph.microsoft.com" --output json
    $out = ($out | ConvertFrom-Json -Depth 10).value
    return $out
}

function Get-AppRoles {
    $query = "{id: id, appRoles: appRoles[?allowedMemberTypes[0]=='Application'].{value: value, id: id}}"
    $graph_app_id = "00000003-0000-0000-c000-000000000000"
    $graph_id = az ad sp show --id $graph_app_id --query $query -o json | ConvertFrom-Json -Depth 10
    return $graph_id.appRoles
}

function Get-AppRoleAssignment {
    param (
        [Parameter(Mandatory=$true)][string]$object_id,
        [Parameter(Mandatory=$true)][string]$app_role_display_name
    )

    $graph_app_roles = Get-AppRoles
    $object_app_roles = Get-AppRoleAssignments -object_id $object_id
    $app_role = $graph_app_roles | Where-Object { $_.value -eq $app_role_display_name }
    return $app_role
}