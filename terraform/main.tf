## Data
data "azurerm_client_config" "current" {
}

## Resource
resource "azurerm_resource_group" "resource_group" {
  name     = local.resource_names.resource_group_name
  location = var.location
}

module "virtual_network" {
  source = "./modules/virtual_network"

  name                = local.resource_names.virtual_network_name
  resource_group_name = azurerm_resource_group.resource_group.name
  location            = var.location
  address_space       = var.virtual_network_address_space
  subnets             = local.subnets
  private_dns_zones = [
    "privatelink.blob.core.windows.net"
  ]
}

module "storage_account" {
  source = "./modules/storage_account"

  name                          = local.resource_names.storage_account_name
  private_endpoint_name         = local.resource_names.subnet_private_endpoint_name
  resource_group_name           = azurerm_resource_group.resource_group.name
  location                      = var.location
  account_tier                  = var.backend_storage_account_tier
  account_replication_type      = var.backend_storage_account_replication_type
  account_access_tier           = var.backend_storage_account_tier
  public_network_access_enabled = var.private_deployment ? false : true
  principal_ids_role_assignment = local.backend_principal_ids
  containers                    = local.storage_account_containers
}

module "private_endpoint" {
  source = "./modules/private_endpoint"

  name                = "privateEndpoint"
  private_service_connection_name = "privateServiceConnection"
  location            = var.location
  resource_group_name = azurerm_resource_group.resource_group.name
  subnet_id           = module.virtual_network.subnets[local.resource_names.subnet_private_endpoint_name].id
  subresource_names = [ "blob" ]
  private_connection_resource_id = module.storage_account.azurerm_storage_account.id
  private_dns_zone_ids = [
    module.private_dns_zone.azurerm_private_dns_zone.id
  ]
}

module "private_dns_zone" {
  source = "./modules/private_dns_zone"

  name                = "privatelink.blob.core.windows.net"
  resource_group_name = azurerm_resource_group.resource_group.name
}

module "linux_virtual_machine_scale_set" {
  source = "./modules/linux_virtual_machine_scale_set"

  name                = local.resource_names.vmss_name
  location            = var.location
  resource_group_name = azurerm_resource_group.resource_group.name
  sku                 = "Standard_B2s"
  subnet_id           = module.virtual_network.subnets[local.resource_names.subnet_runner_name].id
  admin_password      = var.virtual_machine_scaleset_use_random_password ? random_password.admin_password[0].result : null
  admin_key           = var.virtual_machine_scaleset_use_azure_key_pair ? module.azure_key_pair[0].public_key : null
  source_image_reference = {
    publisher = "Canonical"
    offer     = "0001-com-ubuntu-server-focal"
    sku       = "20_04-lts-gen2"
    version   = "latest"
  }

  do_not_run_extensions_on_overprovisioned_vm = true

  // Boolean on whether to use managed identity or not
  enable_managed_identity = local.authentication_method_managed_identity

  custom_data = data.cloudinit_config.multipart.rendered
}

# Authentication

## Password

resource "random_password" "admin_password" {
  count   = var.virtual_machine_scaleset_use_random_password ? 1 : 0
  length  = 14
  lower   = true
  upper   = true
  numeric = true
  special = true

  lifecycle {
    ignore_changes = [
      length, lower, upper, numeric, special # We don't want to update the password if it's already set.
    ]
  }
}

## Azure Key Pair

module "azure_key_pair" {
  count             = var.virtual_machine_scaleset_use_azure_key_pair ? 1 : 0
  source            = "./modules/ssh_public_key"
  location          = var.location
  resource_group_id = azurerm_resource_group.resource_group.id
}


data "cloudinit_config" "multipart" {
  gzip          = false
  base64_encode = true
  dynamic "part" {
    for_each = fileset("${path.module}/cloud_init", "*.yaml")
    content {
      filename     = "install_${split(".", part.value)[0]}"
      content_type = "text/cloud-config"
      content      = file("${path.module}/cloud_init/${part.value}")
    }
  }
}

# RBAC

resource "azurerm_role_assignment" "role_assignment" {
  count = local.authentication_method_managed_identity ? 1 : 0

  principal_id         = local.rbac_assign_object_id
  role_definition_name = "Owner" //may need to assign RBAC
  scope                = azurerm_resource_group.resource_group.id
}