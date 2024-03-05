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

function New-AppRoleAssignments {
    param (
        [Parameter(Mandatory=$true)][string]$object_id,
        [Parameter(Mandatory=$true)][string[]]$app_role_display_names
    )

    $output = @()
    $graph_app_roles = Get-AppRoles
    $object_app_roles = Get-AppRoleAssignments -object_id $object_id
    $app_role = $graph_app_roles | Where-Object { $_.value -in $app_role_display_names }
    foreach($role in $app_role) {
        if($object_app_roles | Where-Object { $_.appRoleId -eq $role.id })
        {
            Write-Warning "Role $($role.value) already assigned to $object_id"
        } else {
            $output += New-AppRoleAssignment -object_id $object_id -resourceId $graph_id.id -appRoleId $role.id
        }
    }
    return $output
}

function New-AppRoleAssignment {
    param (
        [Parameter(Mandatory=$true)][string]$object_id,
        [Parameter(Mandatory=$true)][string]$resourceId,
        [Parameter(Mandatory=$true)][string]$appRoleId
    )

    $app_role_assignment = @{
        "principalId" = $object_id
        "resourceId" = $resourceId
        "appRoleId" = $appRoleId
    } | ConvertTo-Json -Depth 10 -Compress | Out-File -FilePath "payload.json" -Force
    Write-Verbose "Payload: $app_role_assignment"
    $uri = "https://graph.microsoft.com/v1.0/servicePrincipals/$object_id/appRoleAssignedTo"
    Write-Verbose "URI: $uri"
    $out = az rest --method POST --uri $uri --body "@payload.json" --output json --resource $graph_app_id
    Write-Verbose "Role $($app_role.value) assigned to $object_id"
    Remove-Item -Path "payload.json" -Force
}