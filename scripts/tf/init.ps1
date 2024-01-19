param(
    [string]$azure_subscription_id,
    [string]$git_bearer_token,
    [string]$git_repo_uri,
    [string]$terraform_migrate = $false,
    [string]$terraform_backend_config,
    [bool]$terraform_backend = $true
)

if($git_bearer_token -and $git_repo_uri){
    Write-Verbose "Setting Git Bearer Token" -Verbose
    git config --global http.$($get_repo_uri).extraheader "AUTHORIZATION: bearer $($git_bearer_token)"
}

if($azure_subscription_id -and $azure_subscription_id -ne $env:ARM_SUBSCRIPTION_ID){
    Write-Verbose "Setting Azure Subscription ID to $azure_subscription_id in CLI and Terraform" -Verbose
    az account set --subscription $azure_subscription_id
    $env:ARM_SUBSCRIPTION_ID = $azure_subscription_id
}

$terraform_params = @()

# Terraform does not like input=false and -migrate-state together...
if($terraform_migrate){
    $terraform_params += "-migrate-state" # Migrate state from local to remote
    $terraform_params += "-force-copy" # Force copy of state from local to remote
} else {
    $terraform_params += "-input=false" # Don't prompt for input
}

if(!$terraform_backend){
    $terraform_params += "-backend=false" # Use a backend
} else {    
    # Backend Config; we can pass multiple -backend-config parameters or a single -backend-config parameter with a JSON file
    if(Test-Json $terraform_backend_config -ErrorAction SilentlyContinue){
        $backend_object = ConvertFrom-Json $terraform_backend_config -Depth 100
    } else {
        $backend_object = $terraform_backend_config
    }

    if($backend_object){
        $backend_object_split = $backend_object.Split(" ")
        foreach($item in $backend_object_split)
        {
            Write-Verbose ('Adding "-backend-config={0}"' -f $item) -Verbose
            $terraform_params += ('-backend-config="{0}"' -f $item)
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