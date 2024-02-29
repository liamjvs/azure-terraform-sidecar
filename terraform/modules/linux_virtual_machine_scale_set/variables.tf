variable "name" {
  description = "The name of the virtual machine scale set."
  type        = string

}

variable "resource_group_name" {
  description = "The name of the resource group in which to create the virtual machine scale set."
  type        = string
}

variable "nic_name" {
  description = "The name of the network interface."
  type        = string
  default     = null
}

variable "location" {
  description = "The location/region where the resources are created."
  type        = string
}

variable "subnet_id" {
  description = "The ID of the subnet where the virtual machine scale set is deployed."
  type        = string
}

variable "admin_username" {
  description = "The username of the local administrator account."
  type        = string
  default     = "adminuser"
}

variable "admin_password" {
  description = "The password of the local administrator account."
  type        = string
  default     = null
}

variable "admin_key" {
  description = "The public key of the local administrator account."
  type        = string
  default     = null
}

variable "sku" {
  description = "The SKU of the virtual machine scale set."
  type        = string
}

variable "os_disk_caching" {
  description = "The caching of the operating system disk."
  type        = string
  default     = "ReadWrite"
  validation {
    condition     = can(regex("^None|ReadWrite|ReadOnly$", var.os_disk_caching))
    error_message = "The caching of the operating system disk must be either None, ReadWrite or ReadOnly."
  }
}

variable "os_disk_storage_account_type" {
  description = "The storage account type of the operating system disk."
  type        = string
  default     = "Standard_LRS"
  validation {
    condition     = can(regex("^Standard_LRS|StandardSSD_LRS|Premium_LRS$", var.os_disk_storage_account_type))
    error_message = "The storage account type of the operating system disk must be either Standard_LRS, StandardSSD_LRS or Premium_LRS."
  }
}

variable "source_image_reference" {
  description = "The source image reference of the virtual machine scale set."
  type = object({
    publisher = string
    offer     = string
    sku       = string
    version   = string
  })
}

variable "single_placement_group" {
  description = "Specifies whether the scale set should be created with a single placement group."
  type        = bool
  default     = false
}

variable "upgrade_mode" {
  description = "Specifies how virtual machine scale set should be upgraded."
  type        = string
  default     = "Manual"
  validation {
    condition     = can(regex("^Automatic|Manual$", var.upgrade_mode))
    error_message = "The upgrade mode of the virtual machine scale set must be either Automatic or Manual."
  }
}

variable "custom_data" {
  description = "The custom data of the virtual machine scale set. If populated, it must be base64 encoded."
  type        = string
  default     = null
}

variable "instances" {
  description = "The number of instances in the virtual machine scale set on initialy deployment. Currently, this property is added to be ignored post-deployment as Azure DevOps handles the instance count"
  type        = number
  default     = 0
  validation {
    condition     = var.instances >= 0
    error_message = "The number of instances in the virtual machine scale set must be greater than or equal to 0."
  }
}

variable "enable_managed_identity" {
  description = "Specifies whether a managed identity should be enabled for the virtual machine scale set."
  type        = bool
  default     = true
}

variable "user_assigned_identity_ids" {
  description = "The IDs of the user assigned identities to assign to the virtual machine scale set."
  type        = list(string)
  default     = []
  nullable    = false
}

variable "automatic_os_upgrade_policy" {
  description = "The automatic OS upgrade policy of the virtual machine scale set."
  type = object({
    enable_automatic_os_upgrade = bool
    disable_automatic_rollback  = bool
  })
  default = {
    enable_automatic_os_upgrade = false
    disable_automatic_rollback  = false
  }
}

variable "do_not_run_extensions_on_overprovisioned_vm" {
  description = <<DESCRIPTION
  Specifies whether to run extensions on overprovisioned virtual machines. 
  Recommend setting this to try if using this for Azure DevOps Agents as you may get a condition where a VM is deprovisioned but has received an Azure DevOps job.
  DESCRIPTION
  type        = bool
  default     = false
}

variable "tags" {
  description = "Tags for this resource"
  type        = map(string)
  default     = {}
}