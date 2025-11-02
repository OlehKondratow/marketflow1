import os
import asyncio
from loguru import logger
from aiokafka import AIOKafkaProducer
import time
from metrics import messages_sent_total, latency_seconds

class KafkaClient:
    def __init__(self, topic: str):
        self.topic = topic
        self.producer = None

    async def start(self):
        self.producer = AIOKafkaProducer(
            bootstrap_servers=os.getenv("KAFKA_BROKER"),
            security_protocol="SASL_SSL",
            sasl_mechanism="PLAIN",
            sasl_plain_username=os.getenv("KAFKA_USERNAME"),
            sasl_plain_password=os.getenv("KAFKA_PASSWORD"),
            ssl_context=ssl.create_default_context()
        )
        await self.producer.start()
        logger.info(f"Kafka producer started for topic: {self.topic}")

    async def send(self, symbol: str, message: str):
        if not self.producer:
            logger.error("Kafka producer not started!")
            return
        try:
            start = time.time()
            await self.producer.send_and_wait(self.topic, message.encode())
            latency_seconds.labels(symbol=symbol).observe(time.time() - start)
            messages_sent_total.labels(symbol=symbol).inc()
        except Exception as e:
            logger.error(f"Kafka send error: {e}")

    async def stop(self):
        if self.producer:
            await self.producer.stop()
            logger.info("Kafka producer stopped.")
