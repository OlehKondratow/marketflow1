## 🧩 **I. Pre-AKS Creation Steps (Mandatory)**

### 🎯 Goal:

To have the cluster connect to an existing network instead of creating "MC_*" resources with its own NSG/VNet/Subnet.

---

### 1️⃣ Create a Resource Group

```bash
az group create --name marketflow-rg --location westeurope
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

### 3️⃣ Create Your Own VNet and Subnet

(the cluster must use a pre-created network)

```bash
az network vnet create \
  --resource-group marketflow-rg \
  --name marketflow-vnet \
  --address-prefixes 10.240.0.0/16 \
  --subnet-name aks-subnet \
  --subnet-prefix 10.240.0.0/24
```
```json
{
  "newVNet": {
    "addressSpace": {
      "addressPrefixes": [
        "10.240.0.0/16"
      ]
    },
    "enableDdosProtection": false,
    "etag": "W/\"2c230112-da51-4f5d-9f6c-c24706f5bb73\"",
    "id": "/subscriptions/65fe7e97-9f6f-4f82-b940-4f374ca027cb/resourceGroups/marketflow-rg/providers/Microsoft.Network/virtualNetworks/marketflow-vnet",
    "location": "westeurope",
    "name": "marketflow-vnet",
    "privateEndpointVNetPolicies": "Disabled",
    "provisioningState": "Succeeded",
    "resourceGroup": "marketflow-rg",
    "resourceGuid": "19ea60db-919c-4387-a92e-248f0a623c02",
    "subnets": [
      {
        "addressPrefix": "10.240.0.0/24",
        "delegations": [],
        "etag": "W/\"2c230112-da51-4f5d-9f6c-c24706f5bb73\"",
        "id": "/subscriptions/65fe7e97-9f6f-4f82-b940-4f374ca027cb/resourceGroups/marketflow-rg/providers/Microsoft.Network/virtualNetworks/marketflow-vnet/subnets/aks-subnet",
        "name": "aks-subnet",
        "privateEndpointNetworkPolicies": "Disabled",
        "privateLinkServiceNetworkPolicies": "Enabled",
        "provisioningState": "Succeeded",
        "resourceGroup": "marketflow-rg",
        "type": "Microsoft.Network/virtualNetworks/subnets"
      }
    ],
    "type": "Microsoft.Network/virtualNetworks",
    "virtualNetworkPeerings": []
  }
}
```
---

### 4️⃣ Create and Attach a Network Security Group (NSG)

(controls inbound/outbound ports for the subnet)

```bash
az network nsg create \
  --resource-group marketflow-rg \
  --name marketflow-lb-nsg \
  --location westeurope
```json
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
        "etag": "W/\"2b8d2192-1570-4ba7-a1b6-ac531182c1bb\"",
        "id": "/subscriptions/65fe7e97-9f6f-4f82-b940-4f374ca027cb/resourceGroups/marketflow-rg/providers/Microsoft.Network/networkSecurityGroups/marketflow-lb-nsg/defaultSecurityRules/AllowVnetInBound",
        "name": "AllowVnetInBound",
        "priority": 65000,
        "protocol": "*",
        "provisioningState": "Succeeded",
        "resourceGroup": "marketflow-rg",
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
        "etag": "W/\"2b8d2192-1570-4ba7-a1b6-ac531182c1bb\"",
        "id": "/subscriptions/65fe7e97-9f6f-4f82-b940-4f374ca027cb/resourceGroups/marketflow-rg/providers/Microsoft.Network/networkSecurityGroups/marketflow-lb-nsg/defaultSecurityRules/AllowAzureLoadBalancerInBound",
        "name": "AllowAzureLoadBalancerInBound",
        "priority": 65001,
        "protocol": "*",
        "provisioningState": "Succeeded",
        "resourceGroup": "marketflow-rg",
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
        "etag": "W/\"2b8d2192-1570-4ba7-a1b6-ac531182c1bb\"",
        "id": "/subscriptions/65fe7e97-9f6f-4f82-b940-4f374ca027cb/resourceGroups/marketflow-rg/providers/Microsoft.Network/networkSecurityGroups/marketflow-lb-nsg/defaultSecurityRules/DenyAllInBound",
        "name": "DenyAllInBound",
        "priority": 65500,
        "protocol": "*",
        "provisioningState": "Succeeded",
        "resourceGroup": "marketflow-rg",
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
        "etag": "W/\"2b8d2192-1570-4ba7-a1b6-ac531182c1bb\"",
        "id": "/subscriptions/65fe7e97-9f6f-4f82-b940-4f374ca027cb/resourceGroups/marketflow-rg/providers/Microsoft.Network/networkSecurityGroups/marketflow-lb-nsg/defaultSecurityRules/AllowVnetOutBound",
        "name": "AllowVnetOutBound",
        "priority": 65000,
        "protocol": "*",
        "provisioningState": "Succeeded",
        "resourceGroup": "marketflow-rg",
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
        "etag": "W/\"2b8d2192-1570-4ba7-a1b6-ac531182c1bb\"",
        "id": "/subscriptions/65fe7e97-9f6f-4f82-b940-4f374ca027cb/resourceGroups/marketflow-rg/providers/Microsoft.Network/networkSecurityGroups/marketflow-lb-nsg/defaultSecurityRules/AllowInternetOutBound",
        "name": "AllowInternetOutBound",
        "priority": 65001,
        "protocol": "*",
        "provisioningState": "Succeeded",
        "resourceGroup": "marketflow-rg",
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
        "etag": "W/\"2b8d2192-1570-4ba7-a1b6-ac531182c1bb\"",
        "id": "/subscriptions/65fe7e97-9f6f-4f82-b940-4f374ca027cb/resourceGroups/marketflow-rg/providers/Microsoft.Network/networkSecurityGroups/marketflow-lb-nsg/defaultSecurityRules/DenyAllOutBound",
        "name": "DenyAllOutBound",
        "priority": 65500,
        "protocol": "*",
        "provisioningState": "Succeeded",
        "resourceGroup": "marketflow-rg",
        "sourceAddressPrefix": "*",
        "sourceAddressPrefixes": [],
        "sourcePortRange": "*",
        "sourcePortRanges": [],
        "type": "Microsoft.Network/networkSecurityGroups/defaultSecurityRules"
      }
    ],
    "etag": "W/\"2b8d2192-1570-4ba7-a1b6-ac531182c1bb\"",
    "id": "/subscriptions/65fe7e97-9f6f-4f82-b940-4f374ca027cb/resourceGroups/marketflow-rg/providers/Microsoft.Network/networkSecurityGroups/marketflow-lb-nsg",
    "location": "westeurope",
    "name": "marketflow-lb-nsg",
    "provisioningState": "Succeeded",
    "resourceGroup": "marketflow-rg",
    "resourceGuid": "3eaf4f1c-8861-4cd4-9e73-0e2969fc4cf2",
    "securityRules": [],
    "type": "Microsoft.Network/networkSecurityGroups"
  }
}
```

