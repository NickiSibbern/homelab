#!/usr/bin/env sh
set -eu

KUBECONFIG_OUT="${KUBECONFIG_OUT:-$HOME/.kube/config}"
TALOSCONFIG_OUT="${TALOSCONFIG_OUT:-$HOME/.talos/config}"

KUBE_DIR=$(dirname "$KUBECONFIG_OUT")
TALOS_DIR=$(dirname "$TALOSCONFIG_OUT")
mkdir -p "$KUBE_DIR" "$TALOS_DIR"

SCRIPT_DIR=$(CDPATH= cd -- "$(dirname -- "$0")" && pwd)
STATE_DIR="$SCRIPT_DIR/infrastructure/cluster"

tofu -chdir="$STATE_DIR" init
STATE_JSON=$(tofu -chdir="$STATE_DIR" state pull)

KUBECONFIG_CONTENT=$(printf "%s" "$STATE_JSON" | jq -r '
  .resources[]
  | select(.mode == "managed" and .type == "talos_cluster_kubeconfig" and .name == "this")
  | .instances[0].attributes.kubeconfig_raw // empty
')

TALOSCONFIG_CONTENT=$(printf "%s" "$STATE_JSON" | jq -r '
  .resources[]
  | select(.mode == "data" and .type == "talos_client_configuration" and .name == "this")
  | .instances[0].attributes.talos_config // empty
')

if [ -z "$KUBECONFIG_CONTENT" ]; then
  echo "error: kubeconfig not found in state (talos_cluster_kubeconfig.this.kubeconfig_raw)" >&2
  exit 1
fi

if [ -z "$TALOSCONFIG_CONTENT" ]; then
  echo "error: talos config not found in state (data.talos_client_configuration.this.talos_config)" >&2
  exit 1
fi

printf "%s\n" "$KUBECONFIG_CONTENT" > "$KUBECONFIG_OUT"
printf "%s\n" "$TALOSCONFIG_CONTENT" > "$TALOSCONFIG_OUT"

chmod 600 "$KUBECONFIG_OUT" "$TALOSCONFIG_OUT" 2>/dev/null || true

echo "wrote kubeconfig to $KUBECONFIG_OUT"
echo "wrote talos config to $TALOSCONFIG_OUT"
