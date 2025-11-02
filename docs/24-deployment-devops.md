Отлично 🚀 — завершаем блок **MarketFlow Trading Automation** заключительной главой,
посвящённой развертыванию, CI/CD и DevOps-процессам.
Ниже — полная версия файла **`24-deployment-devops.md`** в том же формате, что и предыдущие.

---

## 📘 **24-deployment-devops.md**

```markdown
# 24. Deployment & DevOps

## 🎯 Цель раздела

Этот этап описывает автоматизацию CI/CD, контейнеризацию и развёртывание всей системы MarketFlow:  
от сборки Docker-образов до деплоя в Azure Kubernetes Service (AKS) с использованием Helm и Terraform.

---

## 🧭 24.1. Общая архитектура DevOps

```

[GitHub / GitLab Repo]
↓
[CI/CD Pipeline (build, test, push)]
↓
[Azure Container Registry (ACR)]
↓
[Helm Deployment → AKS]
↓
[Monitoring via Grafana Cloud]

````

---

## ⚙️ 24.2. Основные компоненты DevOps конвейера

| Компонент | Назначение |
|------------|------------|
| **Dockerfile** | Универсальный образ для всех микросервисов (ingestor, strategy, executor) |
| **Helm Chart** | Шаблоны деплоя в Kubernetes |
| **Terraform** | Создание ресурсов Azure (RG, ACR, AKS, EventHub, KeyVault) |
| **GitLab CI / GitHub Actions** | Автоматизация сборки, тестирования и деплоя |
| **Azure Key Vault** | Хранение секретов (API-ключи, Kafka-пароли) |

---

## 🧩 24.3. Пример Dockerfile (универсальный)

```dockerfile
FROM python:3.11-slim
WORKDIR /app

COPY requirements.txt .
RUN pip install --no-cache-dir -r requirements.txt

COPY . .
ENV PYTHONUNBUFFERED=1

CMD ["python", "main.py"]
````

---

## 🧱 24.4. Пример Helm-чарта

**helm/marketflow/values.yaml**

```yaml
image:
  repository: marketflowregistry.azurecr.io/ingestor
  tag: v0.1
  pullPolicy: Always

env:
  - name: KAFKA_BROKER
    valueFrom:
      secretKeyRef:
        name: marketflow-secrets
        key: KAFKA_BROKER
  - name: BINANCE_API_KEY
    valueFrom:
      secretKeyRef:
        name: marketflow-secrets
        key: BINANCE_API_KEY

service:
  type: ClusterIP
  port: 8000

resources:
  limits:
    cpu: "500m"
    memory: "512Mi"
```

**helm/marketflow/templates/deployment.yaml**

```yaml
apiVersion: apps/v1
kind: Deployment
metadata:
  name: marketflow-{{ .Chart.Name }}
spec:
  replicas: 1
  selector:
    matchLabels:
      app: marketflow-{{ .Chart.Name }}
  template:
    metadata:
      labels:
        app: marketflow-{{ .Chart.Name }}
    spec:
      containers:
        - name: {{ .Chart.Name }}
          image: "{{ .Values.image.repository }}:{{ .Values.image.tag }}"
          env: {{ toYaml .Values.env | nindent 10 }}
          ports:
            - containerPort: {{ .Values.service.port }}
```

---

## 🧮 24.5. Пример GitLab CI/CD pipeline

**.gitlab-ci.yml**

```yaml
stages:
  - build
  - push
  - deploy

variables:
  IMAGE_NAME: "$CI_REGISTRY_IMAGE/marketflow"
  IMAGE_TAG: "$CI_COMMIT_SHORT_SHA"

build:
  stage: build
  script:
    - docker build -t $IMAGE_NAME:$IMAGE_TAG .
    - docker push $IMAGE_NAME:$IMAGE_TAG

deploy:
  stage: deploy
  image: bitnami/kubectl:latest
  script:
    - kubectl config use-context marketflow-aks
    - helm upgrade --install marketflow ./helm/marketflow \
        --set image.tag=$IMAGE_TAG \
        --namespace marketflow-prod
