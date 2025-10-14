variable "azure_resource_group_name" {
  description = "The name of the Azure Resource Group"
  type        = string
}

variable "azure_location" {
  description = "The Azure region where resources will be created"
  type        = string
  default     = "West Europe"
}

variable "azure_storage_account_name" {
  description = "The name of the Azure Storage Account to use for the Terraform state."
  type        = string
}
