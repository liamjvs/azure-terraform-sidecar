variable "name" {
  description = "The name of the storage account."
  type        = string
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

variable "min_tls_version" {
  description = "The minimum TLS version to use for this storage account."
  type        = string
  default     = "TLS1_2"
}

variable "enable_https_traffic_only" {
  description = "Whether or not to only allow HTTPS traffic to the storage account."
  type        = bool
  default     = true
}

variable "shared_access_key_enabled" {
  description = "Whether or not to enable shared access keys for this storage account."
  type        = bool
  default     = false
}

variable "public_network_access_enabled" {
  description = "Whether or not public network access is allowed for this storage account."
  type        = bool
}

variable "principal_ids_role_assignment" {
  description = "The IDs of the principals to assign the Storage Blob Data Contributor role to."
  type        = map(string)
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

variable "tags" {
  description = "Tags for this resource"
  type        = map(string)
  default     = {}
}