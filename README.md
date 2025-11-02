infra/
├── env/
│ ├── dev/ # Конфигурация окружения dev
│ └── prod/ # Конфигурация окружения prod
├── modules/azure/ # Модули Azure (network, acr, aks, keyvault, storage)
├── modules/kubernetes/ # Helm + kubectl манифесты (httpbin, ingress, policies)
├── modules/phase/ # EventHub, RoleAssignments
└── versions.tf # Общие версии провайдеров и Terraform

Завжди показувати відомості

---

## ✅ Что создается

### ☸️ Kubernetes / AKS
- Azure Kubernetes Service (AKS)
- Статический IP (ingress)
- Ingress NGINX с HTTPS
- Network Policies (меж-namespace)

### 🌐 Сеть и безопасность
- Virtual Network `10.240.0.0/16`
  - `subnet-dev`: 10.240.2.0/24 — доступ по IP офиса
  - `subnet-prod`: 10.240.1.0/24 — открыт HTTP/HTTPS
- NSG (firewall)
  - dev: ограничен IP офиса
  - prod: открыт для всех

### 🔐 Секреты и Key Vault
- Azure Key Vault для хранения:
  - Паролей (например: `postgres_password`)
  - TLS сертификатов
- Подключение через Managed Identity

### 📦 ACR
- Azure Container Registry (ACR)
- Выдача прав AKS на `AcrPull`

### 💾 Хранилище
- Azure Storage Account
- PVC (PersistentVolumeClaim) и CSI Driver

### 📊 Event Hub
- Подключение EventHub для ingest/metrics
- Возможность подписки через Kafka-compatible consumer

---

## 🧪 Пример outputs `infra/env/dev/outputs.tf`

```hcl
output "aks_fqdn"      # API сервер AKS
output "acr_login_server"
output "keyvault_uri"  # Endpoint Key Vault
output "storage_primary_blob_endpoint"
output "subnet_dev_id"
output "role_assignments_summary" # { keyvault_role_id, acr_role_id }

🧬 Переменные
Завжди показувати відомості
variable "project_name"         # marketflow0
variable "location"             # northeurope
variable "resource_group_name" # marketflow0-rg
variable "environment"          # dev | prod
variable "office_ip"            # CIDR (для доступа в dev)
variable "postgres_password"    # Secret для Key Vault
variable "dns_prefix"           # AKS DNS префикс

🚀 CI/CD (Terraform) пример: .gitlab-ci.yml
Завжди показувати відомості
stages: [validate, plan, apply]

variables:
  ARM_CLIENT_ID: $AZURE_CLIENT_ID
  ARM_CLIENT_SECRET: $AZURE_CLIENT_SECRET
  ARM_SUBSCRIPTION_ID: $AZURE_SUBSCRIPTION_ID
  ARM_TENANT_ID: $AZURE_TENANT_ID

plan_dev:
  stage: plan
  script:
    - cd infra/env/dev
    - terraform init -input=false
    - terraform plan -var-file="terraform.tfvars" -out=tfplan

apply_dev:
  stage: apply
  when: manual
  script:
    - cd infra/env/dev
    - terraform apply -input=false tfplan

🔐 Пример подключения к Key Vault
Завжди показувати відомості
az login --service-principal -u $AZURE_CLIENT_ID -p $AZURE_CLIENT_SECRET --tenant $AZURE_TENANT_ID

az keyvault secret show \
  --vault-name marketflow0-vault \
  --name postgres_password \
  --query value -o tsv

📎 Альтернатива/ресурсы

Terraform Azure Provider Docs

AKS Best Practices

Cert Manager for AKS

GitLab Terraform Templates

Завжди показувати відомості

# Save README
readme_path = Path("readme.md")
readme_path.write_text(readme_content.strip())

readme_path.name

Проаналізовано
Завжди показувати відомості
from pathlib import Path

readme_content = """
# 🚀 MarketFlow AKS Infrastructure (Terraform)

Полнофункциональная Terraform-инфраструктура для проекта **MarketFlow**:
- Среды: `dev` и `prod`
- Компоненты: AKS, ACR, Key Vault, Storage, Event Hub, Ingress, Network Policies
- Секреты, сертификаты, доступы, мониторинг

---

## 📦 Структура проекта



infra/
├── env/
│ ├── dev/ # Конфигурация окружения dev
│ └── prod/ # Конфигурация окружения prod
├── modules/azure/ # Модули Azure (network, acr, aks, keyvault, storage)
├── modules/kubernetes/ # Helm + kubectl манифесты (httpbin, ingress, policies)
├── modules/phase/ # EventHub, RoleAssignments
└── versions.tf # Общие версии провайдеров и Terraform

Завжди показувати відомості

---

## ✅ Что создается

### ☸️ Kubernetes / AKS
- Azure Kubernetes Service (AKS)
- Статический IP (ingress)
- Ingress NGINX с HTTPS
- Network Policies (меж-namespace)

### 🌐 Сеть и безопасность
- Virtual Network `10.240.0.0/16`
  - `subnet-dev`: 10.240.2.0/24 — доступ по IP офиса
  - `subnet-prod`: 10.240.1.0/24 — открыт HTTP/HTTPS
- NSG (firewall)
  - dev: ограничен IP офиса
  - prod: открыт для всех

### 🔐 Секреты и Key Vault
- Azure Key Vault для хранения:
  - Паролей (например: `postgres_password`)
  - TLS сертификатов
- Подключение через Managed Identity

### 📦 ACR
- Azure Container Registry (ACR)
- Выдача прав AKS на `AcrPull`

### 💾 Хранилище
- Azure Storage Account
- PVC (PersistentVolumeClaim) и CSI Driver

### 📊 Event Hub
- Подключение EventHub для ingest/metrics
- Возможность подписки через Kafka-compatible consumer

---

## 🧪 Пример outputs `infra/env/dev/outputs.tf`

```hcl
output "aks_fqdn"      # API сервер AKS
output "acr_login_server"
output "keyvault_uri"  # Endpoint Key Vault
output "storage_primary_blob_endpoint"
output "subnet_dev_id"
output "role_assignments_summary" # { keyvault_role_id, acr_role_id }

