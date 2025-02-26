terraform {
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = ">= 4.0.0"
    }
    proxmox = {
      source = "bpg/proxmox"
    }
  }
  backend "azurerm" {
    resource_group_name  = "homelab"
    storage_account_name = "sahomelabnickisibbern"
    container_name       = "tfstate"
    key                  = "terraform.tfstate"
  }
}

provider "azurerm" {
  features {}
}

provider "proxmox" {
  endpoint  = var.proxmox_endpoint
  api_token = "${data.azurerm_key_vault_secret.proxmox_username.value}@pam!terraform=${data.azurerm_key_vault_secret.proxmox_api_key.value}"
  insecure  = true

  ssh {
    agent    = true
    username = "homelab"
    password = data.azurerm_key_vault_secret.proxmox_password.value
  }
}
