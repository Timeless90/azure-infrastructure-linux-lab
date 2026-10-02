# Kosten, Pausen und vollständiges Cleanup

Prüfdatum 2026-10-02, geplante Region Sweden Central. Es gibt **keine verifizierte Euro-Preisschätzung** für deine Subscription. Prüfe unmittelbar vor Erstellung im [Azure Pricing Calculator](https://azure.microsoft.com/en-us/pricing/calculator/) und in deinen Vertragskonditionen. Free Credits sind kein Preisversprechen. Die kleine SKU kann in deiner Region/Subscription gesperrt oder ohne Kapazität sein.

## Kosteninventar und Schätzverfahren

| Stufe | Einzubeziehen | Annahmen für deine eigene Rechnung |
|---|---|---|
| Basis | 2 × Standard_B1s Linux, 2 × Standard-LRS OS-Disk, 2 × Standard Public IPv4 | z. B. 2 VMs × 6 Stunden pro Woche; Disks/IPs solange vorhanden |
| 07 | StorageV2 Standard LRS, Blob Private Endpoint, Private DNS Zone/Abfragen, PE-Daten | wenige synthetische Requests, keine echten Daten |
| 08 | Key Vault Standard, Secret-Operationen | ein harmloser Lab-Wert; Soft Delete beachten |
| 09 | ACA Consumption CPU/RAM/Requests, ggf. Diagnostics | 0–1 Replica; keine Zusage kostenfreien Idle |
| Optional | NAT Gateway, Bastion, Firewall, Resolver, Gateway/Front Door | stündliche/monatliche Grundkosten und Datenkosten separat |

Rechnung: VM-Stunden × Vertrags-Stundensatz + Disk-Monate anteilig + IP-Stunden + Dienstgrundkosten + Operationen/Daten/Egress + Steuern/Währung. Speichere Region, Datum, Nutzungsdauer und enthaltene Ressourcen in deinen privaten Notizen. Ein kurzer Lab-Tag bedeutet nicht, dass Disk-/IP-Kosten nur während SSH-Nutzung entstehen.

Budget im Cost Management erstellen, nach RG/Subscription sinnvoll filtern und mehrere Warnschwellen/Empfänger setzen. Alerts können verzögert kommen und **sperren Ausgaben nicht garantiert**. Nach jeder Sitzung Inventar und Cost Analysis prüfen. Budgeterstellung benötigt dafür passende Kostenverwaltungsrechte.

## Pause: deallocate ist nicht löschen

[AZURE-CLI-TERMINAL — Repository-Wurzel]
```bash
source scripts/common.sh
load_lab
guard_rg
az vm deallocate -g "$RG" -n client-vm --subscription "$SUBSCRIPTION"
az vm deallocate -g "$RG" -n server-vm --subscription "$SUBSCRIPTION"
```

Es bleiben Disks, IPs, Storage, Private Endpoint, DNS, Key Vault und ACA bestehen. VM `Stopped` ohne `deallocated` kann weiter Compute-Kosten verursachen. ACA läuft unabhängig von VM-Stopp. Starten ist wieder kostenpflichtig und kann an Kapazität scheitern:

[AZURE-CLI-TERMINAL]
```bash
source scripts/common.sh
load_lab
guard_rg
# KOSTENPFLICHTIG
az vm start -g "$RG" -n client-vm --subscription "$SUBSCRIPTION"
az vm start -g "$RG" -n server-vm --subscription "$SUBSCRIPTION"
```

## Alles entfernen

Vorher Beweisnotizen sichern, Captures/Keys nicht committen. Welche Fehler aktiv sind, spielt für RG-Löschung keine Rolle; es werden auch manuell hinzugefügte Lab-Regeln gelöscht. Das Skript löscht ausschließlich die konfigurierte, getaggte RG nach expliziter Bestätigung, nicht einzelne Ressourcen in fremden RGs.

[AZURE-CLI-TERMINAL]
```bash
bash scripts/cleanup.sh
```

Die Abfrage am Ende muss RG-Existenz `false` ergeben. Management-Plane-Daten sind eventuell verzögert. Unter Subscription-Ressourcen und Kostenanalyse prüfen, ob getrennt angelegte Diagnosespeicher/Budgets oder Extensions außerhalb der RG übrig sind. Der Kurs erzeugt keine davon automatisch. Bei Key Vault bleiben soft-deleted Vault und ggf. Namen bis zur Retention erhalten. Kein automatischer Purge, keine Umgehung von Purge Protection. Unter Key Vault → Manage deleted vaults ansehen; üblicherweise ist dies kein laufender aktiver Vault, aber regionale Namen sind nicht sofort wieder nutzbar.

RBAC-Zuweisungen an gelöschte Managed Identities können auf fremden Scopes übrig bleiben. Deshalb im Lab Rollen nur auf den konkreten Kurs-Storage/Vault setzen, nie pauschal Subscription. Registrierte Resource Provider sind Subscription-Einstellungen; nicht zum Cleanup deregistrieren. Budget kann für weitere Labs bestehen bleiben oder vom Nutzer separat entfernt werden.

Lokal `.state/`, Virtualenv und SSH-Key existieren noch. Lösche sie nach eigener Prüfung über Dateimanager oder gezielt; keine automatische private-Key-Löschung. Öffentliches GHCR-Lab-Image aus Modul 09 kann separat bestehen bleiben; keine Cloud-RG-Ressource. Entferne das Package manuell, wenn nicht mehr benötigt.
