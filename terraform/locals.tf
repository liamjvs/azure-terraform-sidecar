locals {
  # storage_account_containers = { for container in var.backend_storage_account_containers : container.name => container }
  backend_principal_ids = concat([data.azurerm_client_config.current.object_id], var.backend_additional_principal_ids)

  subnets = {
    "${local.default_resource_names.subnet_runner_name}" = {
      address_prefixes = [var.subnet_runner_address_prefixes]
    }
    "${local.default_resource_names.subnet_private_endpoint_name}" = {
      address_prefixes = [var.subnet_private_endpoint_address_prefixes]
    }
  }

  storage_account_containers = concat(var.backend_storage_account_containers, [local.default_resource_names.storage_account_container_sidecar])

  tfstate_file = {
    resource_group_name       = azurerm_resource_group.resource_group.name
    storage_account_name      = module.storage_account.azurerm_storage_account.name
    container_name            = local.default_resource_names.storage_account_container_sidecar
    virtual_machine_scale_set = module.linux_virtual_machine_scale_set.azurerm_linux_virtual_machine_scale_set.id
    use_azuread_auth          = true
  }

  resource_names = {
    resource_group_name               = coalesce(var.resource_group_name, local.default_resource_names.resource_group_name)
    virtual_network_name              = coalesce(var.virtual_network_name, local.default_resource_names.virtual_network_name)
    subnet_runner_name                = coalesce(var.subnet_private_runner_name, local.default_resource_names.subnet_runner_name)
    subnet_private_endpoint_name      = coalesce(var.subnet_private_endpoint_name, local.default_resource_names.subnet_private_endpoint_name)
    storage_account_name              = coalesce(var.backend_storage_account_name, local.default_resource_names.storage_account_name)
    storage_account_container_sidecar = coalesce(var.backend_storage_account_container, local.default_resource_names.storage_account_container_sidecar)
    vmss_name                         = coalesce(var.virtual_machine_scaleset_name, local.default_resource_names.vmss_name)
    vmss_nic_name                     = coalesce(var.virtual_machine_scaleset_nic_name, local.default_resource_names.vmss_nic_name)
  }

  default_resource_names = {
    resource_group_name               = join("-", compact(["rg", local.location_to_short_map[var.location], var.context]))
    virtual_network_name              = join("-", compact(["vnet", local.location_to_short_map[var.location], var.context]))
    subnet_runner_name                = join("-", compact(["subnet", local.location_to_short_map[var.location], var.context, "runner"]))
    subnet_private_endpoint_name      = join("-", compact(["subnet", local.location_to_short_map[var.location], var.context, "endpoint"]))
    storage_account_name              = join("", compact(["sa", local.location_to_short_map[var.location], var.context, substr(data.azurerm_client_config.current.object_id, 0, 2)]))
    storage_account_container_sidecar = "sidecar" //Sidecar container to store this TF deployment
    vmss_name                         = join("-", compact(["vmss", local.location_to_short_map[var.location], var.context]))
    vmss_disk_name                    = join("-", compact(["vmss", local.location_to_short_map[var.location], var.context, "disk"]))
    vmss_nic_name                     = join("-", compact(["vmss", local.location_to_short_map[var.location], var.context, "nic"]))
  }

  location_to_short_map = {
    "eastus"             = "eus"
    "westus"             = "wus"
    "westeurope"         = "weu"
    "eastus2"            = "eus2"
    "westus2"            = "wus2"
    "westeurope"         = "weu"
    "eastus2euap"        = "eus2euap"
    "westus2euap"        = "wus2euap"
    "westus3"            = "wus3"
    "eastus3"            = "eus3"
    "eastus2euap"        = "eus2euap"
    "westus2euap"        = "wus2euap"
    "westus3"            = "wus3"
    "eastus3"            = "eus3"
    "eastasia"           = "eas"
    "southeastasia"      = "sea"
    "centralus"          = "cus"
    "northcentralus"     = "ncus"
    "southcentralus"     = "scus"
    "northeurope"        = "neu"
    "westeurope"         = "weu"
    "japanwest"          = "jpw"
    "japaneast"          = "jpe"
    "brazilsouth"        = "brs"
    "australiaeast"      = "aeu"
    "australiasoutheast" = "ase"
    "southindia"         = "sin"
    "centralindia"       = "cin"
    "westindia"          = "win"
    "canadacentral"      = "cca"
    "canadaeast"         = "cae"
    "uksouth"            = "uks"
    "ukwest"             = "ukw"
    "westcentralus"      = "wcus"
    "westus"             = "wus"
    "koreacentral"       = "krc"
    "koreasouth"         = "krs"
    "francecentral"      = "frc"
    "francesouth"        = "frs"
    "australiacentral"   = "acu"
    "australiacentral2"  = "acu2"
    "southafricanorth"   = "san"
    "southafricawest"    = "saw"
  }
}