🧬 Переменные
Завжди показувати відомості
variable "project_name"         # marketflow0
variable "location"             # northeurope
variable "resource_group_name" # marketflow0-rg
variable "environment"          # dev | prod
variable "office_ip"            # CIDR (для доступа в dev)
variable "postgres_password"    # Secret для Key Vault
variable "dns_prefix"           # AKS DNS префикс

🚀 CI/CD (Terraform) пример: .gitlab-ci.yml
Завжди показувати відомості
stages: [validate, plan, apply]

variables:
  ARM_CLIENT_ID: $AZURE_CLIENT_ID
  ARM_CLIENT_SECRET: $AZURE_CLIENT_SECRET
  ARM_SUBSCRIPTION_ID: $AZURE_SUBSCRIPTION_ID
  ARM_TENANT_ID: $AZURE_TENANT_ID

plan_dev:
  stage: plan
  script:
    - cd infra/env/dev
    - terraform init -input=false
    - terraform plan -var-file="terraform.tfvars" -out=tfplan

apply_dev:
  stage: apply
  when: manual
  script:
    - cd infra/env/dev
    - terraform apply -input=false tfplan

🔐 Пример подключения к Key Vault
Завжди показувати відомості
az login --service-principal -u $AZURE_CLIENT_ID -p $AZURE_CLIENT_SECRET --tenant $AZURE_TENANT_ID

az keyvault secret show \
  --vault-name marketflow0-vault \
  --name postgres_password \
  --query value -o tsv

📎 Альтернатива/ресурсы

Terraform Azure Provider Docs

AKS Best Practices

Cert Manager for AKS

GitLab Terraform Templates

"""

readme_path = Path("readme.md")
readme_path.write_text(readme_content.strip())

readme_path.name

Завжди показувати відомості
Результат
'readme.md'
