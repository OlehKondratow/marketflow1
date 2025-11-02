resource "kubernetes_network_policy_v1" "allow_ingress_prod" {
  metadata {
    name      = "allow-ingress-from-ingress-prod"
    namespace = kubernetes_namespace.marketflow_prod.metadata[0].name
  }

  spec {
    pod_selector {}

    policy_types = ["Ingress"]

    ingress {
      from {
        namespace_selector {
          match_labels = {
            name = "marketflow-prod"
          }
        }
      }

      from {
        namespace_selector {
          match_labels = {
            name = "ingress-prod"
          }
        }
      }
    }
  }
}
