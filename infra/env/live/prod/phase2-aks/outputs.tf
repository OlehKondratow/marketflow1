###############################################################################
# Outputs exported from the AKS module to be consumed by later phases
###############################################################################

output "aks_cluster_name" {
  description = "The name of the AKS cluster."
  value       = module.aks.aks_cluster_name
}

output "aks_cluster_id" {
  description = "The resource ID of the AKS cluster."
  value       = module.aks.aks_cluster_id
}

output "aks_cluster_fqdn" {
  description = "The fully qualified domain name of the AKS cluster API server."
  value       = module.aks.aks_cluster_fqdn
}

output "aks_kube_admin_config" {
  description = "Kubeconfig credentials with admin privileges for the AKS cluster."
  value       = module.aks.aks_kube_admin_config
  sensitive   = true
}

output "aks_principal_id" {
  description = "The managed identity principal ID of the AKS cluster."
  value       = module.aks.aks_principal_id
}

