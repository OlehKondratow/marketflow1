resource "azurerm_kubernetes_cluster" "aks" {
  name                = "${var.project_name}-aks"
  resource_group_name = var.resource_group_name
  location            = var.location
  dns_prefix          = "${var.project_name}-dns"

  identity {
    type = "SystemAssigned"
  }

  default_node_pool {
    name           = "system"
    vm_size        = "Standard_B2s"
    node_count     = 2
    vnet_subnet_id = var.subnet_prod_id
  }

  network_profile {
    network_plugin = "azure"
    network_policy = "calico"
    load_balancer_sku = "standard"
  }

  tags = {
    environment = var.environment
    project     = var.project_name
  }
}
