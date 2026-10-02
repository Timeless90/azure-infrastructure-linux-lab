#!/usr/bin/env bash
set -euo pipefail
# shellcheck source=scripts/common.sh
source "$(dirname "$0")/common.sh"
MODE=${1:-what-if}
[[ "$MODE" == 'what-if' || "$MODE" == 'deploy' ]] || { echo 'Aufruf: bash scripts/deploy.sh [what-if|deploy]' >&2; exit 1; }
load_lab
python3 "$ROOT/scripts/config.py" prepare
az bicep build --file "$ROOT/infra/bicep/main.bicep" --outfile "$ROOT/.state/main.json"
if [[ $(az group exists --name "$RG" --subscription "$SUBSCRIPTION" -o tsv) != 'true' ]]; then
  echo 'Resource Group fehlt. Anlegen ist eine Management-Änderung, legt noch keine VMs an.'
  confirm "CREATE $RG"
  az group create -n "$RG" -l "$LOCATION" --subscription "$SUBSCRIPTION" \
    --tags courseLabId="$LAB_ID" purpose=azure-linux-course -o none
fi
guard_rg
if [[ "$MODE" == 'what-if' ]]; then
  az deployment group what-if -g "$RG" --subscription "$SUBSCRIPTION" \
    --name course-base --template-file "$ROOT/infra/bicep/main.bicep" --parameters "@$ROOT/.state/parameters.json"
else
  echo 'KOSTENPFLICHTIG: 2 VMs, 2 OS-Disks, 2 Standard Public IPs. Vorher what-if und Kosten prüfen.'
  confirm "DEPLOY $RG"
  az deployment group create -g "$RG" --subscription "$SUBSCRIPTION" --name course-base \
    --template-file "$ROOT/infra/bicep/main.bicep" --parameters "@$ROOT/.state/parameters.json" -o none
  bash "$ROOT/scripts/outputs.sh"
fi
