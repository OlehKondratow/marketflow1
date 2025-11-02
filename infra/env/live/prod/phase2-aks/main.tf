terraform {
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "~> 3.0"
    }
  }
}

# Phase 2: AKS cluster
module "aks" {
  source              = "../modules/aks"

  project_name        = var.project_name
  resource_group_name = var.resource_group_name
  location            = var.location
  acr_id              = var.acr_id

  # В одном кластере prod и dev могут использовать одну и ту же подсеть
  subnet_prod_id      = var.subnet_id
  subnet_dev_id       = var.subnet_id
}

