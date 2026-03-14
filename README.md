# Homelab Cluster

## Requirements
- proxmox instance
- opentofu
- direnv
- az cli
- taloscli
- kubectl

## Prepare OpenTofu

1. Make sure you are authorized with the Azure CLI, and set `ARM_SUBSCRIPTION_ID` and `ARM_TENANT_ID` in `.envc.rc` or as env vars.
2. Go to [./infrastructure/bootstrap/state/](./infrastructure/bootstrap/state/) and run:

```sh
tofu init -var-file ../../../kube/dev.tfvars &&
tofu apply -var-file ../../../kube/dev.tfvars
```

3. Go to [./infrastructure/bootstrap/keyvault/](./infrastructure/bootstrap/keyvault/) and create a `secrets.json` file containing the secrets to inject into Key Vault.

```json
{
  "cloudflare-api-key": "",
  "email": "",
  "proxmox-api-key": "",
  "proxmox-password": "",
  "proxmox-username": "",
  "flux-github-token": ""
}
```

Then run:

```sh
tofu init -var-file ../../../kube/dev.tfvars &&
tofu apply -var-file ../../../kube/dev.tfvars
```

## Setup cluster

Go to [./infrastructure/cluster](./infrastructure/cluster/) and run:

```sh
tofu init -var-file=../../../kube/dev.tfvars && tofu apply -var-file=../../../kube/dev.tfvars
```

This sets up the cluster as specified in `kubernetes_config`.
It also copies the kubeconfig into `~/.kube/` and the Talos config into `~/.talos/`.

## Cluster configuration

All cluster configuration is managed by Terraform in [./kube/configuration](./kube/configuration/).

> Use the vars file in the `kube` folder.
