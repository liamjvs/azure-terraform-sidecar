param(
    [string]$azure_subscription_id
)

try {
    Write-Output "Checking if logged in to Azure"
    $az_login = az account show --query user -o tsv
    if(!$az_login){
        Write-Output "Not logged in to Azure."
        exit 1
    } else {
        Write-Output "You are logged in to Azure."
    }

    # Check if Terraform is installed
    Write-Output "Checking if Terraform is installed"
    $tf_version = terraform --version
    if(!$tf_version){
        Write-Output "Terraform is not installed."
        exit 1
    } else {
        Write-Output "Terraform is installed."
    }

    # get the current azure subscription name and id into json
    $azure_subscription = az account show --output json
    $azure_subscription = $azure_subscription | ConvertFrom-Json -Depth 2

    # prompt the user for their subscription id
    if(!$azure_subscription_id) {
        $azure_subscription_id = (Read-Host ("Enter the Azure Subscription ID (blank: {0})" -f $($azure_subscription).id))
        if($azure_subscription_id -eq "") {
            $azure_subscription_id = $azure_subscription.id
        } else {
            while($azure_subscription_id -notmatch "^[0-9a-f]{8}-([0-9a-f]{4}-){3}[0-9a-f]{12}$") {
                Write-Output "Subscription ID must be valid"
                $azure_subscription_id = Read-Host "Enter the Azure Subscription ID"
            }
        }
    }

    Write-Output "Changing to Terraform directory"
    cd terraform

    Write-Output "Disabling backend.tf"
    ../scripts/utils/modify_backend.ps1 -disable $true

    Read-Host "Press Enter to continue with terraform init or Ctrl+C to cancel..."
    Write-Output "Running terraform init"
    ../scripts/tf/init.ps1 -azure_subscription_id $azure_subscription_id
    if($LASTEXITCODE -ne 0){
        Write-Output "Terraform init failed"
        exit 1
    }

    Read-Host "Press Enter to continue with terraform plan or Ctrl+C to cancel..."
    Write-Output "Running terraform plan"
    ../scripts/tf/plan.ps1
    if($LASTEXITCODE -eq 1){
        Write-Output "Terraform plan failed"
        exit 1
    }

    Read-Host "Press Enter to continue with terraform apply or Ctrl+C to cancel..."
    Write-Output "Running terraform apply"
    ../scripts/tf/apply.ps1
    if($LASTEXITCODE -ne 0){
        Write-Output "Terraform apply failed"
        exit 1
    }

    Write-Output "Getting Terraform Outputs"
    ../scripts/tf/output.ps1 -cicd_ado $false

    Write-Output "Creating Terraform State File"
    ../scripts/utils/create_state_file.ps1 -cicd_ado $false

    Write-Output "Enabling backend.tf"
    ../scripts/utils/modify_backend.ps1 -enable $true

    Write-Output "Migrating Terraform State"
    ../scripts/tf/init.ps1 -azure_subscription_id $azure_subscription_id -terraform_migrate $true -terraform_backend_config "terraform.tfbackend"

    Read-Host "Press Enter to continue with terraform plan or Ctrl+C to cancel..."
    Write-Output "Running terraform plan"
    ../scripts/tf/plan.ps1 -terraform_vars "resource_group_name=rg-terraform-demo"
    if($LASTEXITCODE -eq 1){
        Write-Output "Terraform plan failed"
        exit 1
    }

    Read-Host "Press Enter to continue with terraform apply or Ctrl+C to cancel..."
    Write-Output "Running terraform apply"
    ../scripts/tf/apply.ps1
    if($LASTEXITCODE -ne 0){
        Write-Output "Terraform apply failed"
        exit 1
    }

} catch {
    Write-Output "An error occurred: $_"
    exit 1
}
finally {
    if(Test-Path "terraform"){
        # Test if backend.tf exists
        if(Test-Path "backend.tf"){
            Write-Output "Restoring backend.tf"
            ../scripts/utils/modify_backend.ps1 -enable $true
        }

        cd ..
    }
}