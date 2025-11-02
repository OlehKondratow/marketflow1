resource "kubernetes_secret" "cloudflare_api_token" {
  metadata {
    name      = "cloudflare-api-token-secret"
    namespace = "cert-manager"
  }

  data = {
    api-token = var.cloudflare_api_token
  }
}

resource "kubernetes_manifest" "letsencrypt_prod" {
  manifest = {
    apiVersion = "cert-manager.io/v1"
    kind       = "ClusterIssuer"
    metadata = { name = "letsencrypt-prod" }
    spec = {
      acme = {
        email  = var.letsencrypt_email
        server = "https://acme-v02.api.letsencrypt.org/directory"
        privateKeySecretRef = { name = "letsencrypt-prod-account-key" }
        solvers = [{
          dns01 = {
            cloudflare = {
              email = var.cloudflare_email
              apiTokenSecretRef = {
                name = "cloudflare-api-token-secret"
                key  = "api-token"
              }
            }
          }
        }]
      }
    }
  }
}
