#!/usr/bin/env bash
set -euo pipefail
# shellcheck source=scripts/common.sh
source "$(dirname "$0")/common.sh"
FAULT=${1:-}; ACTION=${2:-}
if ! { [[ "$FAULT" == nsg || "$FAULT" == route ]] && [[ "$ACTION" == break || "$ACTION" == restore ]]; }; then
  echo 'Aufruf: bash scripts/azure-fault.sh nsg|route break|restore' >&2; exit 1;
fi
load_lab; guard_rg
confirm "$ACTION $FAULT $RG"
if [[ "$FAULT" == nsg ]]; then
  if [[ "$ACTION" == break ]]; then
    az network nsg rule create -g "$RG" --nsg-name server-nsg -n fault-web --subscription "$SUBSCRIPTION" \
      --priority 150 --direction Inbound --access Deny --protocol Tcp \
      --source-address-prefixes "$CLIENT_IP/32" --source-port-ranges '*' \
      --destination-address-prefixes "$SERVER_IP/32" --destination-port-ranges 8080 -o none
  else
    az network nsg rule delete -g "$RG" --nsg-name server-nsg -n fault-web --subscription "$SUBSCRIPTION"
  fi
else
  if [[ "$ACTION" == break ]]; then
    az network route-table route create -g "$RG" --route-table-name client-routes -n fault-web \
      --subscription "$SUBSCRIPTION" --address-prefix "$SERVER_IP/32" --next-hop-type None -o none
  else
    az network route-table route delete -g "$RG" --route-table-name client-routes -n fault-web --subscription "$SUBSCRIPTION"
  fi
fi
printf 'Nur Datenverkehr Client → Server betroffen; direktes SSH von adminSourceCidr bleibt erhalten.\n'
