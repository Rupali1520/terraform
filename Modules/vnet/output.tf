output "vnet_id" {
  description = "ID of the virtual network"
  value       = azurerm_virtual_network.vnet.id
}



output "vnet_name" {
   value = azurerm_virtual_network.vnet.name
  
}