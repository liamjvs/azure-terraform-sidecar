Write-Host "Checking if logged in to Azure"
$az_login = az account show --query user -o tsv
if(!$az_login){
    Write-Host "Not logged in to Azure."
    exit 1
} else {
    Write-Host "Already logged in to Azure"
}