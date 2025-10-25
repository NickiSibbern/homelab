# Homelab cluster

## Requirements
- proxmox instance
- opentofu
- direnv
- az cli
- taloscli
- kubectl

## Prepare opentofu

1. make sure you are authorized with the azure cli, and set the `ARM_SUBSCRIPTION_ID` and `ARM_TENANT_ID` as variables in `.envc.rc` file
2. go to [./infrastructure/bootstrap/state/](./infrastructure/bootstrap/state/) and do

```sh
tofu init -var-file ../../../kube/dev.tfvars &&
tofu apply -var-file ../../../kube/dev.tfvars
```

3. go to [./infrastructure/bootstrap/keyvault/](./infrastructure/bootstrap/keyvault/) and create a `secrets.json` which is a json of all the secrets that should be injected into the keyvault

```json
{
  "cloudflare-api-key": "",
  "email": "",
  "proxmox-api-key": "",
  "proxmox-password": "",
  "proxmox-username": "",
  "argo-github-token": "",
  "argocd-password": ""
}
```

then execute:

```sh
tofu init -var-file ../../../kube/dev.tfvars &&
tofu apply -var-file ../../../kube/dev.tfvar
```

## Setup cluster

to to [./infrastructure/cluster](./infrastructure/cluster/) and do:

```sh
tofu init -var-file=../../../kube/dev.tfvars && opentofu apply -var-file=../../../kube/dev.tfvars
```

this will setup the cluster as specified in the kubernetes_config variable
It will also copy the kube config into your `~/.kube/` folder and talos config to your `~/.talos/`

## Cluster configuration

all cluster configuration is done in the [./kube/configuration](./kube/configuration/) managed by terraform

> use the vars file in the kube folder
