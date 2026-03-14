# general
domain          = "nickisibbern.dk" # base domain for services
default_gateway = "10.0.0.1"
subnet_mask     = "22"

# proxmox / ansible
proxmox_config = {
  "endpoint" : "https://10.0.1.1:8006",
  "nodes" : [ "lab01" ]
}

# azure
azure_config = {
  "location" : "westeurope",
  "resource_group_name" : "homelab",
  "storage_account_name" : "sahomelabnickisibbern",
  "keyvault_name" : "kv-homelab-nickisibbern"
}

kubernetes_config = {
  cluster_name = "homelab" # name of the kubernetes cluster
  hostname     = "kube.nickisibbern.dk"
  endpoint     = "https://kube.nickisibbern.dk:6443" # domain for the kubernetes api endpoint

  certManager = {
    version = "1.20.0"
  }

  cilium = {
    version = "1.19.1"
    cidr_block = "10.0.2.0/24" # CIDR block for Cilium LoadBalancerIPPool, this is used for services of type LoadBalancer where an external IP is needed
  }

  flux = {
    state_repo = "https://github.com/nickisibbern/homelab-state"
    version    = "v2.8.2" # https://github.com/fluxcd/flux2/releases
  }

  talos = {
    version = "v1.12.5" # Talos version to use for the kubernetes cluster
  }

  nodes = {
    controlplane1 = {
      name      = "control-plane-01"
      role      = "controlplane"
      pve_node  = "lab01"
      ip_address = "10.0.1.110"
      network_interface = "ens18"
      cpu       = 2
      memory    = 6144
      disk_size = 20
    }
    worker1 = {
      name      = "worker-node-01"
      role      = "worker"
      pve_node  = "lab01"
      ip_address = "10.0.1.120"
      network_interface = "ens18"
      cpu       = 6
      memory    = 12288
      disk_size = 150
    }
    worker2 = {
      name = "worker-node-02"
      role     = "worker"
      pve_node = "lab01"
      ip_address = "10.0.1.121"
      network_interface = "ens18"
      cpu     = 6
      memory  = 12288
      disk_size = 150
    }
  }
}
