param(
    [bool]$managed_identity = $false
)

if($managed_identity) {
    Write-Verbose "Using Managed Identity" -Verbose
    az login --identity
    $env:ARM_TENANT_ID = (az account show --query tenantId -o tsv)
    $env:ARM_USE_MSI = "true"
} else {
    # The AzureCLI task performs a `az account clear` at the end. We want a persistent login across tasks.
    Write-Verbose "Using Service Principal" -Verbose
    az login --service-principal --username $env:ARM_CLIENT_ID --password $env:ARM_CLIENT_SECRET --tenant $env:ARM_TENANT_ID
}