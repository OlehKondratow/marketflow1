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

# ==============================================================================
# KEDA Network Policies
#
# These policies are required for KEDA to function correctly when a default
# network policy is in place (e.g., when using 'azure' or 'calico' CNI).
# These policies should be applied to the 'keda' namespace.
# ==============================================================================

# Policy 1: Allow all egress traffic from the KEDA namespace.
# This is necessary for KEDA's scalers to connect to external event sources
# like Azure Event Hubs, Kafka, etc.
resource "kubernetes_network_policy_v1" "keda_allow_egress" {
  metadata {
    name      = "keda-allow-all-egress"
    namespace = "keda" # Assumes KEDA is installed in the 'keda' namespace
  }

  spec {
    pod_selector {}
    policy_types = ["Egress"]
    egress {
      # Allow all outbound traffic
      to = [{}]
    }
  }
}

# Policy 2: Allow ingress traffic to the KEDA metrics server.
# This allows the Kubernetes Horizontal Pod Autoscaler (HPA) and control plane
# to scrape metrics from KEDA for making scaling decisions.
resource "kubernetes_network_policy_v1" "keda_allow_metrics_ingress" {
  metadata {
    name      = "keda-allow-metrics-ingress"
    namespace = "keda" # Assumes KEDA is installed in the 'keda' namespace
  }

  spec {
    # Apply this policy only to the KEDA metrics server pods
    pod_selector {
      match_labels = {
        app = "keda-metrics-apiserver"
      }
    }
    policy_types = ["Ingress"]
    ingress {
      # Allow ingress from any pod in any namespace. This is a simple way
      # to ensure the control plane components can reach the metrics server.
      from {
        namespace_selector = {}
      }
    }
  }
}
