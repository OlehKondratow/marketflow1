resource "kubernetes_namespace" "marketflow_prod" {
  metadata {
    name = "marketflow-prod"
  }
}

resource "kubernetes_namespace" "test_prod" {
  metadata {
    name = "test-prod"
  }
}
