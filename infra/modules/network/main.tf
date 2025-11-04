##############################################################
# 🌐 Virtual Network and Subnets
##############################################################

resource "azurerm_virtual_network" "vnet" {
  name                = "${var.project_name}-vnet"
  location            = var.location
  resource_group_name = var.resource_group_name
  address_space       = ["10.240.0.0/16"]

  tags = {
    environment = var.environment
    project     = var.project_name
  }
}

resource "azurerm_subnet" "subnet_prod" {
  name                 = "aks-subnet-prod"
  resource_group_name  = var.resource_group_name
  virtual_network_name = azurerm_virtual_network.vnet.name
  address_prefixes     = ["10.240.1.0/24"]
}

resource "azurerm_subnet" "subnet_dev" {
  name                 = "aks-subnet-dev"
  resource_group_name  = var.resource_group_name
  virtual_network_name = azurerm_virtual_network.vnet.name
  address_prefixes     = ["10.240.2.0/24"]
}

##############################################################
# 🔒 Network Security Groups (NSGs)
##############################################################

# ➤ PROD NSG: Allow HTTP/HTTPS from anywhere
resource "azurerm_network_security_group" "prod_nsg" {
  name                = "${var.project_name}-prod-nsg"
  location            = var.location
  resource_group_name = var.resource_group_name

  security_rule {
    name                       = "AllowHTTPS"
    priority                   = 100
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "443"
    source_address_prefix      = "Internet"
    destination_address_prefix = "*"
  }

  security_rule {
    name                       = "AllowHTTP"
    priority                   = 110
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "80"
    source_address_prefix      = "Internet"
    destination_address_prefix = "*"
  }
}

# ➤ DEV NSG: Only allow HTTPS from office IP, deny everything else
resource "azurerm_network_security_group" "dev_nsg" {
  name                = "${var.project_name}-dev-nsg"
  location            = var.location
  resource_group_name = var.resource_group_name

  security_rule {
    name                       = "AllowOfficeHTTPS"
    priority                   = 100
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "443"
    source_address_prefix      = var.office_ip
    destination_address_prefix = "*"
    description                = "Allow HTTPS from office IP"
  }

  security_rule {
    name                       = "DenyAllInbound"
    priority                   = 400
    direction                  = "Inbound"
    access                     = "Deny"
    protocol                   = "*"
    source_port_range          = "*"
    destination_port_range     = "*"
    source_address_prefix      = "*"
    destination_address_prefix = "*"
    description                = "Deny all other inbound traffic"
  }
}

##############################################################
# 🔗 Associate NSGs with Subnets
##############################################################

resource "azurerm_subnet_network_security_group_association" "prod_nsg_assoc" {
  subnet_id                 = azurerm_subnet.subnet_prod.id
  network_security_group_id = azurerm_network_security_group.prod_nsg.id
}

resource "azurerm_subnet_network_security_group_association" "dev_nsg_assoc" {
  subnet_id                 = azurerm_subnet.subnet_dev.id
  network_security_group_id = azurerm_network_security_group.dev_nsg.id
}

##############################################################
# 🌐 Public IPs
##############################################################

resource "azurerm_public_ip" "prod_pip" {
  name                = "${var.project_name}-prod-pip"
  location            = var.location
  resource_group_name = var.resource_group_name
  allocation_method   = "Static"
  sku                 = "Standard"

  tags = {
    environment = "prod"
    project     = var.project_name
  }
}

resource "azurerm_public_ip" "dev_pip" {
  name                = "${var.project_name}-dev-pip"
  location            = var.location
  resource_group_name = var.resource_group_name
  allocation_method   = "Static"
  sku                 = "Standard"

  tags = {
    environment = "dev"
    project     = var.project_name
  }
}
