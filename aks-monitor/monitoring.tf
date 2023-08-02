resource "random_id" "log_analytics_workspace_name_suffix" {
  byte_length = 8
}

resource "azurerm_log_analytics_workspace" "logs" {
  # The WorkSpace name has to be unique across the whole of azure, not just the current subscription/tenant.
  name                = "${azurerm_resource_group.name.name}-${random_id.log_analytics_workspace_name_suffix.dec}"
    location            = azurerm_resource_group.name.location
  resource_group_name = azurerm_resource_group.name.name
  sku                 = var.log_analytics_workspace_sku
  tags                = var.tags
}

resource "azurerm_log_analytics_solution" "logs" {
  solution_name         = "ContainerInsights"
    location            = azurerm_resource_group.name.location
  resource_group_name = azurerm_resource_group.name.name
  workspace_resource_id = azurerm_log_analytics_workspace.logs.id
  workspace_name        = azurerm_log_analytics_workspace.logs.name

  plan {
    publisher = "Microsoft"
    product   = "OMSGallery/ContainerInsights"
  }

  tags = var.tags

  lifecycle {
    ignore_changes = [
      tags
    ]
  }
}

resource "azurerm_monitor_diagnostic_setting" "control_plane" {
  name                       = "AKS Control Plane Logging"
  target_resource_id         = azurerm_kubernetes_cluster.aks.id
  log_analytics_workspace_id = azurerm_log_analytics_workspace.logs.id

  enabled_log {
    category = "cloud-controller-manager"

    retention_policy {
      enabled = true
      days    = 7
    }
  }

  enabled_log {
    category = "cluster-autoscaler"

    retention_policy {
      enabled = true
      days    = 7
    }
  }

  enabled_log {
    category = "csi-azuredisk-controller"

    retention_policy {
      enabled = true
      days    = 7
    }
  }

  enabled_log {
    category = "csi-azurefile-controller"

    retention_policy {
      enabled = true
      days    = 7
    }
  }

  enabled_log {
    category = "csi-snapshot-controller"

    retention_policy {
      enabled = true
      days    = 7
    }
  }

  enabled_log {
    category = "kube-apiserver"

    retention_policy {
      enabled = true
      days    = 7
    }
  }

  enabled_log {
    category = "kube-controller-manager"

    retention_policy {
      enabled = true
      days    = 7
    }
  }

  enabled_log {
    category = "kube-scheduler"

    retention_policy {
      enabled = true
      days    = 7
    }
  }

  metric {
    category = "AllMetrics"
    enabled  = false

    retention_policy {
      enabled = false
      days    = 0
    }
  }
}