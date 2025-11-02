```
acr_admin_password = <sensitive>
acr_admin_username = <sensitive>
acr_id = "/subscriptions/65fe7e97-9f6f-4f82-b940-4f374ca027cb/resourceGroups/marketflow0-rg/providers/Microsoft.ContainerRegistry/registries/marketflow0acrce38"
acr_login_server = "marketflow0acrce38.azurecr.io"
aks_fqdn = "marketflow0-dns-vra1uzuy.hcp.northeurope.azmk8s.io"
aks_id = "/subscriptions/65fe7e97-9f6f-4f82-b940-4f374ca027cb/resourceGroups/marketflow0-rg/providers/Microsoft.ContainerService/managedClusters/marketflow0-aks"
aks_kube_admin_config = <sensitive>
aks_principal_id = "bf36acb2-d554-4fc1-8b9c-e4fb651156ab"
keyvault_id = "/subscriptions/65fe7e97-9f6f-4f82-b940-4f374ca027cb/resourceGroups/marketflow0-rg/providers/Microsoft.KeyVault/vaults/marketflow0-vault"
keyvault_uri = "https://marketflow0-vault.vault.azure.net/"
role_assignments_summary = {
  "acr_role_id" = "/subscriptions/65fe7e97-9f6f-4f82-b940-4f374ca027cb/resourceGroups/marketflow0-rg/providers/Microsoft.ContainerRegistry/registries/marketflow0acrce38/providers/Microsoft.Authorization/roleAssignments/32172084-dac6-594b-aaf7-35678c1e4130"
  "keyvault_role_id" = "/subscriptions/65fe7e97-9f6f-4f82-b940-4f374ca027cb/resourceGroups/marketflow0-rg/providers/Microsoft.KeyVault/vaults/marketflow0-vault/providers/Microsoft.Authorization/roleAssignments/5d3868e7-29fd-44d7-f315-f04e33d67755"
}
storage_id = "/subscriptions/65fe7e97-9f6f-4f82-b940-4f374ca027cb/resourceGroups/marketflow0-rg/providers/Microsoft.Storage/storageAccounts/marketflow0stord6e2"
storage_primary_blob_endpoint = "https://marketflow0stord6e2.blob.core.windows.net/"
subnet_dev_id = "/subscriptions/65fe7e97-9f6f-4f82-b940-4f374ca027cb/resourceGroups/marketflow0-rg/providers/Microsoft.Network/virtualNetworks/marketflow0-vnet/subnets/aks-subnet-dev"
subnet_prod_id = "/subscriptions/65fe7e97-9f6f-4f82-b940-4f374ca027cb/resourceGroups/marketflow0-rg/providers/Microsoft.Network/virtualNetworks/marketflow0-vnet/subnets/aks-subnet-prod"
vnet_id = "/subscriptions/65fe7e97-9f6f-4f82-b940-4f374ca027cb/resourceGroups/marketflow0-rg/providers/Microsoft.Network/virtualNetworks/marketflow0-vnet"
```

terraform apply -target=module.kubernetes_dev.helm_release.cert_manager
terraform apply -target=module.kubernetes_dev.kubernetes_manifest.homelab_ca_issuer
terraform apply -target=module.kubernetes_dev.kubernetes_manifest.letsencrypt_staging

```
az network public-ip list --resource-group marketflow0-rg --output table
Name                 ResourceGroup    Location     Zones    Address        IdleTimeoutInMinutes    ProvisioningState
-------------------  ---------------  -----------  -------  -------------  ----------------------  -------------------
marketflow0-dev-ip   marketflow0-rg   northeurope           4.210.65.14    4                       Succeeded
marketflow0-prod-ip  marketflow0-rg   northeurope           128.251.42.38  4                       Succeeded
```

 az network vnet subnet list \
  --resource-group marketflow0-rg \
  --vnet-name marketflow0-vnet \
  --query "[].{Name:name,NSG:networkSecurityGroup.id}" -o table
Name
---------------
aks-subnet-prod
aks-subnet-dev

