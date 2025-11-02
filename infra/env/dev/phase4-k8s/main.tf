terraform {
  required_providers {
    azurerm    = { source = "hashicorp/azurerm",    version = "~> 3.0" }
    kubernetes = { source = "hashicorp/kubernetes", version = "~> 2.0" }
    helm       = { source = "hashicorp/helm",       version = "~> 2.0" }
  }
}

###########################################################################
# Phase 4: Kubernetes add-ons and namespaces
#
# Деплой ingress‑контроллеров, cert-manager и неймспейсов dev/prod.
# К kubeconfig подключаемся, читая `aks_kube_admin_config` из state
# phase2-aks. Это позволяет автоматически конфигурировать кластер, не
# передавая креденшелы вручную.
###########################################################################

data "terraform_remote_state" "phase2_aks" {
  backend = "local"
  config = {
    path = "../phase2-aks/terraform.tfstate"
  }
}

locals {
  kube_host                   = try(data.terraform_remote_state.phase2_aks.outputs.aks_kube_admin_config["host"], "")
  kube_client_certificate     = try(base64decode(data.terraform_remote_state.phase2_aks.outputs.aks_kube_admin_config["client_certificate"]), "")
  kube_client_key             = try(base64decode(data.terraform_remote_state.phase2_aks.outputs.aks_kube_admin_config["client_key"]), "")
  kube_cluster_ca_certificate = try(base64decode(data.terraform_remote_state.phase2_aks.outputs.aks_kube_admin_config["cluster_ca_certificate"]), "")
}

module "kubernetes_dev" {
  source  = "../modules/kubernetes/dev"

  resource_group_name = var.resource_group_name
  dev_ingress_ip      = var.dev_ingress_ip
  ca_crt_b64          = var.ca_crt_b64
  ca_key_b64          = var.ca_key_b64
  domain              = var.domain

  depends_on = [data.terraform_remote_state.phase2_aks]
}

module "kubernetes_prod" {
  source = "../modules/kubernetes/prod"

  resource_group_name  = var.resource_group_name
  prod_ingress_ip      = var.prod_ingress_ip
  cloudflare_api_token = var.cloudflare_api_token
  cloudflare_email     = var.cloudflare_email
  letsencrypt_email    = var.letsencrypt_email
  domain               = var.domain

  depends_on = [data.terraform_remote_state.phase2_aks]
}

