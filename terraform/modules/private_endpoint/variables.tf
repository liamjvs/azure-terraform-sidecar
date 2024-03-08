variable "resource_group_name" {
  description = "Name of the resource group"
  type        = string
}

variable "location" {
  description = "Location of the resource group"
  type        = string
}

variable "subnet_id" {
  description = "ID of the subnet"
  type        = string
}

variable "name" {
  description = "Name of the private endpoint"
  type        = string
}

variable "private_service_connection_name" {
  description = "Name of the private service connection"
  type        = string
  default     = "private-service-connection"
}

variable "private_connection_resource_id" {
  description = "ID of the private connection resource"
  type        = string
}

variable "is_manual_connection" {
  description = "Is the connection manual"
  type        = bool
  default     = false
}

variable "subresource_names" {
  description = "Subresource names"
  type        = list(string)
}

variable "private_dns_zone_ids" {
  description = "Private DNS zone IDs"
  type        = list(string)
  default     = []
}

variable "private_dns_zone_group_name" {
  description = "Name of the private DNS zone group"
  type        = string
  default     = "default"
}

variable "tags" {
  description = "Tags for this resource"
  type        = map(string)
  default     = {}
}