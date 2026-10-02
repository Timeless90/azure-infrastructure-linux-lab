# Azure Infrastructure Engineering mit Linux

Ein deutschsprachiger, praxisorientierter Self-Learning-Kurs für Entwickler mit Python/FastAPI-, GitHub- und Azure-Erfahrung. Du lernst Linux-Betrieb und Netzwerkdiagnose durch eigene Messungen und kontrollierte Fehler, nicht durch Auswendiglernen für eine Zertifizierung.

**Starte mit [Modul 00](modules/00-setup/README.md)** und [Getting Started](docs/getting-started.md). Vor einem Azure-Deployment: [Kosten und Cleanup](docs/costs-and-cleanup.md) lesen. Alle Cloud-Schritte führst du selbst aus; dieses Repository enthält keine automatische Azure-Anmeldung oder Deployment-Pipeline.

## Was du baust

Zwei Ubuntu-24.04-LTS-VMs in zwei Subnetzen eines VNet. Ein kleiner Linux-Service antwortet auf TCP/8080 ausschließlich dem Lab-Client. Du untersuchst Listener, Routen, DNS, TCP, TLS, NSGs und Berechtigungen. Danach ergänzen Blob Private Endpoint, Managed Identity, FastAPI, Docker und Azure Container Apps das Modell.

## Voraussetzungen und Lernweise

Arbeitsplatz: macOS (auch Apple Silicon) oder Linux mit Git, SSH, Python 3.12 und Bash. Die Linux-Administration findet auf einer ausdrücklich für den Kurs bereitgestellten Ubuntu-VM statt; deine bestehende Rechnerkonfiguration wird nicht umgebaut. Azure-Subscription mit erlaubten Ressourcen, passender Quota und Contributor auf der Kurs-RG ist für Cloud-Labs erforderlich. RBAC-Zuweisungen in Modul 08 benötigen gesonderte, begrenzte Rechte.

Plane pro Modul eine oder mehrere konzentrierte Sitzungen. Lies das Modell, führe das Guided Lab aus, protokolliere deine Beobachtungen und löse erst dann Break & Fix und Challenge. Prüfe die getrennte `solutions.md` erst nach einem eigenen Versuch. [PROGRESS](PROGRESS.md) misst Erklären, Durchführen und Diagnostizieren.

## Navigation

- [ROADMAP](ROADMAP.md): alle zwölf Module und Abhängigkeiten
- [Architektur](docs/architecture.md), [Sicherheit](docs/safety.md), [Troubleshooting-Methode](docs/troubleshooting-method.md)
- [Fehlerübungsindex](docs/break-fix-index.md)
- [Cheatsheet nach Diagnosefragen](cheatsheets/diagnosis.md), [Glossar](docs/glossary.md), [KI-Tutor](docs/tutor-prompt.md)
- [Quellen](SOURCES.md), [Attributionen](ATTRIBUTIONS.md), [Versionen](docs/versions.md), [Validierung und Grenzen](VALIDATION.md)
- [Manueller GitHub-Upload](docs/github-upload.md) für ein heruntergeladenes Archiv

## Grenzen

Scans und Captures nur auf explizit eigene Lab-IP-Adressen und benannte Ports. Keine Exploits, Passwortangriffe, produktiven Daten oder Secrets. Keine öffentlichen Freigaben des Webports. Public IP bedeutet in diesem Lab expliziten Outbound und eingeschränktes SSH, nicht öffentliches HTTP. Das Repository selbst ist nach ausdrücklicher Nutzerfreigabe öffentlich; es enthält ausschließlich generische Unterrichtsdateien. GitHub Pages bleibt deaktiviert. Es wird keine öffentliche Open-Source-Lizenz für das Gesamtwerk vergeben.

Bicep und Shellskripte sind Unterrichtsartefakte. Ein erfolgreiches lokales Prüfergebnis ersetzt keinen Cloud-Integrationstest. Lies den aktuellen Prüfstatus in VALIDATION.md.
