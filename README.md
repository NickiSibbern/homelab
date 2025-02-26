# Homelab cluster

## Requirements
- ubuntu 24.04 servers with ssh access already setup
- ansible
- terraform
- direnv
- az cli

## Prepare terraform

1) make sure you are authorized with the azure cli, and set the `ARM_SUBSCRIPTION_ID` and `ARM_TENANT_ID` as variables in `.envc.rc` file
2) go to [./infrastructure/init/state/](./infrastructure/init/state/) and do
``` sh
terraform init && terraform apply
```


3) go to [./infrastructure/init/keyvault/](./infrastructure/init/keyvault/) and create a `secrets.json` which is a json of all the secrets that should be injected into the keyvault
``` json
{
    "proxmox-username": "",
    "proxmox-password": "",
    "proxmox-api-key": "",
}
```
then execute:
 ``` sh
terraform init && terraform apply
```
in order to initialize the keyvault with all the keys from secret.json

## Setup proxmox instances

1) go to [./infrastructure/proxmox/](./infrastructure/virtual-machines/) and execute:
``` sh
terraform init && terraform apply -var-file=dev.tfvars
```
this should setup all the proxmox virual machines configured for a cluster

## Install kubernetes
1) go to [./infrastructure/kube/](./infrastructure/kube/) and execute
``` sh
ansible-playbook  -i ./inventory/host.yaml ./playbooks/setup-cluster.yaml
```
this will setup the cluster as specified in the playbook with cilium.
It will also copy the kube config into your `~/.kube` folder


## Cluster configuration
all cluster configuration is done in the [./environment/](./environment/) via primarily terraform
