# general
domain          = "nickisibbern.dk" # base domain for services
default_gateway = "10.0.0.1"
subnet_mask     = "22"

# proxmox / ansible
proxmox_config = {
  "endpoint" : "https://10.0.1.1:8006",
  "nodes" : ["lab01", "lab02"]
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

  cilium = {
    cidr_block = "10.0.2.0/24" # CIDR block for Cilium LoadBalancerIPPool, this is used for services of type LoadBalancer where an external IP is needed
  }

  argo = {
    github_organization = "nickisibbern" # GitHub organization for ArgoCD to sync from
    state_repo = "https://github.com/nickisibbern/homelab-state" # should be in the same org as github_organization, access is only granted to that org via credentialTemplates in argocd-values.yaml
  }

  talos = {
    version = "v1.11.3" # Talos version to use for the kubernetes cluster
  }

  nodes = {
    controlplane1 = {
      name      = "control-plane-01"
      ip        = "10.0.1.110"
      role      = "controlplane"
      pve_node  = "lab01"
      cpu       = 2
      memory    = 8192
      disk_size = 20
    }
    worker1 = {
      name      = "worker-node-01"
      ip        = "10.0.1.120"
      role      = "worker"
      pve_node  = "lab01"
      cpu       = 2
      memory    = 15000
      disk_size = 50
    }
    worker2 = {
      name = "worker-node-02"
      ip       = "10.0.1.121"
      role     = "worker"
      pve_node = "lab02"
      cpu     = 2
      memory  = 15000
      disk_size = 50
    }
    worker3 = {
      name = "worker-node-03"
      ip       = "10.0.1.122"
      role     = "worker"
      pve_node = "lab02"
      cpu     = 2
      memory  = 15000
      disk_size = 50
    }
  }
}
