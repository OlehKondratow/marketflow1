resource "kubernetes_network_policy_v1" "deny_cross_ns" {
  metadata {
    name      = "deny-cross-namespace"
    namespace = kubernetes_namespace.marketflow_dev.metadata[0].name
  }

  spec {
    pod_selector {}
    policy_types = ["Ingress", "Egress"]

    ingress {
      from {
        namespace_selector {
          match_labels = {
            environment = "dev"
          }
        }
      }
    }

    egress {
      to {
        namespace_selector {
          match_labels = {
            environment = "dev"
          }
        }
      }
    }
  }
}