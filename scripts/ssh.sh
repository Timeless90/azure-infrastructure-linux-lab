#!/usr/bin/env bash
set -euo pipefail
# shellcheck source=scripts/common.sh
source "$(dirname "$0")/common.sh"
ROLE=${1:-}; [[ "$ROLE" == client || "$ROLE" == server ]] || { echo 'Aufruf: bash scripts/ssh.sh client|server' >&2; exit 1; }
# SSH uses only local lab config and cached outputs, no Azure login on VMs.
python3 "$ROOT/scripts/config.py" >/dev/null
ADMIN=$(get adminUsername)
PUB=$(get sshPublicKeyPath)
KEY=${PUB%.pub}
IP=$(python3 - "$ROOT/.state/outputs.json" "$ROLE" <<'EOF'
import json,sys,ipaddress
v=json.load(open(sys.argv[1]))[sys.argv[2]+'PublicIp']['value']
ipaddress.IPv4Address(v);print(v)
EOF
)
mkdir -p "$ROOT/.state"
exec ssh -i "$KEY" -o IdentitiesOnly=yes -o StrictHostKeyChecking=ask \
  -o UserKnownHostsFile="$ROOT/.state/known_hosts" "$ADMIN@$IP"
