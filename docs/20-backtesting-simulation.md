# 20. Backtesting & Simulation

## 🎯 Цель раздела

Цель этого этапа — проверить эффективность торговых стратегий на исторических данных.  
Backtesting позволяет оценить потенциальную прибыль, просадку и частоту сделок,  
прежде чем стратегия будет запущена в реальном времени.

---

## 🧭 20.1. Общая архитектура

```

[Snowflake: OHLCV_FEATURES + SIGNALS]
↓
[Backtest Engine (Python / dbt-run)]
↓
[Simulation Results → Snowflake / CSV]
↓
[Visualization: Streamlit / Grafana]

```

---

## ⚙️ 20.2. Основные цели

| Этап | Цель |
|------|------|
| 1️⃣ | Загрузить исторические данные и сигналы |
| 2️⃣ | Симулировать сделки на основе сигналов |
| 3️⃣ | Рассчитать PnL, WinRate, Drawdown |
| 4️⃣ | Визуализировать Equity-кривую |
| 5️⃣ | Сохранить результаты в Snowflake для анализа |

---

## 🧩 20.3. Источник данных

Исторические данные поступают из таблиц Snowflake:

| Таблица | Назначение |
|----------|------------|
| `ANALYTICS.OHLCV_FEATURES` | Исторические свечи и индикаторы |
| `ANALYTICS.TRADING_SIGNALS` | Сгенерированные сигналы (BUY/SELL/HOLD) |

---

## 🧮 20.4. Алгоритм симуляции (псевдокод)

```

for row in trading_signals:
if signal == "BUY_SM" and not in_position:
buy_price = close
in_position = True
elif signal == "SELL_SM" and in_position:
profit = (close - buy_price) / buy_price * 100
results.append(profit)
in_position = False

````

---

## 🧠 20.5. Python Backtesting Engine

**backtest_smartmoney.py**
```python
import pandas as pd
import matplotlib.pyplot as plt

df = pd.read_csv("signals.csv")
equity = [1000.0]
in_pos, buy_price = False, 0

for _, row in df.iterrows():
    if row.signal_type == "BUY_SM" and not in_pos:
        buy_price = row.close
        in_pos = True
    elif row.signal_type == "SELL_SM" and in_pos:
        profit = (row.close - buy_price) / buy_price
        equity.append(equity[-1] * (1 + profit))
        in_pos = False
    else:
        equity.append(equity[-1])

df["equity"] = equity
print(f"Final equity: {df.equity.iloc[-1]:.2f} USD")

plt.figure(figsize=(10,5))
plt.plot(df["t_min"], df["equity"])
plt.title("SmartMoney Backtest Equity Curve")
plt.xlabel("Time")
plt.ylabel("Equity (USD)")
plt.grid()
plt.show()
````

---

## 📊 20.6. Пример результатов

```
Начальный капитал:   1000 USDC
Количество сделок:   22
Победные сделки:     16 (72.7%)
Максимальная просадка: -8.4%
Финальный капитал:   1275 USDC (+27.5%)
Средняя прибыль/убыток: +1.21%
```

---

## 🧮 20.7. Метрики эффективности

| Метрика           | Описание                                        |
| ----------------- | ----------------------------------------------- |
| **PnL (%)**       | Общая доходность за период                      |
| **Win Rate (%)**  | Процент прибыльных сделок                       |
| **Max Drawdown**  | Максимальная просадка капитала                  |
| **Profit Factor** | Отношение суммарной прибыли к суммарному убытку |
| **Sharpe Ratio**  | Доходность на единицу риска                     |
| **Avg Trade (%)** | Средний результат сделки                        |

---

## 🧱 20.8. Интеграция с dbt / Snowflake

Можно автоматизировать бэктест через dbt-модель:

**models/backtest_summary.sql**

```sql
{{ config(materialized='table') }}

select
    symbol,
    count_if(signal_type='BUY_SM') as total_buys,
    count_if(signal_type='SELL_SM') as total_sells,
    avg(profit_pct) as avg_profit,
    stddev(profit_pct) as std_profit,
    sum(case when profit_pct > 0 then 1 else 0 end)/count(*)*100 as winrate
from {{ ref('trade_results') }}
group by symbol
```

---

## 📈 20.9. Streamlit визуализация

```python
import streamlit as st
import pandas as pd
df = pd.read_csv("backtest_results.csv")

st.title("📊 SmartMoney Backtest Results")
st.line_chart(df["equity"])
st.metric("WinRate", "72.7%")
st.metric("Total PnL", "+27.5%")
```

---

## ⚡ 20.10. Расширенные сценарии симуляции

| Тип сценария              | Особенности                                                  |
| ------------------------- | ------------------------------------------------------------ |
| **Multi-Symbol Backtest** | Одновременный анализ нескольких инструментов                 |
| **Risk-Based Backtest**   | Использование фиксированного риска (1–2% депозита на сделку) |
| **Fee-Adjusted PnL**      | Учёт комиссий Binance (0.1%)                                 |
| **Leverage Simulation**   | Проверка влияния плеча на результат                          |

---

