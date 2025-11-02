variable "project_name" {
  description = "Project or system name (e.g., marketflow0)"
  type        = string
}

variable "resource_group_name" {
  description = "Name of the resource group"
  type        = string
}

variable "location" {
  description = "Azure region for deployment"
  type        = string
}

variable "environment" {
  description = "Deployment environment (e.g., dev, prod)"
  type        = string
}

variable "office_ip" {
  description = "CIDR-formatted IP of the office network (e.g., 185.100.200.10/32)"
  type        = string
}
