variable "azure_resource_group_name" {
  description = "The name of the Azure Resource Group"
  type        = string
}

variable "azure_keyvault_name" {
  description = "The name of the Azure Key Vault"
  type        = string
}

variable "azure_storage_account_name" {
  description = "The name of the Azure Storage Account to use for the Terraform state."
  type        = string
}
