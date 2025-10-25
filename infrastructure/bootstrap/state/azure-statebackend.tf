resource "azurerm_storage_account" "tfstate" {
  name                     = var.azure_storage_account_name
  resource_group_name      = azurerm_resource_group.homelab.name
  location                 = azurerm_resource_group.homelab.location
  account_tier             = "Standard"
  account_replication_type = "LRS"
  allow_nested_items_to_be_public = false
}

resource "azurerm_storage_container" "tfstate" {
  name                  = "tfstate"
  storage_account_id    = azurerm_storage_account.tfstate.id
  container_access_type = "private"
}
