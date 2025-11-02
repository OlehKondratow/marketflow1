# 8. Certificate Management (cert-manager)

### 8.1. Install cert-manager via Helm
```bash
kubectl create namespace cert-manager
helm repo add jetstack https://charts.jetstack.io
helm repo update
helm install cert-manager jetstack/cert-manager \
  --namespace cert-manager \
  --set crds.enabled=true
```

### 8.2. Create Cloudflare API Secret
```bash
kubectl create secret generic cloudflare-api-token-secret \
  --from-literal=api-token="CF_API_TOKEN>" \
  -n cert-manager
```

### 8.3. Configure ClusterIssuer for Let's Encrypt
```bash
kubectl describe clusterissuer letsencrypt-prod
```
```text
Name:         letsencrypt-prod
Namespace:    
Labels:       <none>
Annotations:  <none>
API Version:  cert-manager.io/v1
Kind:         ClusterIssuer
Metadata:
  Creation Timestamp:  2025-10-27T08:47:55Z
  Generation:          1
  Resource Version:    10246
  UID:                 532851c8-9b8c-4f44-86e9-b38172ff8d02
Spec:
  Acme:
    Email:  oleh.kondracki@gmail.com
    Private Key Secret Ref:
      Name:  letsencrypt-prod-account-key
    Server:  https://acme-v02.api.letsencrypt.org/directory
    Solvers:
      dns01:
        Cloudflare:
          API Token Secret Ref:
            Key:   api-token
            Name:  cloudflare-api-token-secret
          Email:   admin@marketflow.ai
Status:
  Acme:
    Last Private Key Hash:  dSNdTWJ/CHeSQsx4R52Vp99NH8k9M/LPWDmBBsfHW+g=
    Last Registered Email:  oleh.kondracki@gmail.com
  Conditions:
    Last Transition Time:  2025-10-27T08:47:56Z
    Message:               The ACME account was registered with the ACME server
    Observed Generation:   1
    Reason:                ACMEAccountRegistered
    Status:                True
    Type:                  Ready
Events:                    <none>
```
