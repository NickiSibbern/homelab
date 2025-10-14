resource "kubectl_manifest" "cluster_gateway" {
  depends_on = [ helm_release.cilium, helm_release.cert-manager, kubectl_manifest.issuer ]

  yaml_body = templatefile("./components/cluster-gateway/cluster-gateway.yaml", {
    domain = var.domain
  })
}

resource "kubectl_manifest" "wildcard_certificate" {
  depends_on = [ helm_release.cilium, helm_release.cert-manager, kubectl_manifest.issuer ]

  yaml_body = templatefile("./components/cluster-gateway/wildcard-certificate.yaml", {
    domain = var.domain
  })
}
