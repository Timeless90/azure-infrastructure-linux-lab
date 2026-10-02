# 08 – Identitäten, Sicherheit und Beobachtbarkeit

[Zur Kursübersicht](../../ROADMAP.md) · [Kompetenznachweis](../../PROGRESS.md)

## A. Lernziele

Du trennst Entra-Identität, RBAC, Netzwerkregeln und Linuxrechte. Du erklärst Managed Identity, Key Vault Management/Data Plane und wählst Network-Watcher-Diagnosen mit Grenzen.

## B. Voraussetzungen

[07](../07-private-networking/README.md), PE eingerichtet für Kontext; Key-Vault-Übung separat. Contributor für Ressourcen, für Rollenzuweisungen zusätzlich begrenztes Role-Based Access Control Administrator oder Adminhilfe am jeweiligen Lab-Ressourcenscope. Kein pauschales Owner.

## C. Verständliche Theorie

Drei Türen sind unabhängig: Netzwerk lässt TCP/TLS zu, Authentifizierung stellt Identität fest, Autorisierung erlaubt die Operation. Microsoft Entra ID stellt Identitäten/Tokens für Azure bereit; RBAC bindet eine Identität an Rolle und Scope. Ein Linuxbenutzer ist nicht automatisch eine Entra-Identität. Ein Azure Contributor darf einen Vault verwalten, hat deshalb unter RBAC nicht automatisch Secret-Inhalte lesen dürfen.

System-assigned Managed Identity gehört zum Lebenszyklus der VM. Azure verwaltet ihr Credential; die Anwendung fragt ein Token über geeignete SDK-/Identity-Mechanismen an. Das ersetzt kein Endnutzer-JWT. Workload → Azure-Dienst und Nutzer → FastAPI sind zwei verschiedene Vertrauensbeziehungen.

Key Vault speichert Secret-Inhalte in der Data Plane, die Vault-Ressource selbst gehört zur Management Plane. Das Lab verwendet nur einen harmlosen synthetischen Wert. Der Vault ist netzwerkseitig zunächst nur von deiner Admin-/32 erreichbar, nicht vom gesamten Internet. Die VM-Identität wird nicht mit einem lokalen `az login --identity` vorausgesetzt, weil Azure CLI nicht auf der VM installiert ist.

Beobachtbarkeit besteht aus mehreren Sichten: Linux-Journal für Gastprozess, Azure Activity Log für Management-Änderungen, effektive Regeln/Routen für Fabric-Konfiguration. Network Watcher IP flow verify simuliert eine NSG-Entscheidung für einen Flow, kein vollständiger HTTP-Test. Connection troubleshoot kann weitere Voraussetzungen/VM-Extension und Kosten haben. Neue NSG Flow Logs sind keine Standardempfehlung; für weiterführendes Logging aktuelle VNet Flow Logs prüfen.

## D. Architektur oder Ablauf

Nutzerkonto → ARM → Vault-Verwaltung; Nutzer/Managed Identity → Token → Vault HTTPS → Secret-RBAC. Die VM/Public-IP-Netzregel bleibt zusätzlich nötig. Kein echter produktiver Secret-Wert wird erzeugt oder gelesen.

## E. Befehle mit Erklärung

[AZURE-CLI-TERMINAL — Repository-Wurzel]
```bash
bash scripts/extension.sh key-vault what-if
# KOSTENPFLICHTIG: Vault und Operationen, nach eigener Prüfung.
bash scripts/extension.sh key-vault deploy
source scripts/common.sh
load_lab
guard_rg
VAULT_NAME=$(az deployment group show -g "$RG" --subscription "$SUBSCRIPTION"   -n course-key-vault --query properties.outputs.vaultName.value -o tsv)
VAULT_ID=$(az keyvault show -g "$RG" -n "$VAULT_NAME" --subscription "$SUBSCRIPTION" --query id -o tsv)
az keyvault show -g "$RG" -n "$VAULT_NAME" --subscription "$SUBSCRIPTION" --query properties.enableRbacAuthorization -o tsv
az vm show -g "$RG" -n server-vm --subscription "$SUBSCRIPTION" --query identity.principalId -o tsv
```
Resource-ID und Principal-ID sind keine Tokens. Nicht auf eine produktive Vault-ID ausweiten.

