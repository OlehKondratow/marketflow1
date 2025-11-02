# main.py
import asyncio
import argparse
import uvicorn
from contextlib import asynccontextmanager
from loguru import logger
import uvloop
from fastapi import FastAPI

from app import config
from app.metrics import metrics_router
from app.telemetry import TelemetryProducer, close_telemetry
from app.loader import run_loader
from app.kafka_client import KafkaControlListener

# Используем uvloop для повышения производительности
asyncio.set_event_loop_policy(uvloop.EventLoopPolicy())

stop_event = asyncio.Event()

async def handle_control_messages(telemetry: TelemetryProducer):
    """Подписка на управляющие команды из Kafka (например, STOP)."""
    listener = KafkaControlListener(config.QUEUE_ID)
    await listener.start()
    try:
        async for command in listener.listen():
            if command.get("command") == "stop":
                logger.warning(f"🛑 Получена команда STOP: {command}")
                await telemetry.send_status_update(
                    status="interrupted",
                    message="Остановлено по команде",
                    finished=True
                )
                stop_event.set()
                break
    finally:
        await listener.stop()

async def run_app_logic():
    """Основная бизнес-логика: запуск WS-загрузки и прослушка команд."""
    telemetry = TelemetryProducer()
    await telemetry.start()
    logger.info(f"🚀 Запуск loader-ws-trades: {config.QUEUE_ID} -> {config.KAFKA_TOPIC}")
    await telemetry.send_status_update(status="started", message="WS Trades загрузка начата")

    loader_task = asyncio.create_task(run_loader(stop_event, telemetry))
    control_task = asyncio.create_task(handle_control_messages(telemetry))

    done, pending = await asyncio.wait([loader_task, control_task], return_when=asyncio.FIRST_COMPLETED)

    for task in pending:
        task.cancel()
        try:
            await task
        except asyncio.CancelledError:
            pass

    logger.info("✅ Завершение работы loader-ws-trades.")
    await close_telemetry(telemetry)

@asynccontextmanager
async def lifespan(app: FastAPI):
    """Обработка старта и остановки FastAPI."""
    parser = argparse.ArgumentParser()
    parser.add_argument("--noop", action="store_true", help="NOOP флаг (например, для CI)")
    args, _ = parser.parse_known_args()

    if not args.noop:
        logger.info("🔄 startup FastAPI")
        app_logic_task = asyncio.create_task(run_app_logic())
        yield
        logger.info("🔻 shutdown FastAPI")
        stop_event.set()
        await app_logic_task
    else:
        logger.info("🧪 NOOP-режим включен — пропускаем запуск бизнес-логики")
        yield

app = FastAPI(title="Loader WS Trades", lifespan=lifespan)
app.include_router(metrics_router)

if __name__ == "__main__":
    uvicorn.run(app, host="0.0.0.0", port=8080)