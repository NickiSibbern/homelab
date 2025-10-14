data "azurerm_resource_group" "homelab" {
  name     = var.azure_resource_group_name
}

data "azurerm_key_vault" "homelab" {
  name                = var.azure_keyvault_name
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

data "azurerm_key_vault_secret" "argo_github_token" {
  name         = "argo-github-token"
  key_vault_id = data.azurerm_key_vault.homelab.id
}

data "azurerm_key_vault_secret" "argocd_password" {
  name         = "argocd-password"
  key_vault_id = data.azurerm_key_vault.homelab.id
}
