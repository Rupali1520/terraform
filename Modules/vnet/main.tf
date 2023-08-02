resource "azurerm_virtual_network" "vnet" {
  name                = "vnet-rupali"
  address_space       = ["10.0.0.0/16"]
  location = "eastus2"
  resource_group_name = "myresourcegroup"
}

# resource "azurerm_subnet" "subnet" {
#   name                 = var.subnet_name
#   address_prefixes     = [var.subnet_address]
#   virtual_network_name = azurerm_virtual_network.vnet.name
# }
