resource "azurerm_key_vault" "keyvault" {
  name                        = "${var.project_name}-vault"
  location                    = var.location
  resource_group_name         = var.resource_group_name
  tenant_id                   = var.tenant_id
  sku_name                    = "standard"
  soft_delete_retention_days  = 90
  purge_protection_enabled    = false
  public_network_access_enabled = true
  rbac_authorization_enabled  = true

  tags = {
    environment = var.environment
    project     = var.project_name
  }
}
