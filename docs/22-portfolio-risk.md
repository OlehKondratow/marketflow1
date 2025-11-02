# 22. Portfolio, Risk & Capital Management

## 🎯 Цель раздела

Основная задача этого этапа — управление капиталом и риском торгового портфеля.  
MarketFlow должен не только исполнять сигналы, но и контролировать общую прибыльность,  
просадку, уровень риска и долю капитала, выделяемого под каждую стратегию или актив.

---

## 🧭 22.1. Общая архитектура

```

[Executed Trades → Snowflake]
↓
[Risk Engine (Python / dbt)]
↓
[Portfolio Allocation / Limits]
↓
[Dashboards + Telegram Alerts]

````

---

## ⚙️ 22.2. Основные цели системы управления рисками

| Компонент | Описание |
|------------|-----------|
| **PnL Tracker** | Расчёт прибыли/убытка по каждой сделке и по портфелю |
| **Exposure Control** | Ограничение размера позиции на актив/стратегию |
| **Risk Limit Manager** | Контроль просадки и Value-at-Risk (VaR) |
| **Rebalancer** | Автоматическое перераспределение капитала между активами |
| **Risk Alerts** | Уведомления при превышении лимитов (в Telegram и Grafana) |

---

## 🧮 22.3. Пример dbt-модели для расчёта PnL

**models/portfolio_pnl.sql**
```sql
{{ config(materialized='table') }}

with execs as (
    select
        symbol,
        side,
        executed_at,
        qty,
        price,
        signal_type,
        lag(price) over (partition by symbol order by executed_at) as prev_price
    from {{ source('analytics', 'order_history') }}
)

select
    symbol,
    executed_at,
    side,
    qty,
    price,
    round(
        case
            when side='SELL' then (price - prev_price) / prev_price * 100
            else 0
        end, 2
    ) as profit_pct
from execs
````

---

## 📈 22.4. Пример Python Risk Engine

**risk_manager.py**

```python
import pandas as pd
from loguru import logger

MAX_DRAWDOWN = 0.15  # 15%
MAX_ALLOCATION = 0.30  # 30% на один актив
CAPITAL = 10000

df = pd.read_csv("order_history.csv")
df["value"] = df["qty"] * df["price"]
df["profit_value"] = df["value"] * df["profit_pct"] / 100

portfolio_value = CAPITAL + df["profit_value"].sum()
drawdown = (df["profit_value"].cumsum().max() - df["profit_value"].cumsum().iloc[-1]) / CAPITAL

if drawdown > MAX_DRAWDOWN:
    logger.warning(f"⚠️ Просадка {drawdown*100:.2f}% превышает лимит. Остановка торгов.")
else:
    logger.info(f"💰 Portfolio value: {portfolio_value:.2f} USDC | Drawdown: {drawdown*100:.2f}%")
```

---

## 🧠 22.5. Ключевые показатели риска

| Показатель           | Формула                                             | Интерпретация               |
| -------------------- | --------------------------------------------------- | --------------------------- |
| **Total PnL (%)**    | (Equity_now / Equity_start - 1) × 100               | Общая доходность            |
| **Max Drawdown (%)** | (Peak - Trough) / Peak × 100                        | Максимальная просадка       |
| **Win Rate (%)**     | (Количество прибыльных сделок / Всего сделок) × 100 | Доля успешных сделок        |
| **VaR (95%)**        | Потенциальный убыток при 95% доверии                | Статистический риск         |
| **Exposure (%)**     | Доля капитала в активе                              | Концентрация риска          |
| **Sharpe Ratio**     | (Средняя доходность / Стандартное отклонение)       | Доходность на единицу риска |

---

## 🧩 22.6. Пример перераспределения капитала

**allocation_optimizer.py**

```python
import pandas as pd

CAPITAL = 10000
alloc = {
    "BTCUSDT": 0.4,
    "ETHUSDT": 0.3,
    "SOLUSDT": 0.2,
    "WIFUSDC": 0.1
}

risk = pd.DataFrame({
    "symbol": alloc.keys(),
    "volatility": [0.22, 0.18, 0.25, 0.35]
})

risk["adjusted_alloc"] = (1 / risk["volatility"]) / (1 / risk["volatility"]).sum()
risk["capital_usd"] = risk["adjusted_alloc"] * CAPITAL
print(risk)
```

✅ Пример вывода:

```
| symbol | volatility | adjusted_alloc | capital_usd |
|---------|-------------|----------------|--------------|
| BTCUSDT | 0.22        | 0.30           | 3000         |
| ETHUSDT | 0.18        | 0.36           | 3600         |
| SOLUSDT | 0.25        | 0.26           | 2600         |
| WIFUSDC | 0.35        | 0.08           | 800          |
```

---

## ⚡ 22.7. Telegram уведомления

**telegram_risk_alerts.py**

```python
import os, requests

def alert_risk(msg):
    requests.post(
        f"https://api.telegram.org/bot{os.getenv('TG_TOKEN')}/sendMessage",
        json={"chat_id": os.getenv("TG_CHAT_ID"), "text": msg}
    )

def check_drawdown(drawdown):
    if drawdown > 0.15:
        alert_risk(f"⚠️ Просадка {drawdown*100:.1f}% превышает лимит! Торговля приостановлена.")
```

---

## 🧾 22.8. Интеграция с Snowflake и Grafana

| Компонент                               | Назначение                                         |
| --------------------------------------- | -------------------------------------------------- |
| **Snowflake table `portfolio_summary`** | Хранение дневных результатов                       |
| **Grafana Dashboard**                   | Визуализация PnL, drawdown, exposure               |
| **Alert Rules**                         | Уведомления при drawdown > 10% или equity < лимита |

---

## 🧮 22.9. Пример SQL отчёта

```sql
select
    current_date() as report_date,
    sum(profit_pct)/count(*) as avg_trade,
    max(profit_pct) as best_trade,
    min(profit_pct) as worst_trade,
    sum(profit_value) as total_pnl_usd
from analytics.portfolio_pnl;
```
