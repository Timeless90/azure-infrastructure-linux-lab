# 06 – Reproduzierbare Infrastruktur

[Zur Kursübersicht](../../ROADMAP.md) · [Kompetenznachweis](../../PROGRESS.md)

## A. Lernziele

Du liest und veränderst Bicep kontrolliert, unterscheidest Parameter/Outputs/Module, kompilierst lokal und vergleichst what-if mit tatsächlichem Deployment.

## B. Voraussetzungen

[05](../05-azure-networking/README.md), vorhandene Basis, Bicep gemäß Getting Started. Erst alle fault-web-Regeln entfernen. Git-Arbeitsbranch für Experimente.

## C. Verständliche Theorie

Manuelle Portaländerungen erzeugen schwer nachvollziehbare Zustände. Infrastructure as Code beschreibt das gewünschte Modell versioniert. Bicep übersetzt deklarative Ressourcen in ARM-JSON: Ressourcenabhängigkeiten ersetzen viele imperativen „erst A dann B“-Befehle. Ein Parameter legt Werte fest, Output gibt entstandene Fakten zurück, ein Modul kapselt wiederverwendbare Teilarchitektur. Unser vm.bicep wird zweimal mit anderem Subnetz und IP aufgerufen.

IaC ist nicht automatisch gefahrlos. Eine andere Region oder VM-Name kann Ersatz-/Konfliktfolgen haben. Wiederholbares Deployment heißt, dass dieselbe Definition geprüft erneut angewandt werden kann, nicht dass jeder externe Paketmirror identisch bleibt. cloud-init läuft grundsätzlich beim ersten Provisioning; ein unverändertes Redeployment führt nicht automatisch alle Gastinstallationsschritte neu aus.

`what-if` fragt Azure nach erwarteten Änderungen, nicht nach tatsächlichen Laufzeitpaketen. Provider können unbekannte/defaultbedingte Werte als Änderungen melden. Compilierung prüft Sprache und Typen, nicht deine Quota, Berechtigung oder regionale Kapazität. Incremental Deployment löscht nicht beliebige nicht deklarierte Ressourcen: manuell ergänzte fault-web-Regeln deshalb mit Restore entfernen, nicht darauf vertrauen, dass ein Redeploy jeden Drift bereinigt.

## D. Architektur oder Ablauf

main.bicep: NSGs + leere UDR-Tabelle + VNet → zweimal vm.bicep → Outputs. private-storage/key-vault/container-app sind getrennte bewusste Deployment-Stufen, keine automatischen Seiteneffekte beim Basiskurs.

## E. Befehle mit Erklärung

[LOKAL — Repository-Wurzel]
```bash
mkdir -p .state
az bicep build --file infra/bicep/main.bicep --outfile .state/main.json
```
[AZURE-CLI-TERMINAL]
```bash
bash scripts/deploy.sh what-if
```
Parameterfile wird aus geprüfter lab.json erzeugt; `@` bedeutet JSON-Dateiinhalt. Public Key wird als secure Parameter behandelt, private Keys werden nicht gelesen.

## F. Guided Lab

1. Lies main.bicep und vm.bicep, markiere jede Beziehung zur Architektur.
2. Baue lokal; notiere alle Warnungen/Fehler. Vergleiche ARM-JSON mit Bicep, ohne es als zweites gepflegtes Sourcefile zu committen.
3. Führe what-if gegen die existierende RG aus. Unbekannte Änderungen erst untersuchen.
4. Ändere nur eine Beschreibung des Kursdienstes oder einen ressourcenbezogenen Tag im Code für deine Challenge; begründe Wirkung.
5. **Kostenpflichtig bei neuen/geänderten Ressourcen:** nach Plan ggf. selbst deployen, Outputs/effektive Regeln und Client-health neu verifizieren. Kein Deployment ist hier durch den Kursautor bereits bewiesen.

## G. Beobachtung und Interpretation

Erwartet: lokale Buildsyntax korrekt; unveränderte Basis weitgehend unverändert. Keine Garantie, dass what-if „No change“ zeigt, weil Providerwerte variieren. Azure-Provisioning succeeded ist noch kein cloud-init-/HTTP-Erfolg. Ein output aus Cache kann alt sein, daher outputs.sh nach Deployment ausführen.

## H. Break & Fix

Ausgangszustand: kompilierbarer Code. Fehleraktivierung nur lokal in einer Kopie: ersetze in einer einzelnen Kopie von vm.bicep `vmSize` im hardwareProfile durch Zahl 42. Symptom: Typprüfung scheitert oder warnt. Auftrag: Parser-/Typfehler vom Azure-Runtimefehler unterscheiden. Nicht deployen; Original bleibt unverändert.

## I. Selbstständige Challenge

Füge einen parametrisierten `environment=learning`-Tag in deiner lokalen Bicep-Kopie hinzu und reiche ihn in beide VM-Module durch. Zeige diff, Build und what-if. Akzeptanz: keine fremde Ressource, keine unnötige VM-Neuerstellung, konsistente Tags.

## J. Quiz

1. Warum beweist Build keinen Cloud-Erfolg?
2. Was ist eine sichere Quelle für eine neue Public IP?
3. Warum führt Redeployment cloud-init nicht wie ein Taskrunner aus?
4. Warum braucht what-if Berechtigungen?

## K. Erfolgskriterien

Du erklärst beide Module, zeigst einen Build, liest einen Plan begründet und unterscheidest Codeprüfung, Management-Plane-Erfolg und Data-Plane-Erfolg. Challenge ist mit Diff/Plan dokumentiert.

## L. Wiederherstellung und Cleanup

Lokale Fehlerkopie entfernen oder korrigieren. Für echte Tagänderung den gewünschten Standardstand per überprüftem Plan wiederherstellen. Basis-VMs bestehen; .state-JSON bleibt ignoriert.

## M. Weiterführende Quellen

- [Bicep Grundlagen](https://learn.microsoft.com/en-us/azure/azure-resource-manager/bicep/overview)
- [Bicep what-if](https://learn.microsoft.com/en-us/azure/azure-resource-manager/bicep/deploy-what-if)
- [Bicep Module](https://learn.microsoft.com/en-us/azure/azure-resource-manager/bicep/modules)

Lösungen erst nach eigenem Versuch: [separate Hinweise und Lösung](solutions.md).
