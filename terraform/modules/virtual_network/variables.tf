variable "name" {
  description = "The name of the Virtual Network."
  type        = string
}

variable "resource_group_name" {
  description = "The name of the resource group in which to create the Virtual Network."
  type        = string
}

variable "location" {
  description = "The location/region where the resources are created."
  type        = string
}

variable "address_space" {
  description = "The address space that is used the virtual network."
  type        = list(string)
}

variable "subnets" {
  description = "The subnets that are used the virtual network."
  type        = map(object({
    address_prefixes = list(string)
  }))
}