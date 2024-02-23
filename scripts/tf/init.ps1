param(
    [string]$azure_subscription_id,
    [string]$git_bearer_token,
    [string]$git_repo_uri,
    [string]$terraform_migrate = $false,
    [string]$terraform_backend_config,
    [bool]$terraform_backend = $true,
    [bool]$az_bearer_token = $false
)

# write-verbose all environment variables
Get-ChildItem env: | ForEach-Object { Write-Verbose ("{0} = {1}" -f $_.Name, $_.Value) -Verbose }

if($git_bearer_token -and $git_repo_uri){
    Write-Verbose "Setting Git Bearer Token" -Verbose
    if($az_bearer_token -eq $true){
        $bearer = az account get-access-token --resource "499b84ac-1321-427f-aa17-267ca6975798" --query accessToken -o tsv
    } else {
        $bearer = $git_bearer_token
    }
    git config --global http.$($get_repo_uri).extraheader "AUTHORIZATION: bearer $($bearer)"
}

if($azure_subscription_id -and $azure_subscription_id -ne $env:ARM_SUBSCRIPTION_ID){
    Write-Verbose "Setting Azure Subscription ID to $azure_subscription_id in CLI and Terraform" -Verbose
    az account set --subscription $azure_subscription_id
    $env:ARM_SUBSCRIPTION_ID = $azure_subscription_id
}

Write-Verbose "ARM_USE_MSI = $env:ARM_USE_MSI" -Verbose
Write-Verbose "ARM_SUBSCRIPTION_ID = $env:ARM_SUBSCRIPTION_ID" -Verbose
Write-Verbose "ARM_TENANT_ID = $env:ARM_TENANT_ID" -Verbose
Write-Verbose "ARM_CLIENT_ID = $env:ARM_CLIENT_ID" -Verbose
Write-Verbose "ARM_CLIENT_SECRET = $env:ARM_CLIENT_SECRET" -Verbose

$terraform_params = @()

# Terraform does not like input=false and -migrate-state together...
if($terraform_migrate -eq $true){
    $terraform_params += "-migrate-state" # Migrate state from local to remote
    $terraform_params += "-force-copy" # Force copy of state from local to remote
} else {
    $terraform_params += "-input=false" # Don't prompt for input
}

if(!$terraform_backend){
    $terraform_params += "-backend=false" # Use a backend
} else {    
    if($terraform_backend_config){
        $backend_object_split = $terraform_backend_config.Split(" ")
        foreach($item in $backend_object_split)
        {
            Write-Verbose ('Adding "-backend-config={0}"' -f $item) -Verbose
            $terraform_params += ('-backend-config={0}' -f $item)
        }
    } else {
        Write-Verbose "terraform_backend_config is null" -Verbose
    }
}

Write-Verbose ("Running 'terraform init {0}'" -f ($terraform_params -join ' ')) -Verbose
terraform init @terraform_params

$terraform_exit_code = $LASTEXITCODE

if($git_bearer_token -and $git_repo_uri){
    Write-Verbose "Unsetting Git Bearer Token" -Verbose
    git config --global --unset http.$($get_repo_uri).extraheader
}

if($terraform_exit_code -ne 0){
    Write-Error "Terraform init failed with exit code $terraform_exit_code"
    exit $terraform_exit_code
}