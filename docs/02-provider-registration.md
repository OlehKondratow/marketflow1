# 2. Azure Provider Registration

### 2.1. Core Networking & Compute
```bash
az provider register --namespace Microsoft.Network
az provider register --namespace Microsoft.Compute
az provider register --namespace Microsoft.OperationsManagement
az provider register --namespace Microsoft.OperationalInsights
```

### 2.2. Storage & Containers
```bash
az provider register --namespace Microsoft.Storage
az provider register --namespace Microsoft.ContainerService
az provider register --namespace Microsoft.ContainerRegistry
```

### 2.3. Security & Secrets
```bash
az provider register --namespace Microsoft.KeyVault
az provider register --namespace Microsoft.ManagedIdentity
```

### 2.4. Monitoring & Telemetry
```bash
az provider register --namespace Microsoft.Insights
az provider register --namespace Microsoft.Monitor
az provider register --namespace Microsoft.AlertsManagement
```

### 2.5. Databases & Streaming
```bash
az provider register --namespace Microsoft.EventHub
az provider register --namespace Microsoft.Kusto
```
### 2.6. List Registered Providers
```bash
az provider list --query "[?registrationState=='Registered'].namespace" -o json
```
```json
[
  "Microsoft.ContainerRegistry",
  "Microsoft.Network",
  "Microsoft.Compute",
  "Microsoft.EventHub",
  "Microsoft.ContainerService",
  "Microsoft.OperationsManagement",
  "Microsoft.OperationalInsights",
  "Microsoft.KeyVault",
  "Microsoft.ManagedIdentity",
  "Microsoft.Monitor",
  "Microsoft.Storage",
  "microsoft.insights",
  "Microsoft.AlertsManagement",
  "Microsoft.Kusto",
  "Microsoft.ADHybridHealthService",
  "Microsoft.Authorization",
  "Microsoft.Billing",
  "Microsoft.ChangeSafety",
  "Microsoft.ClassicSubscription",
  "Microsoft.Commerce",
  "Microsoft.Consumption",
  "Microsoft.CostManagement",
  "Microsoft.Features",
  "Microsoft.MarketplaceOrdering",
  "Microsoft.Portal",
  "Microsoft.ResourceGraph",
  "Microsoft.ResourceIntelligence",
  "Microsoft.ResourceNotifications",
  "Microsoft.Resources",
  "Microsoft.SerialConsole",
  "microsoft.support"
]
```