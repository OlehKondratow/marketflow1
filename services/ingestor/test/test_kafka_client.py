import asyncio
from ws_client import BinanceWSClient
from kafka_client import KafkaProducerClient

async def main():
    ws = BinanceWSClient(symbols=["ethusdt"])
    producer = KafkaProducerClient(topic="trades_raw")

    async for msg in ws.stream():
        await producer.send(msg)
        print("Sent:", msg)
        break

if __name__ == "__main__":
    asyncio.run(main())
