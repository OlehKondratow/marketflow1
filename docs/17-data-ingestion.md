# 17. Data Ingestion & Market Connectivity

## 🎯 Цель раздела

Настроить получение рыночных данных в реальном времени из внешних источников (Binance, KuCoin, Coinbase и т.д.)  
и обеспечить потоковую передачу этих данных в Kafka (или Azure Event Hub) для дальнейшей обработки и анализа.

MarketFlow использует архитектуру:
**Exchange API → WebSocket → Kafka/EventHub → Snowflake/dbt/Airflow**

---

## 🧭 17.1. Общая архитектура

```

[Binance WS Streams]
↓
[ws_client.py]
↓
[Kafka Producer → ohlcv_raw]
↓
[EventHub Namespace (marketflow-kafka-ns)]
↓
[Snowflake Staging / dbt Models]

````

---

## ⚙️ 17.2. Основные компоненты

| Компонент | Назначение |
|------------|-------------|
| **ws_client.py** | Подключение к Binance WebSocket API для получения потоков сделок (`@trade`) |
| **kafka_client.py** | Отправка полученных данных в Kafka (или Azure Event Hub) |
| **ingestor.py** | Центральный сервис, объединяющий WS-клиент и Kafka-продюсер |
| **config.py** | Настройки подключения (переменные окружения, топики, брокеры) |
| **requirements.txt** | Зависимости Python (aiokafka, websockets, loguru, prometheus-client) |

---

## 🧩 17.3. Пример кода Ingestor (уже реализовано)

```python
async def run_ingestor():
    kafka = KafkaClient("ohlcv_raw")
    await kafka.start()

    ws = BinanceWSClient(["btcusdt", "ethusdt", "solusdt"])
    logger.info("Prometheus metrics on :8000")

    while True:
        try:
            async for msg in ws.connect():
                payload = msg.get("data")
                if payload:
                    await kafka.send(payload)
        except Exception as e:
            logger.warning(f"WebSocket error: {e}, retrying in 5s...")
            await asyncio.sleep(5)
````

**Особенности реализации:**

* Используется `asyncio + uvloop` для высокой производительности.
* Автоматическое переподключение при разрыве.
* Интеграция с Prometheus для метрик.
* Совместимость с Azure Event Hubs (`--enable-kafka true`).

---

## 🧰 17.4. Переменные окружения (.env)

```env
SYMBOLS=btcusdt,ethusdt,solusdt
KAFKA_BROKER=marketflow-kafka-ns.servicebus.windows.net:9093
KAFKA_TOPIC=ohlcv_raw
KAFKA_USERNAME=$ConnectionString
KAFKA_PASSWORD=<RootManageSharedAccessKey>
PROM_PORT=8000
LOG_LEVEL=INFO
```

---

## 🧪 17.5. Тестирование локально

```bash
# Запуск вручную
python ingestor.py

# Пример вывода
2025-10-28 10:01:36 | INFO | Starting MarketFlow Ingestor for ['btcusdt', 'ethusdt', 'solusdt']
2025-10-28 10:01:37 | INFO | Kafka producer started for topic: ohlcv_raw
2025-10-28 10:01:37 | INFO | Prometheus metrics on :8000
```

---

## 🧠 17.6. Поток данных (Data Flow)

| Этап | Описание                                                   | Компонент         |
| ---- | ---------------------------------------------------------- | ----------------- |
| 1️⃣  | Подключение к Binance WS                                   | `ws_client.py`    |
| 2️⃣  | Приём сообщений JSON (`{e:"trade", p:"0.4832", q:"0.24"}`) | WebSocket         |
| 3️⃣  | Сериализация и отправка в Kafka                            | `kafka_client.py` |
| 4️⃣  | Kafka → EventHub (через SASL_SSL)                          | Azure Service Bus |
| 5️⃣  | EventHub → Snowflake (через StreamLoader/dbt)              | Data Pipeline     |

---

## 📈 17.7. Метрики Prometheus

| Метрика                   | Тип       | Описание                                        |
| ------------------------- | --------- | ----------------------------------------------- |
| `ingestor_messages_total` | Counter   | Общее количество принятых сообщений             |
| `kafka_send_errors_total` | Counter   | Ошибки при отправке в брокер                    |
| `ws_reconnects_total`     | Counter   | Количество переподключений к WebSocket          |
| `latency_seconds`         | Histogram | Задержка между получением и отправкой сообщения |


