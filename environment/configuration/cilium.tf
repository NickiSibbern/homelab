
locals {
  customcrds = [
    "https://raw.githubusercontent.com/kubernetes-sigs/gateway-api/v1.2.0/config/crd/standard/gateway.networking.k8s.io_gatewayclasses.yaml",
    "https://raw.githubusercontent.com/kubernetes-sigs/gateway-api/v1.2.0/config/crd/standard/gateway.networking.k8s.io_gateways.yaml",
    "https://raw.githubusercontent.com/kubernetes-sigs/gateway-api/v1.2.0/config/crd/standard/gateway.networking.k8s.io_httproutes.yaml",
    "https://raw.githubusercontent.com/kubernetes-sigs/gateway-api/v1.2.0/config/crd/standard/gateway.networking.k8s.io_referencegrants.yaml",
    "https://raw.githubusercontent.com/kubernetes-sigs/gateway-api/v1.2.0/config/crd/standard/gateway.networking.k8s.io_grpcroutes.yaml",
    "https://raw.githubusercontent.com/kubernetes-sigs/gateway-api/v1.2.0/config/crd/experimental/gateway.networking.k8s.io_tlsroutes.yaml"
  ]

  cidr_block = var.cilium_cidr_block

  cilium_values = templatefile("./components/cilium/cilium-values.yaml", {
    kubernetes_hostname = var.kubernetes_hostname
  })
}

data "http" "crd_yaml" {
  for_each = toset(local.customcrds)
  url      = each.value
}

resource "kubectl_manifest" "cilium_custom_resources" {
  for_each = toset(local.customcrds)

  yaml_body = data.http.crd_yaml[each.value].response_body
}

resource "helm_release" "cilium" {
  depends_on = [kubectl_manifest.cilium_custom_resources]

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

resource "kubectl_manifest" "CiliumL2AnnouncementPolicy" {
  depends_on = [helm_release.cilium]

  yaml_body = templatefile("./components/cilium/cilium-l2-announcement.yaml", {})
}

resource "kubectl_manifest" "CiliumLoadBalancerIPPool" {
  depends_on = [ helm_release.cilium ]

  yaml_body = templatefile("./components/cilium/cilium-lb-pool.yaml", {
    cidr_block = local.cidr_block
  })
}
