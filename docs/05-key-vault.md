# 5. Azure Key Vault

### 5.1. Create Key Vault
```bash
az keyvault create \
  --name marketflow-vault \
  --resource-group marketflow-rg \
  --location westeurope \
  --sku standard
```
```json
{
  "id": "/subscriptions/65fe7e97-9f6f-4f82-b940-4f374ca027cb/resourceGroups/marketflow-rg/providers/Microsoft.KeyVault/vaults/marketflow-vault",
  "location": "westeurope",
  "name": "marketflow-vault",
  "properties": {
    "accessPolicies": [],
    "createMode": null,
    "enablePurgeProtection": null,
    "enableRbacAuthorization": true,
    "enableSoftDelete": true,
    "enabledForDeployment": false,
    "enabledForDiskEncryption": false,
    "enabledForTemplateDeployment": false,
    "hsmPoolResourceId": null,
    "networkAcls": null,
    "privateEndpointConnections": null,
    "provisioningState": "Succeeded",
    "publicNetworkAccess": "Enabled",
    "sku": {
      "family": "A",
      "name": "standard"
    },
    "softDeleteRetentionInDays": 90,
    "tenantId": "7f776ea7-75ee-492e-83f3-40a9552b9320",
    "vaultUri": "https://marketflow-vault.vault.azure.net/"
  },
  "resourceGroup": "marketflow-rg",
  "systemData": {
    "createdAt": "2025-10-27T06:36:20.124000+00:00",
    "createdBy": "oleh.kondracki@gmail.com",
    "createdByType": "User",
    "lastModifiedAt": "2025-10-27T06:36:20.124000+00:00",
    "lastModifiedBy": "oleh.kondracki@gmail.com",
    "lastModifiedByType": "User"
  },
  "tags": {},
  "type": "Microsoft.KeyVault/vaults"
}
```

### 5.2. Assign Roles for Key Vault Access
```bash
az keyvault show --name marketflow-vault --query properties.enableRbacAuthorization
```
```text
true
```
```bash
az ad signed-in-user show --query id -o tsv
```
```text
9ef05d8f-5e3a-46a7-b56f-b494d734fee6
```
```bash
az role assignment create \
  --role "Key Vault Secrets Officer" \
  --assignee 9ef05d8f-5e3a-46a7-b56f-b494d734fee6 \
  --scope $(az keyvault show --name marketflow-vault --query id -o tsv)
```
```json
{
  "condition": null,
  "conditionVersion": null,
  "createdBy": null,
  "createdOn": "2025-10-27T07:10:51.199794+00:00",
  "delegatedManagedIdentityResourceId": null,
  "description": null,
  "id": "/subscriptions/65fe7e97-9f6f-4f82-b940-4f374ca027cb/resourceGroups/marketflow-rg/providers/Microsoft.KeyVault/vaults/marketflow-vault/providers/Microsoft.Authorization/roleAssignments/b2e92eae-f8c9-4cae-8c31-b9e5e0a12f61",
  "name": "b2e92eae-f8c9-4cae-8c31-b9e5e0a12f61",
  "principalId": "9ef05d8f-5e3a-46a7-b56f-b494d734fee6",
  "principalType": "User",
  "resourceGroup": "marketflow-rg",
  "roleDefinitionId": "/subscriptions/65fe7e97-9f6f-4f82-b940-4f374ca027cb/providers/Microsoft.Authorization/roleDefinitions/b86a8fe4-44ce-4948-aee5-eccb2c155cd7",
  "scope": "/subscriptions/65fe7e97-9f6f-4f82-b940-4f374ca027cb/resourceGroups/marketflow-rg/providers/Microsoft.KeyVault/vaults/marketflow-vault",
  "type": "Microsoft.Authorization/roleAssignments",
  "updatedBy": "9ef05d8f-5e3a-46a7-b56f-b494d734fee6",
  "updatedOn": "2025-10-27T07:10:51.548808+00:00"
}
```

### 5.3. Set Secrets in Key Vault
```bash
az keyvault secret set \
  --vault-name marketflow-vault \
  --name "KafkaConnectionString" \
  --value "Endpoint=sb://marketflow-kafka-ns.servicebus.windows.net/;SharedAccessKeyName=RootManageSharedAccessKey;<REDACTED>
```

