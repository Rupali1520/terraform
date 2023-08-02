provider "azurerm" {
  features {}
}
resource "azurerm_resource_group" "rg" {
    name = "rg-best"
    location = "North Central Us"   
}

resource "azurerm_virtual_network" "vnet" {
    name = "vnet-best"
    resource_group_name = azurerm_resource_group.rg.name
    location = azurerm_resource_group.rg.location
    address_space = [ "10.0.0.0/16" ]
  
}

resource "azurerm_subnet" "SubnetA" {
  name                 = "SubnetA"
  resource_group_name  = azurerm_resource_group.rg.name
  virtual_network_name = azurerm_virtual_network.vnet.name
  address_prefixes     = ["10.0.1.0/24"]
  depends_on = [
    azurerm_virtual_network.vnet
  ]
}

// This subnet is meant for the Azure Bastion service
resource "azurerm_subnet" "Azure_Bastion_Subnet" {
  name                 = "AzureBastionSubnet"
  resource_group_name  = azurerm_resource_group.rg.name
  virtual_network_name = azurerm_virtual_network.vnet.name
  address_prefixes     = ["10.0.2.0/24"]
  depends_on = [
    azurerm_virtual_network.vnet
  ]
}

resource "azurerm_network_interface" "app_interface" {
  name                = "app-interface"
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name

  ip_configuration {
    name                          = "internal"
    subnet_id                     = azurerm_subnet.SubnetA.id
    private_ip_address_allocation = "Dynamic"
  }

  depends_on = [
    azurerm_virtual_network.vnet,
    azurerm_subnet.SubnetA
  ]
}

resource "azurerm_linux_virtual_machine" "app_vm" {
  name                = "appvm"
  resource_group_name = azurerm_resource_group.rg.name
  location            = azurerm_resource_group.rg.location
  size                = "Standard_D2s_v3"
   
  network_interface_ids = [
    azurerm_network_interface.app_interface.id,
  ]
  
  computer_name                   = "myvm"
  admin_username                  = "azureuser"
  disable_password_authentication = false
  admin_password = "Rupali152012345"
  os_disk {
    caching              = "ReadWrite"
    storage_account_type = "Standard_LRS"
  }

  source_image_reference {
    publisher = "Canonical"
    offer     = "0001-com-ubuntu-server-jammy"
    sku       = "22_04-lts-gen2"
    version   = "latest"
  }

  depends_on = [
    azurerm_network_interface.app_interface
  ]
}



resource "azurerm_network_security_group" "app_nsg" {
  name                = "app-nsg"
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name

# We are creating a rule to allow traffic on port 3389
  security_rule {
    name                       = "Allow_HTTP"
    priority                   = 200
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "3389"
    source_address_prefix      = "*"
    destination_address_prefix = "*"
  }
}

resource "azurerm_subnet_network_security_group_association" "nsg_association" {
  subnet_id                 = azurerm_subnet.SubnetA.id
  network_security_group_id = azurerm_network_security_group.app_nsg.id
  depends_on = [
    azurerm_network_security_group.app_nsg
  ]
}

resource "azurerm_public_ip" "bastion_ip" {
  name                = "bastion-ip"
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name
  allocation_method   = "Static"
  sku                 = "Standard"
}

resource "azurerm_bastion_host" "app_bastion" {
  name                = "app-bastion"
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name

  ip_configuration {
    name                 = "configuration"
    subnet_id            = azurerm_subnet.Azure_Bastion_Subnet.id
    public_ip_address_id = azurerm_public_ip.bastion_ip.id
  }

  depends_on=[
    azurerm_subnet.Azure_Bastion_Subnet,
    azurerm_public_ip.bastion_ip
  ]
}