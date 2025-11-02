# Используем официальный образ Python 3.11
FROM python:3.11-slim

# Устанавливаем зависимости Python
RUN pip install --upgrade pip && pip install fastapi websockets requests python-arango

# Устанавливаем рабочую директорию
WORKDIR /app

# Копируем файл зависимостей
COPY requirements.txt /app/

# Устанавливаем зависимости Python
RUN pip install --no-cache-dir -r requirements.txt

# Копируем всё приложение в контейнер
COPY . /app/

# Указываем порт, который будет слушать приложение
EXPOSE 8000

# Команда для запуска приложения
CMD ["uvicorn", "main:app", "--host", "0.0.0.0", "--port", "8000"]
