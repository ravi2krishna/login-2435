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