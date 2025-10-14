terraform {
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = ">= 4.0.0"
    }
  }
  backend "azurerm" {
    resource_group_name  = var.azure_resource_group_name
    storage_account_name = var.azure_storage_account_name
    container_name       = "tfstate"
    key                  = "keyvault-terraform.tfstate"
  }
}

provider "azurerm" {
  features {}
}
