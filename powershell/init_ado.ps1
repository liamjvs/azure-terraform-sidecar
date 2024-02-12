# Description: This script initializes the ADO environment

param(
    [string]$ado_organization = "https://dev.azure.com/lismithmcaps",
    [string]$ado_project = "Code",
    [string]$service_connection_name,
    [string]$subscription_id = "3f96fd38-eec2-48f5-8d76-c9b6c17c8c95",
    [string]$service_principal_id
)

try {
    Import-Module ../scripts/ado/funcs/service_connection.ps1 -Force
    Import-Module ../scripts/ado/funcs/project.ps1 -Force
}
catch {
    Write-Error "Failed to import the required modules. Please make sure the modules are present in the correct location."
    exit
}

# check if the az cli is installed
if(!(Get-Command az -ErrorAction SilentlyContinue)) {
    Write-Host "Azure CLI is not installed. Please install Azure CLI and try again."
    exit
}

# check if the user is logged in
$az_account = az account show --output json
if(!$az_account) {
    Write-Host "Please login to Azure CLI and try again."
    exit
}

# prompt the user for the ado organization
if (!$ado_organization) {
    $ado_organization = Read-Host "Enter the ADO organization"
    # check if the ado organization starts with https://
    if ($ado_organization -notlike "https://*") {
        # prompt the user has entered the organization name only
        while($answer -ne "y" -and $answer -ne "n") {
            $answer = Read-Host "Do you want to append 'https://dev.azure.com' to the organization name? (y/n)"
            if($answer -ne "y" -and $answer -ne "n") {
                Write-Host "Invalid input. Please enter 'y' or 'n'"
            } else {
                if($answer -eq "y") {
                    $ado_organization = "https://dev.azure.com/$ado_organization"
                }
            }
        }
    }
}

# prompt the user for their ado project
if(!$ado_project) {
    $ado_project = Read-Host "Enter the ADO project"
    while(!$ado_project) {
        Write-Host "ADO project must be valid"
        $ado_project = Read-Host "Enter the ADO project"
    }
}

$ado_projectObject = Get-ProjectObject -ado_org $ado_organization -ado_project $ado_project
if(!$ado_projectObject) {
    Write-Error "ADO project not found. Please check the ADO organization and project name."
    exit
}
$ado_project_id = $ado_projectObject.id

# prompt the user for their subscription id
if(!$subscription_id) {
    $subscription_id = Read-Host "Enter the Azure Subscription ID"
    #subscription should be a valid azure subscription id
    while($subscription_id -notmatch "^[0-9a-f]{8}-([0-9a-f]{4}-){3}[0-9a-f]{12}$") {
        Write-Host "Subscription id must be valid"
        $subscription_id = Read-Host "Enter the Azure Subscription ID"
    }
}

# prompt the user if the az name for the subscription name is ok
$subscription_name = az account show --query "name" -o tsv
$answer = Read-Host "Is the subscription name '$subscription_name' ok? (y/n)."
if($answer -ne "y") {
    $subscription_name = Read-Host "Enter the Azure Subscription Name"
}

# prompt the user for their service principal id
if(!$service_principal_id) {
    $service_principal_id = Read-Host "Enter the service principal application id (blank: script will create a new service principal)"
    if(!$service_principal_id) {
        $service_principal_id = "to_be_created"
    } else {
        #service principal id should be a valid guid
        while($service_principal_id -notmatch "^[0-9a-f]{8}-([0-9a-f]{4}-){3}[0-9a-f]{12}$") {
            Write-Host "Service Principal ID must be valid"
            $service_principal_id = Read-Host "Enter the service principal application id (default: script will create a new service principal)"
        }
    }
}

# prompt the user for their service connection name
if(!$service_connection_name) {
    $service_connection_name = Read-Host "Enter the service connection name (blank: sidecar-service-connection)"
    if(!$service_connection_name) {
        $service_connection_name = "sidecar-service-connection"
    }
}

# check service connection name is unique
$service_connections = Get-ServiceConnections -ado_org $ado_organization -ado_project $ado_project
if($service_connections) {
    $service_connection_names = $service_connections.value.name
    if($service_connection_names -contains $service_connection_name) {
        Write-Error "Service Connection name already exists. Please enter a unique name."
        exit
    }
}

# Write new line
Write-Host ""

# Confirm with the user the values entered
Write-Host "ADO Organization: $ado_organization"
Write-Host "ADO Project: $ado_project"
Write-Host "Subscription ID: $subscription_id"
Write-Host "Subscription Name: $subscription_name"
Write-Host "Service Principal ID: $service_principal_id"
Write-Host "Service Connection Name: $service_connection_name"
$confirm = Read-Host "Do you want to continue? (y/n)"
if($confirm -ne "y") {
    Write-Host "Exiting..."
    exit
}

# Create Service Principal and Service Connection
Write-Host "Creating Service Principal"
$service_principal = az ad sp create-for-rbac --name $service_connection_name --role Owner --scopes "/subscriptions/$subscription_id" --only-show-errors --output json
$service_principal = $service_principal | ConvertFrom-Json -Depth 10
if(!$service_principal) {
    Write-Error "Service Principal creation failed. Do you have the required permissions to create a service principal?"
}

# Create Service Connection
Write-Host "Creating Service Connection"
$service_connection = New-ServiceConnection -ado_org $ado_organization -ado_project $ado_project -ado_project_id $ado_project_id -subscription_id $subscription_id -subscription_name $subscription_name -service_principal_id $($service_principal).appId -service_principal_secret $($service_principal).password -tenant_id $($service_principal).tenant -ado_service_connection_name $service_connection_name
if(!$service_connection) {
    Write-Error "Service Connection creation failed. Do you have the required permissions to create a service connection?"
} else {
    Write-Host "Service Connection created successfully"
}

# Write new line
Write-Host ""

# Write in green
Write-Host "ADO Environment initialized successfully" -ForegroundColor Green

# Write new line
Write-Host ""
Write-Host "Please create a pipeline and use the service connection '$service_connection_name' to deploy the application to ADO."
Write-Host "The pipeline will also need the subscription id '$subscription_id' added."

# Clean up the environment
Write-Verbose "Cleaning up the environment"
$variables = @("answer", "ado_organization")
foreach ($variable in $variables) {
    Write-Verbose "Removing variable: $variable"
    Remove-Variable -Name $variable -ErrorAction SilentlyContinue
}
