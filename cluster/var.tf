variable "resource_group_name1" {
  description = "Name of the resource group"
  type        = string
}
variable "resource_group_name2" {
  description = "Name of the resource group"
  type        = string
}

variable "location1" {
  description = "Azure region"
  type        = string
}

variable "location2" {
  description = "Azure region"
  type        = string
}
variable "vnet1" {
  type = string  
}
variable "vnet2" {
   type =  string   
}

variable "sub_name1" {
  type = string
  
}

variable "sub_name2" {
  type = string
  
}
variable "cluster_name" {
  description = "Name of the AKS cluster"
  type        = string
}

variable "dns_prefix" {
  description = "DNS prefix for the AKS cluster"
  type        = string
}

# variable "node_count" {
#   description = "Number of nodes in the AKS cluster"
#   type        = number
#   default     = 1
# }

# variable "vm_size" {
#   description = "Size of the VMs in the AKS cluster"
#   type        = string
#   default     = "Standard_DS2_v2"
# }

# variable "min_node_count" {
#   description = "Minimum number of nodes for auto-scaling"
#   type        = number
#   default     = 1
# }

# variable "max_node_count" {
#   description = "Maximum number of nodes for auto-scaling"
#   type        = number
#   default     = 5
# }

variable "client_id" {
  description = "Client ID of the Azure service principal"
  type        = string
}

variable "client_secret" {
  description = "Client secret of the Azure service principal"
  type        = string
}

variable "sub_id" {
  type = string

}
variable "tent_id" {
  type = string

}