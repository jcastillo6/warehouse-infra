resource "random_pet" "prefix" {}
resource "random_string" "random" {
  length           = 30
  special          = false
}

provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "az_resource_group" {
  name     = "${random_pet.prefix.id}-group"
  location = "East US"

  tags = {
    environment = "sandbox"
  }
}

resource "azurerm_container_registry" "az_registry" {
  name                = random_string.random.id
  resource_group_name = azurerm_resource_group.az_resource_group.name
  location            = azurerm_resource_group.az_resource_group.location
  sku                 = "Basic"
}

resource "azurerm_kubernetes_cluster" "az_aks" {
  name                = "${random_pet.prefix.id}-aks"
  location            = azurerm_resource_group.az_resource_group.location
  resource_group_name = azurerm_resource_group.az_resource_group.name
  dns_prefix          = "${random_pet.prefix.id}-k8s"
  kubernetes_version  = "1.26.3"

  default_node_pool {
    name            = "default"
    node_count      = 3
    vm_size         = "Standard_B2s"
    os_disk_size_gb = 30
  }

  service_principal {
    client_id     = var.appId
    client_secret = var.password
  }

  role_based_access_control_enabled = true

  tags = {
    environment = "sandbox"
  }
}

resource "azurerm_role_assignment" "az_role_assignment" {
  principal_id                     = azurerm_kubernetes_cluster.az_aks.service_principal[0].client_id
  role_definition_name             = "AcrPull"
  scope                            = azurerm_container_registry.az_registry.id
  skip_service_principal_aad_check = true
}