> az network nsg create \
  --name marketflow0-prod-nsg \
  --resource-group marketflow0-rg \
  --location northeurope
{
  "NewNSG": {
    "defaultSecurityRules": [
      {
        "access": "Allow",
        "description": "Allow inbound traffic from all VMs in VNET",
        "destinationAddressPrefix": "VirtualNetwork",
        "destinationAddressPrefixes": [],
        "destinationPortRange": "*",
        "destinationPortRanges": [],
        "direction": "Inbound",
        "etag": "W/\"20f300ef-66a4-4c0d-acfc-327dc80cb2ef\"",
        "id": "/subscriptions/65fe7e97-9f6f-4f82-b940-4f374ca027cb/resourceGroups/marketflow0-rg/providers/Microsoft.Network/networkSecurityGroups/marketflow0-prod-nsg/defaultSecurityRules/AllowVnetInBound",
        "name": "AllowVnetInBound",
        "priority": 65000,
        "protocol": "*",
        "provisioningState": "Succeeded",
        "resourceGroup": "marketflow0-rg",
        "sourceAddressPrefix": "VirtualNetwork",
        "sourceAddressPrefixes": [],
        "sourcePortRange": "*",
        "sourcePortRanges": [],
        "type": "Microsoft.Network/networkSecurityGroups/defaultSecurityRules"
      },
      {
        "access": "Allow",
        "description": "Allow inbound traffic from azure load balancer",
        "destinationAddressPrefix": "*",
        "destinationAddressPrefixes": [],
        "destinationPortRange": "*",
        "destinationPortRanges": [],
        "direction": "Inbound",
        "etag": "W/\"20f300ef-66a4-4c0d-acfc-327dc80cb2ef\"",
        "id": "/subscriptions/65fe7e97-9f6f-4f82-b940-4f374ca027cb/resourceGroups/marketflow0-rg/providers/Microsoft.Network/networkSecurityGroups/marketflow0-prod-nsg/defaultSecurityRules/AllowAzureLoadBalancerInBound",
        "name": "AllowAzureLoadBalancerInBound",
        "priority": 65001,
        "protocol": "*",
        "provisioningState": "Succeeded",
        "resourceGroup": "marketflow0-rg",
        "sourceAddressPrefix": "AzureLoadBalancer",
        "sourceAddressPrefixes": [],
        "sourcePortRange": "*",
        "sourcePortRanges": [],
        "type": "Microsoft.Network/networkSecurityGroups/defaultSecurityRules"
      },
      {
        "access": "Deny",
        "description": "Deny all inbound traffic",
        "destinationAddressPrefix": "*",
        "destinationAddressPrefixes": [],
        "destinationPortRange": "*",
        "destinationPortRanges": [],
        "direction": "Inbound",
        "etag": "W/\"20f300ef-66a4-4c0d-acfc-327dc80cb2ef\"",
        "id": "/subscriptions/65fe7e97-9f6f-4f82-b940-4f374ca027cb/resourceGroups/marketflow0-rg/providers/Microsoft.Network/networkSecurityGroups/marketflow0-prod-nsg/defaultSecurityRules/DenyAllInBound",
        "name": "DenyAllInBound",
        "priority": 65500,
        "protocol": "*",
        "provisioningState": "Succeeded",
        "resourceGroup": "marketflow0-rg",
        "sourceAddressPrefix": "*",
        "sourceAddressPrefixes": [],
        "sourcePortRange": "*",
        "sourcePortRanges": [],
        "type": "Microsoft.Network/networkSecurityGroups/defaultSecurityRules"
      },
      {
        "access": "Allow",
        "description": "Allow outbound traffic from all VMs to all VMs in VNET",
        "destinationAddressPrefix": "VirtualNetwork",
        "destinationAddressPrefixes": [],
        "destinationPortRange": "*",
        "destinationPortRanges": [],
        "direction": "Outbound",
        "etag": "W/\"20f300ef-66a4-4c0d-acfc-327dc80cb2ef\"",
        "id": "/subscriptions/65fe7e97-9f6f-4f82-b940-4f374ca027cb/resourceGroups/marketflow0-rg/providers/Microsoft.Network/networkSecurityGroups/marketflow0-prod-nsg/defaultSecurityRules/AllowVnetOutBound",
        "name": "AllowVnetOutBound",
        "priority": 65000,
        "protocol": "*",
        "provisioningState": "Succeeded",
        "resourceGroup": "marketflow0-rg",
        "sourceAddressPrefix": "VirtualNetwork",
        "sourceAddressPrefixes": [],
        "sourcePortRange": "*",
        "sourcePortRanges": [],
        "type": "Microsoft.Network/networkSecurityGroups/defaultSecurityRules"
      },
      {
        "access": "Allow",
        "description": "Allow outbound traffic from all VMs to Internet",
        "destinationAddressPrefix": "Internet",
        "destinationAddressPrefixes": [],
        "destinationPortRange": "*",
        "destinationPortRanges": [],
        "direction": "Outbound",
        "etag": "W/\"20f300ef-66a4-4c0d-acfc-327dc80cb2ef\"",
        "id": "/subscriptions/65fe7e97-9f6f-4f82-b940-4f374ca027cb/resourceGroups/marketflow0-rg/providers/Microsoft.Network/networkSecurityGroups/marketflow0-prod-nsg/defaultSecurityRules/AllowInternetOutBound",
        "name": "AllowInternetOutBound",
        "priority": 65001,
        "protocol": "*",
        "provisioningState": "Succeeded",
        "resourceGroup": "marketflow0-rg",
        "sourceAddressPrefix": "*",
        "sourceAddressPrefixes": [],
        "sourcePortRange": "*",
        "sourcePortRanges": [],
        "type": "Microsoft.Network/networkSecurityGroups/defaultSecurityRules"
      },
      {
        "access": "Deny",
        "description": "Deny all outbound traffic",
        "destinationAddressPrefix": "*",
        "destinationAddressPrefixes": [],
        "destinationPortRange": "*",
        "destinationPortRanges": [],
        "direction": "Outbound",
        "etag": "W/\"20f300ef-66a4-4c0d-acfc-327dc80cb2ef\"",
        "id": "/subscriptions/65fe7e97-9f6f-4f82-b940-4f374ca027cb/resourceGroups/marketflow0-rg/providers/Microsoft.Network/networkSecurityGroups/marketflow0-prod-nsg/defaultSecurityRules/DenyAllOutBound",
        "name": "DenyAllOutBound",
        "priority": 65500,
        "protocol": "*",
        "provisioningState": "Succeeded",
        "resourceGroup": "marketflow0-rg",
        "sourceAddressPrefix": "*",
        "sourceAddressPrefixes": [],
        "sourcePortRange": "*",
        "sourcePortRanges": [],
        "type": "Microsoft.Network/networkSecurityGroups/defaultSecurityRules"
      }
    ],
    "etag": "W/\"20f300ef-66a4-4c0d-acfc-327dc80cb2ef\"",
    "id": "/subscriptions/65fe7e97-9f6f-4f82-b940-4f374ca027cb/resourceGroups/marketflow0-rg/providers/Microsoft.Network/networkSecurityGroups/marketflow0-prod-nsg",
    "location": "northeurope",
    "name": "marketflow0-prod-nsg",
    "provisioningState": "Succeeded",
    "resourceGroup": "marketflow0-rg",
    "resourceGuid": "d724a678-1611-4223-a489-d5860b50afed",
    "securityRules": [],
    "type": "Microsoft.Network/networkSecurityGroups"
  }
}

> az network nsg rule create \
  --resource-group marketflow0-rg \
  --nsg-name marketflow0-prod-nsg \
  --name AllowHTTP \
  --protocol Tcp \
  --direction Inbound \
  --priority 100 \
  --source-address-prefixes '*' \
  --source-port-ranges '*' \
  --destination-port-ranges 80 \
  --access Allow
{
  "access": "Allow",
  "destinationAddressPrefix": "*",
  "destinationAddressPrefixes": [],
  "destinationPortRange": "80",
  "destinationPortRanges": [],
  "direction": "Inbound",
  "etag": "W/\"50aaa343-2045-4eee-8a44-c5a751a071a1\"",
  "id": "/subscriptions/65fe7e97-9f6f-4f82-b940-4f374ca027cb/resourceGroups/marketflow0-rg/providers/Microsoft.Network/networkSecurityGroups/marketflow0-prod-nsg/securityRules/AllowHTTP",
  "name": "AllowHTTP",
  "priority": 100,
  "protocol": "Tcp",
  "provisioningState": "Succeeded",
  "resourceGroup": "marketflow0-rg",
  "sourceAddressPrefix": "*",
  "sourceAddressPrefixes": [],
  "sourcePortRange": "*",
  "sourcePortRanges": [],
  "type": "Microsoft.Network/networkSecurityGroups/securityRules"
}

> az network nsg rule create \
  --resource-group marketflow0-rg \
  --nsg-name marketflow0-prod-nsg \
  --name AllowHTTPS \
  --protocol Tcp \
  --direction Inbound \
  --priority 101 \
  --source-address-prefixes '*' \
  --source-port-ranges '*' \
  --destination-port-ranges 443 \
  --access Allow
{
  "access": "Allow",
  "destinationAddressPrefix": "*",
  "destinationAddressPrefixes": [],
  "destinationPortRange": "443",
  "destinationPortRanges": [],
  "direction": "Inbound",
  "etag": "W/\"40d691ac-b10e-4d9b-9aa2-c9749e3972be\"",
  "id": "/subscriptions/65fe7e97-9f6f-4f82-b940-4f374ca027cb/resourceGroups/marketflow0-rg/providers/Microsoft.Network/networkSecurityGroups/marketflow0-prod-nsg/securityRules/AllowHTTPS",
  "name": "AllowHTTPS",
  "priority": 101,
  "protocol": "Tcp",
  "provisioningState": "Succeeded",
  "resourceGroup": "marketflow0-rg",
  "sourceAddressPrefix": "*",
  "sourceAddressPrefixes": [],
  "sourcePortRange": "*",
  "sourcePortRanges": [],
  "type": "Microsoft.Network/networkSecurityGroups/securityRules"
}

