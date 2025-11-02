###########################################################
# Outputs — Azure Key Vault
###########################################################

output "keyvault_id" {
  value       = azurerm_key_vault.keyvault.id
  description = "Resource ID of the Azure Key Vault"
}

output "keyvault_name" {
  value       = azurerm_key_vault.keyvault.name
  description = "Name of the Azure Key Vault"
}

output "keyvault_uri" {
  value       = azurerm_key_vault.keyvault.vault_uri
  description = "Vault URI for accessing secrets"
}

output "keyvault_tenant_id" {
  value       = azurerm_key_vault.keyvault.tenant_id
  description = "Tenant ID associated with the Key Vault"
}
