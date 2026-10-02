#!/usr/bin/env bash
set -euo pipefail
# shellcheck source=scripts/common.sh
source "$(dirname "$0")/common.sh"
load_lab; guard_rg
mkdir -p "$ROOT/.state"
az deployment group show -g "$RG" --subscription "$SUBSCRIPTION" -n course-base \
  --query properties.outputs -o json > "$ROOT/.state/outputs.json"
python3 - "$ROOT/.state/outputs.json" <<'EOF'
import json,sys
for k,v in json.load(open(sys.argv[1])).items(): print(k+": "+str(v['value']))
EOF
