resource "azurerm_resource_group" "homelab" {
  name     = var.azure_resource_group_name
  location = var.azure_location
}
