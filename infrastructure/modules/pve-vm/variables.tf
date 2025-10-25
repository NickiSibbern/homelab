variable "name" {
  description = "Name of the VM"
  type        = string
}

variable "pve_node" {
  description = "Proxmox VE node name where the VM will be created"
  type        = string
}

variable "tags" {
  description = "Tags to assign to the VM"
  type        = list(string)
  default     = []
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
