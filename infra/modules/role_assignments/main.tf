###########################################################################
# Module: role_assignments (без проверки существования)
# Создаёт роли RBAC: Network Contributor / Key Vault Secrets Officer / AcrPull
###########################################################################

variable "aks_principal_id" {
  type        = string
  description = "Principal ID управляемой идентичности AKS"
}

variable "resource_group_id" {
  type        = string
  description = "ID Resource Group, где назначаем роль Network Contributor"
}

variable "keyvault_id" {
  type        = string
  description = "ID Key Vault, где назначаем роль Key Vault Secrets Officer"
}

variable "acr_id" {
  type        = string
  description = "ID ACR, где назначаем роль AcrPull"
}

###########################################################################
# 🔹 Назначение ролей (без проверки существования)
###########################################################################

data "external" "network" {
  program = ["bash", "${path.module}/check_role.sh", var.resource_group_id, var.aks_principal_id]
}

data "external" "keyvault" {
  program = ["bash", "${path.module}/check_role.sh", var.keyvault_id, var.aks_principal_id]
}

data "external" "acr" {
  program = ["bash", "${path.module}/check_role.sh", var.acr_id, var.aks_principal_id]
}

resource "azurerm_role_assignment" "network_contributor" {
  count                = data.external.network.result.exists == "false" ? 1 : 0
  scope                = var.resource_group_id
  role_definition_name = "Network Contributor"
  principal_id         = var.aks_principal_id
  skip_service_principal_aad_check = true
}

resource "azurerm_role_assignment" "keyvault_officer" {
  count                = data.external.keyvault.result.exists == "false" ? 1 : 0
  scope                = var.keyvault_id
  role_definition_name = "Key Vault Secrets Officer"
  principal_id         = var.aks_principal_id
  skip_service_principal_aad_check = true
}

resource "azurerm_role_assignment" "acr_pull" {
  count                = data.external.acr.result.exists == "false" ? 1 : 0
  scope                = var.acr_id
  role_definition_name = "AcrPull"
  principal_id         = var.aks_principal_id
  skip_service_principal_aad_check = true
}

