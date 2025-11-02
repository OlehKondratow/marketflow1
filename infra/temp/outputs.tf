###########################################################
# ✅ Outputs — DEV environment (разделены по модулям)
###########################################################

# ───────────────────────────────
# ☸️ AKS
# ───────────────────────────────
output "aks_id" {
  value       = module.aks.aks_id
  description = "Resource ID of AKS cluster"
}

output "aks_fqdn" {
  value       = module.aks.aks_fqdn
  description = "Public FQDN of AKS API server"
}

output "aks_kube_admin_config" {
  value       = module.aks.aks_kube_admin_config
  description = "Admin kubeconfig for AKS cluster"
  sensitive   = true
}

output "aks_principal_id" {
  value       = module.aks.aks_identity_principal_id
  description = "AKS managed identity principal ID"
}

# ───────────────────────────────
# 📦 ACR
# ───────────────────────────────
output "acr_id" {
  value       = module.acr.acr_id
  description = "Azure Container Registry ID"
}

output "acr_login_server" {
  value       = module.acr.acr_login_server
  description = "ACR login server URL"
}

output "acr_admin_username" {
  value       = module.acr.acr_admin_username
  description = "ACR admin username"
  sensitive   = true
}

output "acr_admin_password" {
  value       = module.acr.acr_admin_password
  description = "ACR admin password"
  sensitive   = true
}

# ───────────────────────────────
# 🔐 Key Vault
# ───────────────────────────────
output "keyvault_id" {
  value       = module.keyvault.keyvault_id
  description = "Key Vault resource ID"
}

output "keyvault_uri" {
  value       = module.keyvault.keyvault_uri
  description = "Key Vault URI endpoint"
}

# ───────────────────────────────
# 🌐 Network
# ───────────────────────────────
output "vnet_id" {
  value       = module.network.vnet_id
  description = "Virtual Network resource ID"
}

output "subnet_dev_id" {
  value       = module.network.subnet_dev_id
  description = "Development subnet ID"
}

# ───────────────────────────────
# 💾 Storage
# ───────────────────────────────
output "storage_id" {
  value       = module.storage.storage_id
  description = "Storage account resource ID"
}

output "storage_primary_blob_endpoint" {
  value       = module.storage.storage_primary_blob_endpoint
  description = "Primary blob endpoint of the storage account"
}

# ───────────────────────────────
# 🧩 Role Assignments
# ───────────────────────────────
#output "role_assignments_summary" {
#  value = {
#    keyvault_role_id = module.role_assignments.keyvault_role_id
#    acr_role_id      = module.role_assignments.acr_role_id
#  }
#  description = "Summary of role assignments for Key Vault and ACR"
#}
