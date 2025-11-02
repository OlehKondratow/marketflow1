# 11. Application Deployment

### 11.1. Configure DNS A-Record
Add a DNS A-record for `app0.okondratov.online` pointing to `20.31.255.92`.

### 11.2. Deploy httpbin Application
```bash
kubectl apply -f k8s/httpbin.yaml
kubectl get pods -n default
```
```text
NAME                       READY   STATUS    RESTARTS   AGE
httpbin-56cc78c99f-bz9ck   1/1     Running   0          19s
```

### 11.3. Create Ingress for httpbin
```bash
kubectl apply -f k8s/httpbin-ingress.yaml
kubectl get ingress -n default
```
```text
NAME              CLASS    HOSTS                    ADDRESS   PORTS     AGE
httpbin-ingress   <none>   app0.okondratov.online             80, 443   18s
```

### 11.4. Verify TLS Certificate
```bash
kubectl describe ingress httpbin-ingress  -n default
```
```yaml
Name:             httpbin-ingress
Labels:           <none>
Namespace:        default
Address:          20.31.255.92
Ingress Class:    <none>
Default backend:  <default>
TLS:
  httpbin-tls terminates app0.okondratov.online
Rules:
  Host                    Path  Backends
  ----                    ----  --------
  app0.okondratov.online  
                          /   httpbin:80 (10.244.1.17:80)
Annotations:              cert-manager.io/cluster-issuer: letsencrypt-prod
                          kubernetes.io/ingress.class: nginx
Events:
  Type    Reason             Age                From                       Message
  ----    ------             ----               ----                       -------
  Normal  CreateCertificate  98s                cert-manager-ingress-shim  Successfully created Certificate "httpbin-tls"
  Normal  Sync               60s (x2 over 98s)  nginx-ingress-controller   Scheduled for sync
```
```bash
kubectl get secret httpbin-tls -o jsonpath='{.data.tls\.crt}' | base64 -d > httpbin.crt
openssl x509 -in httpbin.crt -noout -text
```
