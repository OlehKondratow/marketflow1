# 16. Ingestor: Binance to Kafka Producer

## 🎯 Purpose

The Ingestor service acts as a real-time data producer. It connects to the public **Binance WebSocket API** to subscribe to live trade data for a configured list of cryptocurrency symbols. It then forwards these messages directly into a Kafka topic for downstream processing.

---

## Key Responsibilities

*   **WebSocket Connection:** Establishes and maintains a persistent connection to the Binance WebSocket stream for multiple symbols (e.g., `btcusdt@trade`, `ethusdt@trade`).
*   **Data Forwarding:** Receives trade messages and produces them as-is into the specified Kafka topic. The message key is the symbol (e.g., `BTCUSDT`).
*   **Resilience:** Automatically handles WebSocket connection drops and attempts to reconnect with a backoff delay.
*   **Monitoring:** Exposes a Prometheus endpoint (`/metrics`) with metrics for sent messages, Kafka latency, and WebSocket reconnects.

---

## ⚙️ Configuration

The service is configured via environment variables, which are set in the Kubernetes deployment.

*   `SYMBOLS`: Comma-separated list of symbols to subscribe to (e.g., `btcusdt,ethusdt`).
*   `KAFKA_TOPIC`: The destination Kafka topic (e.g., `ohlcv_raw`).
*   `KAFKA_BROKER`: The address of the Kafka broker.
*   `KAFKA_USERNAME`: Username for SASL authentication (e.g., `$ConnectionString`).
*   `KAFKA_PASSWORD`: Password for SASL authentication (the Event Hub connection string).

---

## 🚀 Helm Chart

The service is deployed to Kubernetes using a Helm chart. The chart creates a `Deployment` and a `Service`.

### Key `values.yaml` settings:

```yaml
replicaCount: 1

image:
  repository: marketflowregistry.azurecr.io/ingestor
  tag: latest

# Service configuration injected as environment variables
config:
  symbols: "btcusdt,ethusdt,solusdt"
  kafkaTopic: "ohlcv_raw"
  kafkaBroker: "marketflow-kafka-ns.servicebus.windows.net:9093"

# Secrets are not stored in values.yaml.
# They are mounted into the pod from Azure Key Vault using a SecretProviderClass.
# The deployment references this class to populate the KAFKA_USERNAME and KAFKA_PASSWORD
# environment variables.
```
