import asyncio
import json
import websockets
from loguru import logger
from metrics import ws_reconnects_total

BINANCE_STREAM_URL = "wss://stream.binance.com:9443/stream"

class BinanceWSClient:
    def __init__(self, symbols):
        self.symbols = symbols

    async def connect(self):
        streams = "/".join([f"{s}@trade" for s in self.symbols])
        url = f"{BINANCE_STREAM_URL}?streams={streams}"
        logger.info(f"Connecting to Binance WS: {url}")

        while True:
            try:
                async with websockets.connect(url, ping_interval=20, ping_timeout=20) as ws:
                    async for msg in ws:
                        data = json.loads(msg)
                        yield data
            except Exception as e:
                logger.warning(f"WebSocket error: {e}, reconnecting in 5s...")
                for sym in self.symbols:
                    ws_reconnects_total.labels(symbol=sym).inc()
                await asyncio.sleep(5)
