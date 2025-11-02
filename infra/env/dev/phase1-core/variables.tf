####################################
# phase1-core variables
#
# These variables configure the Azure subscription and naming for the
# foundational resources.  Values should be provided via a tfvars file
# (e.g. infra/terraform.tfvars) or via the command line.
####################################

variable "subscription_id" {
  description = "The Azure subscription ID under which resources will be deployed."
  type        = string
}

variable "tenant_id" {
  description = "The Azure Active Directory tenant ID."
  type        = string
}

variable "project_name" {
  description = "A short name used as a prefix for resource naming."
  type        = string
}

variable "location" {
  description = "Azure region where resources will be created."
  type        = string
}

variable "office_ip" {
  description = "CIDR block of the office IP used to restrict dev ingress."
  type        = string
}

