###########################################
# 🔐 Role Assignments for AKS Identity
###########################################

# Получаем информацию о текущем аккаунте
data "azurerm_client_config" "current" {}

###########################################
# 🌐 Network Contributor — доступ к сети
###########################################
resource "azurerm_role_assignment" "network_contributor" {
  scope                = var.resource_group_id
  role_definition_name = "Network Contributor"
  principal_id         = var.principal_id
}

###########################################
# 🔑 Key Vault Secrets Officer — доступ к секретам
###########################################
resource "azurerm_role_assignment" "keyvault_officer" {
  scope                = var.keyvault_id
  role_definition_name = "Key Vault Secrets Officer"
  principal_id         = var.principal_id
}

###########################################
# 🐳 AcrPull — разрешает AKS тянуть образы из ACR
###########################################
resource "azurerm_role_assignment" "acr_pull" {
  scope                = var.acr_id
  role_definition_name = "AcrPull"
  principal_id         = var.aks_principal_id
}
