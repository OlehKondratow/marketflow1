# 4. Azure Event Hubs

### 4.1. Create Event Hubs Namespace
```bash
az eventhubs namespace create \
  --name marketflow-kafka-ns \
  --resource-group marketflow-rg \
  --location westeurope \
  --sku Standard \
  --enable-kafka true
```
```json
{
  "createdAt": "2025-10-27T06:32:13.9183721Z",
  "disableLocalAuth": false,
  "geoDataReplication": {
    "locations": [
      {
        "locationName": "westeurope",
        "replicaState": "Ready",
        "roleType": "Primary"
      }
    ],
    "maxReplicationLagDurationInSeconds": 0
  },
  "id": "/subscriptions/65fe7e97-9f6f-4f82-b940-4f374ca027cb/resourceGroups/marketflow-rg/providers/Microsoft.EventHub/namespaces/marketflow-kafka-ns",
  "isAutoInflateEnabled": false,
  "kafkaEnabled": true,
  "location": "westeurope",
  "maximumThroughputUnits": 0,
  "metricId": "65fe7e97-9f6f-4f82-b940-4f374ca027cb:marketflow-kafka-ns",
  "minimumTlsVersion": "1.2",
  "name": "marketflow-kafka-ns",
  "provisioningState": "Succeeded",
  "publicNetworkAccess": "Enabled",
  "resourceGroup": "marketflow-rg",
  "serviceBusEndpoint": "https://marketflow-kafka-ns.servicebus.windows.net:443/",
  "sku": {
    "capacity": 1,
    "name": "Standard",
    "tier": "Standard"
  },
  "status": "Active",
  "tags": {},
  "type": "Microsoft.EventHub/Namespaces",
  "updatedAt": "2025-10-27T06:32:34Z",
  "zoneRedundant": true
}
```

### 4.2. Create Event Hub Topic
```bash
az eventhubs eventhub create \
  --name marketflow-topic \
  --namespace-name marketflow-kafka-ns \
  --resource-group marketflow-rg
```
```json
{
  "createdAt": "2025-10-27T06:33:59.127Z",
  "id": "/subscriptions/65fe7e97-9f6f-4f82-b940-4f374ca027cb/resourceGroups/marketflow-rg/providers/Microsoft.EventHub/namespaces/marketflow-kafka-ns/eventhubs/marketflow-topic",
  "location": "westeurope",
  "messageRetentionInDays": 7,
  "messageTimestampDescription": {
    "timestampType": "LogAppend"
  },
  "name": "marketflow-topic",
  "partitionCount": 4,
  "partitionIds": [
    "0",
    "1",
    "2",
    "3"
  ],
  "resourceGroup": "marketflow-rg",
  "retentionDescription": {
    "cleanupPolicy": "Delete",
    "retentionTimeInHours": 168
  },
  "status": "Active",
  "type": "Microsoft.EventHub/namespaces/eventhubs",
  "updatedAt": "2025-10-27T06:33:59.45Z"
}
```

### 4.3. Get Access Keys and Connection String
```bash
az eventhubs namespace authorization-rule keys list \
  --resource-group marketflow-rg \
  --namespace-name marketflow-kafka-ns \
  --name RootManageSharedAccessKey \
  --output json
```
```json
{
  "keyName": "RootManageSharedAccessKey",
  "primaryConnectionString": "<REDACTED>",
  "primaryKey": "***",
  "secondaryConnectionString": "<REDACTED>",
  "secondaryKey": "***"
}
```
```bash
export KAFKA_CONNECTION_STRING="<REDACTED>***"
```
