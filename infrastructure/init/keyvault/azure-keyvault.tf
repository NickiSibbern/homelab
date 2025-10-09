data "azurerm_client_config" "current" {}
data "azurerm_resource_group" "homelab" {
    name     = "homelab"
}

resource "azurerm_key_vault" "homelab" {
  name                        = "kv-homelab-nickisibbern"
  location                    = data.azurerm_resource_group.homelab.location
  resource_group_name         = data.azurerm_resource_group.homelab.name
  enabled_for_disk_encryption = true
  tenant_id                   = data.azurerm_client_config.current.tenant_id
  soft_delete_retention_days  = 7
  purge_protection_enabled    = false

  sku_name = "standard"

  access_policy {
    tenant_id = data.azurerm_client_config.current.tenant_id
    object_id = data.azurerm_client_config.current.object_id

    key_permissions         = [ "Get", "List", "Create", "Delete", "Recover", "Backup", "Restore", "Import", "Update", "GetRotationPolicy", "SetRotationPolicy", "Rotate" ]
    secret_permissions      = [ "Get", "List", "Set", "Delete", "Recover", "Backup", "Restore", "Purge" ]
    storage_permissions     = [ "Backup", "Delete", "DeleteSAS", "Get", "GetSAS", "List", "ListSAS", "Purge", "Recover", "RegenerateKey", "Restore", "Set", "SetSAS", "Update" ]
  }
}

resource "azurerm_key_vault_secret" "this" {
    key_vault_id = azurerm_key_vault.homelab.id
    for_each = {
      for key, value in jsondecode(file("${path.module}/secrets.json")) : key => value
    }
    name = each.key
    value = each.value
}
