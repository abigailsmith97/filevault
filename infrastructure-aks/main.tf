provider "azurerm" {
  features {}
  subscription_id = "48740eb3-ae90-47df-9a7b-b7833ad9314e"
  tenant_id       = "34cc7ab5-fd16-446f-bd35-2d04775d2de1"
}

locals {
  external_rg_name = "firevault"
  acr_name         = "firevaultregistry"
  key_vault_name   = "firevault-secrets"
  aks_rg_name      = "aks-resource-group"
  location         = "West Europe"
}

data "azurerm_resource_group" "data_rg" {
  name = local.external_rg_name
}

data "azurerm_container_registry" "acr" {
  name                = local.acr_name
  resource_group_name = data.azurerm_resource_group.data_rg.name
}

data "azurerm_key_vault" "vault" {
  name                = local.key_vault_name
  resource_group_name = data.azurerm_resource_group.data_rg.name
}

resource "azurerm_resource_group" "aks_rg" {
  name     = local.aks_rg_name
  location = local.location
}

resource "azurerm_kubernetes_cluster" "aks" {
  name                = "firevault-cluster"
  location            = azurerm_resource_group.aks_rg.location
  resource_group_name = azurerm_resource_group.aks_rg.name
  dns_prefix          = "firevault-dns"
  
  # Updated to 1.32 to stay in the Free Tier GA window
  kubernetes_version  = "1.32" 
  sku_tier            = "Free"

  default_node_pool {
    name       = "default"
    node_count = 1
    vm_size    = "Standard_B2s_v2"
  }

  identity {
    type         = "UserAssigned"
    identity_ids = [azurerm_user_assigned_identity.app_identity.id]
  }

  key_vault_secrets_provider {
    secret_rotation_enabled = true
  }
}

resource "azurerm_user_assigned_identity" "app_identity" {
  name                = "firevault-app-identity"
  location            = azurerm_resource_group.aks_rg.location
  resource_group_name = azurerm_resource_group.aks_rg.name
}

resource "azurerm_role_assignment" "aks_acr_pull" {
  scope                = data.azurerm_container_registry.acr.id
  role_definition_name = "AcrPull"
  principal_id         = azurerm_kubernetes_cluster.aks.kubelet_identity[0].object_id
}

output "get_credentials_command" {
  value = "az aks get-credentials --resource-group ${azurerm_resource_group.aks_rg.name} --name ${azurerm_kubernetes_cluster.aks.name}"
}

resource "azurerm_role_assignment" "github_actions_aks_user" {
  scope                = azurerm_kubernetes_cluster.aks.id
  role_definition_name = "Azure Kubernetes Service Cluster User Role"
  principal_id         = "44476512-9f20-47ce-b3e2-e2afbf378092"
}

output "app_identity_client_id" {
  value = azurerm_user_assigned_identity.app_identity.client_id
}