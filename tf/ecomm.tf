resource "azurerm_resource_group" "tf-rg" {
  name     = "tf-resources"
  location = "East US"
}

resource "azurerm_virtual_network" "ecomm-vnet" {
  name                = "ecomm-vnet"
  location            = azurerm_resource_group.tf-rg.location
  resource_group_name = azurerm_resource_group.tf-rg.name
  address_space       = ["10.0.0.0/16"]
  tags = {
    environment = "ecomm"
  }
}

resource "azurerm_subnet" "ecomm-web-sn" {
  name                 = "ecomm-web-subnet"
  resource_group_name  = azurerm_resource_group.tf-rg.name
  virtual_network_name = azurerm_virtual_network.ecomm-vnet.name
  address_prefixes     = ["10.0.1.0/24"]
}

resource "azurerm_subnet" "ecomm-api-sn" {
  name                 = "ecomm-api-subnet"
  resource_group_name  = azurerm_resource_group.tf-rg.name
  virtual_network_name = azurerm_virtual_network.ecomm-vnet.name
  address_prefixes     = ["10.0.2.0/24"]
}

resource "azurerm_subnet" "ecomm-db-sn" {
  name                 = "ecomm-db-subnet"
  resource_group_name  = azurerm_resource_group.tf-rg.name
  virtual_network_name = azurerm_virtual_network.ecomm-vnet.name
  address_prefixes     = ["10.0.3.0/24"]
}

resource "azurerm_public_ip" "ecomm-web-pip" {
  name                = "ecomm-web-public-ip"
  resource_group_name = azurerm_resource_group.tf-rg.name
  location            = azurerm_resource_group.tf-rg.location
  allocation_method   = "Static"

  tags = {
    environment = "ecomm"
  }
}

resource "azurerm_public_ip" "ecomm-api-pip" {
  name                = "ecomm-api-public-ip"
  resource_group_name = azurerm_resource_group.tf-rg.name
  location            = azurerm_resource_group.tf-rg.location
  allocation_method   = "Static"

  tags = {
    environment = "ecomm"
  }
}

resource "azurerm_network_security_group" "ecomm-web-nsg" {
  name                = "ecomm-web-firewall"
  location            = azurerm_resource_group.tf-rg.location
  resource_group_name = azurerm_resource_group.tf-rg.name
}

resource "azurerm_network_security_rule" "ecomm-web-nsg-ssh" {
  name                        = "ecomm-web-ssh"
  priority                    = 100
  direction                   = "Inbound"
  access                      = "Allow"
  protocol                    = "Tcp"
  source_port_range           = "*"
  destination_port_range      = "22"
  source_address_prefix       = "*"
  destination_address_prefix  = "*"
  resource_group_name         = azurerm_resource_group.tf-rg.name
  network_security_group_name = azurerm_network_security_group.ecomm-web-nsg.name
}

resource "azurerm_network_security_rule" "ecomm-web-nsg-http" {
  name                        = "ecomm-web-http"
  priority                    = 101
  direction                   = "Inbound"
  access                      = "Allow"
  protocol                    = "Tcp"
  source_port_range           = "*"
  destination_port_range      = "80"
  source_address_prefix       = "*"
  destination_address_prefix  = "*"
  resource_group_name         = azurerm_resource_group.tf-rg.name
  network_security_group_name = azurerm_network_security_group.ecomm-web-nsg.name
}

resource "azurerm_network_security_group" "ecomm-api-nsg" {
  name                = "ecomm-api-firewall"
  location            = azurerm_resource_group.tf-rg.location
  resource_group_name = azurerm_resource_group.tf-rg.name
}

resource "azurerm_network_security_rule" "ecomm-api-nsg-ssh" {
  name                        = "ecomm-api-ssh"
  priority                    = 100
  direction                   = "Inbound"
  access                      = "Allow"
  protocol                    = "Tcp"
  source_port_range           = "*"
  destination_port_range      = "22"
  source_address_prefix       = "*"
  destination_address_prefix  = "*"
  resource_group_name         = azurerm_resource_group.tf-rg.name
  network_security_group_name = azurerm_network_security_group.ecomm-api-nsg.name
}

resource "azurerm_network_security_rule" "ecomm-api-nsg-http" {
  name                        = "ecomm-api-http"
  priority                    = 101
  direction                   = "Inbound"
  access                      = "Allow"
  protocol                    = "Tcp"
  source_port_range           = "*"
  destination_port_range      = "8080"
  source_address_prefix       = "*"
  destination_address_prefix  = "*"
  resource_group_name         = azurerm_resource_group.tf-rg.name
  network_security_group_name = azurerm_network_security_group.ecomm-api-nsg.name
}

