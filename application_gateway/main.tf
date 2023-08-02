provider "azurerm" {
  features {}
}
resource "azurerm_resource_group" "rg" {
    name = var.resource_group_name
    location = var.resource_group_location
  
}

resource "azurerm_virtual_network" "vnet" {
    name = "vnet_application_gateway"
    resource_group_name =  azurerm_resource_group.rg.name
    location = azurerm_resource_group.rg.location
    address_space = [ "10.0.0.0/16" ]
    
    
}


resource "azurerm_public_ip" "vmpubip" {
  name                = "vmpip"
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name
  allocation_method   = "Static"
  sku                 = "Standard"
}
resource "azurerm_public_ip" "vm1pubip" {
  name                = "vm1pip"
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name
  allocation_method   = "Static"
  sku                 = "Standard"
}

resource "azurerm_public_ip" "gatwayip" {
  name                = "gatway-pip"
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name
  allocation_method   = "Static"
   sku                 = "Standard"
   
}
resource "azurerm_subnet" "subnetvm" {
  name                 = "subnetforvm"
  resource_group_name  = azurerm_resource_group.rg.name
  virtual_network_name = azurerm_virtual_network.vnet.name
  address_prefixes     = ["10.0.1.0/24"]
}

resource "azurerm_subnet" "subnetapp" {
  name                 = "subnetforapp"
  resource_group_name  = azurerm_resource_group.rg.name
  virtual_network_name = azurerm_virtual_network.vnet.name
  address_prefixes     = ["10.0.2.0/24"]
}
resource "azurerm_subnet" "appsubnet" {
  name                 = "subnetforlb"
  resource_group_name  = azurerm_resource_group.rg.name
  virtual_network_name = azurerm_virtual_network.vnet.name
  address_prefixes     = ["10.0.3.0/24"]
}

resource "azurerm_network_interface" "nic1" {
  name                = "example-nic-vm1"
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name

  ip_configuration {
    name                          = "internal"
    subnet_id                     = azurerm_subnet.subnetvm.id
    private_ip_address_allocation = "Dynamic"
    public_ip_address_id  = azurerm_public_ip.vmpubip.id
  }
}
resource "azurerm_network_interface" "nic2" {
  name                = "example-nic-vm2"
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name

  ip_configuration {
    name                          = "internal"
    subnet_id                     = azurerm_subnet.subnetvm.id
    private_ip_address_allocation = "Dynamic"
    public_ip_address_id  = azurerm_public_ip.vm1pubip.id
  }
}

resource "azurerm_network_security_group" "nsg1" {
  name                = "nsg2"
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name


  security_rule {
    name                       = "All"
    priority                   = 200
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "*"
    source_address_prefix      = "*"
    destination_address_prefix = "*"
  }
  


}
resource "azurerm_network_security_group" "nsg2" {
  name                = "nsg3"
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name


  security_rule {
    name                       = "All"
    priority                   = 200
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "*"
    source_address_prefix      = "*"
    destination_address_prefix = "*"
  }
  


}

resource "azurerm_network_interface_security_group_association" "sg" {

  network_interface_id      = azurerm_network_interface.nic1.id
  network_security_group_id = azurerm_network_security_group.nsg1.id
  


}
resource "azurerm_network_interface_security_group_association" "sg1" {

  network_interface_id      = azurerm_network_interface.nic2.id
  network_security_group_id = azurerm_network_security_group.nsg2.id
  


}


resource "azurerm_linux_virtual_machine" "vm1" {
  name                = "example-machine"
  resource_group_name = azurerm_resource_group.rg.name
  location            = azurerm_resource_group.rg.location
  size                  = "Standard_DS1_v2"
  
  
  network_interface_ids = [
    azurerm_network_interface.nic1.id,
  ]
  

  computer_name                   = "myvm"
  admin_username                  = "azureuser"
  disable_password_authentication = false
  admin_password = "Rupali152012345"

  os_disk {
    name = "osdist1"
    caching              = "ReadWrite"
    storage_account_type = "Standard_LRS"
  }



  source_image_reference {
    publisher = "Canonical"
    offer     = "0001-com-ubuntu-server-jammy"
    sku       = "22_04-lts-gen2"
    version   = "latest"
  }
}
resource "azurerm_linux_virtual_machine" "vm2" {
  name                = "example-machine1"
  resource_group_name = azurerm_resource_group.rg.name
  location            = azurerm_resource_group.rg.location
  size                  = "Standard_DS1_v2"
  
  
  network_interface_ids = [
    azurerm_network_interface.nic2.id,
  ]
  

  computer_name                   = "myvm"
  admin_username                  = "azureuser"
  disable_password_authentication = false
  admin_password = "Rupali152012345"

  os_disk {
    name = "osdist2"
    caching              = "ReadWrite"
    storage_account_type = "Standard_LRS"
  }



  source_image_reference {
    publisher = "Canonical"
    offer     = "0001-com-ubuntu-server-jammy"
    sku       = "22_04-lts-gen2"
    version   = "latest"
  }
}

resource "azurerm_application_gateway" "network" {
  name                = "example-appgateway"
  resource_group_name = azurerm_resource_group.rg.name
  location            = azurerm_resource_group.rg.location

  sku {
    name     = "Standard_v2"
    tier     = "Standard_v2"
    capacity = 1
  }

  gateway_ip_configuration {
    name      = "my-gateway-ip-configuration"
    subnet_id = azurerm_subnet.subnetapp.id
  }

  frontend_port {
    name = "fornt-port"
    port = 80
  }

  frontend_ip_configuration {
    name                 = "forntip"
    public_ip_address_id = azurerm_public_ip.gatwayip.id
  }

  backend_address_pool {
    name = "pool"
    ip_addresses = [
        "${azurerm_network_interface.nic1.private_ip_address}",
        
        "${azurerm_network_interface.nic2.private_ip_address}"

        ]
  }

  backend_http_settings {
    name                  = "httpsetting"
    cookie_based_affinity = "Disabled"
    path = ""
    port                  = 80
    protocol              = "Http"
    request_timeout       = 1
  }


  http_listener {
    name                           = "listner"
    frontend_ip_configuration_name = "forntip"
    frontend_port_name             = "fornt-port"
    protocol                       = "Http"
  }


  request_routing_rule {
    name                       = "rule1"
    rule_type                  = "Basic"
    priority                   = 2
    http_listener_name         = "listner"
    backend_address_pool_name  = "pool"
    backend_http_settings_name = "httpsetting"
  }
}


