function Get-ProjectObject {
    param (
        [Parameter(Mandatory=$true)][string]$ado_org,
        [Parameter(Mandatory=$true)][string]$ado_project
    )

    $projects_uri = "$($ado_org)/_apis/projects?api-version=7.1-preview.4"
    Write-Verbose "Trying for projects: $projects_uri"
    $ado_projects = az rest --uri $projects_uri --method get --resource '499b84ac-1321-427f-aa17-267ca6975798' --output json
    Write-Verbose ("Projects: {0}" -f ($ado_projects | ConvertFrom-Json -Depth 10 | ConvertTo-Json -Compress))
    $ado_projectsObject = $ado_projects | ConvertFrom-Json -Depth 10
    $ado_projectTargetObject = $ado_projectsObject.value | where-object { $_.name -eq $ado_project }

    return $ado_projectTargetObject
}