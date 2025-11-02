##############################################################
# Namespaces for DEV environment
# (marketflow-dev — основное приложение, test — для отладки)
##############################################################

# Основное пространство для всех dev-приложений
resource "kubernetes_namespace" "marketflow_dev" {
  metadata {
    name = "marketflow-dev"
    labels = {
      environment = "dev"
      project     = "marketflow"
      managed_by  = "terraform"
    }
  }
}

# Дополнительное тестовое пространство (если нужно)
resource "kubernetes_namespace" "test" {
  metadata {
    name = "test"
    labels = {
      environment = "test"
      project     = "marketflow"
      managed_by  = "terraform"
    }
  }
}
