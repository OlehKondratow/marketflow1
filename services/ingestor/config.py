import os

# Список валютных пар
SYMBOLS = os.getenv("SYMBOLS", "btcusdt,ethusdt,solusdt").split(",")

# Kafka topic
TOPIC = os.getenv("KAFKA_TOPIC", "ohlcv_raw")
