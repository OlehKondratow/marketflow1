# 15. Grafana Cloud Integration

## Goal
Integrate AKS (MarketFlow) with Grafana Cloud using the official `grafana-k8s-monitoring` Helm chart.

---

## Step 1 — Deploy Grafana Cloud Agent

```bash
helm repo add grafana https://grafana.github.io/helm-charts
helm repo update
kubectl create namespace monitoring

helm install grafana-k8s-monitoring grafana/k8s-monitoring \
  -n monitoring \
  --set cluster.name="marketflow-aks" \
  --set grafanaCloud.user="YOUR_GRAFANA_CLOUD_USER_ID" \
  --set grafanaCloud.token="YOUR_GRAFANA_CLOUD_API_TOKEN"
````

---

## Step 2 — Verify

```bash
kubectl get pods -n monitoring
```

Expected:

```
grafana-k8s-monitoring-alloy-*        Running
grafana-k8s-monitoring-beyla-*        Running
grafana-k8s-monitoring-kepler-*       Running
grafana-k8s-monitoring-node-exporter  Running
grafana-k8s-monitoring-operator       Running
```

---

## Step 3 — Configure Ingestor

Add annotations to `deployment.yaml`:

```yaml
metadata:
  annotations:
    k8s.grafana.com/scrape: "true"
    k8s.grafana.com/port: "8000"
    k8s.grafana.com/path: "/metrics"
```

Upgrade release:

```bash
helm upgrade --install ingestor ./marketflow-ingestor -n marketflow-dev
```

---

## Step 4 — Check in Grafana Cloud

Metrics → Explore:

```
marketflow_ingestor_messages_sent_total
marketflow_ingestor_latency_seconds
```

Logs → Explore:

```
{namespace="marketflow-dev"}
```

---

## Step 5 — Example Dashboard

```json
{
  "title": "MarketFlow Ingestor Metrics",
  "panels": [
    {
      "type": "timeseries",
      "title": "Messages per Second",
      "targets": [{ "expr": "rate(marketflow_ingestor_messages_sent_total[1m])" }]
    },
    {
      "type": "timeseries",
      "title": "Latency (s)",
      "targets": [{ "expr": "avg_over_time(marketflow_ingestor_latency_seconds[5m])" }]
    }
  ]
}
```

---

## Result

Grafana Cloud connected.
All `marketflow-ingestor` instances export metrics and logs automatically.



