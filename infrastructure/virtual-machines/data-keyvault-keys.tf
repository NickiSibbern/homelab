data "azurerm_resource_group" "homelab" {
  name     = var.azure_resource_group_name
}

data "azurerm_key_vault" "homelab" {
  name                = var.azure_keyvault_name
  resource_group_name = data.azurerm_resource_group.homelab.name
}

data "azurerm_key_vault_secret" "proxmox_username" {
  name         = "proxmox-username"
  key_vault_id = data.azurerm_key_vault.homelab.id
}

data "azurerm_key_vault_secret" "proxmox_password" {
  name         = "proxmox-password"
  key_vault_id = data.azurerm_key_vault.homelab.id
}

data "azurerm_key_vault_secret" "proxmox_api_key" {
  name         = "proxmox-api-key"
  key_vault_id = data.azurerm_key_vault.homelab.id
}

