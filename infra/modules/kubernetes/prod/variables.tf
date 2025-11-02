variable "prod_ingress_ip" {
  type        = string
  description = "Static IP for ingress controller in prod"
}

variable "cloudflare_api_token" {
  type        = string
  sensitive   = true
  description = "Cloudflare API token for DNS challenge"
}

variable "cloudflare_email" {
  type        = string
  description = "Cloudflare account email"
}

variable "letsencrypt_email" {
  type        = string
  description = "Email address for Let's Encrypt registration"
}

variable "domain" {
  type = string
}

variable "resource_group_name" {
  type        = string
  description = "Azure Resource Group name for load balancer annotation"
}
