###########################################################################
# Module: role_assignments
# Назначает роли RBAC (Network Contributor, Key Vault Secrets Officer, AcrPull)
# с защитой от дубликатов (ошибка 409 RoleAssignmentExists)
###########################################################################

data "azurerm_role_assignments" "existing_network" {
  filter {
    principal_id         = var.aks_principal_id
    role_definition_name = "Network Contributor"
    scope                = var.resource_group_id
  }
}

data "azurerm_role_assignments" "existing_keyvault" {
  filter {
    principal_id         = var.aks_principal_id
    role_definition_name = "Key Vault Secrets Officer"
    scope                = var.keyvault_id
  }
}

data "azurerm_role_assignments" "existing_acr" {
  filter {
    principal_id         = var.aks_principal_id
    role_definition_name = "AcrPull"
    scope                = var.acr_id
  }
}

###########################################################################
# 🔹 Создание ролей только если они отсутствуют
###########################################################################

resource "azurerm_role_assignment" "network_contributor" {
  count                = length(data.azurerm_role_assignments.existing_network.assignments) == 0 ? 1 : 0
  scope                = var.resource_group_id
  role_definition_name = "Network Contributor"
  principal_id         = var.aks_principal_id
  skip_service_principal_aad_check = true
}

resource "azurerm_role_assignment" "keyvault_officer" {
  count                = length(data.azurerm_role_assignments.existing_keyvault.assignments) == 0 ? 1 : 0
  scope                = var.keyvault_id
  role_definition_name = "Key Vault Secrets Officer"
  principal_id         = var.aks_principal_id
  skip_service_principal_aad_check = true
}

resource "azurerm_role_assignment" "acr_pull" {
  count                = length(data.azurerm_role_assignments.existing_acr.assignments) == 0 ? 1 : 0
  scope                = var.acr_id
  role_definition_name = "AcrPull"
  principal_id         = var.aks_principal_id
  skip_service_principal_aad_check = true
}
