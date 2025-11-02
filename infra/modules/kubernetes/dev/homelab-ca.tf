resource "kubernetes_secret" "homelab_ca" {
  metadata {
    name      = "homelab-ca"
    namespace = "cert-manager"
  }
  type = "kubernetes.io/tls"
  data = {
    "tls.crt" = base64decode(var.ca_crt_b64)
    "tls.key" = base64decode(var.ca_key_b64)
  }
}

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


resource "kubernetes_manifest" "test_cert" {
  manifest = {
    apiVersion = "cert-manager.io/v1"
    kind       = "Certificate"
    metadata = {
      name      = "test-cert"
      namespace = "test"
    }
    spec = {
      secretName  = "test-cert-tls"
      duration    = "2160h"
      renewBefore = "360h"
      subject = {
        organizations = ["MyOrg"]
      }
      commonName = "test-cert.ai.home"
      dnsNames   = ["test-cert.ai.home"]
      issuerRef = {
        name = "homelab-ca-issuer"
        kind = "ClusterIssuer"
      }
    }
  }

  depends_on = [kubernetes_manifest.homelab_ca_issuer]
}