> az network vnet subnet update \
  --name aks-subnet-prod \
  --resource-group marketflow0-rg \
  --vnet-name marketflow0-vnet \
  --network-security-group marketflow0-prod-nsg
{
  "addressPrefix": "10.240.1.0/24",
  "defaultOutboundAccess": true,
  "delegations": [],
  "etag": "W/\"cd6c596d-8bd2-4862-9bc5-86422f6b15bd\"",
  "id": "/subscriptions/65fe7e97-9f6f-4f82-b940-4f374ca027cb/resourceGroups/marketflow0-rg/providers/Microsoft.Network/virtualNetworks/marketflow0-vnet/subnets/aks-subnet-prod",
  "ipConfigurations": [
    {
      "id": "/subscriptions/65fe7e97-9f6f-4f82-b940-4f374ca027cb/resourceGroups/MC_MARKETFLOW0-RG_MARKETFLOW0-AKS_NORTHEUROPE/PROVIDERS/MICROSOFT.COMPUTE/VIRTUALMACHINESCALESETS/AKS-SYSTEM-29940087-VMSS/VIRTUALMACHINES/0/NETWORKINTERFACES/AKS-SYSTEM-29940087-VMSS/ipConfigurations/IPCONFIG1",
      "resourceGroup": "MC_MARKETFLOW0-RG_MARKETFLOW0-AKS_NORTHEUROPE"
    },
    {
      "id": "/subscriptions/65fe7e97-9f6f-4f82-b940-4f374ca027cb/resourceGroups/MC_MARKETFLOW0-RG_MARKETFLOW0-AKS_NORTHEUROPE/PROVIDERS/MICROSOFT.COMPUTE/VIRTUALMACHINESCALESETS/AKS-SYSTEM-29940087-VMSS/VIRTUALMACHINES/0/NETWORKINTERFACES/AKS-SYSTEM-29940087-VMSS/ipConfigurations/IPCONFIG10",
      "resourceGroup": "MC_MARKETFLOW0-RG_MARKETFLOW0-AKS_NORTHEUROPE"
    },
    {
      "id": "/subscriptions/65fe7e97-9f6f-4f82-b940-4f374ca027cb/resourceGroups/MC_MARKETFLOW0-RG_MARKETFLOW0-AKS_NORTHEUROPE/PROVIDERS/MICROSOFT.COMPUTE/VIRTUALMACHINESCALESETS/AKS-SYSTEM-29940087-VMSS/VIRTUALMACHINES/0/NETWORKINTERFACES/AKS-SYSTEM-29940087-VMSS/ipConfigurations/IPCONFIG11",
      "resourceGroup": "MC_MARKETFLOW0-RG_MARKETFLOW0-AKS_NORTHEUROPE"
    },
    {
      "id": "/subscriptions/65fe7e97-9f6f-4f82-b940-4f374ca027cb/resourceGroups/MC_MARKETFLOW0-RG_MARKETFLOW0-AKS_NORTHEUROPE/PROVIDERS/MICROSOFT.COMPUTE/VIRTUALMACHINESCALESETS/AKS-SYSTEM-29940087-VMSS/VIRTUALMACHINES/0/NETWORKINTERFACES/AKS-SYSTEM-29940087-VMSS/ipConfigurations/IPCONFIG12",
      "resourceGroup": "MC_MARKETFLOW0-RG_MARKETFLOW0-AKS_NORTHEUROPE"
    },
    {
      "id": "/subscriptions/65fe7e97-9f6f-4f82-b940-4f374ca027cb/resourceGroups/MC_MARKETFLOW0-RG_MARKETFLOW0-AKS_NORTHEUROPE/PROVIDERS/MICROSOFT.COMPUTE/VIRTUALMACHINESCALESETS/AKS-SYSTEM-29940087-VMSS/VIRTUALMACHINES/0/NETWORKINTERFACES/AKS-SYSTEM-29940087-VMSS/ipConfigurations/IPCONFIG13",
      "resourceGroup": "MC_MARKETFLOW0-RG_MARKETFLOW0-AKS_NORTHEUROPE"
    },
    {
      "id": "/subscriptions/65fe7e97-9f6f-4f82-b940-4f374ca027cb/resourceGroups/MC_MARKETFLOW0-RG_MARKETFLOW0-AKS_NORTHEUROPE/PROVIDERS/MICROSOFT.COMPUTE/VIRTUALMACHINESCALESETS/AKS-SYSTEM-29940087-VMSS/VIRTUALMACHINES/0/NETWORKINTERFACES/AKS-SYSTEM-29940087-VMSS/ipConfigurations/IPCONFIG14",
      "resourceGroup": "MC_MARKETFLOW0-RG_MARKETFLOW0-AKS_NORTHEUROPE"
    },
    {
      "id": "/subscriptions/65fe7e97-9f6f-4f82-b940-4f374ca027cb/resourceGroups/MC_MARKETFLOW0-RG_MARKETFLOW0-AKS_NORTHEUROPE/PROVIDERS/MICROSOFT.COMPUTE/VIRTUALMACHINESCALESETS/AKS-SYSTEM-29940087-VMSS/VIRTUALMACHINES/0/NETWORKINTERFACES/AKS-SYSTEM-29940087-VMSS/ipConfigurations/IPCONFIG15",
      "resourceGroup": "MC_MARKETFLOW0-RG_MARKETFLOW0-AKS_NORTHEUROPE"
    },
    {
      "id": "/subscriptions/65fe7e97-9f6f-4f82-b940-4f374ca027cb/resourceGroups/MC_MARKETFLOW0-RG_MARKETFLOW0-AKS_NORTHEUROPE/PROVIDERS/MICROSOFT.COMPUTE/VIRTUALMACHINESCALESETS/AKS-SYSTEM-29940087-VMSS/VIRTUALMACHINES/0/NETWORKINTERFACES/AKS-SYSTEM-29940087-VMSS/ipConfigurations/IPCONFIG16",
      "resourceGroup": "MC_MARKETFLOW0-RG_MARKETFLOW0-AKS_NORTHEUROPE"
    },
    {
      "id": "/subscriptions/65fe7e97-9f6f-4f82-b940-4f374ca027cb/resourceGroups/MC_MARKETFLOW0-RG_MARKETFLOW0-AKS_NORTHEUROPE/PROVIDERS/MICROSOFT.COMPUTE/VIRTUALMACHINESCALESETS/AKS-SYSTEM-29940087-VMSS/VIRTUALMACHINES/0/NETWORKINTERFACES/AKS-SYSTEM-29940087-VMSS/ipConfigurations/IPCONFIG17",
      "resourceGroup": "MC_MARKETFLOW0-RG_MARKETFLOW0-AKS_NORTHEUROPE"
    },
    {
      "id": "/subscriptions/65fe7e97-9f6f-4f82-b940-4f374ca027cb/resourceGroups/MC_MARKETFLOW0-RG_MARKETFLOW0-AKS_NORTHEUROPE/PROVIDERS/MICROSOFT.COMPUTE/VIRTUALMACHINESCALESETS/AKS-SYSTEM-29940087-VMSS/VIRTUALMACHINES/0/NETWORKINTERFACES/AKS-SYSTEM-29940087-VMSS/ipConfigurations/IPCONFIG18",
      "resourceGroup": "MC_MARKETFLOW0-RG_MARKETFLOW0-AKS_NORTHEUROPE"
    },
    {
      "id": "/subscriptions/65fe7e97-9f6f-4f82-b940-4f374ca027cb/resourceGroups/MC_MARKETFLOW0-RG_MARKETFLOW0-AKS_NORTHEUROPE/PROVIDERS/MICROSOFT.COMPUTE/VIRTUALMACHINESCALESETS/AKS-SYSTEM-29940087-VMSS/VIRTUALMACHINES/0/NETWORKINTERFACES/AKS-SYSTEM-29940087-VMSS/ipConfigurations/IPCONFIG19",
      "resourceGroup": "MC_MARKETFLOW0-RG_MARKETFLOW0-AKS_NORTHEUROPE"
    },
    {
      "id": "/subscriptions/65fe7e97-9f6f-4f82-b940-4f374ca027cb/resourceGroups/MC_MARKETFLOW0-RG_MARKETFLOW0-AKS_NORTHEUROPE/PROVIDERS/MICROSOFT.COMPUTE/VIRTUALMACHINESCALESETS/AKS-SYSTEM-29940087-VMSS/VIRTUALMACHINES/0/NETWORKINTERFACES/AKS-SYSTEM-29940087-VMSS/ipConfigurations/IPCONFIG2",
      "resourceGroup": "MC_MARKETFLOW0-RG_MARKETFLOW0-AKS_NORTHEUROPE"
    },
    {
      "id": "/subscriptions/65fe7e97-9f6f-4f82-b940-4f374ca027cb/resourceGroups/MC_MARKETFLOW0-RG_MARKETFLOW0-AKS_NORTHEUROPE/PROVIDERS/MICROSOFT.COMPUTE/VIRTUALMACHINESCALESETS/AKS-SYSTEM-29940087-VMSS/VIRTUALMACHINES/0/NETWORKINTERFACES/AKS-SYSTEM-29940087-VMSS/ipConfigurations/IPCONFIG20",
      "resourceGroup": "MC_MARKETFLOW0-RG_MARKETFLOW0-AKS_NORTHEUROPE"
    },
    {
      "id": "/subscriptions/65fe7e97-9f6f-4f82-b940-4f374ca027cb/resourceGroups/MC_MARKETFLOW0-RG_MARKETFLOW0-AKS_NORTHEUROPE/PROVIDERS/MICROSOFT.COMPUTE/VIRTUALMACHINESCALESETS/AKS-SYSTEM-29940087-VMSS/VIRTUALMACHINES/0/NETWORKINTERFACES/AKS-SYSTEM-29940087-VMSS/ipConfigurations/IPCONFIG21",
      "resourceGroup": "MC_MARKETFLOW0-RG_MARKETFLOW0-AKS_NORTHEUROPE"
    },
    {
      "id": "/subscriptions/65fe7e97-9f6f-4f82-b940-4f374ca027cb/resourceGroups/MC_MARKETFLOW0-RG_MARKETFLOW0-AKS_NORTHEUROPE/PROVIDERS/MICROSOFT.COMPUTE/VIRTUALMACHINESCALESETS/AKS-SYSTEM-29940087-VMSS/VIRTUALMACHINES/0/NETWORKINTERFACES/AKS-SYSTEM-29940087-VMSS/ipConfigurations/IPCONFIG22",
      "resourceGroup": "MC_MARKETFLOW0-RG_MARKETFLOW0-AKS_NORTHEUROPE"
    },
    {
      "id": "/subscriptions/65fe7e97-9f6f-4f82-b940-4f374ca027cb/resourceGroups/MC_MARKETFLOW0-RG_MARKETFLOW0-AKS_NORTHEUROPE/PROVIDERS/MICROSOFT.COMPUTE/VIRTUALMACHINESCALESETS/AKS-SYSTEM-29940087-VMSS/VIRTUALMACHINES/0/NETWORKINTERFACES/AKS-SYSTEM-29940087-VMSS/ipConfigurations/IPCONFIG23",
      "resourceGroup": "MC_MARKETFLOW0-RG_MARKETFLOW0-AKS_NORTHEUROPE"
    },
    {
      "id": "/subscriptions/65fe7e97-9f6f-4f82-b940-4f374ca027cb/resourceGroups/MC_MARKETFLOW0-RG_MARKETFLOW0-AKS_NORTHEUROPE/PROVIDERS/MICROSOFT.COMPUTE/VIRTUALMACHINESCALESETS/AKS-SYSTEM-29940087-VMSS/VIRTUALMACHINES/0/NETWORKINTERFACES/AKS-SYSTEM-29940087-VMSS/ipConfigurations/IPCONFIG24",
      "resourceGroup": "MC_MARKETFLOW0-RG_MARKETFLOW0-AKS_NORTHEUROPE"
    },
    {
      "id": "/subscriptions/65fe7e97-9f6f-4f82-b940-4f374ca027cb/resourceGroups/MC_MARKETFLOW0-RG_MARKETFLOW0-AKS_NORTHEUROPE/PROVIDERS/MICROSOFT.COMPUTE/VIRTUALMACHINESCALESETS/AKS-SYSTEM-29940087-VMSS/VIRTUALMACHINES/0/NETWORKINTERFACES/AKS-SYSTEM-29940087-VMSS/ipConfigurations/IPCONFIG25",
      "resourceGroup": "MC_MARKETFLOW0-RG_MARKETFLOW0-AKS_NORTHEUROPE"
    },
    {
      "id": "/subscriptions/65fe7e97-9f6f-4f82-b940-4f374ca027cb/resourceGroups/MC_MARKETFLOW0-RG_MARKETFLOW0-AKS_NORTHEUROPE/PROVIDERS/MICROSOFT.COMPUTE/VIRTUALMACHINESCALESETS/AKS-SYSTEM-29940087-VMSS/VIRTUALMACHINES/0/NETWORKINTERFACES/AKS-SYSTEM-29940087-VMSS/ipConfigurations/IPCONFIG26",
      "resourceGroup": "MC_MARKETFLOW0-RG_MARKETFLOW0-AKS_NORTHEUROPE"
    },
    {
      "id": "/subscriptions/65fe7e97-9f6f-4f82-b940-4f374ca027cb/resourceGroups/MC_MARKETFLOW0-RG_MARKETFLOW0-AKS_NORTHEUROPE/PROVIDERS/MICROSOFT.COMPUTE/VIRTUALMACHINESCALESETS/AKS-SYSTEM-29940087-VMSS/VIRTUALMACHINES/0/NETWORKINTERFACES/AKS-SYSTEM-29940087-VMSS/ipConfigurations/IPCONFIG27",
      "resourceGroup": "MC_MARKETFLOW0-RG_MARKETFLOW0-AKS_NORTHEUROPE"
    },
    {
      "id": "/subscriptions/65fe7e97-9f6f-4f82-b940-4f374ca027cb/resourceGroups/MC_MARKETFLOW0-RG_MARKETFLOW0-AKS_NORTHEUROPE/PROVIDERS/MICROSOFT.COMPUTE/VIRTUALMACHINESCALESETS/AKS-SYSTEM-29940087-VMSS/VIRTUALMACHINES/0/NETWORKINTERFACES/AKS-SYSTEM-29940087-VMSS/ipConfigurations/IPCONFIG28",
      "resourceGroup": "MC_MARKETFLOW0-RG_MARKETFLOW0-AKS_NORTHEUROPE"
    },
    {
      "id": "/subscriptions/65fe7e97-9f6f-4f82-b940-4f374ca027cb/resourceGroups/MC_MARKETFLOW0-RG_MARKETFLOW0-AKS_NORTHEUROPE/PROVIDERS/MICROSOFT.COMPUTE/VIRTUALMACHINESCALESETS/AKS-SYSTEM-29940087-VMSS/VIRTUALMACHINES/0/NETWORKINTERFACES/AKS-SYSTEM-29940087-VMSS/ipConfigurations/IPCONFIG29",
      "resourceGroup": "MC_MARKETFLOW0-RG_MARKETFLOW0-AKS_NORTHEUROPE"
    },
    {
      "id": "/subscriptions/65fe7e97-9f6f-4f82-b940-4f374ca027cb/resourceGroups/MC_MARKETFLOW0-RG_MARKETFLOW0-AKS_NORTHEUROPE/PROVIDERS/MICROSOFT.COMPUTE/VIRTUALMACHINESCALESETS/AKS-SYSTEM-29940087-VMSS/VIRTUALMACHINES/0/NETWORKINTERFACES/AKS-SYSTEM-29940087-VMSS/ipConfigurations/IPCONFIG3",
      "resourceGroup": "MC_MARKETFLOW0-RG_MARKETFLOW0-AKS_NORTHEUROPE"
    },
    {
      "id": "/subscriptions/65fe7e97-9f6f-4f82-b940-4f374ca027cb/resourceGroups/MC_MARKETFLOW0-RG_MARKETFLOW0-AKS_NORTHEUROPE/PROVIDERS/MICROSOFT.COMPUTE/VIRTUALMACHINESCALESETS/AKS-SYSTEM-29940087-VMSS/VIRTUALMACHINES/0/NETWORKINTERFACES/AKS-SYSTEM-29940087-VMSS/ipConfigurations/IPCONFIG4",
      "resourceGroup": "MC_MARKETFLOW0-RG_MARKETFLOW0-AKS_NORTHEUROPE"
    },
    {
      "id": "/subscriptions/65fe7e97-9f6f-4f82-b940-4f374ca027cb/resourceGroups/MC_MARKETFLOW0-RG_MARKETFLOW0-AKS_NORTHEUROPE/PROVIDERS/MICROSOFT.COMPUTE/VIRTUALMACHINESCALESETS/AKS-SYSTEM-29940087-VMSS/VIRTUALMACHINES/0/NETWORKINTERFACES/AKS-SYSTEM-29940087-VMSS/ipConfigurations/IPCONFIG5",
      "resourceGroup": "MC_MARKETFLOW0-RG_MARKETFLOW0-AKS_NORTHEUROPE"
    },
    {
      "id": "/subscriptions/65fe7e97-9f6f-4f82-b940-4f374ca027cb/resourceGroups/MC_MARKETFLOW0-RG_MARKETFLOW0-AKS_NORTHEUROPE/PROVIDERS/MICROSOFT.COMPUTE/VIRTUALMACHINESCALESETS/AKS-SYSTEM-29940087-VMSS/VIRTUALMACHINES/0/NETWORKINTERFACES/AKS-SYSTEM-29940087-VMSS/ipConfigurations/IPCONFIG6",
      "resourceGroup": "MC_MARKETFLOW0-RG_MARKETFLOW0-AKS_NORTHEUROPE"
    },
    {
      "id": "/subscriptions/65fe7e97-9f6f-4f82-b940-4f374ca027cb/resourceGroups/MC_MARKETFLOW0-RG_MARKETFLOW0-AKS_NORTHEUROPE/PROVIDERS/MICROSOFT.COMPUTE/VIRTUALMACHINESCALESETS/AKS-SYSTEM-29940087-VMSS/VIRTUALMACHINES/0/NETWORKINTERFACES/AKS-SYSTEM-29940087-VMSS/ipConfigurations/IPCONFIG7",
      "resourceGroup": "MC_MARKETFLOW0-RG_MARKETFLOW0-AKS_NORTHEUROPE"
    },
    {
      "id": "/subscriptions/65fe7e97-9f6f-4f82-b940-4f374ca027cb/resourceGroups/MC_MARKETFLOW0-RG_MARKETFLOW0-AKS_NORTHEUROPE/PROVIDERS/MICROSOFT.COMPUTE/VIRTUALMACHINESCALESETS/AKS-SYSTEM-29940087-VMSS/VIRTUALMACHINES/0/NETWORKINTERFACES/AKS-SYSTEM-29940087-VMSS/ipConfigurations/IPCONFIG8",
      "resourceGroup": "MC_MARKETFLOW0-RG_MARKETFLOW0-AKS_NORTHEUROPE"
    },
    {
      "id": "/subscriptions/65fe7e97-9f6f-4f82-b940-4f374ca027cb/resourceGroups/MC_MARKETFLOW0-RG_MARKETFLOW0-AKS_NORTHEUROPE/PROVIDERS/MICROSOFT.COMPUTE/VIRTUALMACHINESCALESETS/AKS-SYSTEM-29940087-VMSS/VIRTUALMACHINES/0/NETWORKINTERFACES/AKS-SYSTEM-29940087-VMSS/ipConfigurations/IPCONFIG9",
      "resourceGroup": "MC_MARKETFLOW0-RG_MARKETFLOW0-AKS_NORTHEUROPE"
    },
    {
      "id": "/subscriptions/65fe7e97-9f6f-4f82-b940-4f374ca027cb/resourceGroups/MC_MARKETFLOW0-RG_MARKETFLOW0-AKS_NORTHEUROPE/PROVIDERS/MICROSOFT.COMPUTE/VIRTUALMACHINESCALESETS/AKS-SYSTEM-29940087-VMSS/VIRTUALMACHINES/1/NETWORKINTERFACES/AKS-SYSTEM-29940087-VMSS/ipConfigurations/IPCONFIG1",
      "resourceGroup": "MC_MARKETFLOW0-RG_MARKETFLOW0-AKS_NORTHEUROPE"
    },
    {
      "id": "/subscriptions/65fe7e97-9f6f-4f82-b940-4f374ca027cb/resourceGroups/MC_MARKETFLOW0-RG_MARKETFLOW0-AKS_NORTHEUROPE/PROVIDERS/MICROSOFT.COMPUTE/VIRTUALMACHINESCALESETS/AKS-SYSTEM-29940087-VMSS/VIRTUALMACHINES/1/NETWORKINTERFACES/AKS-SYSTEM-29940087-VMSS/ipConfigurations/IPCONFIG10",
      "resourceGroup": "MC_MARKETFLOW0-RG_MARKETFLOW0-AKS_NORTHEUROPE"
    },
    {
      "id": "/subscriptions/65fe7e97-9f6f-4f82-b940-4f374ca027cb/resourceGroups/MC_MARKETFLOW0-RG_MARKETFLOW0-AKS_NORTHEUROPE/PROVIDERS/MICROSOFT.COMPUTE/VIRTUALMACHINESCALESETS/AKS-SYSTEM-29940087-VMSS/VIRTUALMACHINES/1/NETWORKINTERFACES/AKS-SYSTEM-29940087-VMSS/ipConfigurations/IPCONFIG11",
      "resourceGroup": "MC_MARKETFLOW0-RG_MARKETFLOW0-AKS_NORTHEUROPE"
    },
    {
      "id": "/subscriptions/65fe7e97-9f6f-4f82-b940-4f374ca027cb/resourceGroups/MC_MARKETFLOW0-RG_MARKETFLOW0-AKS_NORTHEUROPE/PROVIDERS/MICROSOFT.COMPUTE/VIRTUALMACHINESCALESETS/AKS-SYSTEM-29940087-VMSS/VIRTUALMACHINES/1/NETWORKINTERFACES/AKS-SYSTEM-29940087-VMSS/ipConfigurations/IPCONFIG12",
      "resourceGroup": "MC_MARKETFLOW0-RG_MARKETFLOW0-AKS_NORTHEUROPE"
    },
    {
      "id": "/subscriptions/65fe7e97-9f6f-4f82-b940-4f374ca027cb/resourceGroups/MC_MARKETFLOW0-RG_MARKETFLOW0-AKS_NORTHEUROPE/PROVIDERS/MICROSOFT.COMPUTE/VIRTUALMACHINESCALESETS/AKS-SYSTEM-29940087-VMSS/VIRTUALMACHINES/1/NETWORKINTERFACES/AKS-SYSTEM-29940087-VMSS/ipConfigurations/IPCONFIG13",
      "resourceGroup": "MC_MARKETFLOW0-RG_MARKETFLOW0-AKS_NORTHEUROPE"
    },
    {
      "id": "/subscriptions/65fe7e97-9f6f-4f82-b940-4f374ca027cb/resourceGroups/MC_MARKETFLOW0-RG_MARKETFLOW0-AKS_NORTHEUROPE/PROVIDERS/MICROSOFT.COMPUTE/VIRTUALMACHINESCALESETS/AKS-SYSTEM-29940087-VMSS/VIRTUALMACHINES/1/NETWORKINTERFACES/AKS-SYSTEM-29940087-VMSS/ipConfigurations/IPCONFIG14",
      "resourceGroup": "MC_MARKETFLOW0-RG_MARKETFLOW0-AKS_NORTHEUROPE"
    },
    {
      "id": "/subscriptions/65fe7e97-9f6f-4f82-b940-4f374ca027cb/resourceGroups/MC_MARKETFLOW0-RG_MARKETFLOW0-AKS_NORTHEUROPE/PROVIDERS/MICROSOFT.COMPUTE/VIRTUALMACHINESCALESETS/AKS-SYSTEM-29940087-VMSS/VIRTUALMACHINES/1/NETWORKINTERFACES/AKS-SYSTEM-29940087-VMSS/ipConfigurations/IPCONFIG15",
      "resourceGroup": "MC_MARKETFLOW0-RG_MARKETFLOW0-AKS_NORTHEUROPE"
    },
    {
      "id": "/subscriptions/65fe7e97-9f6f-4f82-b940-4f374ca027cb/resourceGroups/MC_MARKETFLOW0-RG_MARKETFLOW0-AKS_NORTHEUROPE/PROVIDERS/MICROSOFT.COMPUTE/VIRTUALMACHINESCALESETS/AKS-SYSTEM-29940087-VMSS/VIRTUALMACHINES/1/NETWORKINTERFACES/AKS-SYSTEM-29940087-VMSS/ipConfigurations/IPCONFIG16",
      "resourceGroup": "MC_MARKETFLOW0-RG_MARKETFLOW0-AKS_NORTHEUROPE"
    },
    {
      "id": "/subscriptions/65fe7e97-9f6f-4f82-b940-4f374ca027cb/resourceGroups/MC_MARKETFLOW0-RG_MARKETFLOW0-AKS_NORTHEUROPE/PROVIDERS/MICROSOFT.COMPUTE/VIRTUALMACHINESCALESETS/AKS-SYSTEM-29940087-VMSS/VIRTUALMACHINES/1/NETWORKINTERFACES/AKS-SYSTEM-29940087-VMSS/ipConfigurations/IPCONFIG17",
      "resourceGroup": "MC_MARKETFLOW0-RG_MARKETFLOW0-AKS_NORTHEUROPE"
    },
    {
      "id": "/subscriptions/65fe7e97-9f6f-4f82-b940-4f374ca027cb/resourceGroups/MC_MARKETFLOW0-RG_MARKETFLOW0-AKS_NORTHEUROPE/PROVIDERS/MICROSOFT.COMPUTE/VIRTUALMACHINESCALESETS/AKS-SYSTEM-29940087-VMSS/VIRTUALMACHINES/1/NETWORKINTERFACES/AKS-SYSTEM-29940087-VMSS/ipConfigurations/IPCONFIG18",
      "resourceGroup": "MC_MARKETFLOW0-RG_MARKETFLOW0-AKS_NORTHEUROPE"
    },
    {
      "id": "/subscriptions/65fe7e97-9f6f-4f82-b940-4f374ca027cb/resourceGroups/MC_MARKETFLOW0-RG_MARKETFLOW0-AKS_NORTHEUROPE/PROVIDERS/MICROSOFT.COMPUTE/VIRTUALMACHINESCALESETS/AKS-SYSTEM-29940087-VMSS/VIRTUALMACHINES/1/NETWORKINTERFACES/AKS-SYSTEM-29940087-VMSS/ipConfigurations/IPCONFIG19",
      "resourceGroup": "MC_MARKETFLOW0-RG_MARKETFLOW0-AKS_NORTHEUROPE"
    },
    {
      "id": "/subscriptions/65fe7e97-9f6f-4f82-b940-4f374ca027cb/resourceGroups/MC_MARKETFLOW0-RG_MARKETFLOW0-AKS_NORTHEUROPE/PROVIDERS/MICROSOFT.COMPUTE/VIRTUALMACHINESCALESETS/AKS-SYSTEM-29940087-VMSS/VIRTUALMACHINES/1/NETWORKINTERFACES/AKS-SYSTEM-29940087-VMSS/ipConfigurations/IPCONFIG2",
      "resourceGroup": "MC_MARKETFLOW0-RG_MARKETFLOW0-AKS_NORTHEUROPE"
    },
    {
      "id": "/subscriptions/65fe7e97-9f6f-4f82-b940-4f374ca027cb/resourceGroups/MC_MARKETFLOW0-RG_MARKETFLOW0-AKS_NORTHEUROPE/PROVIDERS/MICROSOFT.COMPUTE/VIRTUALMACHINESCALESETS/AKS-SYSTEM-29940087-VMSS/VIRTUALMACHINES/1/NETWORKINTERFACES/AKS-SYSTEM-29940087-VMSS/ipConfigurations/IPCONFIG20",
      "resourceGroup": "MC_MARKETFLOW0-RG_MARKETFLOW0-AKS_NORTHEUROPE"
    },
    {
      "id": "/subscriptions/65fe7e97-9f6f-4f82-b940-4f374ca027cb/resourceGroups/MC_MARKETFLOW0-RG_MARKETFLOW0-AKS_NORTHEUROPE/PROVIDERS/MICROSOFT.COMPUTE/VIRTUALMACHINESCALESETS/AKS-SYSTEM-29940087-VMSS/VIRTUALMACHINES/1/NETWORKINTERFACES/AKS-SYSTEM-29940087-VMSS/ipConfigurations/IPCONFIG21",
      "resourceGroup": "MC_MARKETFLOW0-RG_MARKETFLOW0-AKS_NORTHEUROPE"
    },
    {
      "id": "/subscriptions/65fe7e97-9f6f-4f82-b940-4f374ca027cb/resourceGroups/MC_MARKETFLOW0-RG_MARKETFLOW0-AKS_NORTHEUROPE/PROVIDERS/MICROSOFT.COMPUTE/VIRTUALMACHINESCALESETS/AKS-SYSTEM-29940087-VMSS/VIRTUALMACHINES/1/NETWORKINTERFACES/AKS-SYSTEM-29940087-VMSS/ipConfigurations/IPCONFIG22",
      "resourceGroup": "MC_MARKETFLOW0-RG_MARKETFLOW0-AKS_NORTHEUROPE"
    },
    {
      "id": "/subscriptions/65fe7e97-9f6f-4f82-b940-4f374ca027cb/resourceGroups/MC_MARKETFLOW0-RG_MARKETFLOW0-AKS_NORTHEUROPE/PROVIDERS/MICROSOFT.COMPUTE/VIRTUALMACHINESCALESETS/AKS-SYSTEM-29940087-VMSS/VIRTUALMACHINES/1/NETWORKINTERFACES/AKS-SYSTEM-29940087-VMSS/ipConfigurations/IPCONFIG23",
      "resourceGroup": "MC_MARKETFLOW0-RG_MARKETFLOW0-AKS_NORTHEUROPE"
    },
    {
      "id": "/subscriptions/65fe7e97-9f6f-4f82-b940-4f374ca027cb/resourceGroups/MC_MARKETFLOW0-RG_MARKETFLOW0-AKS_NORTHEUROPE/PROVIDERS/MICROSOFT.COMPUTE/VIRTUALMACHINESCALESETS/AKS-SYSTEM-29940087-VMSS/VIRTUALMACHINES/1/NETWORKINTERFACES/AKS-SYSTEM-29940087-VMSS/ipConfigurations/IPCONFIG24",
      "resourceGroup": "MC_MARKETFLOW0-RG_MARKETFLOW0-AKS_NORTHEUROPE"
    },
    {
      "id": "/subscriptions/65fe7e97-9f6f-4f82-b940-4f374ca027cb/resourceGroups/MC_MARKETFLOW0-RG_MARKETFLOW0-AKS_NORTHEUROPE/PROVIDERS/MICROSOFT.COMPUTE/VIRTUALMACHINESCALESETS/AKS-SYSTEM-29940087-VMSS/VIRTUALMACHINES/1/NETWORKINTERFACES/AKS-SYSTEM-29940087-VMSS/ipConfigurations/IPCONFIG25",
      "resourceGroup": "MC_MARKETFLOW0-RG_MARKETFLOW0-AKS_NORTHEUROPE"
    },
    {
      "id": "/subscriptions/65fe7e97-9f6f-4f82-b940-4f374ca027cb/resourceGroups/MC_MARKETFLOW0-RG_MARKETFLOW0-AKS_NORTHEUROPE/PROVIDERS/MICROSOFT.COMPUTE/VIRTUALMACHINESCALESETS/AKS-SYSTEM-29940087-VMSS/VIRTUALMACHINES/1/NETWORKINTERFACES/AKS-SYSTEM-29940087-VMSS/ipConfigurations/IPCONFIG26",
      "resourceGroup": "MC_MARKETFLOW0-RG_MARKETFLOW0-AKS_NORTHEUROPE"
    },
    {
      "id": "/subscriptions/65fe7e97-9f6f-4f82-b940-4f374ca027cb/resourceGroups/MC_MARKETFLOW0-RG_MARKETFLOW0-AKS_NORTHEUROPE/PROVIDERS/MICROSOFT.COMPUTE/VIRTUALMACHINESCALESETS/AKS-SYSTEM-29940087-VMSS/VIRTUALMACHINES/1/NETWORKINTERFACES/AKS-SYSTEM-29940087-VMSS/ipConfigurations/IPCONFIG27",
      "resourceGroup": "MC_MARKETFLOW0-RG_MARKETFLOW0-AKS_NORTHEUROPE"
    },
    {
      "id": "/subscriptions/65fe7e97-9f6f-4f82-b940-4f374ca027cb/resourceGroups/MC_MARKETFLOW0-RG_MARKETFLOW0-AKS_NORTHEUROPE/PROVIDERS/MICROSOFT.COMPUTE/VIRTUALMACHINESCALESETS/AKS-SYSTEM-29940087-VMSS/VIRTUALMACHINES/1/NETWORKINTERFACES/AKS-SYSTEM-29940087-VMSS/ipConfigurations/IPCONFIG28",
      "resourceGroup": "MC_MARKETFLOW0-RG_MARKETFLOW0-AKS_NORTHEUROPE"
    },
    {
      "id": "/subscriptions/65fe7e97-9f6f-4f82-b940-4f374ca027cb/resourceGroups/MC_MARKETFLOW0-RG_MARKETFLOW0-AKS_NORTHEUROPE/PROVIDERS/MICROSOFT.COMPUTE/VIRTUALMACHINESCALESETS/AKS-SYSTEM-29940087-VMSS/VIRTUALMACHINES/1/NETWORKINTERFACES/AKS-SYSTEM-29940087-VMSS/ipConfigurations/IPCONFIG29",
      "resourceGroup": "MC_MARKETFLOW0-RG_MARKETFLOW0-AKS_NORTHEUROPE"
    },
    {
      "id": "/subscriptions/65fe7e97-9f6f-4f82-b940-4f374ca027cb/resourceGroups/MC_MARKETFLOW0-RG_MARKETFLOW0-AKS_NORTHEUROPE/PROVIDERS/MICROSOFT.COMPUTE/VIRTUALMACHINESCALESETS/AKS-SYSTEM-29940087-VMSS/VIRTUALMACHINES/1/NETWORKINTERFACES/AKS-SYSTEM-29940087-VMSS/ipConfigurations/IPCONFIG3",
      "resourceGroup": "MC_MARKETFLOW0-RG_MARKETFLOW0-AKS_NORTHEUROPE"
    },
    {
      "id": "/subscriptions/65fe7e97-9f6f-4f82-b940-4f374ca027cb/resourceGroups/MC_MARKETFLOW0-RG_MARKETFLOW0-AKS_NORTHEUROPE/PROVIDERS/MICROSOFT.COMPUTE/VIRTUALMACHINESCALESETS/AKS-SYSTEM-29940087-VMSS/VIRTUALMACHINES/1/NETWORKINTERFACES/AKS-SYSTEM-29940087-VMSS/ipConfigurations/IPCONFIG4",
      "resourceGroup": "MC_MARKETFLOW0-RG_MARKETFLOW0-AKS_NORTHEUROPE"
    },
    {
      "id": "/subscriptions/65fe7e97-9f6f-4f82-b940-4f374ca027cb/resourceGroups/MC_MARKETFLOW0-RG_MARKETFLOW0-AKS_NORTHEUROPE/PROVIDERS/MICROSOFT.COMPUTE/VIRTUALMACHINESCALESETS/AKS-SYSTEM-29940087-VMSS/VIRTUALMACHINES/1/NETWORKINTERFACES/AKS-SYSTEM-29940087-VMSS/ipConfigurations/IPCONFIG5",
      "resourceGroup": "MC_MARKETFLOW0-RG_MARKETFLOW0-AKS_NORTHEUROPE"
    },
    {
      "id": "/subscriptions/65fe7e97-9f6f-4f82-b940-4f374ca027cb/resourceGroups/MC_MARKETFLOW0-RG_MARKETFLOW0-AKS_NORTHEUROPE/PROVIDERS/MICROSOFT.COMPUTE/VIRTUALMACHINESCALESETS/AKS-SYSTEM-29940087-VMSS/VIRTUALMACHINES/1/NETWORKINTERFACES/AKS-SYSTEM-29940087-VMSS/ipConfigurations/IPCONFIG6",
      "resourceGroup": "MC_MARKETFLOW0-RG_MARKETFLOW0-AKS_NORTHEUROPE"
    },
    {
      "id": "/subscriptions/65fe7e97-9f6f-4f82-b940-4f374ca027cb/resourceGroups/MC_MARKETFLOW0-RG_MARKETFLOW0-AKS_NORTHEUROPE/PROVIDERS/MICROSOFT.COMPUTE/VIRTUALMACHINESCALESETS/AKS-SYSTEM-29940087-VMSS/VIRTUALMACHINES/1/NETWORKINTERFACES/AKS-SYSTEM-29940087-VMSS/ipConfigurations/IPCONFIG7",
      "resourceGroup": "MC_MARKETFLOW0-RG_MARKETFLOW0-AKS_NORTHEUROPE"
    },
    {
      "id": "/subscriptions/65fe7e97-9f6f-4f82-b940-4f374ca027cb/resourceGroups/MC_MARKETFLOW0-RG_MARKETFLOW0-AKS_NORTHEUROPE/PROVIDERS/MICROSOFT.COMPUTE/VIRTUALMACHINESCALESETS/AKS-SYSTEM-29940087-VMSS/VIRTUALMACHINES/1/NETWORKINTERFACES/AKS-SYSTEM-29940087-VMSS/ipConfigurations/IPCONFIG8",
      "resourceGroup": "MC_MARKETFLOW0-RG_MARKETFLOW0-AKS_NORTHEUROPE"
    },
    {
      "id": "/subscriptions/65fe7e97-9f6f-4f82-b940-4f374ca027cb/resourceGroups/MC_MARKETFLOW0-RG_MARKETFLOW0-AKS_NORTHEUROPE/PROVIDERS/MICROSOFT.COMPUTE/VIRTUALMACHINESCALESETS/AKS-SYSTEM-29940087-VMSS/VIRTUALMACHINES/1/NETWORKINTERFACES/AKS-SYSTEM-29940087-VMSS/ipConfigurations/IPCONFIG9",
      "resourceGroup": "MC_MARKETFLOW0-RG_MARKETFLOW0-AKS_NORTHEUROPE"
    }
  ],
  "name": "aks-subnet-prod",
  "networkSecurityGroup": {
    "id": "/subscriptions/65fe7e97-9f6f-4f82-b940-4f374ca027cb/resourceGroups/marketflow0-rg/providers/Microsoft.Network/networkSecurityGroups/marketflow0-prod-nsg",
    "resourceGroup": "marketflow0-rg"
  },
  "privateEndpointNetworkPolicies": "Disabled",
  "privateLinkServiceNetworkPolicies": "Enabled",
  "provisioningState": "Succeeded",
  "resourceGroup": "marketflow0-rg",
  "serviceEndpoints": [],
  "type": "Microsoft.Network/virtualNetworks/subnets"
}


