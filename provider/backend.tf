terraform {
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "~>3.0"
    }
  }
  backend "azurerm" {
      resource_group_name  = "rupali-backup-rg"
      storage_account_name = "acct17"
      container_name       = "vhds1"
      key                  = "statefiles"
  }

}