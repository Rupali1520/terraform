resource "azurerm_user_assigned_identity" "hephaestus" {
  name                = "hephaestus"
  location            = azurerm_resource_group.name.location
  resource_group_name = azurerm_resource_group.name.name
}
resource "azurerm_federated_identity_credential" "hephaestus" {
  name                = "hephaestus"
  resource_group_name = azurerm_resource_group.name.name
  audience            = ["api://AzureADTokenExchange"]
  issuer              = azurerm_kubernetes_cluster.aks.oidc_issuer_url
  parent_id           = azurerm_user_assigned_identity.hephaestus.id
  subject             = "system:serviceaccount:${var.namespaces.compute}:hephaestus"
}