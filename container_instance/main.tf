provider "azurerm" {
  features {}

  subscription_id   = var.sub_id

  tenant_id         = var.tent_id
  client_id         = var.client_id
  client_secret     = var.client_secret
}

module "rg" {
  source = "/home/knoldus/terraform/Modules/resourcegroup"
  
}

module "vnet" {
  source = "/home/knoldus/terraform/Modules/vnet"
  
}


resource "azurerm_subnet" "subnetapp" {
  name                 = "subnetforapp"
  resource_group_name  =  module.rg.resource_group_name
  virtual_network_name = module.vnet.vnet_name
  address_prefixes     = ["10.0.2.0/24"]
}

resource "azurerm_subnet" "subnetapp1" {
  name                 = "subnetforapp1"
  resource_group_name  =  module.rg.resource_group_name
  virtual_network_name = module.vnet.vnet_name
  address_prefixes     = ["10.0.1.0/24"]
   delegation {
    name = "aciDelegation"
    service_delegation {
      name    = "Microsoft.ContainerInstance/containerGroups"
      actions = ["Microsoft.Network/virtualNetworks/subnets/action"]
    }
  }
}

resource "azurerm_storage_account" "test" {
  name                     = "acctestsa1520"
  resource_group_name      = module.rg.resource_group_name
  location                 = module.rg.resource_group_location
  account_tier             = "Standard"                                
  account_replication_type = "LRS"
}
resource "azurerm_storage_share" "test" {
  name                 = "fileshare1"
  storage_account_name = azurerm_storage_account.test.name
  quota                = 50
}
resource "azurerm_container_group" "example" {
  name                = "con-private"
  location            = "${module.rg.resource_group_location}"
  resource_group_name = "${module.rg.resource_group_name}"
  
  ip_address_type     = "Private"
  subnet_ids= [ azurerm_subnet.subnetapp1.id ]
  os_type             = "Linux"

  container {
    name   = "container1"
    image  = "rupali1520/todo:23"
    cpu    = "0.5"
    memory = "1.5"

    ports {
      port     = 5000
      protocol = "TCP"
    }
    volume {
      name                 = "my-volume"
      mount_path           = "/aci-store/"
      storage_account_name = azurerm_storage_account.test.name
      storage_account_key  = azurerm_storage_account.test.primary_access_key
      share_name           = azurerm_storage_share.test.name
    }
  }
  container {
    name   = "container2"
    image  = "somyanegi/testimage:35"
    cpu    = "1.0"
    memory = "2.0"

    ports {
      port     = 8000
      protocol = "TCP"
    }
    volume {
      name                 = "my-volume1"
      mount_path           = "/aci-store2/"
      storage_account_name = azurerm_storage_account.test.name
      storage_account_key  = azurerm_storage_account.test.primary_access_key
      share_name           = azurerm_storage_share.test.name
    }
  }

  
}

resource "azurerm_public_ip" "gatwayip" {
  name                = "pub-ip1"
  location            = module.rg.resource_group_location
  resource_group_name =  module.rg.resource_group_name
  allocation_method   = "Static"
   sku                 = "Standard"
   
}
resource "azurerm_application_gateway" "network" {
  name                = "app-gatway"
  resource_group_name = module.rg.resource_group_name
  location            =  module.rg.resource_group_location

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
         "${azurerm_container_group.example.ip_address}"

        ]
  }

  backend_http_settings {
    name                  = "httpsetting"
    cookie_based_affinity = "Disabled"
    path = ""
    port                  = 5000
    protocol              = "Http"
    request_timeout       = 1
  }
  backend_http_settings {
    name                  = "httpsetting1"
    cookie_based_affinity = "Disabled"
    path = ""
    port                  = 8000
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
    name               = "RoutingRuleA"
    rule_type          = "PathBasedRouting"
    priority = 2
    url_path_map_name  = "RoutingPath"
    http_listener_name = "listner"
  }
  url_path_map {
    name                               = "RoutingPath"    
    default_backend_address_pool_name   = "pool"
    default_backend_http_settings_name  = "httpsetting"

    

    path_rule {
      name                          = "rule2"
      backend_address_pool_name     = "pool"
      backend_http_settings_name    = "httpsetting1"
      paths = ["/admin/*"]
    }
  }
}
