# 10 – Hinweise und Lösungen

[Zur Aufgabenstellung](README.md)

## Route

Hinweis 1: Client-Private-IP-Flows betreffen die Route Table des Client-Subnetzes. Hinweis 2: /32 ist spezifischer als /16. [AZURE-CLI-TERMINAL]:
[AZURE-CLI-TERMINAL]
```bash
source scripts/common.sh
load_lab
guard_rg
az network nic show-effective-route-table -g "$RG" -n client-nic --subscription "$SUBSCRIPTION" -o table
bash scripts/azure-fault.sh route restore
```
Die explizite `fault-web`-Route löschen, nicht gesamte Tabelle oder Default-Route. Die Shellscript-Grenze verhindert Veränderungen am Arbeitsplatz. Client health wiederholen.

## TLS

Hinweis 1: CA kann richtig sein, Name falsch. Hinweis 2: SAN im Zertifikat ist lab.test. Lösung: URL/resolve auf lab.test korrigieren; `--cacert lab.crt` beibehalten. Keine System-CA-Installation und keine `-k`-Ausnahme. Für Trustfehler CA explizit nur für den einzelnen Lab-Request nutzen. Die synthetische CA legitimiert keinen fremden Server.

## Challenge

Timeout: falsches Ziel, NSG, fehlender Rückweg, Route oder überlasteter Service; ss/Clientroute/effective routes/Capture vergleichen. Certificate error: Name, Zeit oder Chain; s_client mit hostname und passender CA, Zertifikats-SAN/Dates inspizieren. 403: Approlle, Vault-Firewall, Gateway oder falsche Ressource; Request-ID/antwortende Komponente/Service-Error-Code mit RBAC und Netzpfad vergleichen.

## Quiz

1. Fabric-Routing außerhalb des Gastkernels. 2. Ergänzt explizites Vertrauen für diesen Request, ändert nicht SAN/Hostname oder Netzroute. 3. Sonst wird Serveridentität nicht geprüft. 4. Lokaler health-Erfolg zeigt lokalen Dienst, nicht dessen externes Binding/Regeln.
