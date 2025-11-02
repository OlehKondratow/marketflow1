# Deployment
resource "kubernetes_deployment" "httpbin" {
  metadata {
    name      = "httpbin"
    namespace = kubernetes_namespace.marketflow_prod.metadata[0].name
    labels = {
      app = "httpbin"
    }
  }

  spec {
    replicas = 1
    selector {
      match_labels = {
        app = "httpbin"
      }
    }

    template {
      metadata {
        labels = {
          app = "httpbin"
        }
      }

      spec {
        container {
          name  = "httpbin"
          image = "kennethreitz/httpbin"
          port {
            container_port = 80
          }
        }
      }
    }
  }
}

# Service
resource "kubernetes_service" "httpbin" {
  metadata {
    name      = "httpbin"
    namespace = kubernetes_namespace.marketflow_prod.metadata[0].name
  }

  spec {
    selector = {
      app = "httpbin"
    }

    port {
      port        = 80
      target_port = 80
    }

    type = "ClusterIP"
  }
}

# Ingress
resource "kubernetes_ingress_v1" "httpbin" {
  metadata {
    name      = "httpbin"
    namespace = kubernetes_namespace.marketflow_prod.metadata[0].name
    annotations = {
      "kubernetes.io/ingress.class"    = "nginx-prod"
      "cert-manager.io/cluster-issuer" = "letsencrypt-prod"
    }
  }

  spec {
    ingress_class_name = "nginx-prod"
    rule {
      host = "httpbin.okondratov.online"
      http {
        path {
          path      = "/"
          path_type = "Prefix"
          backend {
            service {
              name = kubernetes_service.httpbin.metadata[0].name
              port {
                number = 80
              }
            }
          }
        }
      }
    }

    tls {
      hosts       = ["httpbin.okondratov.online"]
      secret_name = "httpbin-prod-tls"
    }
  }

  depends_on = [helm_release.ingress_nginx_prod]
}
