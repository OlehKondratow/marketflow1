###########################################################################
# Module: role_assignments
# Назначает роли RBAC (Network Contributor, Key Vault Secrets Officer, AcrPull)
# с защитой от дубликатов
###########################################################################

variable "aks_principal_id"  { type = string }
variable "resource_group_id" { type = string }
variable "keyvault_id"       { type = string }
variable "acr_id"            { type = string }