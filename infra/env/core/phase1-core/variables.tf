#############################################
# Variables for live/prod phase1-core
#############################################

variable "subscription_id" {
  description = "Azure subscription ID"
  type        = string
}

variable "tenant_id" {
  description = "Azure AD tenant ID"
  type        = string
}

variable "project_name" {
  description = "Project or system name used as a prefix for resources"
  type        = string
}

variable "resource_group_name" {
  description = "Name of the resource group for the live/prod environment"
  type        = string
}

variable "location" {
  description = "Azure region where resources will be deployed"
  type        = string
}

variable "office_ip" {
  description = "CIDR-formatted office IP used to restrict dev ingress"
  type        = string
}
