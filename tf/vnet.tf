resource "azurerm_resource_group" "tf-rg" {
  name     = "tf-resources"
  location = "East US"
}

resource "azurerm_virtual_network" "lms-vnet" {
  name                = "lms-vnet"
  location            = azurerm_resource_group.tf-rg.location
  resource_group_name = azurerm_resource_group.tf-rg.name
  address_space       = ["10.0.0.0/16"]
  tags = {
    environment = "lms"
  }
}

resource "azurerm_subnet" "lms-web-sn" {
  name                 = "lms-web-subnet"
  resource_group_name  = azurerm_resource_group.tf-rg.name
  virtual_network_name = azurerm_virtual_network.lms-vnet.name
  address_prefixes     = ["10.0.1.0/24"]
}

resource "azurerm_subnet" "lms-api-sn" {
  name                 = "lms-api-subnet"
  resource_group_name  = azurerm_resource_group.tf-rg.name
  virtual_network_name = azurerm_virtual_network.lms-vnet.name
  address_prefixes     = ["10.0.2.0/24"]
}

resource "azurerm_subnet" "lms-db-sn" {
  name                 = "lms-db-subnet"
  resource_group_name  = azurerm_resource_group.tf-rg.name
  virtual_network_name = azurerm_virtual_network.lms-vnet.name
  address_prefixes     = ["10.0.3.0/24"]
}

resource "azurerm_public_ip" "lms-web-pip" {
  name                = "lms-web-public-ip"
  resource_group_name = azurerm_resource_group.tf-rg.name
  location            = azurerm_resource_group.tf-rg.location
  allocation_method   = "Static"

  tags = {
    environment = "lms"
  }
}

resource "azurerm_public_ip" "lms-api-pip" {
  name                = "lms-api-public-ip"
  resource_group_name = azurerm_resource_group.tf-rg.name
  location            = azurerm_resource_group.tf-rg.location
  allocation_method   = "Static"

  tags = {
    environment = "lms"
  }
}

resource "azurerm_network_security_group" "lms-web-nsg" {
  name                = "lms-web-firewall"
  location            = azurerm_resource_group.tf-rg.location
  resource_group_name = azurerm_resource_group.tf-rg.name
}

resource "azurerm_network_security_rule" "lms-web-nsg-ssh" {
  name                        = "lms-web-ssh"
  priority                    = 100
  direction                   = "Inbound"
  access                      = "Allow"
  protocol                    = "Tcp"
  source_port_range           = "*"
  destination_port_range      = "22"
  source_address_prefix       = "*"
  destination_address_prefix  = "*"
  resource_group_name         = azurerm_resource_group.tf-rg.name
  network_security_group_name = azurerm_network_security_group.lms-web-nsg.name
}

resource "azurerm_network_security_rule" "lms-web-nsg-http" {
  name                        = "lms-web-http"
  priority                    = 100
  direction                   = "Inbound"
  access                      = "Allow"
  protocol                    = "Tcp"
  source_port_range           = "*"
  destination_port_range      = "80"
  source_address_prefix       = "*"
  destination_address_prefix  = "*"
  resource_group_name         = azurerm_resource_group.tf-rg.name
  network_security_group_name = azurerm_network_security_group.lms-web-nsg.name
}