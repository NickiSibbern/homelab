variable "domain" {
  description = "Base domain for services"
  type        = string
}

variable "default_gateway" {
  description = "Default gateway for the VM"
  type        = string
}

variable "subnet_mask" {
  description = "Subnet mask for the VM"
  type        = string
}

variable "proxmox_endpoint" {
  description = "Proxmox VE API endpoint"
  type        = string
}

variable "proxmox_nodes" {
  description = "List of Proxmox node names"
  type        = list(string)
}

variable "azure_resource_group_name" {
  description = "The name of the resource group in which to create the AKS cluster."
  type        = string
}

variable "azure_storage_account_name" {
  description = "The name of the Azure Storage Account to use for the Terraform state."
  type        = string
}

variable "azure_keyvault_name" {
  description = "The name of the Azure Key Vault to retrieve secrets from."
  type        = string
}

variable "kubernetes_cluster_nodes" {
  description = "Map of control plane and worker nodes with their respective IP addresses"
  type        = map(map(object({
    ip          = string
    proxmox_node = string
  })))
}

variable "vm_username" {
  description = "Username for the VMs"
  type        = string
}

variable "ssh_key_location" {
  description = "Path to the SSH public key"
  type        = string
}
