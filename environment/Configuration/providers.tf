terraform {
  required_providers {
    kubernetes = {
      source  = "hashicorp/kubernetes"
      version = ">= 1.0.0"
    }
  }
  backend "azurerm" {
    resource_group_name  = "homelab"
    storage_account_name = "sahomelabnickisibbern"
    container_name       = "tfstate"
    key                  = "cluster-terraform.tfstate"
  }
}

provider "kubernetes" {
  config_path = "~/.kube/config"
}