resource "azurerm_network_security_group" "ecomm-db-nsg" {
  name                = "ecomm-db-firewall"
  location            = azurerm_resource_group.tf-rg.location
  resource_group_name = azurerm_resource_group.tf-rg.name
}

resource "azurerm_network_security_rule" "ecomm-db-nsg-ssh" {
  name                        = "ecomm-db-ssh"
  priority                    = 100
  direction                   = "Inbound"
  access                      = "Allow"
  protocol                    = "Tcp"
  source_port_range           = "*"
  destination_port_range      = "22"
  source_address_prefix       = "*"
  destination_address_prefix  = "*"
  resource_group_name         = azurerm_resource_group.tf-rg.name
  network_security_group_name = azurerm_network_security_group.ecomm-db-nsg.name
}

resource "azurerm_network_security_rule" "ecomm-db-nsg-postgres" {
  name                        = "ecomm-db-postgres"
  priority                    = 101
  direction                   = "Inbound"
  access                      = "Allow"
  protocol                    = "Tcp"
  source_port_range           = "*"
  destination_port_range      = "5432"
  source_address_prefix       = "*"
  destination_address_prefix  = "*"
  resource_group_name         = azurerm_resource_group.tf-rg.name
  network_security_group_name = azurerm_network_security_group.ecomm-db-nsg.name
}

resource "azurerm_network_interface" "ecomm-web-nic" {
  name                = "ecomm-web-nic"
  location            = azurerm_resource_group.tf-rg.location
  resource_group_name = azurerm_resource_group.tf-rg.name

  ip_configuration {
    name                          = "internal"
    subnet_id                     = azurerm_subnet.ecomm-web-sn.id
    private_ip_address_allocation = "Dynamic"
    public_ip_address_id          = azurerm_public_ip.ecomm-web-pip.id
  }
}

resource "azurerm_network_interface_security_group_association" "ecomm-web-nic-nsg" {
  network_interface_id      = azurerm_network_interface.ecomm-web-nic.id
  network_security_group_id = azurerm_network_security_group.ecomm-web-nsg.id
}

resource "azurerm_network_interface" "ecomm-api-nic" {
  name                = "ecomm-api-nic"
  location            = azurerm_resource_group.tf-rg.location
  resource_group_name = azurerm_resource_group.tf-rg.name

  ip_configuration {
    name                          = "internal"
    subnet_id                     = azurerm_subnet.ecomm-api-sn.id
    private_ip_address_allocation = "Dynamic"
    public_ip_address_id          = azurerm_public_ip.ecomm-api-pip.id
  }
}

resource "azurerm_network_interface_security_group_association" "ecomm-api-nic-nsg" {
  network_interface_id      = azurerm_network_interface.ecomm-api-nic.id
  network_security_group_id = azurerm_network_security_group.ecomm-api-nsg.id
}

resource "azurerm_network_interface" "ecomm-db-nic" {
  name                = "ecomm-db-nic"
  location            = azurerm_resource_group.tf-rg.location
  resource_group_name = azurerm_resource_group.tf-rg.name

  ip_configuration {
    name                          = "internal"
    subnet_id                     = azurerm_subnet.ecomm-db-sn.id
    private_ip_address_allocation = "Dynamic"
  }
}

resource "azurerm_network_interface_security_group_association" "ecomm-db-nic-nsg" {
  network_interface_id      = azurerm_network_interface.ecomm-db-nic.id
  network_security_group_id = azurerm_network_security_group.ecomm-db-nsg.id
}

resource "azurerm_linux_virtual_machine" "ecomm-web-vm" {
  name                = "ecomm-web-vm"
  resource_group_name = azurerm_resource_group.tf-rg.name
  location            = azurerm_resource_group.tf-rg.location
  size                = "Standard_F2"
  admin_username      = "ubuntu"
  custom_data = filebase64("script.sh")
  network_interface_ids = [
    azurerm_network_interface.ecomm-web-nic.id,
  ]

  admin_ssh_key {
    username   = "ubuntu"
    public_key = file("~/.ssh/id_rsa.pub")
  }

  os_disk {
    caching              = "ReadWrite"
    storage_account_type = "Standard_LRS"
  }

  source_image_reference {
    publisher = "Canonical"
    offer     = "0001-com-ubuntu-server-jammy"
    sku       = "22_04-lts"
    version   = "latest"
  }
}