###############################################################################
# Outputs exported from the AKS module to be consumed by later phases
###############################################################################

output "aks_cluster_name" {
  description = "The name of the AKS cluster."
  value       = azurerm_kubernetes_cluster.aks.name
}

output "aks_cluster_id" {
  description = "The resource ID of the AKS cluster."
  value       = azurerm_kubernetes_cluster.aks.id
}

output "aks_cluster_fqdn" {
  description = "The fully qualified domain name of the AKS cluster API server."
  value       = azurerm_kubernetes_cluster.aks.fqdn
}

output "aks_kube_admin_config" {
  description = "Kubeconfig credentials for the AKS cluster."
  value = {
    host                   = azurerm_kubernetes_cluster.aks.kube_config[0].host
    client_certificate     = azurerm_kubernetes_cluster.aks.kube_config[0].client_certificate
    client_key             = azurerm_kubernetes_cluster.aks.kube_config[0].client_key
    cluster_ca_certificate = azurerm_kubernetes_cluster.aks.kube_config[0].cluster_ca_certificate
    username               = azurerm_kubernetes_cluster.aks.kube_config[0].username
  }
  sensitive = true
}

output "aks_principal_id" {
  description = "The managed identity principal ID of the AKS cluster."
  value       = azurerm_kubernetes_cluster.aks.identity[0].principal_id
}

