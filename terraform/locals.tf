locals {
  # storage_account_containers = { for container in var.backend_storage_account_containers : container.name => container }
  backend_principal_ids = merge(
    {
      for k, v in [true] : "system_managed_identity" => module.linux_virtual_machine_scale_set[0].azurerm_linux_virtual_machine_scale_set.identity[0].principal_id
      if local.authentication_method_managed_identity && local.deployment_choice_agent_pool
    },
    {
      for k, v in [true] : "user_managed_identity" => module.user_assigned_identity[0].azurerm_user_assigned_identity.principal_id
      if local.authentication_method_user_managed_identity && local.deployment_choice_agent_pool
    },
    {
      for k, v in [true] : "service_principal" => data.azurerm_client_config.current.object_id
      if local.authentication_method_service_principal || var.init
    },
    {
      for k, v in [true] : "user" => data.azurerm_client_config.current.object_id
      if local.authentication_method_user
    },
    {
      for k, v in var.backend_additional_principal_ids : k => v
    }
  )

  # the object ID to assign rights to
  rbac_assign_object_id = (
    local.authentication_method_managed_identity ? one(module.linux_virtual_machine_scale_set[*].azurerm_linux_virtual_machine_scale_set.identity[0].principal_id) :
    local.authentication_method_user_managed_identity ? module.user_assigned_identity.azurerm_user_assigned_identity.principal_id :
    local.authentication_method_service_principal || local.authentication_method_user ? data.azurerm_client_config.current.object_id :
    null // you've not selected an authentication method
  )

  subnets = {
    lookup(local.resource_names, "subnet_runner_name", local.default_resource_names.subnet_runner_name) = {
      address_prefixes = [var.subnet_runner_address_prefixes]
    }
    lookup(local.resource_names, "subnet_private_endpoint_name", local.default_resource_names.subnet_private_endpoint_name) = {
      address_prefixes                  = [var.subnet_private_endpoint_address_prefixes]
      private_endpoint_network_policies = true
    }
  }

  private_deployment = var.init ? false : var.private_deployment

  deployment_choice_agent_pool = var.deployment_choice == "AgentPool"

  authentication_method_managed_identity      = var.authentication_method == "SystemManagedIdentity"
  authentication_method_user_managed_identity = var.authentication_method == "UserManagedIdentity"
  authentication_method_service_principal     = var.authentication_method == "ServicePrincipal"
  authentication_method_user                  = var.authentication_method == "User"

  storage_account_containers = concat(var.backend_storage_account_containers, [local.default_resource_names.storage_account_container_sidecar])

  resource_names = {
    resource_group_name               = coalesce(var.resource_group_name, local.default_resource_names.resource_group_name)
    virtual_network_name              = coalesce(var.virtual_network_name, local.default_resource_names.virtual_network_name)
    subnet_runner_name                = coalesce(var.subnet_private_runner_name, local.default_resource_names.subnet_runner_name)
    subnet_private_endpoint_name      = coalesce(var.subnet_private_endpoint_name, local.default_resource_names.subnet_private_endpoint_name)
    storage_account_name              = coalesce(var.backend_storage_account_name, local.default_resource_names.storage_account_name)
    storage_account_container_sidecar = coalesce(var.backend_storage_account_container, local.default_resource_names.storage_account_container_sidecar)
    storage_account_private_endpoint  = coalesce(var.storage_account_private_endpoint_name, local.default_resource_names.storage_account_private_endpoint)
    user_assigned_identity            = coalesce(var.user_assigned_identity_name, local.default_resource_names.user_assigned_identity)
    vmss_name                         = coalesce(var.virtual_machine_scaleset_name, local.default_resource_names.vmss_name)
  }

  default_resource_names = {
    resource_group_name               = join("-", compact(["rg", local.location_to_short_map[var.location], var.context]))
    virtual_network_name              = join("-", compact(["vnet", local.location_to_short_map[var.location], var.context]))
    subnet_runner_name                = join("-", compact(["subnet", local.location_to_short_map[var.location], var.context, "runner"]))
    subnet_private_endpoint_name      = join("-", compact(["subnet", local.location_to_short_map[var.location], var.context, "endpoint"]))
    storage_account_name              = join("", compact(["sa", local.location_to_short_map[var.location], var.context, substr(data.azurerm_client_config.current.subscription_id, 0, 2)]))
    storage_account_container_sidecar = "sidecar" //Sidecar container to store this TF deployment
    storage_account_private_endpoint  = join("-", compact(["pe", local.location_to_short_map[var.location], var.context, "sa"]))
    user_assigned_identity            = join("-", compact(["umi", local.location_to_short_map[var.location], var.context]))
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
    "westus3"            = "wus3"
    "eastus3"            = "eus3"
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