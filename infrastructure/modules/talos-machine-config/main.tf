data "talos_machine_configuration" "this" {
  cluster_name     = var.cluster_name
  machine_type     = var.machine_type
  cluster_endpoint = var.cluster_endpoint
  machine_secrets  = var.machine_secrets.machine_secrets
}

resource "talos_machine_configuration_apply" "this" {
  depends_on = [
    data.talos_machine_configuration.this
  ]

  client_configuration        = var.machine_secrets.client_configuration
  machine_configuration_input = data.talos_machine_configuration.this.machine_configuration
  node                        = var.machine_ip

  config_patches              = var.config_patches
}
