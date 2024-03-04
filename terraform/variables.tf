## Global
variable "location" {
  description = "The location/region where the resources are created."
  type        = string
  default     = "uksouth"
}

variable "context" {
  description = "The context of the deployment."
  type        = string
  default     = "sidecar"
}

variable "init" {
  description = "If this is the first deployment of the solution."
  type        = bool
  default     = false
}

variable "deployment_choice" {
  description = <<DEPLOYMENT_METHOD
  Select the deployment choice. This can either be:
  - Storage Account
    - A public storage account is created to store the backend state file(s).
  - Agent Pool
    - A Virtual Network, Private DNS Zone, Linux Virtual Machine Scale Set, Storage Account and Private Endpoint are created with the appropriate Role-Based Access Control (RBAC) assignments.
  DEPLOYMENT_METHOD
  type        = string
  default     = "Storage Account"
  validation {
    condition     = can(regex("^(Storage Account|Agent Pool)$", var.deployment_choice))
    error_message = "The deployment choice must be either Storage Account or Agent Pool."
  }
}

variable "private_deployment" {
  description = "Make the solution private and only accessible via private endpoints."
  type        = bool
  default     = false
}

variable "authentication_method" {
  description = "Post-deployment authentication method; either User, Service Principal or Managed Identity."
  type        = string
  default     = "User"
  validation {
    condition     = can(regex("^(User|Service Principal|System Managed Identity|User Managed Identity)$", var.authentication_method))
    error_message = "The authentication method must be either User, Service Principal, System Managed Identity or User Managed Identity."
  }
}

## Resource Group
variable "resource_group_name" {
  description = "The name of the resource group in which to create the virtual network."
  type        = string
  default     = null
}

### Virtual Network

variable "virtual_network_name" {
  description = "The name of the virtual network."
  type        = string
  default     = null
}

variable "virtual_network_address_space" {
  description = "The address space that is used the virtual network."
  type        = list(string)
  default     = ["10.0.0.0/23"]
}

### Subnets

#### Runner Subnet

variable "subnet_private_runner_name" {
  description = "The name of the runner subnet."
  type        = string
  default     = null
}

variable "subnet_runner_address_prefixes" {
  description = "The address prefixes to use for the runner subnet."
  type        = string
  default     = "10.0.0.0/24"
  validation {
    condition     = length(var.subnet_runner_address_prefixes) > 0
    error_message = "The runner subnet cannot be empty."
  }
}

#### Endpoint Subnet

variable "subnet_private_endpoint_name" {
  description = "The name of the endpoint subnet."
  type        = string
  default     = null
}

variable "subnet_private_endpoint_address_prefixes" {
  description = "The address prefixes to use for the endpoint subnet."
  type        = string
  default     = "10.0.1.0/24"
  validation {
    condition     = length(var.subnet_private_endpoint_address_prefixes) > 0
    error_message = "The runner subnet cannot be empty."
  }
}

### Backend Storage Account

variable "backend_storage_account_name" {
  description = "The name of the storage account to store the backend state file(s) on. Must be unique."
  type        = string
  default     = null
}

variable "backend_storage_account_tier" {
  description = "The tier to use for this storage account."
  type        = string
  default     = "Standard"
}

variable "backend_storage_account_replication_type" {
  description = "The type of replication to use for this storage account."
  type        = string
  default     = "LRS"
}

variable "backend_storage_account_containers" {
  description = "The containers to create in the storage account."
  type        = list(string)
  default     = []
}

variable "backend_storage_account_container" {
  description = "The container to store this Sidecar Terraform deployment into post-deployment."
  type        = string
  default     = ""
}

variable "backend_additional_principal_ids" {
  description = "The additional principal IDs to grant access to the storage account."
  type        = list(string)
  default     = []
}

variable "storage_account_private_endpoint_name" {
  description = "The name of the private endpoint for the storage account."
  type        = string
  default     = null
}

### Virtual Machine Scale Set

variable "virtual_machine_scaleset_name" {
  description = "The name of the virtual machine scale set."
  type        = string
  default     = null
}

#### Autehntication

variable "virtual_machine_scaleset_use_random_password" {
  description = "Whether to use a random password for the virtual machine scale set."
  type        = bool
  default     = true
}

variable "virtual_machine_scaleset_use_azure_key_pair" {
  description = "Whether to use an Azure key pair for the virtual machine scale set."
  type        = bool
  default     = false
}

### User Assigned

variable "user_assigned_identity_name" {
  description = "The name of the user assigned managed identity"
  type        = string
  default     = ""
}