# 1. Initial Setup

### 1.1. Tool Versions Check
```bash
az --version
kubectl version --client
```

```text
azure-cli                         2.78.0

core                              2.78.0
telemetry                          1.1.0

Dependencies:
msal                            1.34.0b1
azure-mgmt-resource               23.3.0

Python location '/opt/az/bin/python3'
Config directory '/home/kinga/.azure'
Extensions directory '/home/kinga/.azure/cliextensions'

Python (Linux) 3.13.7 (main, Oct  9 2025, 05:50:17) [GCC 13.3.0]

Legal docs and information: aka.ms/AzureCliLegal


Your CLI is up-to-date.
Client Version: v1.28.15
Kustomize Version: v5.0.4-0.20230601165947-6ce0bf390ce3
```

### 1.2. Azure Login
```bash
az login --use-device-code
az account show
az account list --output table
```

### 1.3. Resource Group Creation
```bash
az group create \
  --name marketflow-rg \
  --location westeurope
```

```json
{
  "id": "/subscriptions/65fe7e97-9f6f-4f82-b940-4f374ca027cb/resourceGroups/marketflow-rg",
  "location": "westeurope",
  "managedBy": null,
  "name": "marketflow-rg",
  "properties": {
    "provisioningState": "Succeeded"
  },
  "tags": null,
  "type": "Microsoft.Resources/resourceGroups"
}
```
