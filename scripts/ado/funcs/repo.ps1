function Get-Repositories {
    param (
        [Parameter(Mandatory=$true)][string]$ado_org,
        [Parameter(Mandatory=$true)][string]$project_id
    )

    $uri = "$($ado_org)/$($project_id)/_apis/git/repositories?api-version=7.1-preview.1"
    $out = az rest --uri $uri --method GET --resource "499b84ac-1321-427f-aa17-267ca6975798" --output json
    $out = ($out | ConvertFrom-Json -Depth 10).value
    return $out
}

function Get-Repository {
    param (
        [Parameter(Mandatory=$true)][string]$ado_org,
        [Parameter(Mandatory=$true)][string]$project_id,
        [Parameter(Mandatory=$true)][string]$repo_name
    )

    $out = Get-Repositories -ado_org $ado_org -project_id $project_id | Where-Object { $_.name -eq $repo_name }
    if (!$out) {
        Write-Error "Could not find the repository. This is unexpected."
    }
    return $out
}

function Get-BuildServiceSecurityID{
    param (
        [Parameter(Mandatory=$true)][string]$ado_org,
        [Parameter(Mandatory=$true)][string]$project_id
    )

    $uri = "$($ado_org)/_apis/accesscontrollists/2e9eb7ed-3c0a-47d4-87c1-0ffdd275fd87"
    $query = @{
        "api-version" = "7.1-preview.1"
        token = "repoV2/$($project_id)"
    } | ConvertTo-Json -Compress | Out-File "query.json" -Force
    $out = az rest --url $uri --method GET --resource "499b84ac-1321-427f-aa17-267ca6975798" --output json --uri-parameters "@query.json"
    Remove-Item -Path "query.json" -Force
    # force conver tot hashtable
    $out = ($out | ConvertFrom-Json -Depth 10).value.acesDictionary.pSobject.Properties.Name | Where {$_ -like "Microsoft.TeamFoundation.ServiceIdentity*"}
    if (!$out) {
        Write-Error "Could not find the build service account. This is unexpected."
    }
    return $out
}

function Set-RepositorySecurity {
    param (
        [Parameter(Mandatory=$true)][string]$ado_org,
        [Parameter(Mandatory=$true)][string]$descriptor,
        [Parameter(Mandatory=$true)][string]$project_id,
        [Parameter(Mandatory=$true)][string]$repo_id,
        [Parameter(Mandatory=$true)][string]$role,
        [Parameter(Mandatory=$true)][bool]$allow
    )

    $bitmap = @{
        "Administer" = 1
        "GenericRead" = 2
        "GenericContribute" = 4
        "ForcePush" = 8
        "CreateBranch" = 16
        "CreateTag" = 32
        "ManageNote" = 64
        "PolicyExempt" = 128
        "CreateRepository" = 256
        "DeleteRepository" = 512
        "RenameRepository" = 1024
        "EditPolicies" = 2048
        "RemoveOthersLocks" = 4096
        "ManagePermissions" = 8192
        "PullRequestContribute" = 16384
        "PullRequestBypassPolicy" = 32768
        "ViewAdvSecAlerts" = 65536
        "DismissAdvSecAlerts" = 131072
        "ManageAdvSecScanning" = 262144
    }

    if($allow){
        $allowBit = $bitmap[$role]
        $denyBit = 0
    } else {
        $allowBit = 0
        $denyBit = $bitmap[$role]
    }

    $uri = "$($ado_org)/_apis/AccessControlEntries/2e9eb7ed-3c0a-47d4-87c1-0ffdd275fd87?api-version=7.1-preview.1"
    Write-Verbose "Setting Repository Security: $uri"

    $payload = @{
            "token" = "repoV2/$($project_id)/$($repo_id)/"
            merge = $true
            accessControlEntries = @(
                @{
                    "descriptor" = $descriptor
                    "allow" = $allowBit
                    "deny" = $denyBit
                }
            )
     } | ConvertTo-Json -Compress -Depth 10

     Write-Verbose ("Payload for Repository Security: {0}" -f ($payload -replace $service_principal_secret, "*"))

    $payload | Out-File -FilePath "payload.json" -Encoding ascii -Force

    $out = az rest --uri $uri --method POST --resource "499b84ac-1321-427f-aa17-267ca6975798" --output json --body "@payload.json"
    # Remove-Item -Path "payload.json" -Force
    $out = $out | ConvertFrom-Json -Depth 10
    return $out
}