###############################################################################
# Outputs for phase4-k8s
###############################################################################

output "cert_manager_status" {
  description = "Status of the cert-manager Helm release in the dev environment"
  value       = module.kubernetes_dev.cert_manager_status
}

output "ingress_dev_status" {
  description = "Status of the ingress controller in the dev environment"
  value       = module.kubernetes_dev.ingress_dev_status
}

output "homelab_ca_issuer_status" {
  description = "Name of the homelab ClusterIssuer in the dev environment"
  value       = module.kubernetes_dev.homelab_ca_issuer_status
}

output "marketflow_prod_namespace" {
  description = "The name of the marketflow production namespace"
  value       = module.kubernetes_prod.marketflow_prod_namespace
}

output "test_prod_namespace" {
  description = "The name of the test production namespace"
  value       = module.kubernetes_prod.test_prod_namespace
}

