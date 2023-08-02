resource "random_id" "random_id" {
  keepers = {
    # Generate a new ID only when a new resource group is defined
    resource_group = azurerm_resource_group.internal.name
  }
  byte_length = 8
}

resource "random_pet" "prefix" {
  prefix = "win-vm-iis"
  length = 1
}

resource "azurerm_virtual_network" "example" {
  name                = var.vnet
  address_space       = ["10.0.0.0/16"]
  location            = azurerm_resource_group.internal.location
  resource_group_name = azurerm_resource_group.internal.name
}

resource "azurerm_subnet" "example" {
  name                 = var.sub
  resource_group_name  = azurerm_resource_group.internal.name
  virtual_network_name = azurerm_virtual_network.example.name
  address_prefixes     = ["10.0.2.0/24"]
}

resource "azurerm_public_ip" "name" {
  name                = var.pub
  location            = azurerm_resource_group.internal.location
  resource_group_name = azurerm_resource_group.internal.name
  allocation_method   = var.allocation_method
}

resource "azurerm_network_interface" "example" {
  name                = var.nic
  location            = azurerm_resource_group.internal.location
  resource_group_name = azurerm_resource_group.internal.name

  ip_configuration {
    name                          = "internal"
    subnet_id                     = azurerm_subnet.example.id
    private_ip_address_allocation = var.allocation_method
    public_ip_address_id          = azurerm_public_ip.name.id
  }
}

locals {
  security_rules = [
    { name = "rule-22", port = 22 , priority = 100},
    { name = "rule-80", port = 80 , priority = 101},
    { name = "rule-3389", port = 3389 , priority = 102},
  ]
}

resource "azurerm_network_security_group" "app_nsg" {
  name                = "1-nsg"
  location            = azurerm_resource_group.internal.location
  resource_group_name = azurerm_resource_group.internal.name

  dynamic "security_rule" {
    for_each = local.security_rules
    content {
      name                       = security_rule.value.name
      priority                   = security_rule.value.priority
      direction                  = "Inbound"
      access                     = "Allow"
      protocol                   = "Tcp"
      source_port_range          = "*"
      destination_port_range     = security_rule.value.port
      source_address_prefix      = "*"
      destination_address_prefix = "*"
    }
  }
}

resource "azurerm_subnet_network_security_group_association" "nsg_association" {
  subnet_id                 = azurerm_subnet.example.id
  network_security_group_id = azurerm_network_security_group.app_nsg.id
  depends_on = [
    azurerm_network_security_group.app_nsg
  ]
}