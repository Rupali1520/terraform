provider "azurerm" {
  features {}
  subscription_id = var.sub_id

  tenant_id     = var.tent_id
  client_id     = var.client_id
  client_secret = var.client_secret
}

resource "azurerm_resource_group" "example" {
  name     = var.resource_group_name1
  location = var.location1
}
resource "azurerm_resource_group" "example-2" {
  name     = var.resource_group_name2
  location = var.location2
}


resource "azurerm_virtual_network" "example-1" {
  name                = var.vnet1
  address_space       = ["172.1.0.0/16"]
  location            = azurerm_resource_group.example.location
  resource_group_name = azurerm_resource_group.example.name
}


resource "azurerm_subnet" "example-1" {
  name                 = var.sub_name1
  resource_group_name  = azurerm_resource_group.example.name
  virtual_network_name = azurerm_virtual_network.example-1.name
  address_prefixes     = ["172.1.0.0/24"]

}


resource "azurerm_virtual_network" "example-2" {
  name                = var.vnet2
  resource_group_name = azurerm_resource_group.example-2.name
  address_space       = ["10.0.0.0/16"]
  location            = azurerm_resource_group.example-2.location
}
resource "azurerm_subnet" "example-2" {
  name                 = var.sub_name2
  resource_group_name  = azurerm_resource_group.example-2.name
  virtual_network_name = azurerm_virtual_network.example-2.name
  address_prefixes     = ["10.0.0.0/24"]
}

resource "azurerm_subnet" "example-3" {
  name                 = "AzureBastionSubnet"
  resource_group_name  = azurerm_resource_group.example-2.name
  virtual_network_name = azurerm_virtual_network.example-2.name
  address_prefixes     = ["10.0.1.0/24"]
}


resource "azurerm_virtual_network_peering" "example-1" {
  name                      = "peer1to2"
  resource_group_name       = azurerm_resource_group.example.name
  virtual_network_name      = azurerm_virtual_network.example-1.name
  remote_virtual_network_id = azurerm_virtual_network.example-2.id
}

resource "azurerm_virtual_network_peering" "example-2" {
  name                      = "peer2to1"
  resource_group_name       = azurerm_resource_group.example-2.name
  virtual_network_name      = azurerm_virtual_network.example-2.name
  remote_virtual_network_id = azurerm_virtual_network.example-1.id
}

# Create an AKS cluster
resource "azurerm_kubernetes_cluster" "example" {
  name                = var.cluster_name
  location            = azurerm_resource_group.example.location
  resource_group_name = azurerm_resource_group.example.name
  dns_prefix          = var.dns_prefix


  identity {
    type = "SystemAssigned"
  }

  default_node_pool {
    name                = "default"
    node_count          = 1
    vm_size             = "Standard_DS2_v2"
    vnet_subnet_id      = azurerm_subnet.example-1.id
    enable_auto_scaling = true
    min_count           = 1
    max_count           = 2
    type                = "VirtualMachineScaleSets"
  }

  network_profile {
    network_plugin = "kubenet"
    dns_service_ip = "192.168.1.1"
    service_cidr   = "192.168.0.0/16"
    pod_cidr       = "172.16.0.0/22"
  }
  private_cluster_enabled = true
}
resource "azurerm_private_dns_zone_virtual_network_link" "link_vnet" {
  name                  = "dnslink-vnet02"
  private_dns_zone_name = join(".", slice(split(".", azurerm_kubernetes_cluster.example.private_fqdn), 1, length(split(".", azurerm_kubernetes_cluster.example.private_fqdn))))
  resource_group_name   = "MC_${azurerm_resource_group.example.name}_${azurerm_kubernetes_cluster.example.name}_${azurerm_resource_group.example.location}"
  virtual_network_id    = azurerm_virtual_network.example-2.id
}


resource "azurerm_public_ip" "my_terraform_public_ip" {
  name                = "myPublicIP"
  location            = azurerm_resource_group.example-2.location
  resource_group_name = azurerm_resource_group.example-2.name
  allocation_method   = "Static"
  sku                 = "Standard"
}
resource "azurerm_bastion_host" "azure-bastion" {
  name                = "azure-bastion"
  location            = azurerm_resource_group.example-2.location
  resource_group_name = azurerm_resource_group.example-2.name
  ip_configuration {
    name                 = "configuration"
    subnet_id            = azurerm_subnet.example-3.id
    public_ip_address_id = azurerm_public_ip.my_terraform_public_ip.id
  }
}


resource "azurerm_network_security_group" "my_terraform_nsg" {
  name                = "myNetworkSecurityGroup"
  location            = azurerm_resource_group.example-2.location
  resource_group_name = azurerm_resource_group.example-2.name
  security_rule {
    name                       = "SSH"
    priority                   = 1001
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "22"
    source_address_prefix      = "*"
    destination_address_prefix = "*"
  }
}


resource "azurerm_network_interface" "my_terraform_nic" {
  name                = "myNIC"
  location            = azurerm_resource_group.example-2.location
  resource_group_name = azurerm_resource_group.example-2.name

  ip_configuration {
    name                          = "my_nic_configuration"
    subnet_id                     = azurerm_subnet.example-2.id
    private_ip_address_allocation = "Dynamic"
   
  }
}

# Connect the security group to the network interface
resource "azurerm_network_interface_security_group_association" "example" {
  network_interface_id      = azurerm_network_interface.my_terraform_nic.id
  network_security_group_id = azurerm_network_security_group.my_terraform_nsg.id
}


# Create virtual machine
resource "azurerm_linux_virtual_machine" "my_terraform_vm" {
  name                  = "myVM1"
  location              = azurerm_resource_group.example-2.location
  resource_group_name   = azurerm_resource_group.example-2.name
  network_interface_ids = [azurerm_network_interface.my_terraform_nic.id]

  size                  = "Standard_DS1_v2"

  os_disk {
    name                 = "myOsDisk"
    caching              = "ReadWrite"
    storage_account_type = "Premium_LRS"
  }

  source_image_reference {
    publisher = "Canonical"
    offer     = "0001-com-ubuntu-server-jammy"
    sku       = "22_04-lts-gen2"
    version   = "latest"
  }

  computer_name                   = "myvm"
  admin_username                  = "azureuser"
  admin_password                  = "Admin_152012345"
  disable_password_authentication = false

}

