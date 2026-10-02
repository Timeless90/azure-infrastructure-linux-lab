#!/usr/bin/env bash
# Source only this reviewed repository file, never a user's existing secret files.
set -euo pipefail
ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
get() { python3 "$ROOT/scripts/config.py" get "$1"; }
load_lab() {
  python3 "$ROOT/scripts/config.py" >/dev/null
  SUBSCRIPTION=$(get subscriptionId); TENANT=$(get tenantId); ACCOUNT=$(get accountName)
  RG=$(get resourceGroup); LAB_ID=$(get labId); LOCATION=$(get location)
  ADMIN=$(get adminUsername); SERVER_IP=$(get serverIp); CLIENT_IP=$(get clientIp)
  export SUBSCRIPTION TENANT ACCOUNT RG LAB_ID LOCATION ADMIN SERVER_IP CLIENT_IP
  command -v az >/dev/null || { echo 'Azure CLI fehlt; docs/getting-started.md lesen' >&2; exit 1; }
  local active tenant user
  active=$(az account show --query id -o tsv)
  tenant=$(az account show --query tenantId -o tsv)
  user=$(az account show --query user.name -o tsv)
  printf 'Konto: %s\nTenant: %s\nSubscription: %s\nResource Group: %s\n' "$user" "$tenant" "$active" "$RG"
  [[ "$active" == "$SUBSCRIPTION" && "$tenant" == "$TENANT" && "$user" == "$ACCOUNT" ]] || {
    echo 'Abbruch: aktive Azure-Identität entspricht nicht config/lab.json' >&2; exit 1;
  }
}
guard_rg() {
  local tag
  tag=$(az group show -n "$RG" --subscription "$SUBSCRIPTION" --query tags.courseLabId -o tsv)
  [[ "$tag" == "$LAB_ID" ]] || { echo 'Abbruch: Lab-Tag fehlt oder stimmt nicht' >&2; exit 1; }
}
confirm() {
  local entered
  printf 'Zur Bestätigung exakt eingeben: %s\n> ' "$1"
  read -r entered
  [[ "$entered" == "$1" ]] || { echo 'Abgebrochen'; exit 1; }
}
