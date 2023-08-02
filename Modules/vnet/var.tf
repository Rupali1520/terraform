variable "vnet_name" {
  description = "Name of the virtual network"
  type        = string
  default = "vnet-rupali"
}

variable "address" {
    type = string
    default = "10.0.0.0/16"
  
}
variable "resource_group" {
    type = string
    default = "rupali-rg" 
}

variable "location1" {
    type = string
    default = "eastus"
  
}
# variable "subnet_name" {
#   description = "Name of the subnet"
#   type        = string
# }

# variable "subnet_address" {
#   description = "Address space of the subnet"
#   type        = string
# }
