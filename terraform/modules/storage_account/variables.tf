variable "name" {
  description = "The name of the storage account."
  type        = string
}

variable "private_endpoint_name" {
  description = "The name of the private endpoint."
  type        = string
  default     = null
}

variable "resource_group_name" {
  description = "The name of the resource group in which to create the storage account."
  type        = string
}

variable "location" {
  description = "The location/region where the resources are created."
  type        = string
}

variable "account_tier" {
  description = "Defines the Tier to use for this storage account."
  type        = string
}

variable "account_replication_type" {
  description = "Defines the type of replication to use for this storage account."
  type        = string
}

variable "account_access_tier" {
  description = "Defines the access tier to use for this storage account."
  type        = string
}

variable "min_tls_version" {
  description = "The minimum TLS version to use for this storage account."
  type        = string
  default     = "TLS1_2"
}

variable "public_network_access_enabled" {
  description = "Whether or not public network access is allowed for this storage account."
  type        = bool
}

variable "private_endpoint_network" {
  description = "The ID of the subnet to use for the private endpoint."
  type        = object({
    virtual_network_id = optional(string)
    subnet            = optional(string)
  })
  default = null
}

variable "principal_ids_role_assignment" {
  description = "The IDs of the principals to assign the Storage Blob Data Contributor role to."
  type        = set(string)
}

variable "private_dns_zone_ids" {
  description = "The IDs of the private DNS zones to link to the private endpoint."
  type        = string
  default     = null
}

variable "containers" {
  description = "The containers to create in the storage account."
  type        = set(string)
  default     = ["container"]
}

variable "container_role_definition_name" {
  description = "The name of the role definition to assign to the container."
  type        = string
  default     = "Storage Blob Data Contributor"
}