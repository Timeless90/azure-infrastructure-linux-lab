#!/usr/bin/env bash
set -euo pipefail
# shellcheck source=scripts/common.sh
source "$(dirname "$0")/common.sh"
load_lab
if [[ $(az group exists -n "$RG" --subscription "$SUBSCRIPTION" -o tsv) != true ]]; then
  echo 'Lab-Resource-Group existiert nicht. Nichts gelöscht.'; exit 0
fi
guard_rg
az resource list -g "$RG" --subscription "$SUBSCRIPTION" --query '[].{name:name,type:type}' -o table
echo 'DESTRUKTIV: löscht die ganze oben angezeigte, getaggte Kurs-RG. Enthält sie Fremdressourcen: abbrechen!'
confirm "DELETE $SUBSCRIPTION/$RG"
az group delete -n "$RG" --subscription "$SUBSCRIPTION" --yes
[[ $(az group exists -n "$RG" --subscription "$SUBSCRIPTION" -o tsv) == false ]] || { echo 'Löschung noch nicht abgeschlossen' >&2; exit 1; }
echo 'RG nicht mehr vorhanden. Key-Vault Soft Delete und externe Rollenzuweisungen separat prüfen; docs/costs-and-cleanup.md.'
