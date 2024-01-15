param(
    [bool]$managed_identity = $false
)

if($managed_identity) {
    Write-Verbose "Using Managed Identity" -Verbose
    az login --identity
    $env:ARM_TENANT_ID = (az account show --query tenantId -o tsv)
    $env:ARM_USE_MSI = "true"
}