output "storage_id" {
  value       = azurerm_storage_account.storage.id
  description = "Storage account ID"
}

output "storage_primary_blob_endpoint" {
  value       = azurerm_storage_account.storage.primary_blob_endpoint
  description = "Primary blob endpoint"
}
