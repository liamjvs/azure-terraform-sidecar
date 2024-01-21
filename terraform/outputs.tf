output "tfstate_file" {
  value = local.tfstate_file
}

output "virtual_machine_scaleset_id" {
  value = module.linux_virtual_machine_scale_set.azurerm_linux_virtual_machine_scale_set.id
}