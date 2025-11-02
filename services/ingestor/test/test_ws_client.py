import pytest
import asyncio
from ws_client import BinanceWSClient

@pytest.mark.asyncio
async def test_ws_connection():
    ws = BinanceWSClient(symbols=["btcusdt"])
    async for msg in ws.stream():
        assert "e" in msg
        break
