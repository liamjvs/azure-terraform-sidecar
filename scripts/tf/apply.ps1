param(
    [string]$terraform_plan_file
)

$terraform_params = @()
$terraform_params += "-input=false" # Don't prompt for input
$terraform_params += "-auto-approve" # Don't prompt for approval

if($terraform_plan_file){
    $terraform_params += "`"$terraform_plan_file`""
}

Write-Verbose ("Running 'terraform apply {0}'" -f ($terraform_params -join ' ')) -Verbose
terraform apply @terraform_params

$terraform_exit_code = $LASTEXITCODE

if($terraform_exit_code -eq 0){
    Write-Verbose "Terraform apply succeeded" -Verbose
} else {
    Write-Verbose "Terraform apply returned an unknown exit code: $terraform_exit_code" -Verbose
}