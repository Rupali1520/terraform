output "public_ip_address_vm1" {
  value = azurerm_linux_virtual_machine.vm1.public_ip_address
}
output "public_ip_address_vm2" {
  value = azurerm_linux_virtual_machine.vm2.public_ip_address
}
output "public_ip_address_gatway" {
  value = azurerm_public_ip.gatwayip.ip_address
}