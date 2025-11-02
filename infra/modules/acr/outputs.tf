
output "acr_id" {
  value       = azurerm_container_registry.acr.id
  description = "ACR resource ID"
}

output "acr_login_server" {
  value       = azurerm_container_registry.acr.login_server
  description = "ACR login server"
}

output "acr_admin_username" {
  value       = azurerm_container_registry.acr.admin_username
  sensitive   = true
  description = "ACR admin username"
}

output "acr_admin_password" {
  value       = azurerm_container_registry.acr.admin_password
  sensitive   = true
  description = "ACR admin password"
}
