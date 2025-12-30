provider "azurerm" {
  features {}
}

# --- LOOKUPS (Reading Layer 1) ---

# 1. Find the Persistent Resource Group
data "azurerm_resource_group" "data_rg" {
  name = "firevault"
}

# 2. Find the Registry
data "azurerm_container_registry" "acr" {
  name                = "firevaultregistry"
  resource_group_name = data.azurerm_resource_group.data_rg.name
}

# 3. Find the Key Vault
data "azurerm_key_vault" "vault" {
  name                = "firevault-secrets"
  resource_group_name = data.azurerm_resource_group.data_rg.name
}

# --- RESOURCES (Creating Layer 2) ---

# 4. Create a separate group for AKS
resource "azurerm_resource_group" "aks_rg" {
  name     = "aks-resource-group"
  location = "West Europe"
}

# 5. The Cluster
resource "azurerm_kubernetes_cluster" "aks" {
  name                = "firevault-cluster"
  location            = azurerm_resource_group.aks_rg.location
  resource_group_name = azurerm_resource_group.aks_rg.name
  dns_prefix          = "firevault-dns"
  kubernetes_version  = "1.33"

  default_node_pool {
    name       = "default"
    node_count = 1
    vm_size    = "Standard_B2s_v2"
  }

  identity {
    type = "SystemAssigned"
  }
}

# 6. Permission: Allow AKS to pull images from ACR
resource "azurerm_role_assignment" "aks_acr_pull" {
  scope                = data.azurerm_container_registry.acr.id
  role_definition_name = "AcrPull"
  principal_id         = azurerm_kubernetes_cluster.aks.kubelet_identity[0].object_id
}

# 7. Output the command to connect to AKS
output "get_credentials_command" {
  value = "az aks get-credentials --resource-group ${azurerm_resource_group.aks_rg.name} --name ${azurerm_kubernetes_cluster.aks.name}"
}