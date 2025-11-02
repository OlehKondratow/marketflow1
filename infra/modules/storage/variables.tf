variable "project_name" {
  type        = string
  description = "Project name prefix for Azure Storage"
}

variable "resource_group_name" {
  type        = string
  description = "Resource group name where Storage Account will be created"
}

variable "location" {
  type        = string
  description = "Azure region"
}

variable "environment" {
  type        = string
  description = "Deployment environment (e.g., dev, prod)"
}


variable "aks_principal_id" {
  description = "Managed Identity (Principal ID) of AKS cluster"
  type        = string
}
