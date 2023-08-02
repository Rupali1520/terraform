variable "api_server_authorized_ip_ranges" {
  type        = list(string)
  description = "The IP ranges to whitelist for incoming traffic to the masters"
  

}

variable "resource_group" {
  type        = string
  description = "Name or id of optional pre-existing resource group to install AKS in"

}
variable "location" {
  type = string
 
}

variable "deploy_id" {
  type        = string
  description = "Domino Deployment ID."
  nullable    = false


  validation {
    condition     = length(var.deploy_id) >= 3 && length(var.deploy_id) <= 24 && can(regex("^([a-z][-a-z0-9]*[a-z0-9])$", var.deploy_id))
    error_message = <<EOT
      Variable deploy_id must:
      1. Length must be between 3 and 24 characters.
      2. Start with a letter.
      3. End with a letter or digit.
      4. May contain lowercase Alphanumeric characters and hyphens.
    EOT
  }
}

variable "kubeconfig_output_path" {
  description = "kubeconfig path"
  type        = string

}

variable "cluster_sku_tier" {
  type        = string
  
  description = "The Domino cluster SKU (defaults to Free)"
}

variable "containers" {
  description = "storage containers to create"
  type = map(object({
    container_access_type = string
  }))

  
  validation {
    condition = alltrue([for k in keys(var.containers) :
      length(k) >= 3 &&
      length(k) <= 32 &&
      can(regex("^([a-z][-a-z0-9]*[a-z0-9])$", k))
    ])
    error_message = <<EOT
      Map containers keys must:
      1. Length must be between 3 and 32 characters.
      2. Start with a letter.
      3. End with a letter or digit.
      4. May contain lowercase Alphanumeric characters and hyphens.
    EOT
  }
}

# refer https://azure.microsoft.com/pricing/details/monitor/ for log analytics pricing
variable "log_analytics_workspace_sku" {
  description = "log analytics sku"
  type        = string

}





variable "storage_account_tier" {
  description = "storage account tier"
  type        = string
  default     = "Standard"
}

variable "storage_account_replication_type" {
  description = "storage replication"
  type        = string
  default     = "LRS"
}

variable "tags" {
  type        = map(string)
  default     = {}
  description = "Tags to apply to resources"
}

variable "kubernetes_version" {
  type        = string
  default     = null
  description = "Optional Kubernetes version to provision. Allows partial input (e.g. 1.18) which is then chosen from azurerm_kubernetes_service_versions."
}

variable "registry_tier" {
  description = "registry tier"
  type        = string
  default     = "Standard"
}

variable "namespaces" {
  type        = object({ platform = string, compute = string })
  description = "Namespace that are used for generating the service account bindings"
   default = {
    platform = "default-platform-namespace"
    compute  = "default-compute-namespace"
  }
}

variable "subscription_id" {
  type = string
  default  = "b7f11749-054e-4aa1-86d2-54a9ab0e168f"

}
variable "tenant_id" {
  type = string
  default         = "56c7f5df-7c55-42bc-898d-0096c86a7dba"
}
