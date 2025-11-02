# 18. Data Processing & Feature Engineering

## 🎯 Цель раздела

На этом этапе данные, полученные от Ingestor через Kafka/EventHub, преобразуются  
в агрегированные наборы OHLCV (Open, High, Low, Close, Volume), на основе которых  
вычисляются технические индикаторы и аналитические признаки для моделей стратегий и сигналов.

MarketFlow реализует модуль обработки на связке:
**Kafka → dbt → Snowflake → Analytics Layer**

---

## 🧭 18.1. Общая архитектура

```

[Kafka / EventHub]
↓
[Snowflake Staging: RAW_TRADES]
↓
[dbt models: ohlcv_agg, volume_stats, momentum_calc]
↓
[Snowflake Analytics: ANALYTICS.OHLCV_FEATURES]

````

---

## 🧩 18.2. Основные задачи

| Подсистема | Описание |
|-------------|-----------|
| **Staging** | Сырые данные из EventHub поступают в таблицу `RAW_TRADES` (через Snowpipe или Stream) |
| **Aggregation** | Формирование свечей по интервалу (1m, 5m, 15m) |
| **Indicators** | Расчёт объёма, волатильности, delta, momentum, Bollinger Bands |
| **Feature Store** | Хранение в `ANALYTICS.OHLCV_FEATURES` для последующих моделей и сигналов |

---

## ⚙️ 18.3. Пример dbt-модели OHLCV

**models/ohlcv_agg.sql**
```sql
{{ config(materialized='table') }}

with trades as (
    select
        symbol,
        timestamp_trunc(trade_time, minute) as t_min,
        avg(price) as close,
        min(price) as low,
        max(price) as high,
        first_value(price) over w as open,
        sum(qty) as volume
    from {{ source('raw', 'trades') }}
    window w as (partition by symbol, timestamp_trunc(trade_time, minute)
                 order by trade_time rows between unbounded preceding and unbounded following)
    group by 1,2
)

select
    symbol,
    t_min,
    open, high, low, close, volume,
    round((high-low)/close*100,2) as volatility,
    lag(close) over (partition by symbol order by t_min) as prev_close,
    round((close - lag(close) over (partition by symbol order by t_min))/lag(close) over (partition by symbol order by t_min)*100, 2) as momentum
from trades
````

---

## 📊 18.4. Пример dbt-модели индикаторов

**models/indicators.sql**

```sql
{{ config(materialized='table') }}

select
    *,
    avg(close) over (partition by symbol order by t_min rows between 20 preceding and current row) as ma_20,
    stddev(close) over (partition by symbol order by t_min rows between 20 preceding and current row) as std_20,
    ma_20 + 2 * std_20 as upper_band,
    ma_20 - 2 * std_20 as lower_band,
    case when close < lower_band then 'BUY_ZONE'
         when close > upper_band then 'SELL_ZONE'
         else 'NEUTRAL' end as signal_zone
from {{ ref('ohlcv_agg') }}
```

---

## 🧮 18.5. Ключевые признаки (features)

| Признак                    | Описание                                  | Используется в              |
| -------------------------- | ----------------------------------------- | --------------------------- |
| `volatility`               | Относительная волатильность свечи         | Анализ импульсов            |
| `momentum`                 | Изменение цены за период (%)              | SmartMoney/Breakout         |
| `volume`                   | Суммарный объём сделок                    | Подтверждение силы движения |
| `ma_20`                    | Среднее за 20 свечей                      | Bollinger Bands             |
| `upper_band`, `lower_band` | Границы канала                            | Signal Zone                 |
| `signal_zone`              | Качественный индикатор (BUY/SELL/NEUTRAL) | Telegram Alerts             |

---

## 🧠 18.6. Snowflake структура таблиц

| Схема       | Таблица          | Назначение            |
| ----------- | ---------------- | --------------------- |
| `RAW`       | `TRADES`         | Сырые сделки из Kafka |
| `STAGING`   | `OHLCV_AGG`      | Агрегация по минутам  |
| `ANALYTICS` | `OHLCV_FEATURES` | Индикаторы и сигналы  |

---

## 🧪 18.7. Пример SQL-запроса для верификации

```sql
select symbol, t_min, close, volume, momentum, signal_zone
from analytics.ohlcv_features
order by t_min desc
limit 10;
```

✅ Пример вывода:

```
| symbol | t_min               | close  | volume | momentum | signal_zone |
|---------|--------------------|--------|---------|------------|--------------|
| BTCUSDT | 2025-11-01 10:20:00| 65324  | 2.13M   | +0.25%     | NEUTRAL      |
| BTCUSDT | 2025-11-01 10:19:00| 65160  | 3.01M   | -0.41%     | BUY_ZONE     |
```

---

## 📈 18.8. Визуализация (Streamlit)

```python
import pandas as pd, streamlit as st
df = pd.read_csv("ohlcv_features.csv")
st.line_chart(df[['close', 'ma_20', 'upper_band', 'lower_band']])
```

