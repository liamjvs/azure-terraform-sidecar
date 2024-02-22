resource "azurerm_storage_account" "this" {
  name                          = var.name
  resource_group_name           = var.resource_group_name
  location                      = var.location
  account_tier                  = var.account_access_tier
  account_replication_type      = var.account_replication_type
  min_tls_version               = var.min_tls_version
  public_network_access_enabled = true # var.public_network_access_enabled
  shared_access_key_enabled     = false
  network_rules {
    default_action = "Allow"
  }
}

resource "azurerm_role_assignment" "this" {
  for_each             = var.principal_ids_role_assignment
  scope                = azurerm_storage_account.this.id
  role_definition_name = var.container_role_definition_name
  principal_id         = each.value
}

resource "time_sleep" "sleep_for_role_assignment_to_take_effect" {
  depends_on = [
    azurerm_role_assignment.this
  ]
  create_duration = "20s"
}

resource "azurerm_storage_container" "this" {
  for_each              = toset(var.containers)
  name                  = each.value
  storage_account_name  = azurerm_storage_account.this.name
  container_access_type = "private"
  depends_on = [
    time_sleep.sleep_for_role_assignment_to_take_effect
  ]
}

resource "azurerm_private_endpoint" "this" {
    count = var.private_endpoint_network != null ? 1 : 0
    name                = coalesce(var.private_endpoint_name, "${var.name}-private-endpoint")
    location            = var.location
    resource_group_name = var.resource_group_name
    subnet_id           = try(format("%s/subnets/%s",var.private_endpoint_network.virtual_network_id, var.private_endpoint_network.subnet),null)
    private_service_connection {
        name                           = format("%s-private-endpoint-connection",coalesce(var.private_endpoint_name, var.name))
        private_connection_resource_id = azurerm_storage_account.this.id
        subresource_names              = ["blob"]
        is_manual_connection           = false
    }

    private_dns_zone_group {
        name = format("%s-dns-zone-group",coalesce(var.private_endpoint_name, var.name))
        private_dns_zone_ids = [var.private_dns_zone_ids]
    }
}