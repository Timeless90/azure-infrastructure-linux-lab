# Index der konkreten Fehlerübungen

Jeden Fall einzeln aktivieren, nach Diagnose wiederherstellen und Erfolgstest wiederholen. Die Modulaufgaben enthalten Ausgangszustand, Aktivierung, Symptom und Auftrag; vollständige Hinweise/Lösung bleiben getrennt. Keine Scans gegen fremde Ziele.

| Fall | Modul mit Aufgabenstellung | Isolierte Änderung / Verwaltungsweg |
|---|---|---|
| Service gestoppt | [02](../modules/02-linux-services/README.md) | nur course-web, SSH unverändert |
| Ungültiger systemd-ExecStart | [02](../modules/02-linux-services/README.md) | eigener Drop-in, SSH unverändert |
| Falscher Zielport | [03](../modules/03-network-basics/README.md) | nur Request8081 statt8080 |
| Loopback-Binding | [04](../modules/04-network-diagnostics/README.md) | nur course-web-Bind, SSH unverändert |
| NSG-Deny | [05](../modules/05-azure-networking/README.md) | Client/32→Server/32:8080, direktes SSH erhalten |
| Falsche Namenszuordnung | [07](../modules/07-private-networking/README.md) | curl-resolve nur für einen Request, System-DNS unverändert |
| Fehlende Data-Plane-Rolle | [08](../modules/08-identity-security/README.md) | vorhandene fehlende Berechtigung nutzen, keine Rechte entziehen; sonst09 |
| Docker-Mapping | [09](../modules/09-containers-aca/README.md) | eigener zusätzlicher Fehlercontainer, korrekter Vergleich bleibt |
| HTTP401/403 statt Netzfehler | [09](../modules/09-containers-aca/README.md) | synthetischer Headerfall, reproduzierbar |
| Fabric-Route | [10](../modules/10-troubleshooting/README.md) | Server-Private-IP/32→None nur am Client-Subnetz, direktes SSH bleibt |
| TLS-Trust/Name | [10](../modules/10-troubleshooting/README.md) | synthetisches Loopback8443, keine System-CA-Änderung |

Zusätzlich: eigene Dateirechte in01 und statischer Bicep-Typfehler in06. In11 werden bekannte Fälle mit FastAPI eigenständig kombiniert. Bei allen Cloudstufen Kosten bis Cleanup beachten.
