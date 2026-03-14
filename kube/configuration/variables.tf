variable "domain" {
  description = "Base domain for services"
  type        = string
}

variable "flux_github_token" {
  description = "GitHub token for Flux to read/write the state repo. Pass via TF_VAR_flux_github_token."
  type        = string
  sensitive   = true
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
    certManager = object({
     version = string
    })
    cilium = object({
      version    = optional(string)
      cidr_block = string
    })
    flux = object({
      state_repo = string
      version    = string
    })
    talos = object({
      version = string
    })
    nodes = map(object({
      name      = string
      role      = string
      pve_node  = string
      ip_address = string
      network_interface = optional(string, "ens18")
      cpu       = number
      memory    = number
      disk_size = number
    }))
  })
}
