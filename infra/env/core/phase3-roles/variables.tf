####################################
# phase3-roles variables
####################################

variable "subscription_id" {
  description = "Azure subscription ID."
  type        = string
}

variable "tenant_id" {
  description = "Azure Active Directory tenant ID."
  type        = string
}

variable "resource_group_id" {
  description = "Resource group ID where role assignments will be created."
  type        = string
}

variable "acr_id" {
  description = "Resource ID of the Azure Container Registry."
  type        = string
}

variable "keyvault_id" {
  description = "Resource ID of the Key Vault."
  type        = string
}

variable "aks_principal_id" {
  description = "The managed identity principal ID of the AKS cluster.  If omitted, the value will be read from the phase2 state file via terraform_remote_state."
  type        = string
  default     = ""
}

