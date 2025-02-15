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
  priority                    = 101
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

resource "azurerm_network_security_group" "lms-api-nsg" {
  name                = "lms-api-firewall"
  location            = azurerm_resource_group.tf-rg.location
  resource_group_name = azurerm_resource_group.tf-rg.name
}

resource "azurerm_network_security_rule" "lms-api-nsg-ssh" {
  name                        = "lms-api-ssh"
  priority                    = 100
  direction                   = "Inbound"
  access                      = "Allow"
  protocol                    = "Tcp"
  source_port_range           = "*"
  destination_port_range      = "22"
  source_address_prefix       = "*"
  destination_address_prefix  = "*"
  resource_group_name         = azurerm_resource_group.tf-rg.name
  network_security_group_name = azurerm_network_security_group.lms-api-nsg.name
}

resource "azurerm_network_security_rule" "lms-api-nsg-http" {
  name                        = "lms-api-http"
  priority                    = 101
  direction                   = "Inbound"
  access                      = "Allow"
  protocol                    = "Tcp"
  source_port_range           = "*"
  destination_port_range      = "8080"
  source_address_prefix       = "*"
  destination_address_prefix  = "*"
  resource_group_name         = azurerm_resource_group.tf-rg.name
  network_security_group_name = azurerm_network_security_group.lms-api-nsg.name
}

resource "azurerm_network_security_group" "lms-db-nsg" {
  name                = "lms-db-firewall"
  location            = azurerm_resource_group.tf-rg.location
  resource_group_name = azurerm_resource_group.tf-rg.name
}

resource "azurerm_network_security_rule" "lms-db-nsg-ssh" {
  name                        = "lms-db-ssh"
  priority                    = 100
  direction                   = "Inbound"
  access                      = "Allow"
  protocol                    = "Tcp"
  source_port_range           = "*"
  destination_port_range      = "22"
  source_address_prefix       = "*"
  destination_address_prefix  = "*"
  resource_group_name         = azurerm_resource_group.tf-rg.name
  network_security_group_name = azurerm_network_security_group.lms-db-nsg.name
}

resource "azurerm_network_security_rule" "lms-db-nsg-postgres" {
  name                        = "lms-db-postgres"
  priority                    = 101
  direction                   = "Inbound"
  access                      = "Allow"
  protocol                    = "Tcp"
  source_port_range           = "*"
  destination_port_range      = "5432"
  source_address_prefix       = "*"
  destination_address_prefix  = "*"
  resource_group_name         = azurerm_resource_group.tf-rg.name
  network_security_group_name = azurerm_network_security_group.lms-db-nsg.name
}

resource "azurerm_network_interface" "lms-web-nic" {
  name                = "lms-web-nic"
  location            = azurerm_resource_group.tf-rg.location
  resource_group_name = azurerm_resource_group.tf-rg.name

  ip_configuration {
    name                          = "internal"
    subnet_id                     = azurerm_subnet.lms-web-sn.id
    private_ip_address_allocation = "Dynamic"
    public_ip_address_id          = azurerm_public_ip.lms-web-pip.id
  }
}