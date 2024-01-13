param(
    [bool]$managed_identity = $false,
    [string]$azure_subscription_id,
    [string]$git_bearer_token,
    [string]$git_repo_uri,
    [string]$terraform_migrate = $false
)

if($managed_identity) {
    Write-Verbose "Using Managed Identity" -Verbose
    az login --identity
    $env:ARM_TENANT_ID = (az account show --query tenantId -o tsv)
    $env:ARM_USE_MSI = "true"
} else {
    Write-Verbose "Using Service Principal" -Verbose
    az login --service-principal --username $env:ARM_CLIENT_ID --password $env:ARM_CLIENT_SECRET --tenant $env:ARM_TENANT_ID --allow-no-subscriptions --only-show-errors
    $env:ARM_USE_MSI = "false"
}

if($git_bearer_token -and $git_repo_uri){
    Write-Verbose "Setting Git Bearer Token" -Verbose
    git config --global http.$($get_repo_uri).extraheader "AUTHORIZATION: bearer $($git_bearer_token)"
}

if($azure_subscription_id -or $env:ARM_SUBSCRIPTION_ID){
    Write-Verbose "Setting Azure Subscription ID to $azure_subscription_id in CLI and Terraform" -Verbose
    az account set --subscription $azure_subscription_id
    $env:ARM_SUBSCRIPTION_ID = $azure_subscription_id
}

$terraform_params = @{}

# Terraform does not like input=false and -migrate-state together...
if($terraform_migrate){
    $terraform_params += '-migrate-state' # Migrate state from local to remote
    $terraform_params += '-force-copy' # Force copy of state from local to remote
} else {
    $terraform_params += '-input=false' # Don't prompt for input
}

# Backend Config; we can pass multiple -backend-config parameters or a single -backend-config parameter with a JSON file


