provider "azurerm" {
  features {
    key_vault {
      purge_soft_delete_on_destroy = true
    }
    resource_group {
      prevent_deletion_if_contains_resources = false
    }
  }

  # This allows GitHub Actions to login without a password/secret
  use_oidc = true
}

# This retrieves the identity of the GitHub runner/Terraform process
data "azurerm_client_config" "current" {}

# ==============================================================================
# 1. DATA INFRASTRUCTURE
# ==============================================================================

resource "azurerm_resource_group" "data_rg" {
  name     = "firevault"
  location = "westeurope"
}

resource "azurerm_container_registry" "acr" {
  name                = "firevaultregistry"
  resource_group_name = azurerm_resource_group.data_rg.name
  location            = azurerm_resource_group.data_rg.location
  sku                 = "Basic"
  admin_enabled       = true
}

resource "azurerm_storage_account" "store" {
  name                     = "firevaultstore"
  resource_group_name      = azurerm_resource_group.data_rg.name
  location                 = azurerm_resource_group.data_rg.location
  account_tier             = "Standard"
  account_replication_type = "LRS"
}

resource "azurerm_key_vault" "vault" {
  name                        = "firevault-secrets"
  location                    = azurerm_resource_group.data_rg.location
  resource_group_name         = azurerm_resource_group.data_rg.name
  enabled_for_disk_encryption = true
  tenant_id                   = data.azurerm_client_config.current.tenant_id
  soft_delete_retention_days  = 7
  purge_protection_enabled    = true 
  sku_name                    = "standard"

  # Admin Access: Grants the GitHub Action runner full secret permissions
  access_policy {
    tenant_id          = data.azurerm_client_config.current.tenant_id
    object_id          = data.azurerm_client_config.current.object_id
    secret_permissions = ["Get", "List", "Set", "Delete", "Recover", "Backup", "Restore", "Purge"]
  }

  # App Access: Grants the AKS Identity permission to read secrets
  access_policy {
    tenant_id          = data.azurerm_client_config.current.tenant_id
    object_id          = azurerm_user_assigned_identity.app_identity.principal_id
    secret_permissions = ["Get", "List"]
  }
}

# ==============================================================================
# 2. AKS INFRASTRUCTURE
# ==============================================================================

resource "azurerm_resource_group" "aks_rg" {
  name     = "aks-resource-group"
  location = "westeurope"
}

resource "azurerm_user_assigned_identity" "app_identity" {
  name                = "firevault-app-identity"
  location            = azurerm_resource_group.aks_rg.location
  resource_group_name = azurerm_resource_group.aks_rg.name
}

resource "azurerm_kubernetes_cluster" "aks" {
  name                = "firevault-cluster"
  location            = azurerm_resource_group.aks_rg.location
  resource_group_name = azurerm_resource_group.aks_rg.name
  dns_prefix          = "firevault-dns"

  kubernetes_version = "1.32"
  sku_tier           = "Free"

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

provider "kubernetes" {
  host                   = azurerm_kubernetes_cluster.aks.kube_config.0.host
  client_certificate     = base64decode(azurerm_kubernetes_cluster.aks.kube_config.0.client_certificate)
  client_key             = base64decode(azurerm_kubernetes_cluster.aks.kube_config.0.client_key)
  cluster_ca_certificate = base64decode(azurerm_kubernetes_cluster.aks.kube_config.0.cluster_ca_certificate)
}

# ==============================================================================
# 3. ROLE ASSIGNMENTS
# ==============================================================================

# Allows the AKS Cluster to pull images from the ACR
resource "azurerm_role_assignment" "aks_acr_pull" {
  scope                = azurerm_container_registry.acr.id
  role_definition_name = "AcrPull"
  principal_id         = azurerm_kubernetes_cluster.aks.kubelet_identity[0].object_id
}

# Allows the GitHub Action Runner to manage the AKS Cluster
resource "azurerm_role_assignment" "github_actions_aks_user" {
  scope                = azurerm_kubernetes_cluster.aks.id
  role_definition_name = "Azure Kubernetes Service Cluster User Role"
  principal_id         = data.azurerm_client_config.current.object_id
}

# ==============================================================================
# 4. OUTPUTS
# ==============================================================================

output "get_credentials_command" {
  value = "az aks get-credentials --resource-group ${azurerm_resource_group.aks_rg.name} --name ${azurerm_kubernetes_cluster.aks.name}"
}

output "app_identity_client_id" {
  value = azurerm_user_assigned_identity.app_identity.client_id
}