variable "name" {
  description = "Name of the VM"
  type        = string
}

variable "user_name" {
  description = "Username for the VM"
  type        = string
  default     = "homelab"
}

variable "ssh_key_location" {
  description = "Path to the SSH public key file used for cloud-init"
  type        = string
}

variable "pve_node" {
  description = "Proxmox VE node name where the VM will be created"
  type        = string
}

variable "cloud_iso_name" {
  description = "Name of the cloud-init ISO file to be used"
  type        = string
}

variable "cpu" {
  description = "CPU configuration for the VM"
  type        = number
  default     = 2
}

variable "memory" {
  description = "Memory size for the VM in MB"
  type        = number
  default     = 2048
}

variable "disk_size" {
  description = "Disk size for the VM in GB"
  type        = number
  default     = 50
}

variable "ip" {
  description = "IP address for the VM"
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

variable "additional_runcmd" {
  description = "Additional runcmd commands to add to cloud-init after Docker installation"
  type        = string
  default     = ""
}

variable "additional_packages" {
  description = "Additional packages to install via cloud-init"
  type        = list(string)
  default     = []
}

variable "proxmox_endpoint" {
  description = "Proxmox API endpoint"
  type        = string
}

variable "proxmox_api_key" {
  description = "Proxmox API key for authentication"
  type        = string
}

variable "proxmox_ssh_username" {
  description = "SSH username for Proxmox"
  type        = string
}

variable "proxmox_ssh_password" {
  description = "SSH password for Proxmox"
  type        = string
}