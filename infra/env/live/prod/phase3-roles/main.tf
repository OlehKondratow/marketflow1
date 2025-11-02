terraform {
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "~> 3.0"
    }
  }
}

###########################################################################
# Phase 3: Role assignments for AKS managed identity
#
# Этот конфиг назначает RBAC‑роли (Network Contributor, Key Vault Secrets
# Officer, AcrPull) для управляемой идентичности AKS. Идентификатор
# principal можно передать вручную (переменная `aks_principal_id`) —
# полезно при первом запуске. Далее его можно читать из state файла
# фазы 2 через data "terraform_remote_state".
###########################################################################

# Чтение principal ID из состояния phase2-aks (local backend).
data "terraform_remote_state" "phase2_aks" {
  backend = "local"
  config = {
    path = "../phase2-aks/terraform.tfstate"
  }
}

locals {
  # Приоритет: сначала берём значение из переменной, затем из remote_state.
  resolved_principal_id = var.aks_principal_id != "" ? var.aks_principal_id : try(data.terraform_remote_state.phase2_aks.outputs.aks_principal_id, "")
}

module "role_assignments" {
  source = "../modules/role_assignments"

  # Передаём ID нужных ресурсов (на первом запуске вручную,
  # потом можно заменить на terraform_remote_state аналогично principal).
  resource_group_id = var.resource_group_id
  acr_id            = var.acr_id
  keyvault_id       = var.keyvault_id

  # Идентификатор управляемой идентичности, которому назначаем роли.
  principal_id      = local.resolved_principal_id
  aks_principal_id  = local.resolved_principal_id
}