### 🧩 **Problem Summary: Azure AKS Load Balancer not reachable from the Internet**

We spent significant time debugging **why the AKS ingress endpoint ([https://httpbin.okondratov.online](https://httpbin.okondratov.online))** was **inaccessible externally**, even though:

* The public IP (`128.251.42.38`) was correctly provisioned and assigned to the AKS-managed load balancer.
* The Ingress and TLS certificate were successfully configured.
* Internal connectivity (in-cluster `curl` to service DNS) was **fully functional**.

#### 💥 Root Cause:

The issue was due to **Network Security Group (NSG) misconfiguration** on the **AKS agentpool subnet**, which is managed under the **MC_*** resource group.

Even though we defined and applied **custom NSGs** (e.g., `marketflow0-prod-nsg`) on our VNET subnets, **the actual AKS nodes were running in the system-generated subnet with its own NSG (`aks-agentpool-...-nsg`)** — where **inbound access was still blocked by default**.

#### 🔍 Clues:

* From outside: `curl https://httpbin.okondratov.online` timed out.
* From within the cluster: `kubectl run curl -- curl https://httpbin.okondratov.online` **succeeded**.
* NSG rules on the MC_* resource group showed default `DenyAllInbound` and no rule for 443 on the public IP.
* Probes and LB rules were correctly provisioned, but the load balancer health check was not reaching backend pods.

#### ✅ Solution:

We added an **NSG rule directly on the system-managed NSG** (`aks-agentpool-...-nsg`) allowing **Inbound TCP traffic on ports 80 and 443** from `Internet`, limited to our public LB IPs (`128.251.42.38`, `4.210.65.14`).

```json
{
  "name": "k8s-azure-lb_allow_IPv4",
  "access": "Allow",
  "direction": "Inbound",
  "priority": 500,
  "protocol": "Tcp",
  "sourceAddressPrefix": "Internet",
  "destinationAddressPrefixes": [
    "128.251.42.38",
    "4.210.65.14"
  ],
  "destinationPortRanges": ["80", "443"]
}
```

After that, external HTTPS access immediately started working.
