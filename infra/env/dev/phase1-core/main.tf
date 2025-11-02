###############################################################################
# phase1-core: deploy foundational Azure resources
#
# This module provisions the baseline infrastructure needed by the rest of
# the MarketFlow stack.  It creates the resource group, virtual network and
# subnets, an Azure Container Registry, an EventHub namespace, and a Key
# Vault.  These resources are referenced by later phases to build out the
# AKS cluster and Kubernetes components.
###############################################################################

# Network (VNet + subnets + NSG)
module "network" {
  source  = "../../../modules/network"

  prefix    = var.project_name
  location  = var.location
  office_ip = var.office_ip
}

# Azure Container Registry
module "acr" {
  source = "../../../modules/acr"

  project_name        = var.project_name
  resource_group_name = module.network.resource_group_name
  location            = var.location
}

# Event Hub namespace and topics
module "eventhub" {
  source = "../../../modules/eventhub"

  project_name        = var.project_name
  resource_group_name = module.network.resource_group_name
  location            = var.location
}

# Key Vault for secrets management
module "keyvault" {
  source = "../../../modules/keyvault"

  project_name        = var.project_name
  resource_group_name = module.network.resource_group_name
  location            = var.location
  tenant_id           = var.tenant_id
}

