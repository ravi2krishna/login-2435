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