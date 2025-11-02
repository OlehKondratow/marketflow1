# 23. Monitoring, Logging & Alerts

## 🎯 Цель раздела

На этом этапе мы обеспечиваем полную наблюдаемость за системой MarketFlow:  
собираем метрики, логи и сигналы с различных сервисов (Ingestor, Strategy, Order Executor, Risk Manager),  
визуализируем их в Grafana и настраиваем оповещения в Telegram.

---

## 🧭 23.1. Общая архитектура

```

[MarketFlow Services]
├── Ingestor
├── Strategy Engine
├── Order Executor
├── Risk Manager
↓
[Prometheus Exporters → Alloy → Grafana Cloud]
↓
[Dashboards + Alert Rules + Telegram Notifications]

````

---

## ⚙️ 23.2. Основные источники данных

| Источник | Метрики / Логи | Назначение |
|-----------|----------------|-------------|
| **Prometheus** | Метрики сервисов (latency, count, errors) | Сбор системных и бизнес метрик |
| **Loki** | Логи Python-приложений | Поиск ошибок, сигналов, ордеров |
| **Grafana** | Дашборды и оповещения | Визуализация и алерты |
| **Telegram Bot** | Нотификации о событиях | Оповещение DevOps / трейдера |

---

## 📈 23.3. Метрики Prometheus

| Компонент | Метрика | Тип | Описание |
|------------|----------|------|-----------|
| **Ingestor** | `ingestor_messages_total` | Counter | Количество обработанных сообщений |
| **Strategy** | `signals_total` | Counter | Генерация сигналов BUY/SELL/HOLD |
| **Order Executor** | `buy_orders_total` / `sell_orders_total` | Counter | Исполненные ордера |
| **Risk Manager** | `portfolio_drawdown` | Gauge | Текущая просадка портфеля |
| **System** | `python_gc_objects_collected_total` | Counter | Показатель GC Python |

---

## 🧩 23.4. Пример интеграции метрик в код

```python
from prometheus_client import Counter, Gauge, start_http_server

# Strategy Engine Metrics
SIGNALS = Counter('signals_total', 'Количество торговых сигналов')
ACTIVE_POSITIONS = Gauge('active_positions', 'Количество открытых позиций')

start_http_server(8002)

def emit_signal(sig_type):
    SIGNALS.inc()
    print(f"Signal emitted: {sig_type}")
````

✅ Метрики доступны по адресу:

```
http://localhost:8002/metrics
```

---

## 🔍 23.5. Логирование (Loki + Promtail)

**loguru** используется во всех микросервисах (`ingestor`, `strategy`, `order_executor`).
Promtail собирает логи и отправляет их в Loki.

**promtail-config.yaml**

```yaml
server:
  http_listen_port: 9080

positions:
  filename: /tmp/positions.yaml

clients:
  - url: https://logs-prod-eu-west.grafana.net/loki/api/v1/push
    basic_auth:
      username: <Grafana Cloud ID>
      password: <Grafana Cloud Token>

scrape_configs:
  - job_name: marketflow
    static_configs:
      - targets:
          - localhost
        labels:
          job: marketflow
          __path__: /var/log/marketflow/*.log
```

---

## 📊 23.6. Пример Grafana Dashboard

**Панель “MarketFlow Overview”** включает:

* 🟩 Кол-во активных сигналов по символам
* 💹 Profit % за период
* ⚠️ Последние ордера и ошибки
* 📉 Drawdown график
* 🔔 Alert-триггеры (PnL < 0, Drawdown > 10%)

**Группы панелей:**

```
[Ingestion Metrics]    → входящий поток данных
[Strategy Signals]     → BUY / SELL динамика
[Execution Metrics]    → кол-во ордеров, прибыль
[Risk Dashboard]       → Equity, VaR, Drawdown
```

---

## 🧠 23.7. Пример Alert Rule (Grafana Cloud)

**alerts/smartmoney.yaml**

```yaml
apiVersion: 1
groups:
  - name: marketflow-alerts
    rules:
      - uid: "drawdown_alert"
        title: "⚠️ Просадка портфеля"
        condition: "A"
        data:
          - refId: A
            datasourceUid: "prometheus"
            model:
              expr: portfolio_drawdown > 0.10
        for: 2m
        labels:
          severity: critical
        annotations:
          summary: "Drawdown превышает 10%"
          description: "MarketFlow портфель просел более чем на 10%."
```

---

## 📬 23.8. Telegram-интеграция алертов

Grafana → Alert → Telegram Bot → чат трейдера/DevOps.
В настройках Grafana указывается Webhook URL Telegram:

**Telegram Webhook пример:**

```
https://api.telegram.org/bot<token>/sendMessage?chat_id=<chat_id>&text={{ .Message }}
```

Пример уведомления:

```
🚨 ALERT: Просадка портфеля
Drawdown: 12.4%
Time: 2025-11-01 10:20 UTC
```

---

## ⚙️ 23.9. Мониторинг состояния сервисов

Проверка контейнеров в AKS:

```bash
kubectl get pods -n marketflow-prod
kubectl logs -f deployment/marketflow-strategy
```

Проверка Prometheus targets:

```
http://grafana-alloy:1234/targets
```

---

## 🧾 23.10. Хранение логов и метрик

| Компонент              | Хранилище             | Период хранения |
| ---------------------- | --------------------- | --------------- |
| **Loki Logs**          | Grafana Cloud Logs    | 7–30 дней       |
| **Prometheus Metrics** | Grafana Cloud Metrics | 14–90 дней      |
| **Snowflake PnL Data** | MarketFlow DB         | Неограниченно   |
| **Telegram Alerts**    | Реальное время        | История в чате  |


