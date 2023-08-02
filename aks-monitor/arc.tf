resource "azurerm_container_registry" "domino" {
  name                = replace("${azurerm_resource_group.name.name}domino", "/[^a-zA-Z0-9]/", "")
  location            = azurerm_resource_group.name.location
  resource_group_name = azurerm_resource_group.name.name
  sku           = var.registry_tier
  admin_enabled = false


  public_network_access_enabled = true

  retention_policy {

    enabled = false
  }

  tags = var.tags
}

resource "azurerm_role_assignment" "aks_domino_acr" {
  scope                = azurerm_container_registry.domino.id
  role_definition_name = "AcrPull"
  principal_id         = azurerm_kubernetes_cluster.aks.kubelet_identity[0].object_id
}

resource "azurerm_role_assignment" "hephaestus_acr" {
  scope                = azurerm_container_registry.domino.id
  role_definition_name = "AcrPush"
  principal_id         = azurerm_user_assigned_identity.hephaestus.principal_id
}