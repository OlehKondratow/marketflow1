###########################################################################
# Variables for Phase 3 – Role Assignments
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
  description = "ID группы ресурсов для назначения ролей"
  type        = string
}

variable "keyvault_id" {
  description = "ID Key Vault для назначения роли Secrets Officer"
  type        = string
}

variable "acr_id" {
  description = "ID Azure Container Registry для назначения роли AcrPull"
  type        = string
}

variable "aks_principal_id" {
  description = "Principal ID управляемой идентичности AKS (если не передаётся — будет взят из remote_state)"
  type        = string
  default     = ""
}
