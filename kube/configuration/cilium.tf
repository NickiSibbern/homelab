resource "kubectl_manifest" "ciliumL2AnnouncementPolicy" {
  yaml_body = templatefile("${path.module}/manifest/cilium/cilium-l2-announcement.yaml", {})
}

resource "kubectl_manifest" "ciliumLoadBalancerIPPool" {
  yaml_body = templatefile("${path.module}/manifest/cilium/cilium-lb-pool.yaml", {
    cidr_block = var.kubernetes_config.cilium.cidr_block
  })
}

resource "kubectl_manifest" "ciliumGatewayClass" {
  yaml_body = templatefile("${path.module}/manifest/cilium/cilium-gatewayclass.yaml", {})
}
