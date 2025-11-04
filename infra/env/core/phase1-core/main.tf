###############################################################################
# phase1-core — foundational Azure resources
#
# Этот конфиг создаёт базовую инфраструктуру:
# ресурсную группу, виртуальную сеть, ACR, EventHub и Key Vault. 
# Модули подключаются из каталога '../../../modules'.
###############################################################################

# 1. Создаём ресурсную группу для всех ресурсов фазы 1
resource "azurerm_resource_group" "core" {
  name     = var.resource_group_name
  location = var.location
}

# 2. Виртуальная сеть, подсети и NSG
module "network" {
  source = "../../../modules/network"

  project_name        = var.project_name
  resource_group_name = azurerm_resource_group.core.name
  location            = var.location
  environment         = "dev"
  office_ip           = var.office_ip
}

# 3. Реестр контейнеров ACR
module "acr" {
  source = "../../../modules/acr"

  project_name        = var.project_name
  resource_group_name = azurerm_resource_group.core.name
  location            = var.location
  environment         = "dev"
}

# 4. Event Hub namespace и топики
module "eventhub" {
  source = "../../../modules/eventhub"

  project_name        = var.project_name
  resource_group_name = azurerm_resource_group.core.name
  location            = var.location
  environment         = "dev"
}

# 5. Key Vault для секретов
module "keyvault" {
  source = "../../../modules/keyvault"

  project_name        = var.project_name
  resource_group_name = azurerm_resource_group.core.name
  location            = var.location
  environment         = "dev"
  tenant_id           = var.tenant_id
}
