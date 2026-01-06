provider "azurerm" {
  features {
    key_vault {
      purge_soft_delete_on_destroy = true
    }
    resource_group {
      prevent_deletion_if_contains_resources = false
    }
  }

  subscription_id = var.subscription_id
  tenant_id       = var.tenant_id
  client_id       = var.client_id
  client_secret   = var.client_secret
}

data "azurerm_client_config" "current" {}

# ==============================================================================
# 1. DATA INFRASTRUCTURE (Resource Group, ACR, KV, Storage)
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
  purge_protection_enabled    = true # Careful with this, it prevents force delete
  sku_name                    = "standard"

  # Admin Access (You/Terraform)
  access_policy {
    tenant_id          = data.azurerm_client_config.current.tenant_id
    object_id          = data.azurerm_client_config.current.object_id
    secret_permissions = ["Get", "List", "Set", "Delete", "Recover", "Backup", "Restore", "Purge"]
  }

  # App Access (The Identity created below)
  access_policy {
    tenant_id          = data.azurerm_client_config.current.tenant_id
    object_id          = azurerm_user_assigned_identity.app_identity.principal_id # DIRECT REFERENCE
    secret_permissions = ["Get", "List"]
  }
}

# ==============================================================================
# 2. AKS INFRASTRUCTURE (Resource Group, Cluster, Identity)
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

  # Assigning the identity to the cluster control plane
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

resource "azurerm_role_assignment" "aks_acr_pull" {
  scope                = azurerm_container_registry.acr.id
  role_definition_name = "AcrPull"
  principal_id         = azurerm_kubernetes_cluster.aks.kubelet_identity[0].object_id
}

resource "azurerm_role_assignment" "github_actions_aks_user" {
  scope                = azurerm_kubernetes_cluster.aks.id
  role_definition_name = "Azure Kubernetes Service Cluster User Role"
  principal_id         = "44476512-9f20-47ce-b3e2-e2afbf378092"
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

data "kubernetes_secret_v1" "firevault_k8s_secret" {
  metadata {
    name = "firevault-k8s-secret"
  }
}