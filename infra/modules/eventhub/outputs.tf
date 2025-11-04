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

output "eventhub_namespace_primary_connection_string" {
  value       = azurerm_eventhub_namespace.main.default_primary_connection_string
  description = "Primary connection string for the Event Hub Namespace"
}

