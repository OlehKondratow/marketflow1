import os
import logging
import requests
import asyncio
from datetime import datetime
from fastapi import FastAPI
from contextlib import asynccontextmanager
from arango import ArangoClient
from tenacity import retry, stop_after_attempt, wait_exponential

logging.basicConfig(level=logging.INFO, format="%(asctime)s - %(levelname)s - %(message)s")
logger = logging.getLogger(__name__)

# ──────────────────────────────────────────────────────────────────────────
# Параметры окружения
# ──────────────────────────────────────────────────────────────────────────
# Переменные окружения
ARANGODB_URL = os.getenv("ARANGODB_URL", "http://abase-3.dmz.home:8529")
ARANGO_USER = os.getenv("ARANGO_USER", "root")
ARANGO_PASSWORD = os.getenv("ARANGO_PASSWORD", "7ZAxJ7w1ItEoKmqWdE")
DB_NAME = os.getenv("DB_NAME", "trading_data")
TRADE_COLLECTION_NAME = os.getenv("TRADE_COLLECTION_NAME", "order_book_API12_2025pixelusdt")

BINANCE_API_KEY = os.getenv('BINANCE_API_KEY')
BINANCE_API_SECRET = os.getenv('BINANCE_API_SECRET')
TELEGRAM_BOT_TOKEN = os.getenv("TELEGRAM_BOT_TOKEN", "7915103866:AAFbTvZb9NpoME0M0VsqrYzUXa9SIqjL17g")
TELEGRAM_CHAT_ID = os.getenv("TELEGRAM_CHAT_ID", "414744220")
# ──────────────────────────────────────────────────────────────────────────
# Глобальные объекты
# ──────────────────────────────────────────────────────────────────────────
client = None
trade_collection = None
binance_session = requests.Session()

# Очередь для разделения этапов чтения и записи
# При желании можно указать maxsize=..., если хотите ограничить рост памяти
write_queue: asyncio.Queue = asyncio.Queue()

# ──────────────────────────────────────────────────────────────────────────
# Функция отправки сообщений в Telegram
# ──────────────────────────────────────────────────────────────────────────
def send_telegram_message(message: str):
    """
    Отправка уведомления в Telegram только в ключевых точках (старт, ошибки, завершение и т.д.).
    """
    if not TELEGRAM_BOT_TOKEN or not TELEGRAM_CHAT_ID:
        logger.warning("⚠ Telegram уведомления отключены (нет токена или chat_id)")
        return

    url = f"https://api.telegram.org/bot{TELEGRAM_BOT_TOKEN}/sendMessage"
    payload = {"chat_id": TELEGRAM_CHAT_ID, "text": message}
    try:
        response = requests.post(url, json=payload)
        if response.status_code != 200:
            logger.error(f"Ошибка отправки в Telegram: {response.text}")
    except Exception as e:
        logger.error(f"Ошибка при отправке в Telegram: {e}")

# ──────────────────────────────────────────────────────────────────────────
# Подключение к ArangoDB
# ──────────────────────────────────────────────────────────────────────────
def connect_to_arango():
    global client, trade_collection
    logger.info(f"🔌 Подключаемся к ArangoDB: {ARANGODB_URL}")
    send_telegram_message(f"🔌 Подключаемся к ArangoDB: {ARANGODB_URL}")

    try:
        client = ArangoClient(hosts=ARANGODB_URL)
        db = client.db(DB_NAME, username=ARANGO_USER, password=ARANGO_PASSWORD)
        if not db.has_collection(TRADE_COLLECTION_NAME):
            logger.info(f"⚠ Коллекция '{TRADE_COLLECTION_NAME}' не найдена. Создаём...")
            db.create_collection(TRADE_COLLECTION_NAME)
        trade_collection = db.collection(TRADE_COLLECTION_NAME)
        logger.info(f"✅ Подключение успешно! Коллекция '{TRADE_COLLECTION_NAME}' доступна.")
        send_telegram_message(f"✅ ArangoDB подключена. Коллекция '{TRADE_COLLECTION_NAME}' доступна.")
    except Exception as e:
        logger.error(f"❌ Ошибка подключения к ArangoDB: {e}", exc_info=True)
        send_telegram_message(f"❌ Ошибка подключения к ArangoDB: {e}")

