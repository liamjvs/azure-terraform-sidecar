output "virtual_machine_scaleset_id" {
  value = module.linux_virtual_machine_scale_set.azurerm_linux_virtual_machine_scale_set.id
}

// Terraform Backend State File Outputs

output "resource_group_name" {
  value = azurerm_resource_group.resource_group.name
}

output "storage_account_name" {
  value = module.storage_account.azurerm_storage_account.name
}

output "container_name" {
  value = local.default_resource_names.storage_account_container_sidecar
}

output "subscription_id" {
  value = data.azurerm_client_config.current.subscription_id
}

output "tenant_id" {
  value = data.azurerm_client_config.current.tenant_id
}

output "use_azuread_auth" {
  value = true # local.authentication_method_service_principal
}

output "use_msi" {
  value = false # local.authentication_method_managed_identity
}