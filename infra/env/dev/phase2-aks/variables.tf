variable "subscription_id" {
  description = "Azure subscription ID."
  type        = string
}

variable "tenant_id" {
  description = "Azure Active Directory tenant ID."
  type        = string
}

variable "project_name" {
  description = "Project name used as a prefix for resources."
  type        = string
}

variable "resource_group_name" {
  description = "Name of the resource group where the AKS cluster will be deployed."
  type        = string
}

variable "location" {
  description = "Azure region for AKS deployment."
  type        = string
}

variable "acr_id" {
  description = "Resource ID of the Azure Container Registry to attach to AKS."
  type        = string
}

variable "subnet_id" {
  description = "The ID of the subnet for the AKS node pool."
  type        = string
}

