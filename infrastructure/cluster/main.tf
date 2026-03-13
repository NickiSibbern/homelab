locals {
  cilium_crds = [
    "https://raw.githubusercontent.com/kubernetes-sigs/gateway-api/v1.2.0/config/crd/standard/gateway.networking.k8s.io_gatewayclasses.yaml",
    "https://raw.githubusercontent.com/kubernetes-sigs/gateway-api/v1.2.0/config/crd/standard/gateway.networking.k8s.io_gateways.yaml",
    "https://raw.githubusercontent.com/kubernetes-sigs/gateway-api/v1.2.0/config/crd/standard/gateway.networking.k8s.io_httproutes.yaml",
    "https://raw.githubusercontent.com/kubernetes-sigs/gateway-api/v1.2.0/config/crd/standard/gateway.networking.k8s.io_referencegrants.yaml",
    "https://raw.githubusercontent.com/kubernetes-sigs/gateway-api/v1.2.0/config/crd/standard/gateway.networking.k8s.io_grpcroutes.yaml",
    "https://raw.githubusercontent.com/kubernetes-sigs/gateway-api/v1.2.0/config/crd/experimental/gateway.networking.k8s.io_tlsroutes.yaml"
  ]
}

data "http" "crd_yaml" {
  for_each = toset(local.cilium_crds)
  url      = each.value
}

locals {
  cilium_crd_manifest = join("\n---\n", [
    for url in local.cilium_crds : data.http.crd_yaml[url].response_body
  ])
}

resource "talos_image_factory_schematic" "this" {
  schematic = file("${path.module}/talos/schemas/talos-schema.yaml")
}

resource "proxmox_virtual_environment_download_file" "talos_nocloud_image" {
  for_each = toset(var.proxmox_config.nodes)

  content_type = "iso"
  datastore_id = "local"
  node_name    = each.key

  file_name = "talos-${var.kubernetes_config.talos.version}-nocloud-amd64.iso"
  url       = "https://factory.talos.dev/image/${talos_image_factory_schematic.this.id}/${var.kubernetes_config.talos.version}/nocloud-amd64.iso"
  overwrite = false
}

module "control-planes" {
  source = "../modules/pve-vm"

  for_each = { for key, value in var.kubernetes_config.nodes : key => value if value.role == "controlplane" }

  name            = each.value.name
  pve_node        = each.value.pve_node
  ip_address      = each.value.ip_address
  default_gateway = var.default_gateway
  subnet_mask     = var.subnet_mask
  cpu             = each.value.cpu
  memory          = each.value.memory
  disk_size       = each.value.disk_size
  cloud_iso_name  = proxmox_virtual_environment_download_file.talos_nocloud_image[each.value.pve_node].id
  tags            = [each.value.role, "terraform", "kubernetes", "talos"]
}

module "workers" {
  source = "../modules/pve-vm"

  for_each = { for key, value in var.kubernetes_config.nodes : key => value if value.role == "worker" }

  name            = each.value.name
  pve_node        = each.value.pve_node
  ip_address      = each.value.ip_address
  default_gateway = var.default_gateway
  subnet_mask     = var.subnet_mask
  cpu             = each.value.cpu
  memory          = each.value.memory
  disk_size       = each.value.disk_size
  cloud_iso_name  = proxmox_virtual_environment_download_file.talos_nocloud_image[each.value.pve_node].id
  tags            = [each.value.role, "terraform", "kubernetes", "talos"]
}

resource "talos_machine_secrets" "this" {}

locals {
  bootstrap_controleplane_ip = one([
    for key, value in module.control-planes : value.ipv4
  ])

  cluster_endpoint = "https://${local.bootstrap_controleplane_ip}:6443"

  cilium_values = templatefile("${path.module}/manifests/cilium/cilium-values.yaml", {
    cluster_endpoint = local.bootstrap_controleplane_ip
  })
}

module "control-planes-talos-config" {
  depends_on = [module.control-planes]
  for_each   = { for key, value in var.kubernetes_config.nodes : key => value if value.role == "controlplane" }

  source = "../modules/talos-machine-config"

