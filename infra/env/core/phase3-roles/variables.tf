###########################################################################
# Input variables for Phase 3
###########################################################################

variable "subscription_id" {
  description = "Azure Subscription ID"
  type        = string
}

variable "tenant_id" {
  description = "Azure Tenant ID"
  type        = string
}

variable "resource_group_id" {
  description = "ID группы ресурсов, где будет назначена роль Network Contributor"
  type        = string
}

variable "keyvault_id" {
  description = "ID Key Vault, где будет назначена роль Key Vault Secrets Officer"
  type        = string
}

variable "acr_id" {
  description = "ID Azure Container Registry, где будет назначена роль AcrPull"
  type        = string
}

variable "aks_principal_id" {
  description = "Principal ID управляемой идентичности AKS (если не задан — берётся из состояния фазы 2)"
  type        = string
  default     = ""
}
