param(
    [bool]$managed_identity = $false,
    [bool]$cicd_ado = $false,
    [string]$subscription_id
)

if($managed_identity) {
    Write-Verbose "Using Managed Identity" -Verbose
    az login --identity

    $env:ARM_USE_MSI = "true"
    if($cicd_ado) {
        Write-Output "##vso[task.setvariable variable=ARM_USE_MSI; isOutput=true;]true"
    }
} elseif ($env:ARM_CLIENT_ID -and $env:ARM_CLIENT_SECRET -and $env:ARM_TENANT_ID) {
    # The AzureCLI task performs a `az account clear` at the end. We want a persistent login across tasks.
    Write-Verbose "Using Service Principal" -Verbose
    az login --service-principal --username $env:ARM_CLIENT_ID --password $env:ARM_CLIENT_SECRET --tenant $env:ARM_TENANT_ID
} else {
    Write-Error "Login failed; no credentials in environment variables"
}

if($subscription_id) {
    Write-Verbose "Setting ARM_SUBSCRIPTION_ID to $subscription_id" -Verbose
    $env:ARM_SUBSCRIPTION_ID = $subscription_id
    if($cicd_ado) {
        Write-Output "##vso[task.setvariable variable=ARM_SUBSCRIPTION_ID; isOutput=true;]$subscription_id"
    }
}

$env:ARM_TENANT_ID = (az account show --query tenantId -o tsv)
if($cicd_ado) {
    Write-Output "##vso[task.setvariable variable=ARM_TENANT_ID; isOutput=true;]$env:ARM_TENANT_ID"
}