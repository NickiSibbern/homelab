# general
domain = "nickisibbern.dk" # base domain for services
default_gateway = "10.0.0.1" # default gateway for vms
subnet_mask     = "22" # subnet mask in CIDR notation of the subnet vms are deployed in, this is configured in my router

# proxmox / ansible
proxmox_endpoint = "https://10.0.1.1:8006" # proxmox api endpoint
proxmox_nodes    = ["lab01", "lab02"] # list of proxmox nodes to use for vm deployment
vm_username      = "homelab" # user for ansible and ssh
ssh_key_location = "~/.ssh/homelab.pub" # path to public ssh key for vm access

# azure
azure_location            = "westeurope" # Azure region to deploy resources in
azure_resource_group_name = "homelab" # The name of the resource group in which to create the state and keyvault
azure_storage_account_name = "sahomelabnickisibbern" # The name of the Azure Storage Account to use for the Terraform state.
azure_keyvault_name       = "kv-homelab-nickisibbern" # The name of the Azure Key Vault to retrieve secrets from.

# github
github_organization = "nickisibbern" # GitHub organization for code is located, used by argocd etc.

# cilium
cilium_cidr_block = "10.0.2.0/24" # CIDR block for Cilium LoadBalancerIPPool, this is used for services of type LoadBalancer where an external IP is needed

# argocd
argo_state_repo = "https://github.com/nickisibbern/homelab-state" # should be in the same org as github_organization, access is only granted to that org via credentialTemplates in argocd-values.yaml


# k8s Cluster, setup the cluster nodes here, make sure the ips are updated in the ansible inventory as well, the ips are staticly assigned.
kubernetes_cluster_nodes = {
  "controlplanes" : {
    "control-plane-01" : {
      "ip" : "10.0.1.110",
      "proxmox_node" : "lab01"
    }
  },
  "workernodes" : {
    "worker-node-01" : {
      "ip" : "10.0.1.120",
      "proxmox_node" : "lab01"
    },
    "worker-node-02" : {
      "ip" : "10.0.1.121",
      "proxmox_node" : "lab02"
    }
  }
}

kubernetes_hostname = "kube.nickisibbern.dk" # should be subdomain of domain value
