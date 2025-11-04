###########################################################################
# Phase 3: Role assignments for AKS managed identity
#
# Назначает RBAC-роли (Network Contributor, Key Vault Secrets Officer, AcrPull)
# для управляемой идентичности кластера AKS.
###########################################################################

data "terraform_remote_state" "phase2_aks" {
  backend = "local"
  config = {
    path = "../phase2-aks/terraform.tfstate"
  }
}

locals {
  resolved_principal_id = (
    var.aks_principal_id != "" ?
    var.aks_principal_id :
    try(data.terraform_remote_state.phase2_aks.outputs.aks_principal_id, "")
  )
}

# ─────────────────────────────────────────────────────────────────────────────
# Вызов модуля role_assignments
# ─────────────────────────────────────────────────────────────────────────────
module "role_assignments" {
  source = "../../../modules/role_assignments"

  aks_principal_id  = local.resolved_principal_id
  resource_group_id = var.resource_group_id
  keyvault_id       = var.keyvault_id
  acr_id            = var.acr_id
}

