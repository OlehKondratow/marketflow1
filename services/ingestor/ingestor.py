import asyncio
import uvloop
import os
from loguru import logger
from kafka_client import KafkaClient
from ws_client import BinanceWSClient
from prometheus_client import start_http_server
from config import SYMBOLS, TOPIC

# --- Start Prometheus metrics endpoint ---
def start_metrics_server():
    port = int(os.getenv("PROM_PORT", 8000))
    start_http_server(port)
    logger.info(f"✅ Prometheus metrics endpoint started on :{port}")

start_metrics_server()

async def run_ingestor():
    kafka = KafkaClient(TOPIC)
    await kafka.start()

    ws = BinanceWSClient(SYMBOLS)
    logger.info(f"Starting WS streams for {SYMBOLS}")

    async for msg in ws.connect():
        try:
            stream = msg.get("stream", "")
            data = msg.get("data", {})
            symbol = stream.split("@")[0].upper() if stream else "UNKNOWN"
            await kafka.send(symbol, json.dumps(data))
        except Exception as e:
            logger.error(f"Message processing error: {e}")
            await asyncio.sleep(2)

async def main():
    logger.info(f"Starting MarketFlow Ingestor for {SYMBOLS}")
    await run_ingestor()

if __name__ == "__main__":
    uvloop.run(main())
