# 7. Azure Kubernetes Service (AKS)

# Get subnet ID
az network vnet subnet show \
  --resource-group marketflow-rg \
  --vnet-name marketflow-vnet \
  --name aks-subnet \
  --query id -o tsv


### 7.1. Create AKS Cluster
```bash
az aks create \
  --name marketflow-aks \
  --resource-group marketflow-rg \
  --location westeurope \
  --enable-managed-identity \
  --enable-oidc-issuer \
  --enable-workload-identity \
  --enable-addons monitoring \
  --node-vm-size Standard_B2s \
  --node-count 2 \
  --attach-acr marketflowregistry \
  --enable-msi-auth-for-monitoring \
  --network-plugin azure \
  --network-plugin-mode overlay \
  --vnet-subnet-id "/subscriptions/65fe7e97-9f6f-4f82-b940-4f374ca027cb/resourceGroups/marketflow-rg/providers/Microsoft.Network/virtualNetworks/marketflow-vnet/subnets/aks-subnet" \
  --generate-ssh-keys

```

```json
{
  "aadProfile": null,
  "addonProfiles": {
    "omsagent": {
      "config": {
        "logAnalyticsWorkspaceResourceID": "/subscriptions/65fe7e97-9f6f-4f82-b940-4f374ca027cb/resourceGroups/DefaultResourceGroup-WEU/providers/Microsoft.OperationalInsights/workspaces/DefaultWorkspace-65fe7e97-9f6f-4f82-b940-4f374ca027cb-WEU",
        "useAADAuth": "true"
      },
      "enabled": true,
      "identity": null
    }
  },
  "agentPoolProfiles": [
    {
      "availabilityZones": null,
      "capacityReservationGroupId": null,
      "count": 2,
      "creationData": null,
      "currentOrchestratorVersion": "1.32.7",
      "eTag": null,
      "enableAutoScaling": false,
      "enableEncryptionAtHost": false,
      "enableFips": false,
      "enableNodePublicIp": false,
      "enableUltraSsd": false,
      "gatewayProfile": null,
      "gpuInstanceProfile": null,
      "gpuProfile": null,
      "hostGroupId": null,
      "kubeletConfig": null,
      "kubeletDiskType": "OS",
      "linuxOsConfig": null,
      "maxCount": null,
      "maxPods": 250,
      "messageOfTheDay": null,
      "minCount": null,
      "mode": "System",
      "name": "nodepool1",
      "networkProfile": null,
      "nodeImageVersion": "AKSUbuntu-2204gen2containerd-202510.03.0",
      "nodeLabels": null,
      "nodePublicIpPrefixId": null,
      "nodeTaints": null,
      "orchestratorVersion": "1.32",
      "osDiskSizeGb": 128,
      "osDiskType": "Managed",
      "osSku": "Ubuntu",
      "osType": "Linux",
      "podIpAllocationMode": null,
      "podSubnetId": null,
      "powerState": {
        "code": "Running"
      },
      "provisioningState": "Succeeded",
      "proximityPlacementGroupId": null,
      "scaleDownMode": "Delete",
      "scaleSetEvictionPolicy": null,
      "scaleSetPriority": null,
      "securityProfile": {
        "enableSecureBoot": false,
        "enableVtpm": false
      },
      "spotMaxPrice": null,
      "status": null,
      "tags": null,
      "type": "VirtualMachineScaleSets",
      "upgradeSettings": {
        "drainTimeoutInMinutes": null,
        "maxSurge": "10%",
        "maxUnavailable": "0",
        "nodeSoakDurationInMinutes": null,
        "undrainableNodeBehavior": null
      },
      "virtualMachineNodesStatus": null,
      "virtualMachinesProfile": null,
      "vmSize": "Standard_B2s",
      "vnetSubnetId": "/subscriptions/65fe7e97-9f6f-4f82-b940-4f374ca027cb/resourceGroups/marketflow-rg/providers/Microsoft.Network/virtualNetworks/marketflow-vnet/subnets/aks-subnet",
      "windowsProfile": null,
      "workloadRuntime": null
    }
  ],
  "aiToolchainOperatorProfile": null,
  "apiServerAccessProfile": null,
  "autoScalerProfile": null,
  "autoUpgradeProfile": {
    "nodeOsUpgradeChannel": "NodeImage",
    "upgradeChannel": null
  },
  "azureMonitorProfile": {
    "metrics": null
  },
  "azurePortalFqdn": "marketflow-marketflow-rg-65fe7e-kh98rsoj.portal.hcp.westeurope.azmk8s.io",
  "bootstrapProfile": {
    "artifactSource": "Direct",
    "containerRegistryId": null
  },
  "currentKubernetesVersion": "1.32.7",
  "disableLocalAccounts": false,
  "diskEncryptionSetId": null,
  "dnsPrefix": "marketflow-marketflow-rg-65fe7e",
  "eTag": null,
  "enableRbac": true,
  "extendedLocation": null,
  "fqdn": "marketflow-marketflow-rg-65fe7e-kh98rsoj.hcp.westeurope.azmk8s.io",
  "fqdnSubdomain": null,
  "httpProxyConfig": null,
  "id": "/subscriptions/65fe7e97-9f6f-4f82-b940-4f374ca027cb/resourcegroups/marketflow-rg/providers/Microsoft.ContainerService/managedClusters/marketflow-aks",
  "identity": {
    "delegatedResources": null,
    "principalId": "55b5f02b-f51e-4d8d-930a-25f6a02d7033",
    "tenantId": "7f776ea7-75ee-492e-83f3-40a9552b9320",
    "type": "SystemAssigned",
    "userAssignedIdentities": null
  },
  "identityProfile": {
    "kubeletidentity": {
      "clientId": "0280abe8-9ccd-435b-ad84-6a46a8f7fbb9",
      "objectId": "64515080-80e9-45e8-9ecf-a9a11fe04c91",
      "resourceId": "/subscriptions/65fe7e97-9f6f-4f82-b940-4f374ca027cb/resourcegroups/MC_marketflow-rg_marketflow-aks_westeurope/providers/Microsoft.ManagedIdentity/userAssignedIdentities/marketflow-aks-agentpool"
    }
  },
  "ingressProfile": null,
  "kind": "Base",
  "kubernetesVersion": "1.32",
  "linuxProfile": {
    "adminUsername": "azureuser",
    "ssh": {
      "publicKeys": [
        {
          "keyData": "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABgQC8CfNHvXqA6GYMPwxSo43WOXpkCotxxn99tUHImfzv6TiM5ey/PtpMjnMaXSPJ0sCMafNSq+TZXoGRHLyRYa5y/ulFdFfjlLCSS2JmS0FX63Z2+0BQPcKxFTrmamUVXYNKjeScT0nGDg1OCLdyi/AG4wqXWvOoE71FzDWW5B69kcUyqW8h9NLU79sU/oveI/RZGXdpwT7vDlLTPmDECp4hnIbP/KSt+zKyMraPLeVMBPY4Wfcmm34ckf3xhfmVCi2U3/TNEL1IfOyuAkag3DKtV0MRgy1WVLGpxXxPNVDsHGedgbnbfXvVcDZ8Q6IZZN+uiz1iBqQyc7knYxbr5uOmBZT0hg94isNpIghlLYXiP2p5KJYGyijrpWH3APIISoKbLm2uE9a8p2HgZ9uIX1OHR6lPSvOM8hHks1jk8itpv4K1ISo+Mo1+Vq1UNMZV40MDlpvDgqmDXlSZdjySAPU4ujjtId3kOm9sR+87TM3hInZ/pceFzuyxhAt35wOMffs= pilgrim@ws5\n"
        }
      ]
    }
  },
  "location": "westeurope",
  "maxAgentPools": 100,
  "metricsProfile": {
    "costAnalysis": {
      "enabled": false
    }
  },
  "name": "marketflow-aks",
  "networkProfile": {
    "advancedNetworking": null,
    "dnsServiceIp": "10.0.0.10",
    "ipFamilies": [
      "IPv4"
    ],
    "loadBalancerProfile": {
      "allocatedOutboundPorts": null,
      "backendPoolType": "nodeIPConfiguration",
      "effectiveOutboundIPs": [
        {
          "id": "/subscriptions/65fe7e97-9f6f-4f82-b940-4f374ca027cb/resourceGroups/MC_marketflow-rg_marketflow-aks_westeurope/providers/Microsoft.Network/publicIPAddresses/ca46de0d-3ebf-40d2-b5d0-1b4c5d66f1bf",
          "resourceGroup": "MC_marketflow-rg_marketflow-aks_westeurope"
        }
      ],
      "enableMultipleStandardLoadBalancers": null,
      "idleTimeoutInMinutes": null,
      "managedOutboundIPs": {
        "count": 1,
        "countIpv6": null
      },
      "outboundIPs": null,
      "outboundIpPrefixes": null
    },
    "loadBalancerSku": "standard",
    "natGatewayProfile": null,
    "networkDataplane": "azure",
    "networkMode": null,
    "networkPlugin": "azure",
    "networkPluginMode": "overlay",
    "networkPolicy": "none",
    "outboundType": "loadBalancer",
    "podCidr": "10.244.0.0/16",
    "podCidrs": [
      "10.244.0.0/16"
    ],
    "serviceCidr": "10.0.0.0/16",
    "serviceCidrs": [
      "10.0.0.0/16"
    ],
    "staticEgressGatewayProfile": null
  },
  "nodeProvisioningProfile": {
    "defaultNodePools": "Auto",
    "mode": "Manual"
  },
  "nodeResourceGroup": "MC_marketflow-rg_marketflow-aks_westeurope",
  "nodeResourceGroupProfile": null,
  "oidcIssuerProfile": {
    "enabled": true,
    "issuerUrl": "https://westeurope.oic.prod-aks.azure.com/7f776ea7-75ee-492e-83f3-40a9552b9320/9f7ef169-02d3-424e-bda2-fce56a40e772/"
  },
  "podIdentityProfile": null,
  "powerState": {
    "code": "Running"
  },
  "privateFqdn": null,
  "privateLinkResources": null,
  "provisioningState": "Succeeded",
  "publicNetworkAccess": null,
  "resourceGroup": "marketflow-rg",
  "resourceUid": "68ff63cee8f4cf0001b5b4fe",
  "securityProfile": {
    "azureKeyVaultKms": null,
    "customCaTrustCertificates": null,
    "defender": null,
    "imageCleaner": null,
    "workloadIdentity": {
      "enabled": true
    }
  },
  "serviceMeshProfile": null,
  "servicePrincipalProfile": {
    "clientId": "msi",
    "secret": null
  },
  "sku": {
    "name": "Base",
    "tier": "Free"
  },
  "status": null,
  "storageProfile": {
    "blobCsiDriver": null,
    "diskCsiDriver": {
      "enabled": true
    },
    "fileCsiDriver": {
      "enabled": true
    },
    "snapshotController": {
      "enabled": true
    }
  },
  "supportPlan": "KubernetesOfficial",
  "systemData": null,
  "tags": null,
  "type": "Microsoft.ContainerService/ManagedClusters",
  "upgradeSettings": null,
  "windowsProfile": {
    "adminPassword": null,
    "adminUsername": "azureuser",
    "enableCsiProxy": true,
    "gmsaProfile": null,
    "licenseType": null
  },
  "workloadAutoScalerProfile": {
    "keda": null,
    "verticalPodAutoscaler": null
  }
}
```


