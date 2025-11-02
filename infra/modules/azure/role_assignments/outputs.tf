###########################################################
# Outputs for module: role_assignments
###########################################################

output "network_contributor_id" {
  value       = azurerm_role_assignment.network_contributor.id
  description = "Network Contributor Role Assignment ID"
}

output "keyvault_officer_id" {
  value       = azurerm_role_assignment.keyvault_officer.id
  description = "KeyVault Secrets Officer Role Assignment ID"
}

output "acr_pull_id" {
  value       = azurerm_role_assignment.acr_pull.id
  description = "AcrPull Role Assignment ID"
}

# ───────────────────────────────
# 🔧 Unified names for external modules
# ───────────────────────────────
output "keyvault_role_id" {
  value       = azurerm_role_assignment.keyvault_officer.id
  description = "Key Vault role assignment ID (alias)"
}

output "acr_role_id" {
  value       = azurerm_role_assignment.acr_pull.id
  description = "ACR pull role assignment ID (alias)"
}

output "network_role_id" {
  value       = azurerm_role_assignment.network_contributor.id
  description = "Network Contributor role assignment ID (alias)"
}
