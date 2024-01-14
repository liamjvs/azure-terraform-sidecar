param(
    [string]$azure_subscription_id,
    [string]$git_bearer_token,
    [string]$git_repo_uri,
    [string]$terraform_migrate = $false,
    [string]$terraform_backend_config
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
    $terraform_params += '-migrate-state' # Migrate state from local to remote
    $terraform_params += '-force-copy' # Force copy of state from local to remote
} else {
    $terraform_params += '-input=false' # Don't prompt for input
}

# Backend Config; we can pass multiple -backend-config parameters or a single -backend-config parameter with a JSON file
$backend_object = ConvertFrom-Json $backendConfigs -Depth 100
if($backend_object){
  # On the conversion, switch on what type of object we have; it can be a single line to point to a backend config file or a series of strings
  switch ($backend_object.GetType().FullName) {
      'System.String' {
          # Force string; was erroring without this
          Write-Verbose ('Adding "-backend-config={0}"' -f ("{0}" -f $backend_object)) -Verbose
          $terraform_params += ('-backend-config={0}' -f $backend_object)
      }
      'System.Management.Automation.PSCustomObject' {
          foreach($item in $backend_object.PSObject.Properties.Name)
          {
              $line_item = "{0}={1}" -f $item, $backend_object.$item 
              Write-Verbose ('Adding "-backend-config={0}"' -f $line_item) -Verbose
              $inputObject += ('-backend-config={0}' -f $line_item)
          }
      }
      Default {
          Write-Error 'Unknown type'
      }
  }
} else {
  Write-Verbose "terraform_backend_config is null" -Verbose
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