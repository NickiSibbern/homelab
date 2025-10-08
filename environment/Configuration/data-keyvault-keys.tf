data "azurerm_resource_group" "homelab" {
  name     = "homelab"
}

data "azurerm_key_vault" "homelab" {
  name                = "kv-homelab-nickisibbern"
  resource_group_name = data.azurerm_resource_group.homelab.name
}

data "azurerm_key_vault_secret" "cloudflare_api_key" {
  name         = "cloudflare-api-key"
  key_vault_id = data.azurerm_key_vault.homelab.id
}

data "azurerm_key_vault_secret" "email" {
  name         = "email"
  key_vault_id = data.azurerm_key_vault.homelab.id
}