## F. Guided Lab

1. Zeige Vault-Ressource; versuche nur Metadaten `az keyvault secret list --vault-name "$VAULT_NAME"`. Ob es scheitert, hängt von vorhandenen Rollen ab; keine angenommene Fehlermeldung erfinden.
2. Falls du Secret-Inhalte schon sehen dürftest: dokumentiere die konkrete Rolle/Scope. Breite vorhandene Rollen nicht entfernen.
3. Für den positiven Data-Plane-Test lasse einen berechtigten Administrator auf genau dem Kurs-Vault deinem Nutzer Key Vault Secrets Officer geben, dann einen synthetischen Wert setzen. Ausführbare Schritte stehen in der separaten Lösung, damit das Diagnoseziel nicht vorweggenommen wird.
4. Vergleiche Management- und Data-Plane-Status. Rollenpropagation kann Minuten brauchen; nicht durch wiederholte pauschale Zuweisungen „fixen“.
5. Im Portal Network Watcher → IP flow verify: Kursserver auswählen, Inbound/TCP, lokale private Server-IP:8080, entfernte Client-IP mit dynamischem Port, passende Region. Für effective NSG Vergleich; kein Capture-Service ungefragt aktivieren.

## G. Beobachtung und Interpretation

Management-Abfrage erfolgreich und Secret-Abfrage 403 ist möglich. Exakter Fehler kann Netzwerkfirewall, fehlende Rolle oder Tokenprobleme unterscheiden helfen; 403 alleine beweist keine einzelne Ursache. Eine NSG-Allow-Ausgabe sagt nichts über Vault-Berechtigungen. Activity Log zeigt nicht jeden Secret-Lesevorgang; Data-Plane-Diagnostics müssten separat konfiguriert werden und können Kosten/Retention erzeugen.

## H. Break & Fix

Ausgangszustand: Vault-Ressource existiert und ist vom Admin-/32 erreichbar. Sichere Fehleraktivierung: führe dieselbe Metadatenoperation als eigenes Konto ohne separat erteilte Secretrolle aus, sofern dies dein vorhandener Rollenstand ist. Keine Rechte entziehen. Symptom: ARM funktioniert, Secretoperation verweigert. Wenn du bereits berechtigt bist, benutze den reproduzierbaren FastAPI-401/403-Fall in Modul09. Auftrag: Netz vs Identität vs Rolle belegen.

## I. Selbstständige Challenge

Entwirf für server-vm die geringste Rolle, um genau einen synthetischen Secret zu lesen. Welche Principal-ID/Scope brauchst du? Welche zusätzliche Netzwerkfreigabe wäre nötig? Vergib keine Subscription-Rolle aus Bequemlichkeit. Optional realer Managed-Identity-Lesetest nach geprüfter Referenzlösung.

## J. Quiz

1. Warum löst Managed Identity keinen FastAPI-Endnutzerlogin?
2. Kann Contributor alle Secret-Werte lesen?
3. Beweist 403 die NSG als Ursache?
4. Was misst IP flow verify und was nicht?

## K. Erfolgskriterien

Du dokumentierst zwei Planes und eine konkrete Rolle/Scope/Principal-Zuordnung. Ein negativer und positiver Test sind korrekt als tatsächliche bzw. nicht ausgeführte Tests markiert. Keine Secret-/Tokeninhalte im Repo.

## L. Wiederherstellung und Cleanup

Keine vorhandenen Rollen verändern. Nur neu angelegte Lab-Rollenzuweisungen gezielt vom berechtigten Admin entfernen oder zusammen mit dem ressourcenspezifischen Scope im RG-Cleanup löschen. Vault soft delete beachten. Keine pauschalen Rollenlöschungen, kein automatischer Purge.

## M. Weiterführende Quellen

- [Key Vault RBAC](https://learn.microsoft.com/en-us/azure/key-vault/general/rbac-guide)
- [Managed Identity Überblick](https://learn.microsoft.com/en-us/entra/identity/managed-identities-azure-resources/overview)
- [IP flow verify](https://learn.microsoft.com/en-us/azure/network-watcher/ip-flow-verify-overview)

Lösungen erst nach eigenem Versuch: [separate Hinweise und Lösung](solutions.md).
