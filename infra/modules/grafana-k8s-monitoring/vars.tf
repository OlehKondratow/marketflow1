
variable "namespace" {
  type    = string
  default = "monitoring"
}

variable "cluster_name" {
  type    = string
  default = "marketflow0"
}

variable "destinations_prometheus_url" {
  type    = string
  default = "https://prometheus-prod-36-prod-us-west-0.grafana.net./api/prom/push"
}

variable "destinations_prometheus_username" {
  type    = string
  default = "2760199"
}

variable "destinations_prometheus_password" {
  type    = string
  default = "REPLACE_WITH_ACCESS_POLICY_TOKEN"
}

variable "destinations_loki_url" {
  type    = string
  default = "https://logs-prod-021.grafana.net./loki/api/v1/push"
}

variable "destinations_loki_username" {
  type    = string
  default = "1375776"
}

variable "destinations_loki_password" {
  type    = string
  default = "REPLACE_WITH_ACCESS_POLICY_TOKEN"
}

variable "destinations_otlp_url" {
  type    = string
  default = "https://otlp-gateway-prod-us-west-0.grafana.net./otlp"
}

variable "destinations_otlp_username" {
  type    = string
  default = "1417982"
}

variable "destinations_otlp_password" {
  type    = string
  default = "REPLACE_WITH_ACCESS_POLICY_TOKEN"
}

variable "destinations_pyroscope_url" {
  type    = string
  default = "https://profiles-prod-008.grafana.net.:443"
}

variable "destinations_pyroscope_username" {
  type    = string
  default = "1417982"
}

variable "destinations_pyroscope_password" {
  type    = string
  default = "REPLACE_WITH_ACCESS_POLICY_TOKEN"
}

variable "fleetmanagement_url" {
  type    = string
  default = "https://fleet-management-prod-014.grafana.net"
}

variable "fleetmanagement_username" {
  type    = string
  default = "1417982"
}

variable "fleetmanagement_password" {
  type    = string
  default = "REPLACE_WITH_ACCESS_POLICY_TOKEN"
}
