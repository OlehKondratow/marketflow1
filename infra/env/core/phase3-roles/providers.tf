###########################################################################
# Provider configuration for AzureRM (Phase 3)
###########################################################################

terraform {
  required_providers {
    kubernetes = {
      source  = "hashicorp/kubernetes"
      version = ">= 2.30.0"
    }
    helm = {
      source  = "hashicorp/helm"
      version = ">= 2.12.1"
    }
  }
}

provider "azurerm" {
  features {}

  # Используем значения из variables.tf
  subscription_id = var.subscription_id
  tenant_id       = var.tenant_id
}
