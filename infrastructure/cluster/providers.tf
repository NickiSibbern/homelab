terraform {
  required_providers {
    talos = {
      source = "siderolabs/talos"
      version = ">= 0.9.0"
    }
    proxmox = {
      source  = "bpg/proxmox"
      version = ">= 0.85.1"
    }
     azurerm = {
      source  = "hashicorp/azurerm"
      version = ">= 4.0.0"
    }
    local = {
      source  = "hashicorp/local"
      version = ">= 2.5.3"
    }
    null = {
      source  = "hashicorp/null"
      version = ">= 3.2.4"
    }
    kubectl = {
      source  = "gavinbunney/kubectl"
      version = ">= 1.19.0"
    }
  }
   backend "azurerm" {
     resource_group_name  = "homelab"
     storage_account_name = "sahomelabnickisibbern"
     container_name       = "tfstate"
     key                  = "infra-terraform.tfstate"
   }
}

provider "kubectl" {
  config_path = "~/.kube/config"
}

provider "helm" {
  kubernetes = {
    config_path = "~/.kube/config"
  }
}

provider "azurerm" {
  features {}
}

provider "proxmox" {
  endpoint  = var.proxmox_config.endpoint
  username  = "${data.azurerm_key_vault_secret.proxmox_username.value}@pam"
  password  = "${data.azurerm_key_vault_secret.proxmox_password.value}"

  insecure  = true
}