az network nsg rule create \
  --resource-group marketflow-rg \
  --nsg-name marketflow-lb-nsg \
  --name AllowHTTPHTTPSInbound \
  --priority 100 \
  --access Allow \
  --direction Inbound \
  --protocol Tcp \
  --source-address-prefix Internet \
  --destination-port-ranges 443
``` 
```json
{
  "access": "Allow",
  "destinationAddressPrefix": "*",
  "destinationAddressPrefixes": [],
  "destinationPortRange": "443",
  "destinationPortRanges": [],
  "direction": "Inbound",
  "etag": "W/\"9b194dec-bf12-40c1-816e-fe60df27046a\"",
  "id": "/subscriptions/65fe7e97-9f6f-4f82-b940-4f374ca027cb/resourceGroups/marketflow-rg/providers/Microsoft.Network/networkSecurityGroups/marketflow-lb-nsg/securityRules/AllowHTTPHTTPSInbound",
  "name": "AllowHTTPHTTPSInbound",
  "priority": 100,
  "protocol": "Tcp",
  "provisioningState": "Succeeded",
  "resourceGroup": "marketflow-rg",
  "sourceAddressPrefix": "Internet",
  "sourceAddressPrefixes": [],
  "sourcePortRange": "*",
  "sourcePortRanges": [],
  "type": "Microsoft.Network/networkSecurityGroups/securityRules"
}
```
and attach it:

```bash
az network vnet subnet update \
  --resource-group marketflow-rg \
  --vnet-name marketflow-vnet \
  --name aks-subnet \
  --network-security-group marketflow-lb-nsg
```
```json
{
  "addressPrefix": "10.240.0.0/24",
  "delegations": [],
  "etag": "W/\"f8dc455f-a6c7-4570-bb75-604cb6330194\"",
  "id": "/subscriptions/65fe7e97-9f6f-4f82-b940-4f374ca027cb/resourceGroups/marketflow-rg/providers/Microsoft.Network/virtualNetworks/marketflow-vnet/subnets/aks-subnet",
  "name": "aks-subnet",
  "networkSecurityGroup": {
    "id": "/subscriptions/65fe7e97-9f6f-4f82-b940-4f374ca027cb/resourceGroups/marketflow-rg/providers/Microsoft.Network/networkSecurityGroups/marketflow-lb-nsg",
    "resourceGroup": "marketflow-rg"
  },
  "privateEndpointNetworkPolicies": "Disabled",
  "privateLinkServiceNetworkPolicies": "Enabled",
  "provisioningState": "Succeeded",
  "resourceGroup": "marketflow-rg",
  "type": "Microsoft.Network/virtualNetworks/subnets"
}
```
---

### 5️⃣ Get the Subnet ID and Use It When Creating AKS

```bash
az network vnet subnet show \
  --resource-group marketflow-rg \
  --vnet-name marketflow-vnet \
  --name aks-subnet \
  --query id -o tsv
  
/subscriptions/65fe7e97-9f6f-4f82-b940-4f374ca027cb/resourceGroups/marketflow-rg/providers/Microsoft.Network/virtualNetworks/marketflow-vnet/subnets/aks-subnet
```