```

---

## 🧰 24.6. Пример GitHub Actions workflow

**.github/workflows/deploy.yml**

```yaml
name: Deploy MarketFlow

on:
  push:
    branches: [ "main" ]

jobs:
  build-deploy:
    runs-on: ubuntu-latest

    steps:
      - name: Checkout code
        uses: actions/checkout@v4

      - name: Login to Azure
        uses: azure/login@v2
        with:
          creds: ${{ secrets.AZURE_CREDENTIALS }}

      - name: Build and push to ACR
        uses: azure/docker-login@v1
        with:
          login-server: marketflowregistry.azurecr.io
          username: ${{ secrets.ACR_USERNAME }}
          password: ${{ secrets.ACR_PASSWORD }}
      - run: |
          docker build -t marketflowregistry.azurecr.io/ingestor:${{ github.sha }} .
          docker push marketflowregistry.azurecr.io/ingestor:${{ github.sha }}

      - name: Deploy to AKS
        uses: azure/aks-set-context@v3
        with:
          resource-group: marketflow-rg
          cluster-name: marketflow-aks
      - run: |
          helm upgrade --install marketflow ./helm/marketflow \
            --set image.tag=${{ github.sha }} \
            --namespace marketflow-prod
```

---

## 🧱 24.7. Terraform инфраструктура

**infra/modules/azure/main.tf**

```hcl
resource "azurerm_kubernetes_cluster" "marketflow_aks" {
  name                = "marketflow-aks"
  location            = "westeurope"
  resource_group_name = azurerm_resource_group.marketflow.name
  dns_prefix          = "marketflow"
  default_node_pool {
    name       = "system"
    node_count = 2
    vm_size    = "Standard_B2s"
  }
  identity {
    type = "SystemAssigned"
  }
  network_profile {
    network_plugin = "azure"
  }
}
```

**Команды:**

```bash
terraform init
terraform plan
terraform apply
```

---

## 📦 24.8. Секреты и Key Vault

Все чувствительные данные (API ключи, токены Kafka, Snowflake, Telegram)
хранятся в **Azure Key Vault** и монтируются в Kubernetes как переменные окружения:

```bash
kubectl create secret generic marketflow-secrets \
  --from-literal=BINANCE_API_KEY=$BINANCE_API_KEY \
  --from-literal=BINANCE_API_SECRET=$BINANCE_API_SECRET \
  --from-literal=KAFKA_BROKER=$KAFKA_BROKER
```

---

## 🧠 24.9. Стратегия релизов и обновлений

| Тип обновления        | Действие                              | Пример                    |
| --------------------- | ------------------------------------- | ------------------------- |
| **Minor Update**      | `helm upgrade marketflow`             | исправления логики        |
| **Major Release**     | новая версия чарта / Docker image     | `v0.2`, `v0.3`            |
| **Rollback**          | `helm rollback marketflow <REVISION>` | возврат предыдущей версии |
| **CI/CD Auto Deploy** | Триггер по merge в `main`             | автоматический деплой     |

---

## 🧩 24.10. Observability после деплоя

После успешного развёртывания:

```bash
kubectl get pods -n marketflow-prod
kubectl logs -f deployment/marketflow-strategy
```

Проверка сервисов:

```
http://marketflow-ingestor.marketflow-prod.svc.cluster.local:8000/metrics
http://marketflow-strategy.marketflow-prod.svc.cluster.local:8002/metrics
```

---

## 🧾 24.11. Резюме CI/CD конвейера

| Этап     | Инструмент    | Результат                 |
| -------- | ------------- | ------------------------- |
| Build    | Docker        | Контейнер с сервисом      |
| Push     | ACR           | Версионированный образ    |
| Deploy   | Helm + AKS    | Обновление сервиса        |
| Monitor  | Grafana Alloy | Метрики и алерты          |
| Rollback | Helm          | Безопасное восстановление |

---

## 🚀 24.12. Завершение блока Trading Automation

✅ Инфраструктура MarketFlow полностью автоматизирована:

* Получение и обработка рыночных данных
* Генерация сигналов
* Исполнение ордеров
* Управление рисками
* Мониторинг и алерты
* Полный CI/CD цикл деплоя в Azure AKS

