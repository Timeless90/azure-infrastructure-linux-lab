# Prüfprotokoll und tatsächliche Grenzen

Prüfdatum2026-10-02. Kursversion1.0.0. Keine kostenpflichtigen Azure-Deployments oder Ressourcenänderungen durch den Kursautor. Beispiele sind als erwartet/synthetisch bezeichnet; eigene Labmessungen erst beim Lernenden.

## 1. Tatsächlich lokal ausgeführt

- Python3.12: Validator prüft genau12 Module mit AbschnittenA–M, separate Lösungen, Mindestinhalt, alle relativen Markdown-Dateilinks, Ausführungskontexte und Bashsyntax aller Befehlsblöcke.
- `bash -n` für alle Shellskripte und ausführbaren Bash-/sh-Blöcke.
- ShellCheck0.10.0, `shellcheck -x scripts/*.sh`: fehlerfrei nach Korrekturen.
- Python-AST aller Repository-Pythondateien, JSON und YAML parsebar (PyYAML6.0.2).
- `pytest`: **18 Tests bestanden**. FastAPI health/401/403/200/404 inklusive Request-ID; echter lokaler synthetischer HTTP-Server mit health/404; Konfigurationsgrenzen und separat unten eingeordnete Mocks.
- Bicep CLI0.34.44: main, vm, private-storage, key-vault und container-app kompiliert und Core-Linter geprüft. Unnötige dependsOn entfernt; Storage-DNS-Suffix auf environment().suffixes.storage umgestellt. Endstand ohne Buildwarnungen.
- Erzeugtes ZIP wird anhand Dateiliste, nichtleeren Kursdateien und Bytevergleich mit Source überprüft. Enthält keine virtuelle Umgebung, temporäre Testergebnisse, Credentials, Captures oder generierten ARM-Dateien.

Testabhängigkeiten wurden in einer separaten Arbeitsumgebung installiert. Eine DeprecationWarning aus Starlette/AnyIO ist im pytest-Lauf vorhanden; keine Testfehlfunktion. Transitive Abhängigkeiten sind nicht vollständig gelockt, siehe Versionen.

## 2. Statisch geprüft

Gemeinsame Ressourcen-/Dateinamen, Skript/Doku/Bicep-Mapping, NSG-/UDR-Fehlergrenzen und direkter SSH-Zugang. HTTP8080 nur Client/32→Server/32; keine pauschale öffentliche Öffnung. Config schützt /32-Adminquelle, konkrete Imageversion, RG-/Tagbindung, Adressüberlappung und ausschließlich ausdrücklich benannte .pub-Datei. Gitignore schließt Keys/Outputs/ENV/Logs/Captures aus. CI hat nur Repository-/Codeprüfungen, keine Azure-Anmeldung und keine Deploymentbefehle.

Statische Vollständigkeit ersetzt keine didaktische Prüfung mit einem echten Teilnehmer. Die kompilierten Schemas ersetzen keinen Azure-Providerlauf.

## 3. Mit Mocks getestet

Vier Cleanup-Schutzfälle benutzen eine Fake-Azure-CLI in temporären Testordnern: falsche Bestätigung, falscher RG-Tag, falsches Konto und bestätigte richtige Labgrenze. Nur letzter Fall löst eine simulierte Löschung aus. Das sind keine Cloud-Integrationstests. Testwerte wie Subscription-UUID/Public-IP werden nicht für echten Netzwerkverkehr verwendet.

## 4. Anhand offizieller Dokumentation geprüft

Canonical24.04-LTS/AMD64/Gen2-Imagefamilie, Azure expliziter Outbound/private Subnetdefaults, NSG stateful, UDR, PE/Blob-DNS, RBAC/Managed Identity, Bicep/API-Schemata, Docker-Namespace-/Portmapping, ACA-Console/Ingress und OpenSSL-Namensprüfung. Quellen und direkte Lizenzprüfung siehe SOURCES/ATTRIBUTIONS.

## 5. Nicht ausgeführt / nicht in Azure validiert

- Kein az login, keine regionalen Subscription-Image-/Quota-/SKU-Abfragen im Nutzerkonto.
- Kein what-if gegen die Nutzer-RG, kein Azure-Deployment, kein SSH auf Nutzer-VMs, keine effektiven Regeln/Routen live geprüft.
- Keine tatsächliche Azure-NSG-/UDR-/DNS-/PE-/Vault-/Managed-Identity-/ACA-Integration ausgeführt.
- Kein Docker-Daemon in der Autorenumgebung; Imagebuild/Runtime/GHCR-Push und ACA-Imagepull nicht ausgeführt.
- Kein systemd-Service gestartet; Unitbetrieb auf Ubuntu-VM muss Lernender bestätigen.
- TLS-/tcpdump-/nmap-VM-Übungen sind geschrieben und statisch geprüft, keine angeblich gemessenen Scans/Captures geliefert.
- Optionale Premium-Netzwerkthemen sind Designvertiefungen, keine vollständig implementierten Zusatzlabs.

Vor eigener Nutzung Preflight, regionales Imagepinning, Rollenscopes, Kosten, Policy, Quota und Kapazität prüfen. Azure CLI/Extensionstand dokumentieren. Eine bestehende NSG-Verbindung kann trotz Deny bestehen; neue Flows testen. Bei abweichenden Providerausgaben Messwerte dokumentieren statt Muster zu übernehmen.

## Reproduzieren

[LOKAL — Repository-Wurzel, aktivierte projektbezogene Virtualenv]
```bash
python -m pip install -r examples/fastapi/requirements.txt -r tests/requirements.txt
python scripts/validate.py
shellcheck -x scripts/*.sh
mkdir -p .state
for template in infra/bicep/*.bicep; do
  az bicep build --file "$template" --outfile ".state/$(basename "$template" .bicep).json"
done
```

Nur Compiler/Repositorychecks, keine Azure-Anmeldung nötig. ShellCheck/Bicep müssen vorher installiert sein. ## GitHub-Speicherung und erneute Prüfung

Der erste Kurscommit `cd2554d293ff09e57662efb7360a95aa2b13cc0d` wurde auf `course/azure-linux-2026-10-02` gespeichert; Pull Request #1 bleibt offen, main unverändert. Alle78 GitHub-Blob-Hashes wurden gegen lokale Sourcebytes geprüft und stimmen überein. [GitHub Actions Lauf1](https://github.com/Timeless90/azure-infrastructure-linux-lab/actions/runs/37042801535) endete erfolgreich, einschließlich Repository-/Python-/ShellCheck-/Bicep-Prüfung. Dies ist zusätzlich zum lokalen Lauf; weiterhin kein Cloud-Integrationstest. Danach wurden ausschließlich Einstieg/Branchhinweis und Cleanup-Hinweis zu möglichem regionalem Network Watcher präzisiert.
