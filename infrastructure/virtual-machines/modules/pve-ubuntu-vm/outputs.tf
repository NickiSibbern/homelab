output "vm_id" {
  value = proxmox_virtual_environment_vm.vm.id
}

output "vm_ip" {
  value = proxmox_virtual_environment_vm.vm.ipv4_addresses[0]
}

output "vm_name" {
  value = proxmox_virtual_environment_vm.vm.name
}
