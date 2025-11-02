output "marketflow_prod_namespace" {
  value = kubernetes_namespace.marketflow_prod.metadata[0].name
}

output "test_prod_namespace" {
  value = kubernetes_namespace.test_prod.metadata[0].name
}
