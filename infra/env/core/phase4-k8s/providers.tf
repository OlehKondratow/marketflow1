###############################################################################
# Provider configuration for phase4-k8s
###############################################################################

terraform {
  required_providers {
    azurerm    = { source = "hashicorp/azurerm",    version = "~> 3.0" }
    kubernetes = { source = "hashicorp/kubernetes", version = "~> 2.0" }
    helm       = { source = "hashicorp/helm",       version = "~> 2.0" }
  }
}

provider "azurerm" {
  subscription_id = var.subscription_id
  tenant_id       = var.tenant_id
  features {}
}

provider "kubernetes" {
  host                   = local.kube_host != "" ? local.kube_host : null
  client_certificate     = local.kube_client_certificate != "" ? local.kube_client_certificate : null
  client_key             = local.kube_client_key != "" ? local.kube_client_key : null
  cluster_ca_certificate = local.kube_cluster_ca_certificate != "" ? local.kube_cluster_ca_certificate : null
  config_path            = local.kube_host == "" ? pathexpand("~/.kube/config") : null
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

