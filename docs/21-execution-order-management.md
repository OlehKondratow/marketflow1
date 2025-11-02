# 21. Execution & Order Management

## 🎯 Цель раздела

Этот этап отвечает за автоматическое размещение ордеров на бирже,  
управление открытыми позициями и логирование всех действий в систему мониторинга.

MarketFlow использует **асинхронную модель исполнения**:  
сигналы поступают из Kafka / dbt, обрабатываются Order Executor’ом,  
и отправляются в Binance через REST API.

---

## 🧭 21.1. Общая архитектура

```

[Trading Signals Topic / Snowflake]
↓
[Order Executor (FastAPI / asyncio)]
↓
[Binance REST API / Testnet]
↓
[Execution Logs → Prometheus / Loki]
↓
[Telegram Alerts + Streamlit Dashboard]

````

---

## ⚙️ 21.2. Основные компоненты

| Компонент | Назначение |
|------------|------------|
| **order_executor.py** | Получает сигналы и размещает ордера |
| **binance_client.py** | Обёртка над Binance REST API |
| **execution_logger** | Логирует и отправляет Prometheus метрики |
| **telegram_notifier.py** | Уведомления об исполнении |
| **dbt-trades / Snowflake** | Хранение истории ордеров |

---

## 💡 21.3. Поток исполнения ордера

| Этап | Описание | Пример |
|------|-----------|--------|
| 1️⃣ | Получен сигнал `BUY_SM` | Kafka / dbt output |
| 2️⃣ | Проверка позиции — если нет, открыть BUY | Binance REST |
| 3️⃣ | Сохранение результата (PnL, цена) | Snowflake |
| 4️⃣ | Отправка метрик и Telegram уведомления | Prometheus / Telegram |

---

## 🧩 21.4. Пример кода Order Executor

**order_executor.py**
```python
import asyncio, os, json, time
from loguru import logger
from aiokafka import AIOKafkaConsumer
from binance.client import Client
from prometheus_client import Counter, Gauge, start_http_server
from telegram_notifier import send_alert

BUY_COUNT = Counter('buy_orders_total', 'Total BUY orders')
SELL_COUNT = Counter('sell_orders_total', 'Total SELL orders')
LAST_PROFIT = Gauge('last_trade_profit', 'Last trade profit (%)')

client = Client(os.getenv("BINANCE_API_KEY"), os.getenv("BINANCE_API_SECRET"))
symbol = os.getenv("SYMBOL", "WIFUSDC")
qty = float(os.getenv("TRADE_QTY", 10))
start_http_server(8001)

async def consume_signals():
    consumer = AIOKafkaConsumer(
        "trading_signals",
        bootstrap_servers=os.getenv("KAFKA_BROKER"),
        security_protocol="SASL_SSL",
        sasl_mechanism="PLAIN",
        sasl_plain_username=os.getenv("KAFKA_USERNAME"),
        sasl_plain_password=os.getenv("KAFKA_PASSWORD"),
        auto_offset_reset="latest"
    )
    await consumer.start()
    in_position = False
    buy_price = 0.0
    logger.info("🧭 Order Executor started")
    try:
        async for msg in consumer:
            data = json.loads(msg.value.decode())
            signal = data["signal_type"]
            price = float(data["close"])
            logger.info(f"Signal received: {signal} @ {price}")
            
            if signal == "BUY_SM" and not in_position:
                order = client.order_market_buy(symbol=symbol, quantity=qty)
                BUY_COUNT.inc()
                in_position = True
                buy_price = price
                send_alert(f"🟩 BUY {symbol} @ {price}")
                logger.info(f"BUY executed: {order['orderId']}")
            
            elif signal == "SELL_SM" and in_position:
                order = client.order_market_sell(symbol=symbol, quantity=qty)
                SELL_COUNT.inc()
                profit = (price - buy_price) / buy_price * 100
                LAST_PROFIT.set(profit)
                send_alert(f"🔴 SELL {symbol} @ {price} | Profit: {profit:.2f}%")
                logger.info(f"SELL executed: {order['orderId']} | Profit {profit:.2f}%")
                in_position = False

    finally:
        await consumer.stop()

asyncio.run(consume_signals())
````

---

## 🔐 21.5. Настройки окружения (.env)

```env
BINANCE_API_KEY=<your_key>
BINANCE_API_SECRET=<your_secret>
SYMBOL=WIFUSDC
TRADE_QTY=10
KAFKA_BROKER=marketflow-kafka-ns.servicebus.windows.net:9093
KAFKA_USERNAME=$ConnectionString
KAFKA_PASSWORD=<RootKey>
```

---

## 🧠 21.6. Метрики Prometheus

| Метрика             | Тип     | Описание                    |
| ------------------- | ------- | --------------------------- |
| `buy_orders_total`  | Counter | Количество BUY ордеров      |
| `sell_orders_total` | Counter | Количество SELL ордеров     |
| `last_trade_profit` | Gauge   | Последняя прибыль (%)       |
| `open_positions`    | Gauge   | Количество активных позиций |

---

## 📬 21.7. Telegram уведомления

**telegram_notifier.py**

```python
import os, requests

def send_alert(msg: str):
    url = f"https://api.telegram.org/bot{os.getenv('TG_TOKEN')}/sendMessage"
    payload = {"chat_id": os.getenv("TG_CHAT_ID"), "text": msg}
    requests.post(url, json=payload)
```

Пример:

```
🟩 BUY_SM executed
Symbol: WIFUSDC
Price: 0.4805
---
🔴 SELL_SM executed
Profit: +7.8%
```

---

## 🧾 21.8. Сохранение истории ордеров

После исполнения ордеров информация сохраняется в таблице Snowflake:

**models/order_history.sql**

```sql
{{ config(materialized='incremental') }}

select
    symbol,
    executed_at,
    side,
    qty,
    price,
    profit_pct,
    signal_type
from {{ source('raw', 'executions') }}
```

---

## ⚙️ 21.9. Тестирование на Binance Testnet

```bash
export BINANCE_API_URL=https://testnet.binance.vision/api
python order_executor.py
```

✅ Ожидается:

```
🧭 Order Executor started
Signal received: BUY_SM @ 0.4801
BUY executed: 123456789
Signal received: SELL_SM @ 0.5220
SELL executed: 123456790 | Profit 8.7%
```

---

## 📈 21.10. Потоковая визуализация ордеров

Можно визуализировать активные сделки в Streamlit:

```python
import streamlit as st, pandas as pd
df = pd.read_csv("order_history.csv")
st.dataframe(df.tail(10))
st.metric("Last Profit", f"{df['profit_pct'].iloc[-1]:.2f}%")
```
