resource "azurerm_resource_group" "rg" {
  name     = "${var.project_name}-rg"
  location = var.location
}

module "network" {
  source              = "../../modules/azure/network"
  project_name        = var.project_name
  resource_group_name = azurerm_resource_group.rg.name
  location            = var.location
  environment         = var.environment
  office_ip           = var.office_ip
}

module "acr" {
  source              = "../../modules/azure/acr"
  resource_group_name = azurerm_resource_group.rg.name
  location            = var.location
  project_name        = var.project_name
  environment         = var.environment

}

module "keyvault" {
  source              = "../../modules/azure/keyvault"
  project_name        = var.project_name
  resource_group_name = azurerm_resource_group.rg.name
  location            = var.location
  tenant_id           = var.tenant_id
  environment         = var.environment
  depends_on          = [module.acr]
}

module "aks" {
  source              = "../../modules/azure/aks"
  project_name        = var.project_name
  resource_group_name = azurerm_resource_group.rg.name
  location            = var.location
  environment         = var.environment
  subnet_prod_id      = module.network.subnet_prod_id
  subnet_dev_id       = module.network.subnet_dev_id
  acr_id              = module.acr.acr_id
  depends_on          = [module.network, module.keyvault]
}

module "storage" {
  source              = "../../modules/azure/storage"
  project_name        = var.project_name
  resource_group_name = azurerm_resource_group.rg.name
  aks_principal_id    = module.aks.aks_identity_principal_id
  location            = var.location
  environment         = var.environment

  depends_on = [module.aks]
}

#module "kubernetes_dev" {
#  source              = "../../modules/kubernetes/dev"
#  resource_group_name = var.resource_group_name
#  dev_ingress_ip      = var.dev_ingress_ip
#  ca_crt_b64          = var.ca_crt_b64
#  ca_key_b64          = var.ca_key_b64

#  domain               = "ai.home"
#  providers = {
#    kubernetes = kubernetes
#    helm       = helm
#  }
#  depends_on = [module.aks]
#}

#module "kubernetes_prod" {
#  source              = "../../modules/kubernetes/prod"
#  prod_ingress_ip     = var.prod_ingress_ip
#  resource_group_name = var.resource_group_name

#  cloudflare_email     = var.cloudflare_email
#  cloudflare_api_token = var.cloudflare_api_token
#  letsencrypt_email    = var.letsencrypt_email
#  domain               = "marketflow.okondratov.online"
#  providers = {
#    kubernetes = kubernetes
#    helm       = helm
#  }
#
#  depends_on = [module.aks]
#}


#module "role_assignments" {
#  source = "../../modules/phase/role_assignments"

#  resource_group_id = azurerm_resource_group.rg.id
#  keyvault_id       = module.keyvault.keyvault_id
#  acr_id            = module.acr.acr_id

#  #AKS Managed Identity
#  principal_id     = module.aks.aks_identity_principal_id
#  aks_principal_id = module.aks.aks_identity_principal_id

#  depends_on = [module.aks]
#}

#module "eventhub" {
#  source              = "../../modules/phase/eventhub"
#  project_name        = var.project_name
#  location            = var.location
#  resource_group_name = azurerm_resource_group.rg.name
#  environment         = var.environment
#}