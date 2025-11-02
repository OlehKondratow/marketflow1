###############################################################################
# Outputs for phase3-roles
#
# Эти выходы содержат ID назначенных ролей.  Их можно использовать для аудита
# или в последующих фазах (например, для мониторинга).
###############################################################################

output "network_role_id" {
  description = "ID of the Network Contributor role assignment"
  value       = module.role_assignments.network_role_id
}

output "keyvault_role_id" {
  description = "ID of the Key Vault Secrets Officer role assignment"
  value       = module.role_assignments.keyvault_role_id
}

output "acr_role_id" {
  description = "ID of the AcrPull role assignment"
  value       = module.role_assignments.acr_role_id
}

