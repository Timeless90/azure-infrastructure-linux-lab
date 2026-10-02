# 00 – Orientierung und sichere Lernumgebung

[Zur Kursübersicht](../../ROADMAP.md) · [Kompetenznachweis](../../PROGRESS.md)

## A. Lernziele

Du kannst Arbeitsplatz, CLI und beide VMs unterscheiden; die nötigen Rollen erklären; einen konkreten Kostenplan und eine sichere Cleanup-Grenze festlegen; deine Kurskopie ohne Secrets versionieren.

## B. Voraussetzungen

Python/Git-Grundkenntnisse. Für den Theorie- und lokalen Start ist kein Azure-Zugang nötig. Für VMs: eigene erlaubte Subscription, Kostenfreigabe, RG-Erstellrecht oder vorbereitete Kurs-RG. Lies [Sicherheit](../../docs/safety.md), [Versionen](../../docs/versions.md) und [Getting Started](../../docs/getting-started.md).

## C. Verständliche Theorie

Ein Terminal ist kein Ort: dieselbe Shellsyntax kann lokal, in einer VM oder in einem Container ausgeführt werden. `hostname` und `pwd` verhindern viele Bedienfehler. GitHub speichert Kursdateien, Azure stellt laufende Ressourcen bereit; ein Commit stoppt keine Rechnung. Eine Resource Group ist ein Verwaltungscontainer, kein Netzwerk und keine automatische Kostenobergrenze. Sie ist unsere Cleanup-Grenze.

Die Bash-Skripte lesen ausschließlich `config/lab.json`, die du neu anlegst. Der private SSH-Key authentifiziert deinen SSH-Client und bleibt lokal. Der Public Key darf auf der VM stehen. Azure CLI authentifiziert unabhängig davon gegen die Management Plane. Ein gültiger Azure-Login erzeugt nicht automatisch einen Linux-Login.

Der erste VM-Aufbau ist ein geführter Bootstrap: du verwendest geprüften IaC-Code und verstehst später in 05/06 jedes Bauteil. Das ist kein Befehl zum ungeprüften Deployment. Vor Erstellung liest du das Ressourceninventar und prüfst Plan, Quota und Kosten selbst.

## D. Architektur oder Ablauf

Lernablauf: lokale Kurskopie → eigene Konfiguration → read-only Preflight → what-if → bewusste Kostenentscheidung → Deployment → zwei SSH-Terminals. Die [Architektur](../../docs/architecture.md) zeigt Daten- und Verwaltungswege.

## E. Befehle mit Erklärung

[LOKAL — Repository-Wurzel]
```bash
pwd
git status --short
git check-ignore .state/course_ed25519 config/lab.json
python3 scripts/validate.py
```
`git check-ignore` zeigt die Schutzregel für benannte lokale Dateien; es sucht keine vorhandenen Secrets. Ein ignoriertes File wird nicht bei normalem `git add` aufgenommen, kann aber mit `-f` erzwungen werden: niemals tun. Der Validator prüft Kursdateien ohne Azure-Anmeldung.

## F. Guided Lab

1. Folge Getting Started bis einschließlich Toolcheck und Konfiguration. Öffne PROGRESS.md.
2. Schreibe einen privaten Plan: Subscription, erlaubte Region, Dauer einer Sitzung, Inventar und Kostenprüfung. Kein Token gehört hinein.
3. Ermittle und dokumentiere lokale/VPN-Netze, setze lab.json vollständig. Starte Preflight und interpretiere Provider-/SKU-Ausgaben.
4. Erzeuge what-if. Bei leerer RG dürfen nur benannte Kursressourcen entstehen. Bei unerwartetem Delete/Modify stoppen.
5. **Kostenpflichtig:** nur nach eigener Entscheidung Basis deployen. Öffne zwei SSH-Terminals, prüfe Fingerprints unabhängig und warte cloud-init ab.
6. Schreibe je Terminal Host, Benutzer und Arbeitsverzeichnis auf. Keine Messwerte aus der Dokumentation übernehmen.

## G. Beobachtung und Interpretation

Erwartet: Konto/Subscription stimmen mit deiner Datei überein; Validator endet ohne Fehler; IPs stammen aus Deployment-Outputs, Pakete sind vorhanden. `ResourceNotFound` ist kein Loginfehlerbeweis. `AuthorizationFailed` weist auf fehlende Rechte am konkreten Scope hin. Ein SKU-Listeneintrag garantiert keine freie Kapazität.

## H. Break & Fix

Ausgangszustand: Kursdateien lokal vorhanden. Fehleraktivierung: kopiere das harmlose Beispiel nach `config/lab.json`, ohne Werte einzutragen, und rufe `python3 scripts/config.py` auf. Symptom: Skript bricht vor jedem Deployment ab. Diagnoseauftrag: Welche Pflichtfelder fehlen, und warum dürfen Standardwerte hier keine echte Subscription auswählen? Danach deine eigene Konfiguration wiederherstellen.

## I. Selbstständige Challenge

Entwerfe einen Startplan für einen zweiten eigenen Arbeitsplatz mit anderem Betriebssystem. Welche Schritte bleiben auf VMs, welche lokal? Trage eine absichtlich überlappende VPN-Route in eine temporäre Testkonfiguration ein und zeige, warum sie zurückgewiesen wird, ohne dein Netz zu ändern.

## J. Quiz

1. Warum ist eine private RG keine Netzwerkisolation?
2. Was schützt `.gitignore`, was nicht?
3. Warum ist ein Budgetalert keine harte Ausgabensperre?
4. Was ist nach `az vm deallocate` noch kostenrelevant?

## K. Erfolgskriterien

Du kannst beide Hosts richtig benennen, eigene Adressräume prüfen, den Outbound-Weg zeigen und das genaue Cleanup-Ziel erläutern. Eine Kostenentscheidung und Toolversionen sind dokumentiert. Kein tatsächliches Deployment ist als „durchgeführt“ markiert, bevor du es selbst ausgeführt hast.

## L. Wiederherstellung und Cleanup

Konfiguration enthält wieder deine gewählten Werte. Bei Nichtfortsetzung: `bash scripts/cleanup.sh` vom CLI-Arbeitsplatz; vollständige Anleitung unter [Kosten/Cleanup](../../docs/costs-and-cleanup.md). Ohne Deployment existieren nur lokale Kurskopie, Keys und Virtualenv.

## M. Weiterführende Quellen

- [Azure CLI installieren](https://learn.microsoft.com/en-us/cli/azure/install-azure-cli)
- [Budgets](https://learn.microsoft.com/en-us/azure/cost-management-billing/costs/tutorial-acm-create-budgets)

Lösungen erst nach eigenem Versuch: [separate Hinweise und Lösung](solutions.md).
