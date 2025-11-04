#############################################
# Variables for phase4-k8s
#############################################

variable "subscription_id" {
  description = "Azure subscription ID. Required by the azurerm provider."
  type        = string
}

variable "tenant_id" {
  description = "Azure Active Directory tenant ID. Required by the azurerm provider."
  type        = string
}

variable "resource_group_name" {
  description = "Name of the Azure Resource Group used by the AKS cluster and load balancer."
  type        = string
}

variable "dev_ingress_ip" {
  description = "Static IP address to assign to the ingress controller in the dev namespace."
  type        = string
}

variable "prod_ingress_ip" {
  description = "Static IP address to assign to the ingress controller in the prod namespace."
  type        = string
}

variable "ca_crt_b64" {
  description = "Base64‑encoded certificate for the homelab CA used in dev."
  type        = string
}

variable "ca_key_b64" {
  description = "Base64‑encoded private key for the homelab CA used in dev."
  type        = string
}

variable "domain" {
  description = "Base domain name used for ingress hosts (e.g. okondratov.online)."
  type        = string
}

variable "cloudflare_api_token" {
  description = "API token for Cloudflare DNS challenge in the prod ClusterIssuer."
  type        = string
  sensitive   = true
}

variable "cloudflare_email" {
  description = "Email associated with the Cloudflare account."
  type        = string
}

variable "letsencrypt_email" {
  description = "Email address used for Let's Encrypt registration in the prod ClusterIssuer."
  type        = string
}

