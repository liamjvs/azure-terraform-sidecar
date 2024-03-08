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

function Get-ServicePrincipalObject {
    param (
        [Parameter(Mandatory=$true)][string]$ado_org,
        [Parameter(Mandatory=$true)][string]$service_principal_id
    )

    $ado_org = $ado_org -replace "https://dev.", "https://vsaex.dev."
    $member_entitlements_uri = "$($ado_org)/_apis/MemberEntitlements"

    $select_query = @{expression = {$_.id}; label = "id"},
    @{expression = {$_.member.applicationId}; label = "applicationId"},
    @{expression = {$_.member.displayName}; label = "displayName"}

    $query = @{
        "api-version" = "7.1-preview.2"
        "`$orderby" = "name Ascending"
        "`$filter" = "userType eq 'application'"
    }

    $query | ConvertTo-Json -Compress | Out-File "query.json" -Force
    $member_entitlement = az rest --uri $member_entitlements_uri --method get --resource "499b84ac-1321-427f-aa17-267ca6975798" --output json --uri-parameters "@query.json"
    $output = $member_entitlement | ConvertFrom-Json -Depth 10
    $member_entitlement_object = $output.items | Select-Object -Property $select_query
    $continuation_token = $output.continuationToken
    while($continuation_token){
        $query_with_token = $query + @{continuationToken = $continuation_token} | ConvertTo-Json -Compress | Out-File "query.json" -Force
        $output = az rest --uri $query_with_token --method get --resource "499b84ac-1321-427f-aa17-267ca6975798" --output json --uri-parameters "@query.json"
        $output = $output | ConvertFrom-Json -Depth 10
        $member_entitlement_object += $output.items | Select-Object -Property $select_query
        $continuation_token = $output.continuationToken
    }
    Remove-Item -Path "query.json" -Force
    $service_principal = $member_entitlement_object | Where-Object { $_.applicationId -eq $service_principal_id }
    return $service_principal
}

function New-ServicePrincipalEntitlement {
    param (
        [Parameter(Mandatory=$true)][string]$ado_org,
        [Parameter(Mandatory=$true)][string]$service_principal_object_id,
        [Parameter(Mandatory=$true)][string]$project_id
    )

    $ado_org = $ado_org -replace "https://dev.", "https://vsaex.dev."
    $uri = "$($ado_org)/_apis/serviceprincipalentitlements?api-version=7.1-preview.1"

    $payload = @{
        "accessLevel" = @{
            "accountLicenseType" = 2
            "assignmentSource" = 1
            "licensingSource" = 1
            "licenseDisplayName" = "Basic"
            "msdnLicenseType" = 0
        }
        "projectEntitlements" = @(
            @{
                "group" = @{
                    "groupType"= "projectReader"
                }
                "projectRef" = @{
                    "id"= $project_id
                }
            }
        )
        "servicePrincipal" = @{
            "origin" = "aad"
            "originId" = $service_principal_object_id
            "subjectKind" = "servicePrincipal"
        }
    } | ConvertTo-Json -Depth 10 -Compress

    $payload | Out-File -FilePath "payload.json" -Encoding ascii -Force
    $request = az rest --uri $uri --method post --resource "499b84ac-1321-427f-aa17-267ca6975798" --output json --body "@payload.json"
    Remove-Item -Path "payload.json" -Force
    $request = $request | ConvertFrom-Json -Depth 10
    return $request.servicePrincipalEntitlement
}