# ──────────────────────────────────────────────────────────────────────────
# Функция загрузки данных из Binance (producer)
# ──────────────────────────────────────────────────────────────────────────
@retry(stop=stop_after_attempt(5), wait=wait_exponential(multiplier=1, min=1, max=10))
async def fetch_historical_trades(symbol: str, start_time: datetime, end_time: datetime):
    """
    Получает данные с Binance и складывает их в очередь (write_queue).
    """
    logger.info(f"🚀 Загрузка данных {symbol} с {start_time} по {end_time}")
    send_telegram_message(f"🚀 Загрузка данных {symbol} с {start_time} по {end_time}")

    base_url = "https://api.binance.com/api/v3/aggTrades"
    params = {
        "symbol": symbol.upper(),
        "startTime": int(start_time.timestamp() * 1000),
        "endTime": int(end_time.timestamp() * 1000),
        "limit": 1000,
    }
    headers = {"X-MBX-APIKEY": BINANCE_API_KEY}

    try:
        total_fetched = 0
        while params["startTime"] < params["endTime"]:
            response = binance_session.get(base_url, headers=headers, params=params)
            if response.status_code == 429:
                retry_after = int(response.headers.get("Retry-After", 1))
                logger.warning(f"Превышен лимит запросов. Повтор через {retry_after} секунд.")
                await asyncio.sleep(retry_after)
                continue

            response.raise_for_status()
            trades = response.json()
            if not trades:
                break

            batch_size = len(trades)
            total_fetched += batch_size
            logger.info(f"💡 Получено {batch_size} записей (startTime={params['startTime']}).")

            # Складываем каждую сделку в очередь
            for trade in trades:
                trade_data = {
                    "_key": str(trade["a"]),
                    "symbol": symbol,
                    "timestamp": trade["T"],  # миллисекунды
                    "trade_id": trade["a"],
                    "tradeSide": "Seller" if trade["m"] else "Buyer",
                    "price": float(trade["p"]),
                    "quantity": float(trade["q"])
                }
                await write_queue.put(trade_data)

            params["startTime"] = trades[-1]["T"] + 1
            await asyncio.sleep(0.05)

        logger.info(f"✅ Завершена загрузка данных для {symbol}, всего получено {total_fetched} записей.")
        send_telegram_message(f"✅ Загрузка данных {symbol} завершена. Получено {total_fetched} записей.")
    except Exception as e:
        logger.error(f"❌ Ошибка загрузки сделок: {e}", exc_info=True)
        send_telegram_message(f"❌ Ошибка загрузки сделок {symbol}: {e}")
        raise

# ──────────────────────────────────────────────────────────────────────────
# Воркер для массовой вставки (batch insert) (consumer)
# ──────────────────────────────────────────────────────────────────────────
async def write_worker(batch_size: int = 5000):
    """
    В цикле накапливает записи из write_queue и вставляет их в ArangoDB одним «батчем».
    batch_size: количество записей, после которого делаем import_bulk(...)
    """
    buffer = []

    while True:
        try:
            # Ждём одну запись (блокирующе)
            item = await write_queue.get()
            buffer.append(item)

            # Если накопили batch_size записей - загружаем их в базу разом
            if len(buffer) >= batch_size:
                try:
                    trade_collection.import_bulk(buffer, on_duplicate="update")
                    logger.info(f"🔸 Успешно добавлено {len(buffer)} записей (batch).")
                except Exception as ex:
                    logger.error(f"Ошибка batch insert в ArangoDB: {ex}")

                # Сигнализируем, что все items внутри batch обработаны
                for _ in range(len(buffer)):
                    write_queue.task_done()
                buffer.clear()

        except asyncio.CancelledError:
            # При отмене воркера: вставим оставшиеся записи, если есть
            if buffer:
                try:
                    trade_collection.import_bulk(buffer, on_duplicate="update")
                    logger.info(f"🟢 Вставлены оставшиеся {len(buffer)} записей при завершении worker.")
                except Exception as ex:
                    logger.error(f"Ошибка при финальном batch insert: {ex}")
                else:
                    for _ in range(len(buffer)):
                        write_queue.task_done()
            raise

        except Exception as e:
            logger.error(f"Ошибка записи в ArangoDB: {e}", exc_info=True)
            # Избавляемся от текущего элемента, чтобы очередь не «застряла»
            write_queue.task_done()

