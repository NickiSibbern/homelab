variable "default_gateway" {
  description = "Default gateway for the VM"
  type        = string
}

variable "subnet_mask" {
  description = "Subnet mask for the VM"
  type        = string
}

variable "proxmox_config" {
  description = "Proxmox configuration map"
  type = object({
    endpoint = string
    nodes    = list(string)
  })
}

variable "azure_config" {
  description = "Azure configuration map"
  type = object({
    location             = string
    resource_group_name  = string
    storage_account_name = string
    keyvault_name        = string
  })
}

variable "kubernetes_config" {
  description = "Kubernetes configuration map"
  type = object({
    cluster_name = string
    hostname     = string
    endpoint     = string
    cilium = object({
      cidr_block = string
    })
    argo = object({
      github_organization = string
      state_repo          = string
    })
    talos = object({
      version = string
    })
    nodes = map(object({
      name      = string
      ip        = string
      role      = string
      pve_node  = string
      cpu       = number
      memory    = number
      disk_size = number
    }))
  })
}
