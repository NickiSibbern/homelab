terraform {
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = ">= 4.0.0"
    }
  }
  backend "azurerm" {
    resource_group_name  = "homelab"
    storage_account_name = "sahomelabnickisibbern"
    container_name       = "tfstate"
    key                  = "keyvault-terraform.tfstate"
  }
}

provider "azurerm" {
  features {}
}
