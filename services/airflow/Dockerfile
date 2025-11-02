FROM apache/airflow:2.9.3-python3.12
USER root
COPY dags/ /opt/airflow/dags/
COPY requirements.txt /
RUN pip install --no-cache-dir -r /requirements.txt
USER airflow
