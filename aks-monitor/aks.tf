

data "azurerm_kubernetes_service_versions" "selected" {
  location       = azurerm_resource_group.name.location
  version_prefix = var.kubernetes_version
}

resource "azurerm_kubernetes_cluster" "aks" {
  

  name                              = var.deploy_id
   location            = azurerm_resource_group.name.location
  resource_group_name = azurerm_resource_group.name.name
  dns_prefix                        = var.deploy_id



    default_node_pool {
    name                = "default"
    node_count          = 1
    vm_size             = "Standard_DS2_v2"
    only_critical_addons_enabled = false
    enable_auto_scaling = true
    min_count           = 1
    max_count           = 2
    type                = "VirtualMachineScaleSets"
  }
 
  identity {
    type = "SystemAssigned"
  }

  oidc_issuer_enabled       = true
  workload_identity_enabled = true

  oms_agent {
    log_analytics_workspace_id = azurerm_log_analytics_workspace.logs.id
  }

  network_profile {
    
    network_plugin = "kubenet"
    dns_service_ip = "192.168.1.1"
    service_cidr   = "192.168.0.0/16"
    pod_cidr       = "172.16.0.0/22"
  }

  tags = var.tags

}