# Downloads the various iso images needed for the vms,
# keeping it separate so that each vm will not control the state of these resources triggering deletion / creation based on their own lifecycle

variable "ubuntu_version_name" {
  description = "Ubuntu version name to download (e.g., 'noble' for 23.04)"
  type        = string
  default     = "noble"
}

resource "proxmox_virtual_environment_download_file" "ubuntu_cloud_image" {
  for_each  = toset(var.proxmox_nodes)
  node_name = each.key

  content_type = "import"
  datastore_id = "local"
  url          = "https://cloud-images.ubuntu.com/${var.ubuntu_version_name}/current/${var.ubuntu_version_name}-server-cloudimg-amd64.img"
  file_name    = "${var.ubuntu_version_name}-server-cloudimg-amd64.qcow2"
}

# Kubernetes
locals {
  base_runcmd = <<-EOF
swapoff -a
sed -i '/swap/d' /etc/fstab
echo 'net.bridge.bridge-nf-call-iptables = 1' | tee /etc/sysctl.d/k8s.conf
echo 'net.ipv4.ip_forward = 1' | tee -a /etc/sysctl.d/k8s.conf
echo 'net.bridge.bridge-nf-call-ip6tables = 1' | tee -a /etc/sysctl.d/k8s.conf
sysctl --system
echo -e 'overlay\nbr_netfilter' | tee /etc/modules-load.d/k8s.conf
apt-get install -y docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin
rm /etc/containerd/config.toml
containerd config default | tee /etc/containerd/config.toml
sed -i 's/SystemdCgroup = false/SystemdCgroup = true/g' /etc/containerd/config.toml
sed -i 's/#DNSStubListener=yes/DNSStubListener=no/' /etc/systemd/resolved.conf
systemctl restart systemd-resolved
systemctl restart containerd
curl -fsSL https://pkgs.k8s.io/core:/stable:/v1.33/deb/Release.key | gpg --dearmor -o /etc/apt/keyrings/kubernetes-apt-keyring.gpg
echo 'deb [signed-by=/etc/apt/keyrings/kubernetes-apt-keyring.gpg] https://pkgs.k8s.io/core:/stable:/v1.33/deb/ /' | tee /etc/apt/sources.list.d/kubernetes.list
apt-get update
apt-get install -y kubelet kubeadm kubectl
apt-mark hold kubelet kubeadm kubectl
systemctl enable --now kubelet
EOF
}

module "control-planes" {
  source = "./modules/pve-ubuntu-vm"

  for_each = var.kubernetes_cluster_nodes["controlplanes"]

  name                 = each.key
  pve_node             = each.value.proxmox_node
  ssh_key_location     = pathexpand(var.ssh_key_location)
  cpu                  = 4
  memory               = 6144
  disk_size            = 100
  ip                   = each.value.ip
  default_gateway      = var.default_gateway
  subnet_mask          = var.subnet_mask
  cloud_iso_name       = proxmox_virtual_environment_download_file.ubuntu_cloud_image[each.value.proxmox_node].id
  user_name            = var.vm_username
  proxmox_endpoint     = var.proxmox_endpoint
  proxmox_api_key      = data.azurerm_key_vault_secret.proxmox_api_key.value
  proxmox_ssh_username = data.azurerm_key_vault_secret.proxmox_username.value
  proxmox_ssh_password = data.azurerm_key_vault_secret.proxmox_password.value
  additional_packages  = []
  additional_runcmd    = local.base_runcmd
}

module "worker-nodes" {
  source = "./modules/pve-ubuntu-vm"

  for_each = var.kubernetes_cluster_nodes["workernodes"]

  name                 = each.key
  pve_node             = each.value.proxmox_node
  ssh_key_location     = pathexpand(var.ssh_key_location)
  cpu                  = 4
  memory               = 30000
  disk_size            = 150
  ip                   = each.value.ip
  default_gateway      = var.default_gateway
  subnet_mask          = var.subnet_mask
  cloud_iso_name       = proxmox_virtual_environment_download_file.ubuntu_cloud_image[each.value.proxmox_node].id
  user_name            = var.vm_username
  proxmox_endpoint     = var.proxmox_endpoint
  proxmox_api_key      = data.azurerm_key_vault_secret.proxmox_api_key.value
  proxmox_ssh_username = data.azurerm_key_vault_secret.proxmox_username.value
  proxmox_ssh_password = data.azurerm_key_vault_secret.proxmox_password.value
  additional_packages  = []
  additional_runcmd    = local.base_runcmd
}
