# Description: This script initializes the ADO environment

param(
    [string]$ado_organization = "https://dev.azure.com/lismithmcaps",
    [string]$ado_project = "Code",
    [string]$repo_name = "azure-terraform-sidecar",
    [string]$service_connection_name,
    [string]$azure_subscription_id = "3f96fd38-eec2-48f5-8d76-c9b6c17c8c95",
    [string]$service_principal_id
)

try {
    Import-Module ./scripts/ado/funcs/agent_pool.ps1 -Force
    Import-Module ./scripts/ado/funcs/service_connection.ps1 -Force
    Import-Module ./scripts/ado/funcs/project.ps1 -Force
    Import-Module ./scripts/ado/funcs/repo.ps1 -Force
}
catch {
    Write-Error "Failed to import the required modules. Please make sure the modules are present in the correct location."
    Write-Warning "Please make sure you are the root of the repository and try again."
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

# prompt user for their repo name
if(!$repo_name) {
    $ado_repositories = Get-Repositories -ado_org $ado_organization -project_id $ado_project_id
    while(!$repo_name){
        $answer = Read-Host "Enter the repo name you want to use (must be valid)"
        if($ado_repositories -notcontains $answer) {
            Write-Host "Repo name must be valid"
        } else {
            $repo_name = $repo_name
        }
    }
}

# get the current azure subscription name and id into json
$azure_subscription = az account show --output json
$azure_subscription = $azure_subscription | ConvertFrom-Json -Depth 2

# prompt the user for their subscription id
if(!$azure_subscription_id) {
    $azure_subscription_id = (Read-Host ("Enter the Azure Subscription ID (blank: {0})" -f $($azure_subscription).id))
    if($azure_subscription_id -eq "") {
        $azure_subscription_id = $azure_subscription.id
    else {
        while($azure_subscription_id -notmatch "^[0-9a-f]{8}-([0-9a-f]{4}-){3}[0-9a-f]{12}$") {
            Write-Host "Subscription ID must be valid"
            $azure_subscription_id = Read-Host "Enter the Azure Subscription ID"
        }
    }
}
}

$answer = (Read-Host ("Enter the Azure Subscription Name (blank: {0})" -f $($azure_subscription).name))
if(!$answer) {
    $subscription_name = $($azure_subscription).name
} else {
    $subscription_name = $answer
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
    $service_connection_to_be = Read-Host "Enter the service connection name (blank: sidecar-service-connection)"
    if(!$service_connection_to_be) {
        $service_connection_to_be = "sidecar-service-connection"
    }
}

# loop through the service connections to check if the service connection name already exists
while($service_connection_to_be){
    $service_connections = Get-ServiceConnections -ado_org $ado_organization -ado_project $ado_project
    if($service_connections) {
        $service_connection_names = $service_connections.name
        if($service_connection_names -contains $service_connection_to_be) {
            $service_connection_to_be = Read-Host "Service Connection name already exists. Please enter a unique name."
        } else {
            $service_connection_name = $service_connection_to_be
            $service_connection_to_be = $false
        }
    }

}
$service_connections = Get-ServiceConnections -ado_org $ado_organization -ado_project $ado_project
if($service_connections) {
    $service_connection_names = $service_connections.value.name
    if($service_connection_names -contains $service_connection_name) {
        Write-Error "Service Connection name already exists. Please enter a unique name."
        exit
    }
}

$assign_creator_role_service_connections = Read-Host "Assign the creator role for service connections to the service principal? (default: y) (y/n)"
if($assign_creator_role_service_connections -ne "n") {
    if($assign_creator_role_service_connections -ne "y" -and $assign_creator_role_service_connections){
        Write-Host "Invalid input. Defaulting to 'y'"
    }
    $assign_creator_role_service_connections = $true
} else {
    $assign_creator_role_service_connections = $false
}

$assign_creator_role_agent_pools = Read-Host "Assign the creator role for agent pools to the service principal? (default: y) (y/n)"
if($assign_creator_role_agent_pools -ne "n") {
    if($assign_creator_role_agent_pools -ne "y" -and $assign_creator_role_agent_pools){
        Write-Host "Invalid input. Defaulting to 'y'"
    }
    $assign_creator_role_agent_pools = $true
} else {
    $assign_creator_role_agent_pools = $false
}

$assign_repo_permissions = Read-Host "Do you want to assign the required access for your service connection to the repo? (default: y) (y/n)"
if($assign_repo_permissions -ne "n") {
    if($assign_repo_permissions -ne "y" -and $assign_repo_permissions){
        Write-Host "Invalid input. Defaulting to 'y'"
    }
    $assign_repo_permissions = $true
} else {
    $assign_repo_permissions = $false
}


# Write new line
Write-Host ""

# Confirm with the user the values entered
Write-Host "ADO Organization: $ado_organization"
Write-Host "ADO Project: $ado_project"
Write-Host "Repo Name: $repo_name"
Write-Host "Subscription ID: $azure_subscription_id"
Write-Host "Subscription Name: $subscription_name"
Write-Host "Service Principal ID: $service_principal_id"
Write-Host "Service Connection Name: $service_connection_name"
Write-Host "Assign Creator Role for Service Connections: $assign_creator_role_service_connections"
Write-Host "Assign Creator Role for Agent Pools: $assign_creator_role_agent_pools"
Write-Host "Assign Repo Permissions: $assign_repo_permissions"
$confirm = Read-Host "Do you want to continue? (y/n)"
if($confirm -ne "y") {
    Write-Host "Exiting..."
    exit
}

# Write new line
Write-Host ""

# Create Service Principal and Service Connection
Write-Host "Creating Service Principal"
$service_principal = az ad sp create-for-rbac --name $service_connection_name --role Owner --scopes "/subscriptions/$azure_subscription_id" --only-show-errors --output json
$service_principal = $service_principal | ConvertFrom-Json -Depth 10
if(!$service_principal) {
    Write-Error "Service Principal creation failed. Do you have the required permissions to create a service principal?"
}

# Create Service Connection
Write-Host "Creating Service Connection"
$service_connection = New-ServiceConnection -ado_org $ado_organization -ado_project $ado_project -ado_project_id $ado_project_id -subscription_id $azure_subscription_id -subscription_name $subscription_name -service_principal_id $($service_principal).appId -service_principal_secret $($service_principal).password -tenant_id $($service_principal).tenant -ado_service_connection_name $service_connection_name
if(!$service_connection) {
    Write-Error "Service Connection creation failed. Do you have the required permissions to create a service connection?"
} else {
    Write-Host "Service Connection created successfully"
}

# Get Object ID of the Service Principal
Write-Host "Getting ID of the Service Principal"
$service_principal_object_id = az ad sp show --id $($service_principal).appId --query "id" -o tsv

# Add Service Principal to the ADO environment
Write-Host "Adding Service Principal to the ADO environment"
$service_principal_entitlement = New-ServicePrincipalEntitlement -ado_org $ado_organization -service_principal_object_id $service_principal_object_id -project_id $ado_project_id

if($assign_creator_role_service_connections) {
    Write-Host "Assigning Creator Role for Service Connections to Service Principal"
    $service_connection = Set-ServiceConnectionSecurity -ado_org $ado_organization -user_id $($service_principal_entitlement).id -project_id $ado_project_id -role "Creator"
}

if($assign_creator_role_agent_pools){
    Write-Host "Assigning Creator Role for Agent Pools to Service Principal"
    $agent_pool = Set-AgentPoolSecurity -ado_org $ado_organization -project_id $ado_project_id -user_id $($service_principal_entitlement).id -role "Creator"
}

if($assign_repo_permissions) {
    Write-Host "Assigning required access to the repo"
    if($build_service){
        $descriptor = Get-BuildServiceSecurityID -ado_org $ado_organization -project_id $ado_project_id
    } else {
        $descriptor = "Microsoft.VisualStudio.Services.Claims.AadServicePrincipal;{0}\{1}" -f $($service_principal).tenant, $service_principal_object_id
    }
    $repo = Get-Repository -ado_org $ado_organization -project_id $ado_project_id -repo_name $repo_name

    $roles = @("GenericContribute", "CreateBranch", "PullRequestContribute")
    foreach ($role in $roles) {
        $repo_security = Set-RepositorySecurity -ado_org $ado_organization -descriptor $descriptor -project_id $ado_project_id -repo_id $repo.id -role $role -allow $true
        sleep 1
        Write-Host ("Assigned $role to the {0} in $repo_name" -f ($build_service ? "build service" : "service principal"))
    }
}

# Write new line
Write-Host ""

# Write in green
Write-Host "ADO Environment initialized successfully" -ForegroundColor Green

# Write new line
Write-Host ""
Write-Host "Please create a pipeline and use the service connection '$service_connection_name' to deploy the application to ADO."
Write-Host "The pipeline will also need the subscription id '$azure_subscription_id' added."

# Clean up the environment
Write-Verbose "Cleaning up the environment"
$variables = @("answer", "ado_organization")
foreach ($variable in $variables) {
    Write-Verbose "Removing variable: $variable"
    Remove-Variable -Name $variable -ErrorAction SilentlyContinue
}
