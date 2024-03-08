variable "name" {
  description = "Name of the user assigned identity"
  type        = string
}

variable "resource_group_name" {
  description = "Name of the resource group"
  type        = string
}

variable "location" {
  description = "Location of the resource group"
  type        = string
}

variable "tags" {
  description = "Tags for this resource"
  type        = map(string)
  default     = {}
}