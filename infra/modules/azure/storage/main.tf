resource "azurerm_storage_account" "storage" {
  name                     = "${var.project_name}stor${substr(uuid(), 0, 4)}"
  resource_group_name      = var.resource_group_name
  location                 = var.location
  account_tier             = "Standard"
  account_replication_type = "LRS"
}

output "storage_account_name" {
  value = azurerm_storage_account.storage.name
}
