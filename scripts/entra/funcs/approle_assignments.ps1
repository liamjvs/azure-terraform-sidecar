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