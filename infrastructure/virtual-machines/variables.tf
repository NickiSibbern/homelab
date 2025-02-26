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
