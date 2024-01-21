output "virtual_machine_scaleset_id" {
  value = module.linux_virtual_machine_scale_set.azurerm_linux_virtual_machine_scale_set.id
}

output "resource_group_name" {
  value = azurerm_resource_group.resource_group.name
}

output "storage_account_name" {
  value = module.storage_account.azurerm_storage_account.name
}

output "use_azuread_auth" {
  value = true
}

output "container_name" {
  value = local.default_resource_names.storage_account_container_sidecar
}