  cluster_name     = var.kubernetes_config.cluster_name
  machine_type     = each.value.role
  cluster_endpoint = local.cluster_endpoint
  machine_ip       = module.control-planes[each.key].ipv4
  machine_secrets  = talos_machine_secrets.this
  config_patches = [
    yamlencode({
      machine = {
        network = {
          interfaces = [
            {
              interface = each.value.network_interface
              dhcp      = false
              addresses = ["${each.value.ip_address}/${var.subnet_mask}"]
              routes = [
                {
                  network = "0.0.0.0/0"
                  gateway = var.default_gateway
                }
              ]
            }
          ]
        }
      }
    }),
    templatefile("${path.module}/talos/machineConfigs/common.yaml", {
    }),
    templatefile("${path.module}/talos/machineConfigs/control-plane.yaml", {
      custom_install_image = "factory.talos.dev/installer/${talos_image_factory_schematic.this.id}:${var.kubernetes_config.talos.version}"
    }),
    yamlencode({
      cluster = {
        inlineManifests = [
          {
            name = "cilium-crds"
            contents = local.cilium_crd_manifest
          }
        ]
      }
    })
  ]
}

module "worker-nodes-talos-config" {
  depends_on = [module.workers]
  for_each   = { for key, value in var.kubernetes_config.nodes : key => value if value.role == "worker" }

  source = "../modules/talos-machine-config"

  cluster_name     = var.kubernetes_config.cluster_name
  machine_type     = each.value.role
  cluster_endpoint = local.cluster_endpoint
  machine_ip       = module.workers[each.key].ipv4
  machine_secrets  = talos_machine_secrets.this
  config_patches = [
    yamlencode({
      machine = {
        network = {
          interfaces = [
            {
              interface = each.value.network_interface
              dhcp      = false
              addresses = ["${each.value.ip_address}/${var.subnet_mask}"]
              routes = [
                {
                  network = "0.0.0.0/0"
                  gateway = var.default_gateway
                }
              ]
            }
          ]
        }
      }
    }),
    templatefile("${path.module}/talos/machineConfigs/common.yaml", {
    }),
    templatefile("${path.module}/talos/machineConfigs/worker-node.yaml", {
      custom_install_image = "factory.talos.dev/installer/${talos_image_factory_schematic.this.id}:${var.kubernetes_config.talos.version}"
    })
  ]
}



resource "time_sleep" "wait_for_vm" {
  depends_on = [module.control-planes, module.control-planes-talos-config]
  create_duration = "120s"
}

resource "talos_machine_bootstrap" "bootstrap" {
  depends_on = [module.control-planes-talos-config, time_sleep.wait_for_vm]

  client_configuration = talos_machine_secrets.this.client_configuration
  node                 = local.bootstrap_controleplane_ip
}

resource "talos_cluster_kubeconfig" "this" {
  depends_on = [
    talos_machine_bootstrap.bootstrap
  ]
  client_configuration = talos_machine_secrets.this.client_configuration
  node                 = local.bootstrap_controleplane_ip
  endpoint             = local.bootstrap_controleplane_ip
}

resource "local_file" "kubeconfig" {
  content  = talos_cluster_kubeconfig.this.kubeconfig_raw
  filename = pathexpand("~/.kube/config")

}

data "talos_client_configuration" "this" {
  cluster_name         = var.kubernetes_config.cluster_name
  client_configuration = talos_machine_secrets.this.client_configuration
  endpoints            = [local.bootstrap_controleplane_ip]
  nodes                = [local.bootstrap_controleplane_ip]
}

resource "local_file" "talos_client_configuration" {
  content  = data.talos_client_configuration.this.talos_config
  filename = pathexpand("~/.talos/config")
}

resource "time_sleep" "wait_for_cluster" {
  depends_on = [talos_machine_bootstrap.bootstrap, talos_cluster_kubeconfig.this]
  create_duration = "120s"
}

resource "helm_release" "cilium" {
  depends_on = [time_sleep.wait_for_cluster]

  name             = "cilium"
  repository       = "https://helm.cilium.io/"
  chart            = "cilium"
  namespace        = "kube-system"
  version          = var.kubernetes_config.cilium.version
  cleanup_on_fail  = true
  wait             = true
  wait_for_jobs    = true
  timeout          = 200
  values           = [local.cilium_values]
}
