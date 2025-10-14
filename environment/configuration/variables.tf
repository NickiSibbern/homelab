variable "domain" {
  description = "Base domain for services"
  type        = string
}

variable "kubernetes_hostname" {
  description = "Hostname for the Kubernetes API server"
  type        = string
}

variable "azure_resource_group_name" {
  description = "The name of the resource group in which to create the AKS cluster."
  type        = string
}

variable "azure_keyvault_name" {
  description = "The name of the Azure Key Vault to retrieve secrets from."
  type        = string
}

variable "azure_storage_account_name" {
  description = "The name of the Azure Storage Account to use for the Terraform state."
  type        = string
}

variable "github_organization" {
  description = "GitHub organization for ArgoCD to sync from"
  type        = string
}

variable "cilium_cidr_block" {
  description = "CIDR block for Cilium LoadBalancerIPPool, this is used for services of type LoadBalancer where an external IP is needed"
  type        = string
}

variable "argo_state_repo" {
  description = "Git repository for ArgoCD to sync from"
  type        = string
}
