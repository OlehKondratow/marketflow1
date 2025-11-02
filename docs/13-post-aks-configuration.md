## 🧭 II. Post-AKS Configuration

This section covers the necessary steps to configure the cluster after its creation, including role assignments and the deployment of essential in-cluster services.

---

### 1️⃣ Assign Roles and Permissions

> **Crucial:** Without these permissions, AKS cannot manage networking resources (like Load Balancers for Ingress) or access secrets from Key Vault.

#### Network Permissions
First, get the Principal ID of the AKS identity.
```bash
az aks show -n marketflow-aks -g marketflow-rg --query identity.principalId -o tsv
# 8dd05366-e077-4ca8-9890-4d66d7081854
```

Now, assign the `Network Contributor` role to this identity, scoped to the resource group. This allows AKS to create and manage public IPs and load balancers.
```bash
az role assignment create \
  --assignee 8dd05366-e077-4ca8-9890-4d66d7081854 \
  --role "Network Contributor" \
  --scope /subscriptions/<id>/resourceGroups/marketflow-rg
```

#### Key Vault Permissions
To allow users or services to manage secrets, assign the `Key Vault Secrets Officer` role.
```bash
az role assignment create \
  --role "Key Vault Secrets Officer" \
  --assignee <user-id> \
  --scope $(az keyvault show --name marketflow-vault --query id -o tsv)
```

---

### 2️⃣ Deploy In-Cluster Components

#### Ingress-Nginx Controller
This component reads `Ingress` resources and routes external traffic to the correct services within the cluster.

```bash
# Add the official Helm repository
helm repo add ingress-nginx https://kubernetes.github.io/ingress-nginx
helm repo update

# Create a dedicated namespace
kubectl create namespace ingress-nginx

# Install the controller using Helm
helm install ingress-nginx ingress-nginx/ingress-nginx \
  --namespace ingress-nginx \
  --set controller.ingressClassResource.default=true \
  --set controller.ingressClassResource.name=nginx \
  --set controller.ingressClass=nginx \
  --set controller.service.annotations."service.beta.kubernetes.io/azure-load-balancer-resource-group"="marketflow-rg"
```

After installation, verify that the controller's pod is running and that it has received an `EXTERNAL-IP`.
```bash
# Check the pod
kubectl get pods --namespace ingress-nginx -o wide

# Check the service for the external IP
kubectl get svc -n ingress-nginx
```

#### Other Essential Components
The following should also be deployed at this stage (details are in their respective documentation files):

*   **cert-manager** (for TLS certificate automation)
*   **ClusterIssuer** (to configure Let's Encrypt as the certificate authority)
*   **Cloudflare API secret** (if using Cloudflare for DNS-01 challenges)
*   Application Namespaces: `marketflow-dev`, `marketflow-prod`

---

### 3️⃣ Summary Table (DevOps Pattern)

This table summarizes the overall workflow:

| Phase                      | Action                                                   | Example                            | Where          |
| :------------------------- | :------------------------------------------------------- | :--------------------------------- | :------------- |
| 🔹 **Pre-AKS (before create)** | Resource Group, VNet, Subnet, NSG, rules, subnet-id      | `az network vnet create`           | outside cluster|
| 🔹 **AKS create**          | Cluster with `--vnet-subnet-id`                          | `az aks create …`                  | Azure          |
| 🔹 **Post-AKS**            | RBAC, `Network Contributor` role, KeyVault, Ingress, TLS | `az role assignment`, Helm install | inside cluster |
