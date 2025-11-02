FROM ghcr.io/dbt-labs/dbt-snowflake:latest
WORKDIR /app
COPY marketflow/ ./
CMD ["dbt", "run", "--project-dir", "/app", "--profiles-dir", "/app"]
