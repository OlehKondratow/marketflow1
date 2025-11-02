# 25. AI Integration & Automation Layer

## 🎯 Цель раздела

Добавить уровень искусственного интеллекта (AI) к системе MarketFlow  
для интеллектуальной оценки торговых сигналов, анализа новостного фона,  
адаптивной оптимизации стратегий и интеграции с внешними источниками (Twitter/X, Telegram, CoinDesk и др.)  
через платформу n8n.

---

## 🧭 25.1. Общая архитектура

```

[MarketFlow Signals & OHLCV Features]
↓
[ML Models → Signal Scoring]
↓
[NLP → News & Sentiment Analysis]
↓
[n8n Workflows → AI Actions]
↓
[Strategy Auto-Tuning & Alerts]

````

---

## 🧠 25.2. ML-оценка торговых сигналов (Signal Quality Scoring)

Цель — оценить вероятность успеха каждого торгового сигнала на основе исторических данных и признаков.  
Модель обучается на данных `ANALYTICS.TRADING_SIGNALS` с меткой результата (`profit_pct > 0`).

| Этап | Описание |
|------|-----------|
| 🧩 Features | volatility, momentum, volume, dist_low, dist_high |
| 🏷 Labels | 1 — успешный сигнал, 0 — убыточный |
| ⚙️ Модель | RandomForest / XGBoost / Logistic Regression |
| 📈 Output | `score ∈ [0,1]` — вероятность успешной сделки |

**Пример Python-модели:**
```python
import pandas as pd
from sklearn.ensemble import RandomForestClassifier

df = pd.read_csv("signals_history.csv")
X = df[["volatility", "momentum", "volume", "dist_low", "dist_high"]]
y = (df["profit_pct"] > 0).astype(int)

model = RandomForestClassifier(n_estimators=200, random_state=42)
model.fit(X, y)
df["score"] = model.predict_proba(X)[:, 1]
df.to_csv("signals_scored.csv", index=False)
````

Результаты записываются в Snowflake:

```
ANALYTICS.SIGNAL_SCORES(symbol, t_min, signal, score)
```

---

## 🗞️ 25.3. NLP-анализ новостей и Twitter/X

AI-агент отслеживает новости и сообщения в социальных сетях, оценивает тональность (sentiment)
и связывает её с торговыми активами.

**Источники:**

* Twitter/X API (через n8n → HTTP Request)
* RSS CoinDesk, CoinTelegraph, Binance Blog
* Telegram / Discord (через ботов)

**Пример анализа твитов:**

```python
import tweepy, textblob

client = tweepy.Client(bearer_token=os.getenv("X_BEARER_TOKEN"))
tweets = client.search_recent_tweets(query="bitcoin", max_results=20)

sentiments = []
for t in tweets.data:
    polarity = textblob.TextBlob(t.text).sentiment.polarity
    sentiments.append(polarity)

avg_sent = sum(sentiments)/len(sentiments)
print(f"Средний сентимент Twitter по 'bitcoin': {avg_sent:.2f}")
```

📊 Среднее значение `avg_sent` сохраняется в Snowflake таблицу `MARKET_SENTIMENT`,
и используется для фильтрации сигналов (например, BUY разрешён только при sentiment > 0).

---

## ⚙️ 25.4. Auto-Tuning стратегий

AI-модуль анализирует последние результаты и подбирает оптимальные параметры стратегий:
дистанцию до WeakLow/WeakHigh, порог объёма, окно скользящей средней и т.д.

**Auto-tune через n8n Workflow:**

```
🕒 Cron Trigger (каждые 24ч)
   → Python Node: анализ исторических PnL
   → SQL Node (Snowflake): обновление параметров
   → Telegram Node: отчёт о новых значениях
```

**Пример Python-кода:**

```python
import numpy as np
from sklearn.model_selection import ParameterGrid

def simulate(df, params):
    return df.apply(lambda r: (r.close - r.open)/r.open if r.signal=='BUY_SM' else 0, axis=1).mean()

grid = {"dist_threshold": [0.006, 0.008, 0.010], "vol_mult": [1.2, 1.5, 2.0]}
best_pnl, best_params = -999, {}

for p in ParameterGrid(grid):
    pnl = simulate(df, p)
    if pnl > best_pnl:
        best_pnl, best_params = pnl, p

print("Лучшие параметры:", best_params)
```

---

## 🤖 25.5. Интеграция n8n (AI + Automation)

n8n используется как оркестратор “AI-потоков”.
Примеры сценариев:

| Workflow                 | Описание                                                |
| ------------------------ | ------------------------------------------------------- |
| **AI Signal Review**     | Отбирает сигналы со score > 0.8 и уведомляет в Telegram |
| **News Sentiment Alert** | При негативном фоне по BTC — снижает объём позиции      |
| **Auto-Tune Strategy**   | Ежедневно обновляет параметры стратегий                 |
| **Weekly Summary**       | Генерирует AI-отчёт по результатам недели через OpenAI  |

**Пример цепочки:**

```
🟦 Snowflake Node → 🟨 OpenAI Node → 🟥 Telegram Node
```

---

## 🧩 25.6. Пример n8n Workflow “AI Market Summary”

1. **Snowflake Node** — выборка последних 24h сигналов и PnL
2. **OpenAI Node (GPT-5)** — запрос:

   > "Сгенерируй краткий отчёт по торговле за сутки. Укажи прибыль, лучшие и худшие активы, общий sentiment."
3. **Telegram Node** — отправка отчёта трейдеру.

**Пример результата:**

```
📊 MarketFlow AI Summary (24h)
Profit: +3.8% | WinRate: 72%
Strong: ETHUSDT (+1.9%), SOLUSDT (+1.5%)
Weak: WIFUSDC (-0.7%)
Market Sentiment: Нейтральный → положительный.
```

---

## 📊 25.7. AI Dashboard в Grafana / Streamlit

| Панель                       | Описание                                          |
| ---------------------------- | ------------------------------------------------- |
| **Signal Confidence**        | Распределение вероятностей `score`                |
| **Market Sentiment**         | Средний sentiment по активам                      |
| **AI-Tuned Parameters**      | История оптимизаций                               |
| **Performance (AI vs Base)** | Сравнение доходности стратегий с/без AI-коррекции |

---

## 🔗 25.8. Технологии AI-интеграции

| Функция              | Инструмент                                  |
| -------------------- | ------------------------------------------- |
| ML-обучение сигналов | scikit-learn / XGBoost / Snowflake ML       |
| NLP-анализ           | OpenAI API / HuggingFace / TextBlob         |
| Авто-тюнинг          | n8n / Airflow / Python scripts              |
| Хранилище данных     | Snowflake (MARKET_SENTIMENT, SIGNAL_SCORES) |
| Мессенджеры          | Telegram / Discord Bots                     |
| Мониторинг           | Grafana Cloud (AI Metrics Dashboard)        |