### 7.2. Connect to AKS Cluster
```bash
az aks get-credentials --resource-group marketflow-rg --name marketflow-aks

```

### 7.3. Check Nodes and Create Namespaces

```bash
kubectl get nodes -o wide
```
```text
 kubectl get nodes -o wide
NAME                                STATUS   ROLES    AGE     VERSION   INTERNAL-IP   EXTERNAL-IP   OS-IMAGE             KERNEL-VERSION      CONTAINER-RUNTIME
aks-nodepool1-66138655-vmss000000   Ready    <none>   7m11s   v1.32.7   10.240.0.5    <none>        Ubuntu 22.04.5 LTS   5.15.0-1096-azure   containerd://1.7.28-1
aks-nodepool1-66138655-vmss000001   Ready    <none>   7m35s   v1.32.7   10.240.0.4    <none>        Ubuntu 22.04.5 LTS   5.15.0-1096-azure   containerd://1.7.28-1
```
```bash
kubectl create namespace marketflow-dev
kubectl create namespace marketflow-prod
```
```bash
kubectl get ns
```
```text
NAME              STATUS   AGE
default           Active   7m31s
kube-node-lease   Active   7m31s
kube-public       Active   7m31s
kube-system       Active   7m31s
marketflow-dev    Active   24s
marketflow-prod   Active   24s
```
```
kubectl get pods -A
```
```text
NAMESPACE     NAME                                                  READY   STATUS    RESTARTS   AGE
kube-system   ama-logs-22q8x                                        3/3     Running   0          8m44s
kube-system   ama-logs-8crpd                                        3/3     Running   0          8m44s
kube-system   ama-logs-rs-67c4db654d-lkxf6                          2/2     Running   0          8m44s
kube-system   azure-cns-mdjx7                                       1/1     Running   0          9m45s
kube-system   azure-cns-zjt4s                                       1/1     Running   0          10m
kube-system   azure-ip-masq-agent-c28wt                             1/1     Running   0          9m45s
kube-system   azure-ip-masq-agent-q2rwc                             1/1     Running   0          10m
kube-system   azure-wi-webhook-controller-manager-876f4f6d7-jz4xp   1/1     Running   0          8m48s
kube-system   azure-wi-webhook-controller-manager-876f4f6d7-lk96q   1/1     Running   0          8m48s
kube-system   cloud-node-manager-cc8g6                              1/1     Running   0          10m
kube-system   cloud-node-manager-qq8k8                              1/1     Running   0          9m45s
kube-system   coredns-6f776c8fb5-7czjs                              1/1     Running   0          10m
kube-system   coredns-6f776c8fb5-kj89s                              1/1     Running   0          9m13s
kube-system   coredns-autoscaler-864c4496bf-l9vtd                   1/1     Running   0          10m
kube-system   csi-azuredisk-node-4r74l                              3/3     Running   0          9m45s
kube-system   csi-azuredisk-node-qfqm9                              3/3     Running   0          10m
kube-system   csi-azurefile-node-pq2pq                              3/3     Running   0          10m
kube-system   csi-azurefile-node-vrq45                              3/3     Running   0          9m45s
kube-system   konnectivity-agent-58bdd8ff5d-fhwxw                   1/1     Running   0          9m13s
kube-system   konnectivity-agent-58bdd8ff5d-sc5kx                   1/1     Running   0          10m
kube-system   konnectivity-agent-autoscaler-6ddd978bfc-p6bc4        1/1     Running   0          10m
kube-system   kube-proxy-8xfgs                                      1/1     Running   0          9m45s
kube-system   kube-proxy-g94tf                                      1/1     Running   0          10m
kube-system   metrics-server-6c4cb48ddc-qpxkp                       2/2     Running   0          9m3s
kube-system   metrics-server-6c4cb48ddc-w92m8                       2/2     Running   0          9m3s
```