output "resource_group_name" {
  description = "Azure resource group name"
  value       = azurerm_resource_group.az_resource_group.name
}

output "kubernetes_registry_name" {
  description = "AKS registry name"
  value       = azurerm_container_registry.az_registry.name
}

output "kubernetes_cluster_name" {
  description = "AKS cluster name"
  value       = azurerm_kubernetes_cluster.az_aks.name
}