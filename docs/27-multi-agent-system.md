# 27. Multi-Agent Trading System (Swarm Layer)

## 🎯 Цель раздела

Создать распределённую систему торговых агентов, где каждый отвечает за свою часть анализа:
- 🧠 SmartMoney Agent — анализ технических уровней и сигналов
- 💬 Sentiment Agent — анализ новостного и социального фона
- ⚖️ Risk Agent — контроль рисков и капитала
- ⚙️ Tuner Agent — автооптимизация параметров
- 🤖 Decision Hub — консолидация решений

MarketFlow становится системой с “роевым интеллектом”,  
в которой агенты взаимодействуют через Kafka, n8n и Snowflake,  
создавая адаптивное, самообучающееся торговое ядро.

---

## 🧭 27.1. Общая архитектура

```

```
 ┌────────────────────────┐
 │  SmartMoney Agent      │ → технический анализ
 └────────────────────────┘
           ↓
 ┌────────────────────────┐
 │  Sentiment Agent       │ → NLP анализ Twitter/новостей
 └────────────────────────┘
           ↓
 ┌────────────────────────┐
 │  Risk Agent            │ → управление капиталом и лимитами
 └────────────────────────┘
           ↓
 ┌────────────────────────┐
 │  Tuner Agent           │ → автообучение и подбор параметров
 └────────────────────────┘
           ↓
 ┌────────────────────────┐
 │  AI Decision Hub       │ → коллективное решение
 └────────────────────────┘
           ↓
     [Execution Engine]
```

```

---

## 🤝 27.2. Коммуникация между агентами

| Канал | Технология | Назначение |
|--------|-------------|------------|
| **Kafka Topics** | `signals`, `sentiment`, `risk`, `tune`, `decisions` | обмен сообщениями между агентами |
| **Snowflake Tables** | `AI_CONTEXT` | хранение общего контекста и весов агентов |
| **n8n Workflows** | маршрутизация событий | организация межагентного взаимодействия |
| **Redis / MQTT (опционально)** | pub/sub сигналы в реальном времени | лёгкий обмен сообщениями |

---

## 🧩 27.3. Пример взаимодействия агентов

```

SmartMoney Agent  → генерирует BUY_SM
Sentiment Agent   → sentiment = +0.3 (оптимистичный)
Risk Agent        → drawdown = 0.04 (низкий)
Tuner Agent       → оптимизирует dist_low = 0.007
Decision Hub      → подтверждает BUY (score 0.83)
Execution Engine  → выставляет ордер

````

---

## ⚙️ 27.4. Пример реализации агента (SmartMoney Agent)

```python
import json, asyncio, os
from aiokafka import AIOKafkaProducer
from loguru import logger

async def run():
    producer = AIOKafkaProducer(bootstrap_servers=os.getenv("KAFKA_BROKER"))
    await producer.start()
    logger.info("🧠 SmartMoney Agent started")
    try:
        signal = {"symbol": "BTCUSDT", "signal_type": "BUY_SM", "score": 0.78}
        await producer.send_and_wait("signals", json.dumps(signal).encode("utf-8"))
        logger.info(f"Signal sent: {signal}")
    finally:
        await producer.stop()

asyncio.run(run())
````

---

## 💬 27.5. Пример Sentiment Agent

```python
import requests, json, asyncio
from aiokafka import AIOKafkaProducer

async def sentiment_agent():
    sentiment = 0.25  # рассчитано через NLP
    msg = {"symbol": "BTCUSDT", "sentiment": sentiment}
    producer = AIOKafkaProducer(bootstrap_servers="localhost:9092")
    await producer.start()
    await producer.send_and_wait("sentiment", json.dumps(msg).encode("utf-8"))
    await producer.stop()

asyncio.run(sentiment_agent())
```

---

## ⚖️ 27.6. Пример Risk Agent

```python
import json, asyncio
from aiokafka import AIOKafkaProducer

async def risk_agent():
    risk_data = {"symbol": "BTCUSDT", "drawdown": 0.06, "exposure": 0.15}
    producer = AIOKafkaProducer(bootstrap_servers="localhost:9092")
    await producer.start()
    await producer.send_and_wait("risk", json.dumps(risk_data).encode("utf-8"))
    await producer.stop()

asyncio.run(risk_agent())
```

---

## 🧠 27.7. Decision Aggregator (коллективное решение)

**decision_hub_aggregator.py**

```python
import json, asyncio
from aiokafka import AIOKafkaConsumer, AIOKafkaProducer
import numpy as np

async def aggregator():
    topics = ["signals", "sentiment", "risk"]
    consumer = AIOKafkaConsumer(*topics, bootstrap_servers="localhost:9092")
    producer = AIOKafkaProducer(bootstrap_servers="localhost:9092")

    await consumer.start(); await producer.start()
    state = {"signal_score": 0, "sentiment": 0, "drawdown": 0}
    try:
        async for msg in consumer:
            data = json.loads(msg.value.decode())
            state.update(data)
            if all(k in state for k in ["signal_type","sentiment","drawdown"]):
                decision = "BUY" if state["signal_score"]>0.7 and state["sentiment"]>0 and state["drawdown"]<0.1 else "HOLD"
                await producer.send_and_wait("decisions", json.dumps({"symbol": "BTCUSDT", "decision": decision}).encode())
    finally:
        await consumer.stop(); await producer.stop()

asyncio.run(aggregator())
```

---

## 📊 27.8. Пример консенсуса агентов

| Агент            | Предложение   | Вес | Итог             |
| ---------------- | ------------- | --- | ---------------- |
| SmartMoney       | BUY           | 0.5 | ✅                |
| Sentiment        | BUY           | 0.3 | ✅                |
| Risk             | HOLD          | 0.2 | ⚠️               |
| **Decision Hub** | **BUY (0.8)** |     | итоговое решение |

---

## 🧮 27.9. Механизм самообучения (Swarm Learning)

Каждый агент обновляет свои параметры в зависимости от результата предыдущих решений.

Пример:

```
если Profit > 0 → увеличить вес агента;
если Profit < 0 → снизить вес агента;
```

**dbt-модель обновления весов:**

```sql
update analytics.agent_weights
set weight = weight + case when profit_pct > 0 then 0.05 else -0.05 end
where agent_name = '{{ this_agent }}';
```

---

## 🧰 27.10. Мониторинг агентов в Grafana

| Метрика                   | Описание                          |
| ------------------------- | --------------------------------- |
| `agent_latency_seconds`   | Время реакции агента              |
| `agent_accuracy`          | Точность решений агента           |
| `consensus_score`         | Средняя согласованность роя       |
| `swarm_profit`            | Суммарная прибыль всех агентов    |
| `decision_conflict_count` | Конфликты сигналов между агентами |

---

## 🤖 27.11. Пример визуализации в Streamlit

```python
import streamlit as st, pandas as pd
df = pd.read_csv("swarm_decisions.csv")

st.title("🤖 MarketFlow Swarm Intelligence Dashboard")
st.dataframe(df.tail(10))
st.metric("Consensus Accuracy", "82%")
st.metric("Total PnL", "+12.4%")
```

---

## 🧩 27.12. Преимущества Swarm Architecture

✅ Масштабируемость — можно добавлять новых агентов (например, Macro Agent, On-Chain Agent).
✅ Самообучение — каждый агент корректирует свою стратегию.
✅ Надёжность — один агент не может “сломать” систему.
✅ Коллективное мышление — решения основаны на нескольких независимых источниках.
✅ Расширяемость — совместимость с n8n, Kafka, Airflow, Snowflake, Grafana.
