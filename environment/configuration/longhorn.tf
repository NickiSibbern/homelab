locals {
  longhorn_values = templatefile("./components/longhorn/longhorn-values.yaml", {
    kubernetes_hostname = var.kubernetes_hostname
  })
}

resource "helm_release" "longhorn" {
  name             = "longhorn"
  repository       = "https://charts.longhorn.io"
  chart            = "longhorn"
  namespace        = "longhorn-system"
  version          = "1.10.0"
  cleanup_on_fail  = true
  wait             = true
  wait_for_jobs    = true
  timeout          = 200
  values           = [local.longhorn_values]
  create_namespace = true
}

resource "kubectl_manifest" "longhorn_http_route" {
  depends_on = [helm_release.longhorn]

  yaml_body = templatefile("./components/longhorn/longhorn-http-route.yaml", {})
}
