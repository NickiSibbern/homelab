terraform {
  required_providers {
    kubernetes = {
      source  = "hashicorp/kubernetes"
      version = ">= 1.0.0"
    }
    helm = {
      source = "hashicorp/helm"
      version = ">=3.0.0"
    }
    azurerm = {
      source  = "hashicorp/azurerm"
      version = ">= 4.0.0"
    }
    kubectl = {
      source  = "gavinbunney/kubectl"
      version = ">= 1.19.0"
    }
  }

  backend "azurerm" {
    resource_group_name  = var.azure_config.resource_group_name
    storage_account_name = var.azure_config.storage_account_name
    container_name       = "tfstate"
    key                  = "cluster-terraform.tfstate"
  }
}

provider "kubernetes" {
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
