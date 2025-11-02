provider "azurerm" {
  features {
    resource_group {
      prevent_deletion_if_contains_resources = false
    }    
  }
  subscription_id = var.subscription_id
  tenant_id       = var.tenant_id
}

locals {
  kube_host                   = try(module.aks.aks_kube_admin_config["host"], "")
  kube_client_certificate     = try(base64decode(module.aks.aks_kube_admin_config["client_certificate"]), "")
  kube_client_key             = try(base64decode(module.aks.aks_kube_admin_config["client_key"]), "")
  kube_cluster_ca_certificate = try(base64decode(module.aks.aks_kube_admin_config["cluster_ca_certificate"]), "")
}

provider "kubernetes" {
  host                   = local.kube_host != "" ? local.kube_host : null
  client_certificate     = local.kube_client_certificate != "" ? local.kube_client_certificate : null
  client_key             = local.kube_client_key != "" ? local.kube_client_key : null
  cluster_ca_certificate = local.kube_cluster_ca_certificate != "" ? local.kube_cluster_ca_certificate : null

  # fallback — если модуль AKS ещё не применён
  config_path = local.kube_host == "" ? pathexpand("~/.kube/config") : null
}

provider "helm" {
  kubernetes = {
    host                   = local.kube_host != "" ? local.kube_host : null
    client_certificate     = local.kube_client_certificate != "" ? local.kube_client_certificate : null
    client_key             = local.kube_client_key != "" ? local.kube_client_key : null
    cluster_ca_certificate = local.kube_cluster_ca_certificate != "" ? local.kube_cluster_ca_certificate : null
    config_path            = local.kube_host == "" ? pathexpand("~/.kube/config") : null
  }
}