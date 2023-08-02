# variable "client_id" {
#   description = "Client ID of the Azure service principal"
#   type        = string
# }

# variable "client_secret" {
#   description = "Client secret of the Azure service principal"
#   type        = string
# }

variable "subscription_id" {
  type = string

}
variable "tenant_id" {
  type = string

}
variable "object_id" {
  type = string
}
variable "vault_name" {
  type        = string
  description = "The name of the key vault to be created. The value will be randomly generated if blank."
  
}



variable "sku_name" {
  type        = string
  description = "The SKU of the vault to be created."
 
  validation {
    condition     = contains(["standard", "premium"], var.sku_name)
    error_message = "The sku_name must be one of the following: standard, premium."
  }
}
variable "sec_name" {
  type    = string
 
}
variable "value_name" {
  type    = string
 
}
variable "sec_name1" {
  type    = string
 
}
variable "value_name1" {
  type    = string

}
variable "key_permissions" {
  type        = list(string)
  description = "List of key permissions."
  default = [
    "Create",
    "Delete",
    "List",
    "Get",
    "Restore",
    "Recover",
    "Update",
    "Import",
    "Backup",
    "GetRotationPolicy",
    "SetRotationPolicy"
  ]
}

variable "secret_permissions" {
  type        = list(string)
  description = "List of secret permissions."
  default = [
    "Set",
    "Get",
    "Delete",
    "Recover",
    "List",
    "Restore",
    "Backup",
    "Purge"
  ]
}

