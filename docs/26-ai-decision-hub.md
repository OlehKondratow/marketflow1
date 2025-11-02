# 26. AI Decision Hub

## 🎯 Цель раздела

AI Decision Hub — это “мозг” системы MarketFlow,  
который принимает торговые решения, объединяя несколько потоков информации:

- 📊 ML-оценку сигналов (Signal Score)
- 💡 Рыночное настроение (Sentiment)
- 💰 Риск-профиль портфеля (Drawdown, Exposure)
- ⚙️ Контроль исполнения (Order Feedback)

Результат — динамическое принятие решений BUY / SELL / HOLD  
с адаптацией параметров и полной обратной связью.

---

## 🧭 26.1. Общая архитектура

```

[Signals + ML Scores + Sentiment + Risk Data]
↓
[AI Decision Engine (Python / n8n / Airflow)]
↓
[Action: BUY / SELL / HOLD]
↓
[Execution → Binance / Snowflake / Telegram]
↓
[Feedback Loop → Retrain + Rebalance]

````

---

## 🧩 26.2. Основные входные данные

| Источник | Таблица / Топик | Описание |
|-----------|------------------|-----------|
| ML Engine | `SIGNAL_SCORES` | вероятность успеха сигнала |
| NLP Engine | `MARKET_SENTIMENT` | средний sentiment активов |
| Risk Manager | `PORTFOLIO_METRICS` | drawdown, exposure |
| Strategy | `TRADING_SIGNALS` | базовые сигналы BUY_SM / SELL_SM |
| Execution | `ORDER_HISTORY` | подтверждения ордеров |

---

## 🧠 26.3. Decision Logic (пример Python)

```python
import pandas as pd

signals = pd.read_csv("signals_scored.csv")
sentiment = pd.read_csv("market_sentiment.csv")
risk = pd.read_csv("portfolio_metrics.csv")

merged = signals.merge(sentiment, on="symbol").merge(risk, on="symbol")
merged["decision"] = "HOLD"

for i, r in merged.iterrows():
    if r.signal_type == "BUY_SM" and r.score > 0.75 and r.sentiment > 0 and r.drawdown < 0.1:
        merged.loc[i, "decision"] = "BUY"
    elif r.signal_type == "SELL_SM" and r.score > 0.7 and r.sentiment < 0 and r.exposure > 0.2:
        merged.loc[i, "decision"] = "SELL"

merged.to_csv("ai_decisions.csv", index=False)
````

---

## 📊 26.4. Пример результатов Decision Hub

```
| symbol | signal_type | score | sentiment | drawdown | exposure | decision |
|---------|--------------|--------|------------|------------|-----------|-----------|
| BTCUSDT | BUY_SM       | 0.84   | 0.21       | 0.05       | 0.18      | BUY       |
| ETHUSDT | SELL_SM      | 0.81   | -0.12      | 0.04       | 0.25      | SELL      |
| SOLUSDT | HOLD         | 0.48   | 0.10       | 0.03       | 0.15      | HOLD      |
```

---

## ⚙️ 26.5. Интеграция Decision Hub в n8n

Workflow-последовательность:

```
🟦 Snowflake SELECT (signals, scores, sentiment)
     ↓
🟨 Python Node (decision logic)
     ↓
🟧 SQL Node → UPDATE decisions table
     ↓
🟥 Telegram Node → уведомление трейдера
```

**Пример уведомления:**

```
🤖 AI Decision Hub
Symbol: BTCUSDT
Action: 🟩 BUY
Score: 0.84 | Sentiment: +0.21 | Drawdown: 5.0%
```

---

## 💾 26.6. Хранение решений в Snowflake

**models/ai_decisions.sql**

```sql
{{ config(materialized='table') }}

select
    symbol,
    t_min,
    decision,
    score,
    sentiment,
    drawdown,
    exposure,
    current_timestamp() as updated_at
from {{ source('analytics', 'ai_decisions_staging') }}
```

---

## 🧮 26.7. Feedback Loop (обратная связь)

AI Decision Hub собирает результаты исполнения и использует их для:

* обновления моделей ML (retrain каждые 7 дней);
* корректировки риск-порогов (auto-tuning);
* анализа точности решений (`Decision Accuracy %`).

**Пример метрик:**

| Показатель             | Значение |
| ---------------------- | -------- |
| Decision Accuracy      | 74.5 %   |
| Avg Profit (AI trades) | +3.2 %   |
| Reduction of Drawdown  | −18 %    |
| Signal Latency         | 1.8 сек  |

---

## 📈 26.8. Grafana Dashboard — “AI Decision Control”

**Основные панели:**

* ✅ Decision Matrix (BUY/SELL vs sentiment)
* 💹 Performance Comparison (AI vs Baseline)
* 📉 Risk Impact (drawdown до/после AI)
* 🧭 Confidence Distribution (распределение score)
* ⚙️ Model Retrain Log (дата, точность, F1-score)

---

## 🤖 26.9. Автоматические действия Decision Hub

| Условие                        | Действие                         |
| ------------------------------ | -------------------------------- |
| `score > 0.85 & sentiment > 0` | увеличить объём сделки           |
| `drawdown > 0.15`              | приостановить торговлю           |
| `WinRate < 60%`                | инициировать retraining          |
| `PnL < 0` 3 дня подряд         | снизить риск или закрыть позиции |

---

## 🧰 26.10. Пример Auto-Retrain Workflow (n8n)

```
🕒 Cron → 🟦 Snowflake Export → 🟨 Python ML Retrain → 🟧 Upload Model → 🟥 Telegram Summary
```

**Telegram отчет:**

```
🤖 Retrain Completed
New model accuracy: 0.81
Feature importance: momentum, sentiment, dist_high
Deployed: 2025-11-10 03:00 UTC
```

---

## 🧠 26.11. Итоговая логика AI Decision Hub

| Модуль                 | Функция                             |
| ---------------------- | ----------------------------------- |
| **ML Scoring**         | оценка качества сигналов            |
| **NLP Sentiment**      | анализ новостного и соц. фона       |
| **Risk Engine**        | контроль капитала и drawdown        |
| **Execution Feedback** | обновление точности                 |
| **Auto-Tuning**        | самообучение и коррекция параметров |
| **Alerts & Dashboard** | визуализация и нотификации          |

