param(
    [string]$azure_subscription_id
)

Write-Host "Checking if logged in to Azure"
$az_login = az account show --query user -o tsv
if(!$az_login){
    Write-Host "Not logged in to Azure."
    exit 1
} else {
    Write-Host "You are logged in to Azure."
}

# Check if Terraform is installed
Write-Host "Checking if Terraform is installed"
$tf_version = terraform --version
if(!$tf_version){
    Write-Host "Terraform is not installed."
    exit 1
} else {
    Write-Host "Terraform is installed."
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
            Write-Host "Subscription ID must be valid"
            $azure_subscription_id = Read-Host "Enter the Azure Subscription ID"
        }
    }
}

cd .\terraform
Write-Host "Running Terraform init"
../scripts/tf/init.ps1 -azure_subscription_id $azure_subscription_id