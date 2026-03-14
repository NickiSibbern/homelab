resource "flux_bootstrap_git" "this" {
  path               = "clusters/homelab"
  version            = var.kubernetes_config.flux.version
  embedded_manifests = true
}
