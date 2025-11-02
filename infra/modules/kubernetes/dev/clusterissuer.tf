resource "kubernetes_manifest" "homelab_ca_issuer" {
  manifest = {
    apiVersion = "cert-manager.io/v1"
    kind       = "ClusterIssuer"
    metadata = {
      name = "homelab-ca-issuer"
    }
    spec = {
      ca = {
        secretName = "homelab-ca"
      }
    }
  }

  depends_on = [kubernetes_secret.homelab_ca]
}