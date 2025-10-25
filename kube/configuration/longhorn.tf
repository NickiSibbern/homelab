locals {
  longhorn_values = templatefile("${path.module}/manifest/longhorn/longhorn-values.yaml", {
    cluster_endpoint = var.kubernetes_config.endpoint
  })
}

resource "kubernetes_namespace" "longhorn_system" {
  metadata {
    name = "longhorn-system"
    labels = {
      "pod-security.kubernetes.io/enforce"         = "privileged"
      "pod-security.kubernetes.io/enforce-version" = "latest"
      "pod-security.kubernetes.io/audit"           = "privileged"
      "pod-security.kubernetes.io/audit-version"   = "latest"
      "pod-security.kubernetes.io/warn"            = "privileged"
      "pod-security.kubernetes.io/warn-version"    = "latest"
    }
  }
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
}

resource "kubectl_manifest" "longhorn_http_route" {
  depends_on = [helm_release.longhorn]

  yaml_body = templatefile("${path.module}/manifest/longhorn/longhorn-http-route.yaml", {})
}
