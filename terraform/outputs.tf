# output "sidecar_resource_group" {
#   value       = module.rg-sidecar.azurerm_resource_group
#   description = "The full object of the resource group where the storage account is deployed."
# }
# output "sidecar_storage_account" {
#   value       = module.storageAccount.azurerm_storage_account
#   description = "The full object of the storage account."
# }
# output "sidecar_container" {
#   value       = module.storageAccount.azurerm_storage_containers.sidecar
#   description = "The name of the storage container."
# }
# output "sidecar_vmss_id" {
#   value       = module.linux_vmss.azurerm_linux_virtual_machine_scale_set.id
#   description = "The ID of the virtual machine scale set."
# }
# output "private_dns_zone" {
#   value       = module.privateDnsZone_storage.azurerm_private_dns_zone
#   description = "The full object of the private DNS zone."
# }
# output "network_security_group" {
#   value       = module.nsg.azurerm_network_security_group
#   description = "The full object of the network security group."
# }
# output "agent_subnet" {
#   value       = module.subnet_agents.azurerm_subnet
#   description = "The full object of the agent subnet."
# }
# output "endpoints_subnet" {
#   value       = module.subnet_endpoints.azurerm_subnet
#   description = "The full object of the endpoints subnet."
# }
# output "virtual_network" {
#   value       = module.vnet.azurerm_virtual_network
#   description = "The full object of the virtual network."
# }
# output "virtual_machine_scaleset" {
#   value       = module.linux_vmss.azurerm_linux_virtual_machine_scale_set
#   description = "The full object of the virtual machine scale set."
# }

# output "publicip_prefix_name" {
#   value       = module.publicip_prefix.name
#   description = "The name of the public IP Prefix."
# }

# output "nat_gateway_name" {
#   value       = module.nat_gateway.nat_gateway_name
#   description = "The name of the NAT Gateway."
# }