function New-AgentPool {
    param (
        [Parameter(Mandatory=$true)][string]$pool_name,
        [Parameter(Mandatory=$true)][string]$ado_org,
        [Parameter(Mandatory=$true)][string]$ado_project_id,
        [Parameter(Mandatory=$true)][string]$ado_agent_pool_vmss_id,
        [Parameter(Mandatory=$true)][string]$service_endpoint_object_id,
        [bool]$authorizeAllPipelines = $false,
        [bool]$autoProvisionProjectPools = $false,
        [int]$maxCapacity = 10,
        [int]$timeToLiveMinutes = 15,
        [int]$desiredIdle = 0,
        [int]$maxSavedNodeCount = 0,
        [bool]$recycleAfterEachUse = $true,
        [bool]$agentInteractiveUI = $false
    )

    $agentPoolUri = "$ado_org/_apis/distributedtask/elasticpools?poolName={0}&authorizeAllPipelines={1}&autoProvisionProjectPools={2}&projectId={3}&api-version=7.0" -f $pool_name, $authorizeAllPipelines, $autoProvisionProjectPools, $ado_project_id
    Write-Verbose ("Trying to register VMSS: {0}" -f $agentPoolUri) -Verbose

    $payload = @{
        agentInteractiveUI = $agentInteractiveUI
        azureId = $ado_agent_pool_vmss_id
        desiredIdle = $desiredIdle
        maxCapacity = $maxCapacity
        maxSavedNodeCount = $maxSavedNodeCount
        osType = 1
        recycleAfterEachUse = $recycleAfterEachUse
        serviceEndpointId = $service_endpoint_object_id
        serviceEndpointScope = $ado_project_id
        timeToLiveMinutes = $timeToLiveMinutes
    }

    $payloadJson = $payload | ConvertTo-Json -Compress -Depth 10
    Write-Debug ("Payload: {0}" -f $payloadJson)

    $payloadJson | Out-File -FilePath "payload.json" -Encoding ascii -Force
    $out = az rest --uri $agentPoolUri --method post --resource '499b84ac-1321-427f-aa17-267ca6975798' --output json --body '@payload.json'
    Remove-Item -Path "payload.json" -Force
    return $out
}

function Get-AgentPools {
    param (
        [Parameter(Mandatory=$true)][string]$ado_org
    )

    $elastic_pools_uri = "$($ado_org)_apis/distributedtask/elasticpools?api-version=7.0"
    Write-Verbose ("Trying for agent pools: {0}" -f $elastic_pools_uri) -Verbose
    $elastic_pools = az rest --uri $elastic_pools_uri --method get --resource '499b84ac-1321-427f-aa17-267ca6975798' --output json
    Write-Verbose ("Elastic Pools: {0}" -f ($elastic_pools | ConvertFrom-Json -Depth 10 | ConvertTo-Json -Compress)) -Verbose
    $elastic_pools_object = $elastic_pools | ConvertFrom-Json -Depth 10

    return $elastic_pools_object
}

function Get-AgentPoolSecurity {
    param (
        [Parameter(Mandatory=$true)][string]$ado_org,
        [Parameter(Mandatory=$true)][string]$user_id,
        [Parameter(Mandatory=$true)][string]$project_id
    )

    $uri = "$($ado_org)_apis/securityroles/scopes/distributedtask.globalagentqueuerole/roleassignments/resources/$($project_id)?api-version=7.1-preview.1"
    Write-Verbose ("Trying for Agent Pool Security: {0}" -f $uri) -Verbose
    $out = az rest --uri $uri --method get --resource '499b84ac-1321-427f-aa17-267ca6975798' --output json
    $out = $out | ConvertFrom-Json -Depth 10 | Select-Object -ExpandProperty value | where-object { $_.identity.id -eq $user_id }
    return $out
}

function Set-AgentPoolSecurity {
    param (
        [Parameter(Mandatory=$true)][string]$ado_org,
        [Parameter(Mandatory=$true)][string]$user_id,
        [Parameter(Mandatory=$true)][string]$project_id,
        [Parameter(Mandatory=$true)][string]$role
    )

    $uri = "$ado_org/_apis/securityroles/scopes/distributedtask.globalagentqueuerole/roleassignments/resources/$($project_id)?api-version=7.1-preview.1"

    $payload = ,@(
        @{
            "roleName" = $role
            "userId" = $user_id
        }
    ) | ConvertTo-Json -Compress -Depth 10

    $payload | Out-File -FilePath "payload.json" -Encoding ascii -Force
    $out = az rest --uri $uri --method put --resource '499b84ac-1321-427f-aa17-267ca6975798' --output json --body '@payload.json'
    Remove-Item -Path "payload.json" -Force
    $out = $out | ConvertFrom-Json -Depth 10
    return $out
}