provider "azurerm" {
  features {}

  subscription_id = var.subscription_id

  tenant_id = var.tenant_id

}

resource "azurerm_resource_group" "example" {
  name     = "rg1"
  location = "Australia Southeast"
}


resource "azurerm_key_vault" "vault" {
  name                       = var.vault_name
 location            = azurerm_resource_group.example.location
  resource_group_name = azurerm_resource_group.example.name
  tenant_id                  = var.tenant_id
  sku_name                   = var.sku_name
  soft_delete_retention_days = 7

  access_policy {
    tenant_id          = var.tenant_id
    object_id          = var.object_id
    key_permissions    = var.key_permissions
    secret_permissions = var.secret_permissions
  }
}



resource "azurerm_key_vault_secret" "example" {
  name         = var.sec_name
  value        = base64encode(var.value_name)
  key_vault_id = azurerm_key_vault.vault.id
}

resource "azurerm_key_vault_secret" "example1" {
  name         = var.sec_name1
  value        = base64encode(var.value_name1)
  key_vault_id = azurerm_key_vault.vault.id
}

