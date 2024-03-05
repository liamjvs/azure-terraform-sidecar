/**
 * # azure-terraform-sidecar
 */

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
  count  = local.deployment_choice_agent_pool ? 1 : 0

  name                = local.resource_names.virtual_network_name
  resource_group_name = azurerm_resource_group.resource_group.name
  location            = var.location
  address_space       = var.virtual_network_address_space
  subnets             = local.subnets
}

module "storage_account" {
  source = "./modules/storage_account"

  name                          = local.resource_names.storage_account_name
  resource_group_name           = azurerm_resource_group.resource_group.name
  location                      = var.location
  account_tier                  = var.backend_storage_account_tier
  account_replication_type      = var.backend_storage_account_replication_type
  public_network_access_enabled = !local.private_deployment
  principal_ids_role_assignment = local.backend_principal_ids
  containers                    = local.storage_account_containers
}

module "private_endpoint" {
  source = "./modules/private_endpoint"
  count  = local.deployment_choice_agent_pool ? 1 : 0

  name                           = local.resource_names.storage_account_private_endpoint
  location                       = var.location
  resource_group_name            = azurerm_resource_group.resource_group.name
  subnet_id                      = module.virtual_network[0].azurerm_subnet[local.resource_names.subnet_private_endpoint_name].id
  subresource_names              = ["blob"]
  private_connection_resource_id = module.storage_account.azurerm_storage_account.id
  private_dns_zone_ids = [
    module.private_dns_zone[0].azurerm_private_dns_zone.id
  ]
}

module "private_dns_zone" {
  source = "./modules/private_dns_zone"
  count  = local.deployment_choice_agent_pool ? 1 : 0

  name                = "privatelink.blob.core.windows.net"
  resource_group_name = azurerm_resource_group.resource_group.name
  virtual_network_ids = {
    "vnet" = module.virtual_network[0].azurerm_virtual_network.id
  }
}

module "linux_virtual_machine_scale_set" {
  source = "./modules/linux_virtual_machine_scale_set"
  count  = local.deployment_choice_agent_pool ? 1 : 0

  name                = local.resource_names.vmss_name
  location            = var.location
  resource_group_name = azurerm_resource_group.resource_group.name
  sku                 = "Standard_B2s"
  subnet_id           = module.virtual_network[0].azurerm_subnet[local.resource_names.subnet_runner_name].id
  admin_password      = var.virtual_machine_scaleset_use_random_password ? random_password.admin_password[0].result : null
  admin_key           = var.virtual_machine_scaleset_use_azure_key_pair ? module.azure_key_pair[0].public_key : null
  source_image_reference = {
    publisher = "Canonical"
    offer     = "0001-com-ubuntu-server-focal"
    sku       = "20_04-lts-gen2"
    version   = "latest"
  }

  do_not_run_extensions_on_overprovisioned_vm = true

  enable_managed_identity = local.authentication_method_managed_identity
  user_assigned_identity_ids = local.authentication_method_user_managed_identity ? [
    module.user_assigned_identity[0].id
  ] : []

  custom_data = data.cloudinit_config.multipart.rendered
}

# Authentication

## Password

resource "random_password" "admin_password" {
  count = var.virtual_machine_scaleset_use_random_password && local.deployment_choice_agent_pool ? 1 : 0

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
  source = "./modules/ssh_public_key"
  count  = var.virtual_machine_scaleset_use_azure_key_pair && local.deployment_choice_agent_pool ? 1 : 0

  location          = var.location
  resource_group_id = azurerm_resource_group.resource_group.id
}

## Cloud Init

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

module "user_assigned_identity" {
  source = "./modules/user_assigned_identity"
  count  = local.authentication_method_user_managed_identity && local.deployment_choice_agent_pool ? 1 : 0

  name                = local.resource_names.user_assigned_identity
  resource_group_name = azurerm_resource_group.resource_group
  location            = var.location
}

resource "azurerm_role_assignment" "role_assignment" {
  count = local.authentication_method_managed_identity || local.authentication_method_user_managed_identity ? 1 : 0

  principal_id         = local.rbac_assign_object_id
  role_definition_name = "Owner"
  scope                = azurerm_resource_group.resource_group.id
}