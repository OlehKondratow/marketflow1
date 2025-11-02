# 19. Strategy Logic (Trading Intelligence)

## 🎯 Цель раздела

На этом этапе данные из аналитического слоя Snowflake (или dbt-моделей)  
используются для построения торговых стратегий, генерации сигналов и формирования решений BUY / SELL / HOLD.

Основная цель — преобразовать данные `ohlcv_features` в actionable-сигналы  
для торгового бота, уведомлений (Telegram) и бэктестинга.

---

## 🧭 19.1. Общая архитектура

```

[Analytics: OHLCV_FEATURES]
↓
[Strategy Engine (dbt + Python)]
↓
[Signals Table / Topic]
↓
[Execution Layer → Binance API / Simulated Trade]

````

---

## 💡 19.2. Концепция SmartMoney Reversal

**Идея:**  
Покупать в зонах повышенного объёма после касания локального минимума (WeakLow)  
и продавать в зонах перекупленности после касания максимума (WeakHigh).  
Сигнал подтверждается импульсом (momentum) и превышением среднего объёма.

---

## ⚙️ 19.3. Логика условий

| Сигнал | Условие | Подтверждение |
|--------|----------|----------------|
| 🟩 **BUY_SM** | Цена ≤ WeakLow × 1.008 | Volume > avg_vol × 1.5 и Momentum > 0 |
| 🔴 **SELL_SM** | Цена ≥ WeakHigh × 0.992 | Volume > avg_vol × 1.5 и Momentum < 0 |
| ⏸ **HOLD** | Все остальные случаи | — |

---

## 🧮 19.4. dbt-модель сигналов

**models/trading_signals.sql**
```sql
{{ config(materialized='table') }}

select
    symbol,
    t_min,
    close,
    volume,
    weak_low,
    weak_high,
    avg_vol,
    momentum,
    case
        when close <= weak_low * 1.008 and volume > avg_vol * 1.5 and momentum > 0 then 'BUY_SM'
        when close >= weak_high * 0.992 and volume > avg_vol * 1.5 and momentum < 0 then 'SELL_SM'
        else 'HOLD'
    end as signal_type
from {{ ref('ohlcv_features') }}
````

---

## 🧩 19.5. Python-версия логики (Strategy Consumer)

**strategy_consumer.py**

```python
import asyncio, json, os
from aiokafka import AIOKafkaConsumer
from loguru import logger

async def consume():
    consumer = AIOKafkaConsumer(
        "ohlcv_features",
        bootstrap_servers=os.getenv("KAFKA_BROKER"),
        security_protocol="SASL_SSL",
        sasl_mechanism="PLAIN",
        sasl_plain_username=os.getenv("KAFKA_USERNAME"),
        sasl_plain_password=os.getenv("KAFKA_PASSWORD"),
        auto_offset_reset="latest"
    )
    await consumer.start()
    logger.info("📊 Strategy Engine started (SmartMoney Reversal)")
    try:
        async for msg in consumer:
            data = json.loads(msg.value.decode())
            close = float(data["close"])
            weak_low = float(data["weak_low"])
            weak_high = float(data["weak_high"])
            volume = float(data["volume"])
            avg_vol = float(data["avg_vol"])
            momentum = float(data["momentum"])

            if close <= weak_low * 1.008 and volume > avg_vol * 1.5 and momentum > 0:
                signal = "BUY_SM"
            elif close >= weak_high * 0.992 and volume > avg_vol * 1.5 and momentum < 0:
                signal = "SELL_SM"
            else:
                signal = "HOLD"

            logger.info(f"{data['symbol']} → {signal} | close={close:.4f} vol={volume:.2f} mom={momentum:.2f}")
    finally:
        await consumer.stop()

asyncio.run(consume())
```

---

## 📈 19.6. Пример сигналов в Snowflake

```sql
select symbol, t_min, close, volume, momentum, signal_type
from analytics.trading_signals
order by t_min desc
limit 10;
```

✅ Пример результата:

```
| symbol | t_min               | close  | vol   | momentum | signal_type |
|---------|--------------------|--------|--------|-----------|--------------|
| WIFUSDC | 2025-11-01 10:18:00 | 0.4821 | 1.9M | +0.45 | BUY_SM |
| WIFUSDC | 2025-11-01 10:19:00 | 0.4860 | 2.5M | -0.35 | HOLD |
| WIFUSDC | 2025-11-01 10:20:00 | 0.5650 | 2.1M | -0.70 | SELL_SM |
```

---

## 🧠 19.7. Расширение стратегии

Возможные модификации:

* Добавить **Delta Volume (покупки–продажи)**;
* Ввести **Adaptive Distance** (0.5–1.2 % от WeakLow/WeakHigh);
* Использовать **ML-модель классификации сигналов** (RandomForest / Snowflake ML);
* Добавить **“Smart Exit”**: SELL при обратном сигнале или достижении +5 % прибыли.

---

## 🧰 19.8. Telegram-уведомления

**telegram_smartmoney_notifier.py**

```python
import requests, os
def send_signal(symbol, signal, price):
    msg = f"🚀 SmartMoney {signal}\nSymbol: {symbol}\nPrice: {price}"
    requests.post(
        f"https://api.telegram.org/bot{os.getenv('TG_TOKEN')}/sendMessage",
        json={"chat_id": os.getenv("TG_CHAT_ID"), "text": msg}
    )
```

---

## 🧪 19.9. Проверка работы в реальном времени

```bash
python strategy_consumer.py
```

Пример вывода:

```
WIFUSDC → 🟩 BUY_SM | close=0.4805 vol=1.8M mom=+0.42
ETHUSDT → 🔴 SELL_SM | close=3375.00 vol=4.5M mom=-0.55
```
