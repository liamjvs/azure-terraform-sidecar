param(
    [string]$terraform_refresh_plan = $false,
    [string]$terraform_vars, # JSON string NEED TO ADD SUPPORT
    [string]$terraform_var_file,
    [string]$terraform_publish_plan = $true,
    [string]$terraform_plan_file = 'terraform.plan'
)

$terraform_params = @()
$terraform_params += '-input=false' # Don't prompt for input

if($terraform_publish_plan){
    $terraform_params += "-out=$terraform_plan_file"
}

if($terraform_refresh_plan){
    $terraform_params += '-refresh=true'
}

if($terraform_var_file){
    $terraform_params += "-var-file=$terraform_var_file"
}

if($terraform_vars){
    $terraform_params += "-var=$terraform_vars"
}

$terraform_params += "-detailed-exitcode"

Write-Verbose ("Running 'terraform plan {0}'" -f ($terraform_params -join ' ')) -Verbose
terraform plan @terraform_params

$terraform_exit_code = $LASTEXITCODE

if($terraform_exit_code -eq 0){
    Write-Verbose "Terraform plan succeeded with no changes required" -Verbose
} elseif($terraform_exit_code -eq 1){
    Write-Verbose "Terraform plan failed" -Verbose
} elseif($terraform_exit_code -eq 2){
    Write-Verbose "Terraform plan succeeded with changes required" -Verbose
} else {
    Write-Verbose "Terraform plan returned an unknown exit code: $terraform_exit_code" -Verbose
}