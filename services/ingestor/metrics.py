from prometheus_client import Counter, Histogram

messages_sent_total = Counter(
    "marketflow_ingestor_messages_sent_total",
    "Total number of messages successfully sent to Kafka/EventHub",
    ["symbol"]
)


ws_reconnects_total = Counter(
    "marketflow_ingestor_ws_reconnects_total",
    "Total number of WebSocket reconnect attempts",
    ["symbol"]
)

latency_seconds = Histogram(
    "marketflow_ingestor_latency_seconds",
    "Latency between message reception and Kafka publish (seconds)",
    ["symbol"]
)
