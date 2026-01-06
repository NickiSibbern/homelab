output "ipv4" {
  value = flatten([
    for iface in proxmox_virtual_environment_vm.vm.ipv4_addresses : [
      for ip in iface : ip if ip != "127.0.0.1"
    ]
  ])[0]
}
