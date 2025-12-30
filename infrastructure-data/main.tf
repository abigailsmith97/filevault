provider "azurerm" {
  features {
    key_vault {
      purge_soft_delete_on_destroy = true 
    }
  }
  # This line fixes the "subscription ID could not be determined" error
  subscription_id = "48740eb3-ae90-47df-9a7b-b7833ad9314e"
}

data "azurerm_client_config" "current" {}

# 1. The Persistent Resource Group
resource "azurerm_resource_group" "data_rg" {
  name     = "firevault"
  location = "westeurope"
}

# 2. Container Registry (Keep your images safe)
resource "azurerm_container_registry" "acr" {
  name                = "firevaultregistry"
  resource_group_name = azurerm_resource_group.data_rg.name
  location            = azurerm_resource_group.data_rg.location
  sku                 = "Basic"
  admin_enabled       = true
}

# 3. Key Vault (The new addition!)
resource "azurerm_key_vault" "vault" {
  name                        = "firevault-secrets"
  location                    = azurerm_resource_group.data_rg.location
  resource_group_name         = azurerm_resource_group.data_rg.name
  enabled_for_disk_encryption = true
  tenant_id                   = data.azurerm_client_config.current.tenant_id
  soft_delete_retention_days  = 7
  purge_protection_enabled    = false
  sku_name                    = "standard"

  access_policy {
    tenant_id = data.azurerm_client_config.current.tenant_id
    object_id = data.azurerm_client_config.current.object_id

    secret_permissions = [
      "Get", "List", "Set", "Delete", "Recover", "Backup", "Restore", "Purge"
    ]
  }
}

# 4. The Existing Storage Account (Adopting the stranger)
resource "azurerm_storage_account" "store" {
  name                     = "firevaultstore"
  resource_group_name      = azurerm_resource_group.data_rg.name
  location                 = azurerm_resource_group.data_rg.location
  account_tier             = "Standard"
  account_replication_type = "LRS" # Assuming Standard_LRS, adjust if needed
}