###############################################################################
# Outputs for live/prod phase1-core
#
# Этот файл экспонирует важные ID и имена, которые потребуются во
# второй фазе (создание AKS), в фазе ролей и при развертывании
# Kubernetes-ресурсов.
###############################################################################

# Имя ресурсной группы (передаётся через переменную var.resource_group_name)
output "resource_group_name" {
  description = "Name of the Azure Resource Group used for the live/prod environment"
  value       = var.resource_group_name
}

# Идентификаторы сети и подсетей
output "vnet_id" {
  description = "ID of the virtual network provisioned for the cluster"
  value       = module.network.vnet_id
}

output "subnet_prod_id" {
  description = "ID of the production subnet (used by AKS)"
  value       = module.network.subnet_prod_id
}

output "subnet_dev_id" {
  description = "ID of the development subnet (if used)"
  value       = module.network.subnet_dev_id
}

# Данные реестра контейнеров
output "acr_id" {
  description = "Resource ID of the Azure Container Registry"
  value       = module.acr.acr_id
}

output "acr_login_server" {
  description = "Login server URL of the Azure Container Registry"
  value       = module.acr.acr_login_server
}

# Namespace Event Hub и имена топиков
output "eventhub_namespace_name" {
  description = "Name of the Event Hub namespace"
  value       = module.eventhub.eventhub_namespace_name
}

output "ohlcv_raw_topic" {
  description = "Name of the raw OHLCV topic"
  value       = module.eventhub.ohlcv_raw_name
}

output "alerts_topic_name" {
  description = "Name of the alerts topic"
  value       = module.eventhub.alerts_topic_name
}

output "eventhub_namespace_primary_connection_string" {
  description = "Primary connection string for the Event Hub Namespace"
  value       = module.eventhub.eventhub_namespace_primary_connection_string
  sensitive   = true
}

# Данные Key Vault
output "keyvault_id" {
  description = "Resource ID of the Key Vault"
  value       = module.keyvault.keyvault_id
}

output "keyvault_name" {
  description = "Name of the Key Vault"
  value       = module.keyvault.keyvault_name
}

output "keyvault_uri" {
  description = "URI endpoint of the Key Vault"
  value       = module.keyvault.keyvault_uri
}

output "public_ip_dev" {
  description = "Public IP for the dev environment"
  value = module.network.public_ip_dev
}

output "public_ip_prod" {
  description = "Public IP for the prod environment"
  value = module.network.public_ip_prod
}
