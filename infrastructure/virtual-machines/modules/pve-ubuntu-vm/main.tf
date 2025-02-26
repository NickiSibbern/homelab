data "local_file" "ssh_public_key" {
  filename = pathexpand(var.ssh_key_location) #TODO: Re-write to use azure keyvault instead
}

resource "proxmox_virtual_environment_file" "user_data_cloud_config" {
  content_type = "snippets"
  datastore_id = "local"
  node_name    = var.pve_node

  source_raw {
    data = <<-EOF
    #cloud-config
    hostname: ${var.name}
    timezone: Europe/Copenhagen

    disable_root: false
    users:
      - default
      - name: ${var.user_name}
        groups:
          - sudo
        shell: /bin/bash
        ssh_authorized_keys:
          - ${trimspace(data.local_file.ssh_public_key.content)}
        sudo: ALL=(ALL) NOPASSWD:ALL
        lock_passwd: false
    package_update: true
    packages:
      - qemu-guest-agent
      - net-tools
      - curl
      - gnupg
      - apt-transport-https
      - ca-certificates
%{for pkg in var.additional_packages~}
      - ${pkg}
%{endfor~}
    runcmd:
      - systemctl enable qemu-guest-agent
      - systemctl start qemu-guest-agent
      - echo "done" > /tmp/cloud-config.done
      - apt-get update
      - apt-get full-upgrade -y
      - curl -fsSL https://download.docker.com/linux/ubuntu/gpg | gpg --dearmor -o /usr/share/keyrings/docker-archive-keyring.gpg
      - echo "deb [arch=$(dpkg --print-architecture) signed-by=/usr/share/keyrings/docker-archive-keyring.gpg] https://download.docker.com/linux/ubuntu $(lsb_release -cs) stable" | tee /etc/apt/sources.list.d/docker.list > /dev/null
      - apt-get update
%{if var.additional_runcmd != ""~}
%{for cmd in split("\n", var.additional_runcmd)~}
%{if cmd != ""~}
      - ${cmd}
%{endif~}
%{endfor~}
%{endif~}
    EOF

    file_name = "${var.name}-cloudinit-config.yaml"
  }
}

# Create vm
resource "proxmox_virtual_environment_vm" "vm" {
  name      = var.name
  node_name = var.pve_node

  agent {
    enabled = true
  }

  cpu {
    cores = var.cpu
  }

  memory {
    dedicated = var.memory
  }

  disk {
    datastore_id = "local-lvm"
    import_from  = var.cloud_iso_name
    interface    = "virtio0"
    iothread     = true
    discard      = "on"
    size         = var.disk_size
  }

  initialization {
    ip_config {
      ipv4 {
        address = "${var.ip}/${var.subnet_mask}"
        gateway = var.default_gateway
      }
    }

    user_data_file_id = proxmox_virtual_environment_file.user_data_cloud_config.id
  }

  network_device {
    bridge = "vmbr0"
  }
}
