resource "azurerm_dashboard_grafana" "this" {
  name                              = "aks-snrp"
  resource_group_name               = azurerm_resource_group.name.name
  location =                            azurerm_resource_group.name.location
  sku                               = "Standard"
  api_key_enabled                   = false
  deterministic_outbound_ip_enabled = false
  public_network_access_enabled     = true
  zone_redundancy_enabled           = false

  identity {
    type = "SystemAssigned"
  }

 
}
# resource "azurerm_role_assignment" "u1" {
#     scope = "/subscriptions/b7f11749-054e-4aa1-86d2-54a9ab0e168f/resourceGroups/${azurerm_resource_group.name.name}/providers/Microsoft.Dashboard/grafana/${azurerm_dashboard_grafana.this.name}"
#     role_definition_name = "Grafana Editor"
#     principal_id = "ee8a764a-fd98-4112-8405-c4350eecd6cb"
  
# }
# # resource "azurerm_role_assignment" "u5" {
# #     scope                = "/subscriptions/B7F11749-054E-4AA1-86D2-54A9AB0E168F"
# #   role_definition_name = "Contributor"
# #     principal_id = "ee8a764a-fd98-4112-8405-c4350eecd6cb"
  
# # }
# # resource "azurerm_role_assignment" "u6" {
# #     scope                = "/subscriptions/B7F11749-054E-4AA1-86D2-54A9AB0E168F"
# #   role_definition_name = "Contributor"
# #     principal_id = "3134cfca-4d24-4834-a0a2-157524759e16"
  
# # }
# # resource "azurerm_role_assignment" "read" {
# #     scope                = "/subscriptions/B7F11749-054E-4AA1-86D2-54A9AB0E168F"
# #   role_definition_name = "Reader"
# #     principal_id = "ee8a764a-fd98-4112-8405-c4350eecd6cb"
  
# # }
# # resource "azurerm_role_assignment" "read1" {
# #     scope                = "/subscriptions/B7F11749-054E-4AA1-86D2-54A9AB0E168F"
# #   role_definition_name = "Reader"
# #     principal_id = "3134cfca-4d24-4834-a0a2-157524759e16"
  
# # }
# resource "azurerm_role_assignment" "u2" {
#     scope = "/subscriptions/b7f11749-054e-4aa1-86d2-54a9ab0e168f/resourceGroups/${azurerm_resource_group.name.name}/providers/Microsoft.Dashboard/grafana/${azurerm_dashboard_grafana.this.name}"
#     role_definition_name = "Grafana Editor"
#     principal_id = "3134cfca-4d24-4834-a0a2-157524759e16"
  
# }

# # resource "azurerm_role_assignment" "u3" {
# #     scope = "/subscriptions/b7f11749-054e-4aa1-86d2-54a9ab0e168f"
# #     role_definition_name = "Monitoring Reader"
# #     principal_id = "ee8a764a-fd98-4112-8405-c4350eecd6cb"
  
# # }
# # resource "azurerm_role_assignment" "u4" {
# #     scope = "/subscriptions/b7f11749-054e-4aa1-86d2-54a9ab0e168f"
# #     role_definition_name = "Monitoring Reader"
# #     principal_id = "3134cfca-4d24-4834-a0a2-157524759e16"
  
# # }

# resource "azurerm_role_assignment" "view" {
#     scope = "/subscriptions/b7f11749-054e-4aa1-86d2-54a9ab0e168f/resourceGroups/${azurerm_resource_group.name.name}/providers/Microsoft.Dashboard/grafana/${azurerm_dashboard_grafana.this.name}"
#     role_definition_name = "Grafana Viewer"
#     principal_id = "ee8a764a-fd98-4112-8405-c4350eecd6cb"
  
# }

# resource "azurerm_role_assignment" "view1" {
#     scope = "/subscriptions/b7f11749-054e-4aa1-86d2-54a9ab0e168f/resourceGroups/${azurerm_resource_group.name.name}/providers/Microsoft.Dashboard/grafana/${azurerm_dashboard_grafana.this.name}"
#     role_definition_name = "Grafana Viewer"
#     principal_id = "3134cfca-4d24-4834-a0a2-157524759e16"
  
# }
# data "azurerm_service_principal" "grafana" {
#   display_name = azurerm_dashboard_grafana.this.name
#   depends_on = [ azurerm_dashboard_grafana.this ]
# }
resource "azurerm_role_assignment" "admin" {
    scope = "/subscriptions/b7f11749-054e-4aa1-86d2-54a9ab0e168f/resourceGroups/${azurerm_resource_group.name.name}/providers/Microsoft.Dashboard/grafana/${azurerm_dashboard_grafana.this.name}"
    role_definition_name = "Grafana Admin"
    principal_id = "ee8a764a-fd98-4112-8405-c4350eecd6cb"
  
}


resource "azurerm_role_assignment" "admin1" {
    scope = "/subscriptions/b7f11749-054e-4aa1-86d2-54a9ab0e168f/resourceGroups/${azurerm_resource_group.name.name}/providers/Microsoft.Dashboard/grafana/${azurerm_dashboard_grafana.this.name}"
    role_definition_name = "Grafana Admin"
    principal_id = "3134cfca-4d24-4834-a0a2-157524759e16"
  
}

# resource "azurerm_role_assignment" "monitor" {
#     scope = "/subscriptions/b7f11749-054e-4aa1-86d2-54a9ab0e168f/resourceGroups/${azurerm_resource_group.name.name}"
#     role_definition_name = " Monitoring Reader"
#     principal_id = azure
  
# }

