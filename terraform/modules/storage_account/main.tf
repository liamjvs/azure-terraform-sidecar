/**
 * # Storage Account
 *
 */

resource "azurerm_storage_account" "this" {
  name                          = var.name
  resource_group_name           = var.resource_group_name
  location                      = var.location
  account_tier                  = var.account_tier
  account_replication_type      = var.account_replication_type
  min_tls_version               = var.min_tls_version
  enable_https_traffic_only     = var.enable_https_traffic_only
  public_network_access_enabled = var.public_network_access_enabled
  shared_access_key_enabled     = var.shared_access_key_enabled
  network_rules {
    default_action = var.public_network_access_enabled ? "Allow" : "Deny"
  }
  tags = var.tags
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
  create_duration = "10s"
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