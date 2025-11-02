output "eventhub_namespace_name" {
  value = azurerm_eventhub_namespace.main.name
}

output "ohlcv_raw_name" {
  value = azurerm_eventhub.ohlcv_raw.name
}

output "alerts_topic_name" {
  value = azurerm_eventhub.alerts.name
}

output "eventhub_namespace_id" {
  value       = azurerm_eventhub_namespace.main.id
  description = "Event Hub Namespace ID"
}

