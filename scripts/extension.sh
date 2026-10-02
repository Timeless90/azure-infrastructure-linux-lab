#!/usr/bin/env bash
set -euo pipefail
# shellcheck source=scripts/common.sh
source "$(dirname "$0")/common.sh"
PART=${1:-}; MODE=${2:-what-if}
if ! { [[ "$PART" == private-storage || "$PART" == key-vault || "$PART" == container-app ]] && [[ "$MODE" == what-if || "$MODE" == deploy ]]; }; then
  echo 'Aufruf: bash scripts/extension.sh private-storage|key-vault|container-app what-if|deploy [image@sha256:digest]' >&2; exit 1;
fi
load_lab; guard_rg
PARAMS=("labId=$LAB_ID" "location=$LOCATION")
if [[ "$PART" == key-vault || "$PART" == container-app ]]; then PARAMS+=("adminSourceCidr=$(get adminSourceCidr)"); fi
if [[ "$PART" == container-app ]]; then
  IMAGE=${3:-}
  [[ "$IMAGE" =~ ^ghcr\.io/timeless90/azure-linux-course-api@sha256:[0-9a-f]{64}$ ]] || { echo 'Expliziter GHCR-Digest des Lab-Images erforderlich' >&2; exit 1; }
  PARAMS+=("image=$IMAGE")
fi
az bicep build --file "$ROOT/infra/bicep/$PART.bicep" --outfile "$ROOT/.state/$PART.json"
if [[ "$MODE" == what-if ]]; then
 az deployment group what-if -g "$RG" --subscription "$SUBSCRIPTION" --name "course-$PART" \
   --template-file "$ROOT/infra/bicep/$PART.bicep" --parameters "${PARAMS[@]}"
else
 echo 'KOSTENPFLICHTIGE ERWEITERUNG. Preise und what-if vorab prüfen.'
 confirm "DEPLOY $PART $RG"
 az deployment group create -g "$RG" --subscription "$SUBSCRIPTION" --name "course-$PART" \
   --template-file "$ROOT/infra/bicep/$PART.bicep" --parameters "${PARAMS[@]}" --query properties.outputs -o json
fi
