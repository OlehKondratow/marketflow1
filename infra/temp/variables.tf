variable "location" {
  description = "Azure region"
  default     = "westeurope"
}

variable "prefix" {
  description = "Prefix for resources"
  default     = "marketflow"
}

variable "subscription_id" {
  type        = string
  description = "Azure subscription ID"
}

variable "tenant_id" {
  type        = string
  description = "Azure tenant ID"
}

variable "project_name" {
  description = "Project name prefix used for all resources"
  type        = string
  default     = "marketflow"
}

variable "user_object_id" {
  description = "Azure AD object ID of user for KeyVault access (role assignment)"
  type        = string
}

variable "resource_group_name" {
  type        = string
  description = "Azure Resource Group for the AKS cluster"
}

variable "environment" {
  type    = string
  default = "dev"
}

variable "office_ip" {
  type        = string
  description = "Public static IP address of the office for dev ingress access"
}


variable "log_analytics_id" {
  type        = string
  description = "Log Analytics Workspace ID (optional)"
  default     = ""
}

variable "ca_crt_b64" {
  type        = string
  description = "Base64-encoded CA certificate"
}

variable "ca_key_b64" {
  type        = string
  sensitive   = true
  description = "Base64-encoded CA private key"
}

variable "prod_ingress_ip" { type = string }
variable "cloudflare_email" { type = string }

variable "cloudflare_api_token" {
  type      = string
  sensitive = true
}

variable "letsencrypt_email" { type = string }
variable "dev_ingress_ip" { type = string }

variable "disable_kubernetes_providers" {
  type        = bool
  description = "Disable Kubernetes and Helm providers during destroy if cluster is deleted"
  default     = false
}