# ──────────────────────────────────────────────────────────────────────────
# lifecycle FastAPI
# ──────────────────────────────────────────────────────────────────────────
@asynccontextmanager
async def lifespan(app: FastAPI):
    logger.info("🚀 FastAPI запускается...")
    send_telegram_message("🚀 FastAPI запускается...")

    # Подключаемся к ArangoDB
    connect_to_arango()

    # Запускаем фоновый воркер записи (один воркер)
    worker_task = asyncio.create_task(write_worker(batch_size=5000))

    # Пример: автоматически загружаем некоторый тестовый интервал при запуске
    symbol = "pixelusdt"
    start_time = datetime(2025, 1, 1, 23, 59, 59)
    end_time = datetime(2025, 3, 31, 23, 59, 59)
    fetch_task = asyncio.create_task(fetch_historical_trades(symbol, start_time, end_time))

    yield  # Уступаем управление FastAPI (обработка HTTP-запросов)

    logger.info("🔌 Завершение работы FastAPI...")
    send_telegram_message("🔌 Завершение работы FastAPI...")

    # Дожидаемся завершения задачи загрузки (чтобы всё скачалось)
    await fetch_task

    # Ждём, пока очередь будет пустая (дозапишутся все данные)
    logger.info("⏳ Ожидаем записи оставшихся данных в очередь...")
    await write_queue.join()
    logger.info("✅ Все данные из очереди записаны.")

    # Останавливаем воркер
    worker_task.cancel()
    try:
        await worker_task
    except asyncio.CancelledError:
        pass

    # Закрываем соединения
    if client is not None:
        client.close()
        logger.info("🔒 Соединение с ArangoDB закрыто.")
        send_telegram_message("🔒 Соединение с ArangoDB закрыто.")

    if binance_session is not None:
        binance_session.close()
        logger.info("🔒 Сессия с Binance закрыта.")
        send_telegram_message("🔒 Сессия с Binance закрыта.")

# ──────────────────────────────────────────────────────────────────────────
# Определяем FastAPI-приложение
# ──────────────────────────────────────────────────────────────────────────
app = FastAPI(lifespan=lifespan)

@app.post("/fetch_trades")
async def fetch_trades(symbol: str, start_time: str, end_time: str):
    """
    Асинхронная загрузка данных по указанному символьному инструменту и временному интервалу.
    Пример тела POST:
    {
        "symbol": "pixelusdt",
        "start_time": "2025-01-01T23:59:59",
        "end_time": "2025-03-31T23:59:59"
    }
    """
    try:
        start_time_dt = datetime.fromisoformat(start_time)
        end_time_dt = datetime.fromisoformat(end_time)

        # Запускаем загрузку в фоне, сразу возвращаем ответ
        asyncio.create_task(fetch_historical_trades(symbol, start_time_dt, end_time_dt))
        msg = (f"Запущена асинхронная загрузка данных для {symbol} "
               f"с {start_time} по {end_time}. Следите за логами / Telegram для статуса.")
        logger.info(msg)
        send_telegram_message(f"👁 {msg}")
        return {"message": msg}

    except Exception as e:
        logger.error(f"Ошибка: {e}", exc_info=True)
        send_telegram_message(f"❌ Ошибка fetch_trades: {e}")
        return {"error": str(e)}

# ──────────────────────────────────────────────────────────────────────────
# Точка входа
# ──────────────────────────────────────────────────────────────────────────
if __name__ == "__main__":
    import uvicorn
    uvicorn.run("main:app", host="0.0.0.0", port=8000)
