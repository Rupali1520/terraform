resource "azurerm_resource_group" "internal" {
  name     = var.resource_group_name
  location = var.location
}
