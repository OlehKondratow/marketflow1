from airflow import DAG
from airflow.operators.python import PythonOperator
from datetime import datetime, timedelta
from kafka import KafkaConsumer
import snowflake.connector
import json
import os

# ---------------------------------------------------------------------------
# 🔧 CONFIGURATION
# ---------------------------------------------------------------------------
KAFKA_TOPIC = os.getenv("KAFKA_TOPIC", "ohlcv_raw")
KAFKA_BROKER = os.getenv("KAFKA_BROKER", "marketflow-kafka-ns.servicebus.windows.net:9093")
KAFKA_USERNAME = os.getenv("KAFKA_USERNAME", "$ConnectionString")
KAFKA_PASSWORD = os.getenv("KAFKA_PASSWORD")

SNOWFLAKE_ACCOUNT = os.getenv("SNOWFLAKE_ACCOUNT")
SNOWFLAKE_USER = os.getenv("SNOWFLAKE_USER")
SNOWFLAKE_PASSWORD = os.getenv("SNOWFLAKE_PASSWORD")
SNOWFLAKE_WAREHOUSE = os.getenv("SNOWFLAKE_WAREHOUSE", "MARKETFLOW_WH")
SNOWFLAKE_DATABASE = os.getenv("SNOWFLAKE_DATABASE", "MARKETFLOW_DB")
SNOWFLAKE_SCHEMA = os.getenv("SNOWFLAKE_SCHEMA", "STAGING")

# ---------------------------------------------------------------------------
# 🧩 FUNCTION: consume from Kafka and write to Snowflake
# ---------------------------------------------------------------------------
def kafka_to_snowflake():
    consumer = KafkaConsumer(
        KAFKA_TOPIC,
        bootstrap_servers=[KAFKA_BROKER],
        security_protocol="SASL_SSL",
        sasl_mechanism="PLAIN",
        sasl_plain_username=KAFKA_USERNAME,
        sasl_plain_password=KAFKA_PASSWORD,
        auto_offset_reset="latest",
        enable_auto_commit=True,
    )

    conn = snowflake.connector.connect(
        account=SNOWFLAKE_ACCOUNT,
        user=SNOWFLAKE_USER,
        password=SNOWFLAKE_PASSWORD,
        warehouse=SNOWFLAKE_WAREHOUSE,
        database=SNOWFLAKE_DATABASE,
        schema=SNOWFLAKE_SCHEMA,
    )
    cur = conn.cursor()

    print("✅ Connected to Kafka and Snowflake.")
    for message in consumer:
        try:
            record = json.loads(message.value)
            cur.execute(
                """
                INSERT INTO OHLCV_RAW (SYMBOL, TS, OPEN, HIGH, LOW, CLOSE, VOLUME)
                VALUES (%s, TO_TIMESTAMP_LTZ(%s), %s, %s, %s, %s, %s)
                """,
                (
                    record["s"],
                    record["E"] / 1000,
                    record["o"],
                    record["h"],
                    record["l"],
                    record["c"],
                    record["v"],
                ),
            )
            conn.commit()
            print(f"Inserted {record['s']} @ {record['E']}")
        except Exception as e:
            print("Error:", e)
        break  # ⚠️ read one message per run for MVP

    consumer.close()
    conn.close()
    print("✅ Done")

# ---------------------------------------------------------------------------
# 📆 DAG DEFINITION
# ---------------------------------------------------------------------------
default_args = {
    "owner": "marketflow",
    "depends_on_past": False,
    "email_on_failure": False,
    "email_on_retry": False,
    "retries": 0,
    "retry_delay": timedelta(minutes=1),
}

with DAG(
    dag_id="ohlcv_to_snowflake",
    description="Consume OHLCV from Kafka and write to Snowflake",
    start_date=datetime(2025, 10, 28),
    schedule_interval="@once",
    catchup=False,
    default_args=default_args,
) as dag:
    load_task = PythonOperator(
        task_id="kafka_to_snowflake",
        python_callable=kafka_to_snowflake,
    )

    load_task
