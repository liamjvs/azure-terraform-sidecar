function New-ServiceConnection {
    param (
        [Parameter(Mandatory=$true)][string]$ado_org,
        [Parameter(Mandatory=$true)][string]$ado_project,
        [Parameter(Mandatory=$true)][string]$ado_project_id,
        [Parameter(Mandatory=$true)][string]$ado_service_connection_name,
        [Parameter(Mandatory=$true)][string]$subscription_name,
        [Parameter(Mandatory=$true)][string]$subscription_id,
        [Parameter(Mandatory=$true)][string]$service_principal_id,
        [Parameter(Mandatory=$true)][string]$service_principal_secret,
        [Parameter(Mandatory=$true)][string]$tenant_id
    )

    $payload = @{
        data = @{
            subscriptionId = $subscription_id
            subscriptionName = $subscription_name
            environment = "AzureCloud"
            scopeLevel = "Subscription"
            creationMode = "Manual"
        }
        name = $ado_service_connection_name
        type = "AzureRM"
        url = "https://management.azure.com/"
        authorization = @{
            parameters = @{
                tenantid = $tenant_id
                serviceprincipalid = $service_principal_id
                authenticationType = "spnKey"
                serviceprincipalkey = $service_principal_secret
            }
            scheme = "ServicePrincipal"
        }
        isShared = $false
        isReady = $true
        serviceEndpointProjectReferences = @(
            @{
                projectReference = @{
                    id = $ado_project_id
                    name = $ado_project
                }
                name = $ado_service_connection_name
            }
        )
    } | ConvertTo-Json -Compress -Depth 10

    $payload | Out-File -FilePath "payload.json" -Encoding ascii -Force
    Write-Verbose ("Payload for Service Endpoint: {0}" -f ($payload -replace $service_principal_secret, "*"))

    $service_connection_uri = "$($ado_org)/_apis/serviceendpoint/endpoints?api-version=7.1-preview.4"
    Write-Verbose ("Trying to create service endpoint: {0}" -f $service_connection_uri)

    $service_endpoints_response = az rest --uri $service_connection_uri --method post --resource "499b84ac-1321-427f-aa17-267ca6975798" --output json --body "@payload.json"
    Remove-Item -Path "payload.json" -Force
    $service_endpoints_object = ($service_endpoints_response | ConvertFrom-Json -Depth 10)
    return $service_endpoints_object
}

function Get-ServiceConnections {
    param (
        [Parameter(Mandatory=$true)][string]$ado_org,
        [Parameter(Mandatory=$true)][string]$ado_project
    )

    $service_connections_uri = "$($ado_org)/$($ado_project)/_apis/serviceendpoint/endpoints?api-version=7.1-preview.4"
    Write-Verbose "Trying for service connections: $service_connections_uri"
    $service_endpoints = az rest --uri $service_connections_uri --method get --resource '499b84ac-1321-427f-aa17-267ca6975798' --output json
    $service_endpoints_search = ($service_endpoints | ConvertFrom-Json -Depth 10).value

    return $service_endpoints_search
}

function Set-ServiceConnectionSecurity {
    param (
        [Parameter(Mandatory=$true)][string]$ado_org,
        [Parameter(Mandatory=$true)][string]$user_id,
        [Parameter(Mandatory=$true)][string]$project_id,
        [Parameter(Mandatory=$true)][string]$role
    )

    $uri = "$($ado_org)/_apis/securityroles/scopes/distributedtask.project.serviceendpointrole/roleassignments/resources/$($project_id)?api-version=7.1-preview.1"

    $payload = ,@(
        @{
            "roleName" = $role
            "userId" = $user_id
        }
    ) | ConvertTo-Json -Compress -Depth 10

    $payload | Out-File -FilePath "payload.json" -Encoding ascii -Force

    $out = az rest --uri $uri --method put --resource "499b84ac-1321-427f-aa17-267ca6975798" --output json --body "@payload.json"
    Remove-Item -Path "payload.json" -Force
    $out = ($out | ConvertFrom-Json -Depth 10).value
    return $out
}

function Update-ServiceConnectionSecret {
    param (
        [Parameter(Mandatory=$true)][string]$ado_org,
        [Parameter(Mandatory=$true)][string]$user_id,
        [Parameter(Mandatory=$true)][string]$project,
        [Parameter(Mandatory=$true)][string]$service_principal_secret
    )

    $uri = "$($ado_org)/_apis/serviceendpoint/endpoints/$($user_id)?api-version=7.1-preview.4"

    $service_connections = Get-ServiceConnections -ado_org $ado_org -ado_project $project

    $service_connection = $service_connections | where-object { $_.id -eq $user_id }

    if($service_connection -eq $null){
        Write-Error "Service Connection Not Found"
    } else {
        Add-Member -InputObject $service_connection.authorization.parameters -Name serviceprincipalkey -Value $service_principal_secret -MemberType NoteProperty
        $service_connection.authorization.parameters.serviceprincipalkey = $service_principal_secret
        $service_connection | ConvertTo-Json -Compress -Depth 10 | Out-File -FilePath "payload.json" -Encoding ascii -Force
        $out = az rest --uri $uri --method put --resource "499b84ac-1321-427f-aa17-267ca6975798" --output json --body "@payload.json"
        Remove-Item -Path "payload.json" -Force
        return ($out | ConvertFrom-Json -Depth 10).value
    }
}