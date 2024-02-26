variable "name" {
  type        = string
  description = "The name of the Private DNS Zone."
}

variable "resource_group_name" {
  description = "The name of the resource group in which to create the virtual network."
  type        = string
}