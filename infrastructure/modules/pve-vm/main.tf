# Vm creation in Proxmox VE
resource "proxmox_virtual_environment_vm" "vm" {
  name      = var.name
  node_name = var.pve_node
  tags      = var.tags

  agent {
    enabled = true
  }

  cpu {
    cores = var.cpu
    type = "x86-64-v2-AES"
  }

  memory {
    dedicated = var.memory
  }

  network_device {
    bridge = "vmbr0"
  }

  disk {
    datastore_id  = "local-lvm"
    file_id       = var.cloud_iso_name
    file_format   = "raw"
    interface     = "virtio0"
    size          = var.disk_size
  }

  initialization {
    ip_config {
      ipv4 {
        address = "${var.ip}/${var.subnet_mask}"
        gateway = var.default_gateway
      }
    }
  }
}
