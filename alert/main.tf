provider "azurerm" {
  features {}

  subscription_id   = var.sub_id

  tenant_id         = var.tenant_id
}

data "azurerm_resource_group" "rg_1" {
  name = var.rg

}

resource "azurerm_virtual_network" "example" {
  name                = var.vnet
  address_space       = ["10.0.0.0/16"]
 location            = data.azurerm_resource_group.rg_1.location
  resource_group_name = data.azurerm_resource_group.rg_1.name
}

resource "azurerm_subnet" "example" {
  name                 = var.sub
  resource_group_name  = data.azurerm_resource_group.rg_1.name
  virtual_network_name = azurerm_virtual_network.example.name
  address_prefixes     = ["10.0.2.0/24"]
}
resource "azurerm_public_ip" "name" {
  name = var.pub
 location            = data.azurerm_resource_group.rg_1.location
  resource_group_name = data.azurerm_resource_group.rg_1.name
  allocation_method = var.allocation_method

}
resource "azurerm_network_interface" "example" {
  name                = var.nic
  location            = data.azurerm_resource_group.rg_1.location
  resource_group_name = data.azurerm_resource_group.rg_1.name

  ip_configuration {
    name                          = "internal"
    subnet_id                     = azurerm_subnet.example.id
    private_ip_address_allocation = var.allocation_method
    public_ip_address_id = azurerm_public_ip.name.id
  }
}
resource "azurerm_network_security_group" "app_nsg" {
  name                = var.nsg
location            = data.azurerm_resource_group.rg_1.location
  resource_group_name = data.azurerm_resource_group.rg_1.name
# We are creating a rule to allow traffic on port 3389
  security_rule {
    name                       = "Allow_HTTP"
    priority                   = 200
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "22"
    source_address_prefix      = "*"
    destination_address_prefix = "*"
  }
}

resource "azurerm_subnet_network_security_group_association" "nsg_association" {
  subnet_id                 = azurerm_subnet.example.id
  network_security_group_id = azurerm_network_security_group.app_nsg.id
  depends_on = [
    azurerm_network_security_group.app_nsg
  ]
}

resource "azurerm_linux_virtual_machine" "myvm" {
  name                = var.vm_name
 location            = data.azurerm_resource_group.rg_1.location
  resource_group_name = data.azurerm_resource_group.rg_1.name
  size                  = "Standard_DS1_v2"
  
  
  network_interface_ids = [
    azurerm_network_interface.example.id,
  ]
  

  computer_name                   = "myvm"
  admin_username                  = var.username
  disable_password_authentication = false
  admin_password = var.pass

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
resource "azurerm_monitor_action_group" "ag" {
  name                = var.ag_name
  resource_group_name = data.azurerm_resource_group.rg_1.name
  short_name          = "expactiongrp"
   email_receiver {
    name          = var.email_to
    email_address = var.email_address
  }

}
resource "azurerm_monitor_metric_alert" "alert" {
  name                = var.alert-name
  resource_group_name = data.azurerm_resource_group.rg_1.name
  scopes              = [azurerm_linux_virtual_machine.myvm.id]
  severity = 3
  frequency = var.feq
  
  criteria { 
    metric_namespace = "Microsoft.Compute/virtualMachines"
    metric_name      = "Percentage CPU"
    aggregation      = "Total"
    operator         = "GreaterThan"
    threshold        = 80
  }

  action {
    action_group_id = azurerm_monitor_action_group.ag.id
  }

  depends_on = [ azurerm_linux_virtual_machine.myvm ]
}
