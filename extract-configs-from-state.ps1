Set-StrictMode -Version Latest
$ErrorActionPreference = 'Stop'

$kubeconfigOut = if ($env:KUBECONFIG_OUT) { $env:KUBECONFIG_OUT } else { Join-Path $HOME '.kube/config' }
$talosconfigOut = if ($env:TALOSCONFIG_OUT) { $env:TALOSCONFIG_OUT } else { Join-Path $HOME '.talos/config' }

$kubeDir = Split-Path -Path $kubeconfigOut -Parent
$talosDir = Split-Path -Path $talosconfigOut -Parent

New-Item -ItemType Directory -Path $kubeDir -Force | Out-Null
New-Item -ItemType Directory -Path $talosDir -Force | Out-Null

$stateDir = Join-Path $PSScriptRoot 'infrastructure/cluster'
tofu "-chdir=$stateDir" init
$state = tofu "-chdir=$stateDir" show -json | ConvertFrom-Json
$resources = $state.values.root_module.resources

$kubeconfigContent = $resources |
  Where-Object { $_.mode -eq 'managed' -and $_.type -eq 'talos_cluster_kubeconfig' -and $_.name -eq 'this' } |
  Select-Object -First 1 |
  Select-Object -ExpandProperty values |
  Select-Object -ExpandProperty kubeconfig_raw

$talosconfigContent = $resources |
  Where-Object { $_.mode -eq 'data' -and $_.type -eq 'talos_client_configuration' -and $_.name -eq 'this' } |
  Select-Object -First 1 |
  Select-Object -ExpandProperty values |
  Select-Object -ExpandProperty talos_config

Set-Content -Path $kubeconfigOut -Value $kubeconfigContent
Set-Content -Path $talosconfigOut -Value $talosconfigContent

Write-Host "wrote kubeconfig to $kubeconfigOut"
Write-Host "wrote talos config to $talosconfigOut"
