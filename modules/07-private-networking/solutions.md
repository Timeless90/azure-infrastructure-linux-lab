# 07 – Hinweise und Lösungen

[Zur Aufgabenstellung](README.md)

## Break & Fix

Hinweis 1: dig kann korrekt sein, während curl eine andere Adresse nutzt. Hinweis 2: `--resolve` überschreibt für diese Host/Port-Kombination die Verbindung. Lösung: Aufruf ohne `--resolve`; DNS, tatsächliche Ziel-IP und TLS erneut prüfen. `127.0.0.1` ist nur der Client selbst. Dies simuliert eine fehlerhafte Namenszuordnung im Client, ohne Systemresolver/Hosts-Datei zu verändern.

## Challenge

Hinweis 1: Zone und VNet-Link sind verschiedene Ressourcen. Hinweis 2: Prüfe, welches VNet der Link referenziert. Referenz [AZURE-CLI-TERMINAL]:
[AZURE-CLI-TERMINAL]
```bash
source scripts/common.sh
load_lab
guard_rg
az network private-dns record-set a list -g "$RG" -z privatelink.blob.core.windows.net --subscription "$SUBSCRIPTION" -o json
az network private-dns link vnet list -g "$RG" -z privatelink.blob.core.windows.net --subscription "$SUBSCRIPTION" -o json
```
Client dig plus getent zeigt Resolver-/NSS-Sicht. Ein fehlender Link kann nicht allein durch einen vorhandenen A-Record kompensiert werden. Bei Custom DNS zusätzlich Forwarding prüfen; das Kernlab verwendet Azure-DNS.

## Quiz

1. TLS benötigt den vorgesehenen Namen/SNI und passende SAN. 2. Nein, Netzwerkzugang ist kein RBAC. 3. Öffentlicher Dienstendpunkt mit Subnetzidentität versus private NIC. 4. Paketmirrors und manche Identitäts-/Managementendpunkte sind separate öffentliche Ziele.
