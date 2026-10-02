#!/usr/bin/env bash
set -euo pipefail
# shellcheck source=scripts/common.sh
source "$(dirname "$0")/common.sh"
load_lab; guard_rg
az vm list -g "$RG" --subscription "$SUBSCRIPTION" --show-details \
  --query '[].{name:name,power:powerState,private:privateIps,public:publicIps}' -o table
for nic in client-nic server-nic; do
  az network nic list-effective-nsg -g "$RG" -n "$nic" --subscription "$SUBSCRIPTION" -o json
  az network nic show-effective-route-table -g "$RG" -n "$nic" --subscription "$SUBSCRIPTION" -o table
done
# Explicitly run the data-plane checks in module 04 from CLIENT-VM.
