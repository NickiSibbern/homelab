locals {
  bootstrap_controleplane_ip = values({
    for key, value in var.kubernetes_config.nodes : key => value.ip if value.role == "controlplane"
  })[0] # Get IP of the first control plane node

  cilium_crds = [
    "https://raw.githubusercontent.com/kubernetes-sigs/gateway-api/v1.2.0/config/crd/standard/gateway.networking.k8s.io_gatewayclasses.yaml",
    "https://raw.githubusercontent.com/kubernetes-sigs/gateway-api/v1.2.0/config/crd/standard/gateway.networking.k8s.io_gateways.yaml",
    "https://raw.githubusercontent.com/kubernetes-sigs/gateway-api/v1.2.0/config/crd/standard/gateway.networking.k8s.io_httproutes.yaml",
    "https://raw.githubusercontent.com/kubernetes-sigs/gateway-api/v1.2.0/config/crd/standard/gateway.networking.k8s.io_referencegrants.yaml",
    "https://raw.githubusercontent.com/kubernetes-sigs/gateway-api/v1.2.0/config/crd/standard/gateway.networking.k8s.io_grpcroutes.yaml",
    "https://raw.githubusercontent.com/kubernetes-sigs/gateway-api/v1.2.0/config/crd/experimental/gateway.networking.k8s.io_tlsroutes.yaml"
  ]

  cilium_values = templatefile("${path.module}/manifests/cilium/cilium-values.yaml", {
    cluster_endpoint = var.kubernetes_config.hostname
  })
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
  cpu             = each.value.cpu
  memory          = each.value.memory
  disk_size       = each.value.disk_size
  ip              = each.value.ip
  default_gateway = var.default_gateway
  subnet_mask     = var.subnet_mask
  cloud_iso_name  = proxmox_virtual_environment_download_file.talos_nocloud_image[each.value.pve_node].id
  tags            = [each.value.role, "terraform", "kubernetes", "talos"]
}

module "workers" {
  source = "../modules/pve-vm"

  for_each = { for key, value in var.kubernetes_config.nodes : key => value if value.role == "worker" }

  name            = each.value.name
  pve_node        = each.value.pve_node
  cpu             = each.value.cpu
  memory          = each.value.memory
  disk_size       = each.value.disk_size
  ip              = each.value.ip
  default_gateway = var.default_gateway
  subnet_mask     = var.subnet_mask
  cloud_iso_name  = proxmox_virtual_environment_download_file.talos_nocloud_image[each.value.pve_node].id
  tags            = [each.value.role, "terraform", "kubernetes", "talos"]
}

resource "talos_machine_secrets" "this" {}

module "control-planes-talos-config" {
  depends_on = [module.control-planes]
  for_each   = { for key, value in var.kubernetes_config.nodes : key => value if value.role == "controlplane" }

  source = "../modules/talos-machine-config"

  cluster_name     = var.kubernetes_config.cluster_name
  machine_type     = each.value.role
  cluster_endpoint = var.kubernetes_config.endpoint
  machine_ip       = each.value.ip
  machine_secrets  = talos_machine_secrets.this
  config_patches = [
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
  cluster_endpoint = var.kubernetes_config.endpoint
  machine_ip       = each.value.ip
  machine_secrets  = talos_machine_secrets.this
  config_patches = [
    templatefile("${path.module}/talos/machineConfigs/common.yaml", {
    }),
    templatefile("${path.module}/talos/machineConfigs/worker-node.yaml", {
      custom_install_image = "factory.talos.dev/installer/${talos_image_factory_schematic.this.id}:${var.kubernetes_config.talos.version}"
    })
  ]
}

resource "null_resource" "wait_for_vm" {
  depends_on = [module.control-planes, module.control-planes-talos-config]

  provisioner "local-exec" {
    command = "sleep 120" # Wait for 2 minutes to allow the VM to boot up before bootstrapping Talos
  }
}

resource "talos_machine_bootstrap" "bootstrap" {
  depends_on = [module.control-planes-talos-config, null_resource.wait_for_vm]

  client_configuration = talos_machine_secrets.this.client_configuration
  node                 = local.bootstrap_controleplane_ip
}

resource "talos_cluster_kubeconfig" "this" {
  depends_on = [
    talos_machine_bootstrap.bootstrap
  ]
  client_configuration = talos_machine_secrets.this.client_configuration
  node                 = local.bootstrap_controleplane_ip
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

resource "null_resource" "wait_for_cluster" {
  depends_on = [talos_machine_bootstrap.bootstrap, talos_cluster_kubeconfig.this]

  provisioner "local-exec" {
    command = <<-EOT
      # Wait for the Kubernetes API server to be fully ready
      timeout=600
      while [ $timeout -gt 0 ]; do
        if kubectl cluster-info >/dev/null 2>&1 && \
           kubectl get nodes >/dev/null 2>&1 && \
           kubectl get crd >/dev/null 2>&1 && \
           kubectl api-versions | grep -q "apiextensions.k8s.io/v1" >/dev/null 2>&1; then
          echo "Kubernetes API server is fully ready"
          break
        fi
        echo "Waiting for Kubernetes API server to be fully ready... ($timeout seconds remaining)"
        sleep 15
        timeout=$((timeout-15))
      done
      if [ $timeout -le 0 ]; then
        echo "Timeout waiting for Kubernetes API server to be ready"
        exit 1
      fi

      # Additional wait for API server to be stable
      echo "Waiting additional 30 seconds for API server stability..."
      sleep 30
    EOT
  }
}

resource "helm_release" "cilium" {
  depends_on = [null_resource.wait_for_cluster]

  name             = "cilium"
  repository       = "https://helm.cilium.io/"
  chart            = "cilium"
  namespace        = "kube-system"
  version          = "1.18.2"
  cleanup_on_fail  = true
  wait             = true
  wait_for_jobs    = true
  timeout          = 200
  values           = [local.cilium_values]
}
