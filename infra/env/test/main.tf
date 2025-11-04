terraform {
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "~> 4.9.0"
    }
  }
}
provider "azurerm" {
  features {}
  subscription_id = "65fe7e97-9f6f-4f82-b940-4f374ca027cb"
}



resource "azurerm_resource_group" "test" {
  name     = "aks-test-rg"
  location = "westeurope"
}

resource "azurerm_kubernetes_cluster" "test" {
  name                = "aks-test"
  location            = azurerm_resource_group.test.location
  resource_group_name = azurerm_resource_group.test.name
  dns_prefix          = "akstest"
  kubernetes_version  = "1.32.7"

  identity {
    type = "SystemAssigned"
  }

  default_node_pool {
    name            = "system"
    vm_size         = "Standard_B2s"
    auto_scaling_enabled = true
    min_count       = 1
    max_count       = 3
    os_disk_size_gb = 60
    type            = "VirtualMachineScaleSets"
    max_pods        = 110
  }

  network_profile {
    network_plugin      = "azure"
    network_plugin_mode = "overlay"
    load_balancer_sku   = "standard"
    outbound_type       = "loadBalancer"
    dns_service_ip      = "10.0.0.10"
    service_cidr        = "10.0.0.0/16"
    pod_cidr            = "10.244.0.0/16"
  }

  role_based_access_control_enabled = true
  sku_tier                          = "Free"
  
  tags = {
    environment = "test"
    purpose     = "autoscaler-demo"
  }
  
  lifecycle {
    ignore_changes = [
      default_node_pool[0].node_count
    ]
  }  
}

output "kube_config" {
  value     = azurerm_kubernetes_cluster.test.kube_config_raw
  sensitive = true
}
