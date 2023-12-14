terraform {
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = ">=2.67.0"
    }
  }
  # backend "azurerm" {}
}
provider "azurerm" {
  features {}
  skip_provider_registration = true
}

locals {
  orgId       = "lmp"
  appId       = "654321"
  environment = "dev"
  context     = "sc"
  location    = "uksouth"
  instance    = "112"
  region      = "uks"
}

module "sidecar_test" {
  source      = "../../"
  orgId       = local.orgId
  appId       = local.appId
  environment = local.environment
  context     = local.context
  instance    = local.instance
  region      = local.region
  location    = local.location
  firstrun    = true
}

output "sidecar_resource_group_name" {
  value = module.sidecar_test.sidecar_resource_group.name
}

output "sidecar_storage_account_name" {
  value = module.sidecar_test.sidecar_storage_account.name
}

output "sidecar_private_dns_zone_name" {
  value = module.sidecar_test.private_dns_zone.name
}

output "sidecar_network_security_group_name" {
  value = module.sidecar_test.network_security_group.name
}

output "sidecar_virtual_network_name" {
  value = module.sidecar_test.virtual_network.name
}

output "sidecar_virtual_network_id" {
  value = module.sidecar_test.virtual_network.id
}

output "sidecar_virtual_machine_scaleset_name" {
  value = module.sidecar_test.virtual_machine_scaleset.name
}

output "sidecar_public_ip_prefix_name" {
  value = module.sidecar_test.publicip_prefix_name
}

output "sidecar_nat_gateway_name" {
  value = module.sidecar_test.nat_gateway_name
}