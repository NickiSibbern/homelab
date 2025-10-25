variable "machine_ip" {
  description = "IP address of the Talos machine"
  type        = string
}

variable "machine_type" {
  description = "Type of the Talos machine (e.g., controlplane, workernode)"
  type        = string
}

variable "cluster_name" {
  description = "Name of the Kubernetes cluster"
  type        = string
}

variable "cluster_endpoint" {
  description = "Hostname for the Kubernetes API server"
  type        = string
}

variable "machine_secrets" {
  description = "Talos machine secrets object"
  type        = any
}

variable "config_patches" {
  description = "List of Talos configuration patches"
  type        = list(string)
  default     = []
}
