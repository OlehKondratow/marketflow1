output "network_role_id" {
  value       = one(azurerm_role_assignment.network_contributor[*].id)
  description = "ID назначения роли Network Contributor"
}

output "keyvault_role_id" {
  value       = one(azurerm_role_assignment.keyvault_officer[*].id)
  description = "ID назначения роли Key Vault Secrets Officer"
}

output "acr_role_id" {
  value       = one(azurerm_role_assignment.acr_pull[*].id)
  description = "ID назначения роли AcrPull"
}