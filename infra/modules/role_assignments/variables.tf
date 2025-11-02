###########################################
# 🔧 Input variables for Role Assignments
###########################################

variable "resource_group_id" {
  type        = string
  description = "ID of the Azure Resource Group where roles are assigned"
}

variable "keyvault_id" {
  type        = string
  description = "Azure Key Vault resource ID"
}

variable "acr_id" {
  type        = string
  description = "Azure Container Registry resource ID"
}

variable "principal_id" {
  type        = string
  description = "Principal ID (object ID) of the Managed Identity for general roles"
}

variable "aks_principal_id" {
  type        = string
  description = "Principal ID (object ID) of the AKS Managed Identity for ACR access"
}

