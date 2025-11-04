resource "azurerm_kubernetes_cluster" "aks" {
  name                = "${var.project_name}-aks"
  location            = var.location
  resource_group_name = var.resource_group_name
  dns_prefix          = "${var.project_name}-dns"

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
    vnet_subnet_id  = var.subnet_dev_id
  }

  network_profile {
    network_plugin     = "azure"
    network_policy     = "azure" 
    load_balancer_sku  = "standard"
  }

  role_based_access_control_enabled = true

  tags = {
    environment = "dev"
    project     = var.project_name
  }
}
