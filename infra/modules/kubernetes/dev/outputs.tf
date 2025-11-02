output "cert_manager_status" {
  value       = helm_release.cert_manager.status
  description = "Status of the cert-manager Helm release"
}

output "ingress_dev_status" {
  value       = helm_release.ingress_nginx_dev.status
  description = "Status of the dev ingress controller"
}

output "homelab_ca_issuer_status" {
  value       = kubernetes_manifest.homelab_ca_issuer.manifest.metadata.name
  description = "Name of homelab ClusterIssuer"
}
