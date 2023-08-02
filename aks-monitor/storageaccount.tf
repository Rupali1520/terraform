resource "azurerm_storage_account" "domino" {
  name                     = "azujdbwsdj"
    location            = azurerm_resource_group.name.location
  resource_group_name = azurerm_resource_group.name.name
  account_kind             = "StorageV2"
  account_tier             = var.storage_account_tier
  account_replication_type = var.storage_account_replication_type
  access_tier              = "Hot"
  min_tls_version          = "TLS1_2"

 
}

resource "azurerm_storage_container" "domino_containers" {
  for_each = {
    for key, value in var.containers :
    key => value
  }

  name                  = "${var.deploy_id}-${each.key}"
  storage_account_name  = azurerm_storage_account.domino.name
  container_access_type = each.value.container_access_type
}