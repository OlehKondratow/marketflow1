########################################
# 🌐 VNet Outputs
########################################

output "vnet_id" {
  value       = azurerm_virtual_network.vnet.id
  description = "ID of the Virtual Network"
}

output "vnet_name" {
  value       = azurerm_virtual_network.vnet.name
  description = "Name of the Virtual Network"
}

output "vnet_address_space" {
  value       = azurerm_virtual_network.vnet.address_space
  description = "CIDR blocks associated with the Virtual Network"
}

output "tags" {
  value       = azurerm_virtual_network.vnet.tags
  description = "Tags applied to the Virtual Network"
}

########################################
# 🧩 Subnet Outputs
########################################

output "subnet_prod_id" {
  value       = azurerm_subnet.subnet_prod.id
  description = "ID of the Production subnet"
}

output "subnet_dev_id" {
  value       = azurerm_subnet.subnet_dev.id
  description = "ID of the Development subnet"
}

output "subnets" {
  value = {
    prod = {
      name = azurerm_subnet.subnet_prod.name
      id   = azurerm_subnet.subnet_prod.id
      cidr = azurerm_subnet.subnet_prod.address_prefixes
    }
    dev = {
      name = azurerm_subnet.subnet_dev.name
      id   = azurerm_subnet.subnet_dev.id
      cidr = azurerm_subnet.subnet_dev.address_prefixes
    }
  }
  description = "Map of subnets with name, id, and CIDR blocks"
}

########################################
# 🔐 Network Security Group Outputs
########################################

output "nsg_prod_id" {
  value       = azurerm_network_security_group.prod_nsg.id
  description = "ID of the Network Security Group for production"
}

output "nsg_dev_id" {
  value       = azurerm_network_security_group.dev_nsg.id
  description = "ID of the Network Security Group for development"
}

########################################
# 🌍 Optional: Public IP (if defined in this module)
########################################

# Uncomment if you define a public IP inside this module
# output "public_ip_address" {
#   value       = azurerm_public_ip.main.ip_address
#   description = "Public IP address (if provisioned in this module)"
# }

output "subnet_names" {
  value = {
    prod = azurerm_subnet.subnet_prod.name
    dev  = azurerm_subnet.subnet_dev.name
  }
  description = "Names of subnets"
}
