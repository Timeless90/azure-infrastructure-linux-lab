#!/usr/bin/env bash
set -euo pipefail
# shellcheck source=scripts/common.sh
source "$(dirname "$0")/common.sh"
load_lab
for tool in git ssh python3; do command -v "$tool" >/dev/null || { echo "$tool fehlt" >&2; exit 1; }; done
az version
az bicep version
VERSION=$(get imageVersion)
az vm image show --subscription "$SUBSCRIPTION" --location "$LOCATION" \
  --urn "Canonical:ubuntu-24_04-lts:server:$VERSION" --query '{name:name,architecture:architecture,hyperVGeneration:hyperVGeneration}' -o json
az vm list-skus --subscription "$SUBSCRIPTION" --location "$LOCATION" --size "$(get vmSize)" --all \
  --query '[].{name:name,restrictions:restrictions}' -o json
for provider in Microsoft.Compute Microsoft.Network Microsoft.Storage Microsoft.KeyVault Microsoft.App Microsoft.OperationalInsights Microsoft.ContainerRegistry; do
  az provider show --namespace "$provider" --subscription "$SUBSCRIPTION" --query '{namespace:namespace,state:registrationState}' -o json
done
az vm list-usage --subscription "$SUBSCRIPTION" --location "$LOCATION" -o table
python3 "$ROOT/scripts/config.py" prepare
printf 'Kein Deployment. Registrierung, Policy, Rollen und freie regionale Kapazität selbst prüfen.\n'
