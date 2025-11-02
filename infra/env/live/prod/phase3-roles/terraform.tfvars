# Идентификаторы вашего Azure‑аккаунта
subscription_id = "65fe7e97-9f6f-4f82-b940-4f374ca027cb"
tenant_id       = "7f776ea7-75ee-492e-83f3-40a9552b9320"

# Идентификаторы ресурсов (выходы из предыдущих фаз)
resource_group_id = "/subscriptions/<sub>/resourceGroups/marketflow-rg"
acr_id            = "/subscriptions/<sub>/resourceGroups/marketflow-rg/providers/Microsoft.ContainerRegistry/registries/marketflowregistry"
keyvault_id       = "/subscriptions/<sub>/resourceGroups/marketflow-rg/providers/Microsoft.KeyVault/vaults/marketflow-vault"

# ID управляемой идентичности AKS — требуется только для первого запуска,
# затем можно читать его из terraform_remote_state
aks_principal_id  = "00000000-0000-0000-0000-000000000000"
