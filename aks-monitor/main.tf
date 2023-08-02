data "azurerm_subscription" "current" {
}

resource "azurerm_resource_group" "name" {
  name = var.resource_group
  location = var.location
}

resource "azurerm_role_assignment" "aks_network" {
  scope                = data.azurerm_subscription.current.id
  role_definition_name = "Network Contributor"
  principal_id         = azurerm_kubernetes_cluster.aks.identity[0].principal_id
}