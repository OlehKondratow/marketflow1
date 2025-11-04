# Идентификаторы вашего Azure‑аккаунта
subscription_id = "65fe7e97-9f6f-4f82-b940-4f374ca027cb"
tenant_id       = "7f776ea7-75ee-492e-83f3-40a9552b9320"

# Имя проекта и регион
project_name        = "marketflow"
resource_group_name = "marketflow-rg"
location            = "westeurope"

vnet_id             = "/subscriptions/65fe7e97-9f6f-4f82-b940-4f374ca027cb/resourceGroups/marketflow-rg/providers/Microsoft.Network/virtualNetworks/marketflow-vnet"
subnet_dev_id       = "/subscriptions/65fe7e97-9f6f-4f82-b940-4f374ca027cb/resourceGroups/marketflow-rg/providers/Microsoft.Network/virtualNetworks/marketflow-vnet/subnets/aks-subnet-dev"
subnet_prod_id      = "/subscriptions/65fe7e97-9f6f-4f82-b940-4f374ca027cb/resourceGroups/marketflow-rg/providers/Microsoft.Network/virtualNetworks/marketflow-vnet/subnets/aks-subnet-prod"
acr_id              = "/subscriptions/65fe7e97-9f6f-4f82-b940-4f374ca027cb/resourceGroups/marketflow-rg/providers/Microsoft.ContainerRegistry/registries/marketflowacr5125"
keyvault_id         = "/subscriptions/65fe7e97-9f6f-4f82-b940-4f374ca027cb/resourceGroups/marketflow-rg/providers/Microsoft.KeyVault/vaults/marketflow-vault"
eventhub_namespace  = "marketflow0-ehns"
