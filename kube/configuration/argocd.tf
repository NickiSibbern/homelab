locals {
  helmvalues = templatefile("${path.module}/manifest/argocd/argocd-values.yaml", {
    github_token               = data.azurerm_key_vault_secret.argo_github_token.value
    argocd_admin_password_hash = data.azurerm_key_vault_secret.argocd_password.value
    host_url                  = "argocd.${var.domain}"
    github_organization       = var.kubernetes_config.argo.github_organization
  })
}

resource "kubernetes_namespace" "argo" {
  metadata {
    name = "argocd"
  }
}

resource "helm_release" "argocd" {

  name             = "argocd"
  repository       = "https://argoproj.github.io/argo-helm"
  chart            = "argo-cd"
  namespace        = kubernetes_namespace.argo.metadata[0].name
  create_namespace = false
  version          = "8.6.1"
  cleanup_on_fail  = true
  wait             = true
  wait_for_jobs    = true
  timeout          = 200
  values           = [local.helmvalues]
}

#app of apps: https://argo-cd.readthedocs.io/en/stable/operator-manual/declarative-setup/#app-of-apps
resource "kubectl_manifest" "app-root" {
  depends_on = [ helm_release.argocd ]

  yaml_body = templatefile("${path.module}/manifest/argocd/app-root.yaml", {
    argo_state_repo = var.kubernetes_config.argo.state_repo
  })
}
