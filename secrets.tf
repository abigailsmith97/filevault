resource "azurerm_key_vault_secret" "destinations_prometheus_password" {
  name         = "destinations-prometheus-password"
  value        = var.destinations_prometheus_password
  key_vault_id = azurerm_key_vault.vault.id
}

resource "azurerm_key_vault_secret" "destinations_loki_password" {
  name         = "destinations-loki-password"
  value        = var.destinations_loki_password
  key_vault_id = azurerm_key_vault.vault.id
}

resource "azurerm_key_vault_secret" "destinations_otlp_password" {
  name         = "destinations-otlp-password"
  value        = var.destinations_otlp_password
  key_vault_id = azurerm_key_vault.vault.id
}

resource "azurerm_key_vault_secret" "fleetmanagement_password" {
  name         = "fleetmanagement-password"
  value        = var.fleetmanagement_password
  key_vault_id = azurerm_key_vault.vault.id
}
