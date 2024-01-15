resource "azurerm_linux_virtual_machine_scale_set" "vmss" {
  name                = var.name
  resource_group_name = var.resource_group_name
  location            = var.location

  sku       = var.sku
  instances = 0

  admin_username                  = var.admin_username
  admin_password                  = var.admin_password

  dynamic "admin_ssh_key" {
    for_each = var.admin_key != null ? ["key"] : []
    content {
      username   = "adminuser"
      public_key = admin_ssh_key.value
    }
  }

  disable_password_authentication = false

  upgrade_mode           = var.upgrade_mode
  single_placement_group = false

  network_interface {
    name = local.nic_name
    primary = true
    ip_configuration {
      name      = "ipconfig"
      primary   = true
      subnet_id = var.subnet_id
    }
  }

  os_disk {
    caching              = var.os_disk_caching
    storage_account_type = var.os_disk_storage_account_type
  }

  source_image_reference {
    publisher = var.source_image_reference.publisher
    offer     = var.source_image_reference.offer
    sku       = var.source_image_reference.sku
    version   = var.source_image_reference.version
  }

  custom_data = var.custom_data

  boot_diagnostics {
    storage_account_uri = null # This will use the Managed Storage Account for boot diagnostics
  }

  dynamic "automatic_os_upgrade_policy" {
    for_each = var.upgrade_mode != "Manual" ? ["policy"] : []
    content {
      disable_automatic_rollback  = var.automatic_os_upgrade_policy.disable_automatic_rollback
      enable_automatic_os_upgrade = var.automatic_os_upgrade_policy.enable_automatic_os_upgrade
    }
  }

  dynamic "identity" {
    for_each = var.enable_managed_identity ? ["foo"] : []
    content {
      type = "SystemAssigned"
    }
  }

  lifecycle {
    ignore_changes = [
      instances, # If we're making changes to the VMSS from this same deployment, we don't want Terraform to update the instances to 0.
      tags["__AzureDevOpsElasticPool"], # We don't want to update the tag if it's already set by Azure DevOps.
      tags["__AzureDevOpsElasticPoolTimeStamp"], # We don't want to update the tag if it's already set by Azure DevOps.
    ]
  }
}