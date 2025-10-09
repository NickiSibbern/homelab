resource "helm_release" "cert-manager" {

  name             = "cert-manager"
  repository       = "https://charts.jetstack.io"
  chart            = "cert-manager"
  namespace        = "cert-manager"
  create_namespace = true
  version          = "1.19.0"
  cleanup_on_fail  = true
  wait             = true
  wait_for_jobs    = true
  timeout          = 200
  values           = [file("./components/cert-manager/cert-manager-values.yaml")]
}

resource "kubernetes_secret" "cloudflare_api_token_secret" {
  metadata {
    name      = "cloudflare-api-token"
    namespace = "cert-manager"
  }

  data = {
    "api-token" = data.azurerm_key_vault_secret.cloudflare_api_key.value
  }
}

resource "kubectl_manifest" "issuer" {
  depends_on = [helm_release.cert-manager]

  yaml_body = templatefile("./components/cert-manager/cert-manager-issuer-manifest.yaml",
  {
    email = data.azurerm_key_vault_secret.email.value
  })
}
