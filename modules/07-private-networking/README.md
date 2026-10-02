# 07 – Private Networking und ausgehender Verkehr

[Zur Kursübersicht](../../ROADMAP.md) · [Kompetenznachweis](../../PROGRESS.md)

## A. Lernziele

Du unterscheidest PE, Private DNS und Service Endpoint, erklärst explizites Egress und weist privaten Storage-Zugriff getrennt von Berechtigung nach.

## B. Voraussetzungen

[06](../06-reproducible-infrastructure/README.md), Basis healthy, keine Route-/NSG-Fehler aktiv. Reader/Contributor für Storage/Private Link und DNS in Kurs-RG; Data-Plane-Lab hier bewusst anonym ohne echte Daten.

## C. Verständliche Theorie

Ein verwalteter Dienst ist nicht automatisch im VNet, nur weil er Azure heißt. Ein Private Endpoint (PE) ist eine private NIC für eine konkrete Dienst-Subresource, hier Blob. DNS muss den normalen Storage-Host im VNet zur privaten Adresse führen. Sonst verbindet die Anwendung sich möglicherweise weiter mit dem öffentlichen Endpoint.

Private DNS Zone ist die Namensdatenbank; der VNet-Link macht sie für Azure-DNS-Auflösung in diesem VNet nutzbar. Der Blob-Host bleibt `<account>.blob.core.windows.net`, nicht willkürlich die PE-IP. So passen TLS-Servername und Zertifikat. Eine nackte HTTPS-IP kann Name/Trust verletzen, obwohl das Netzwerk funktioniert.

Ein Service Endpoint verwendet weiterhin den öffentlichen Dienstnamen/Endpunkt, ergänzt aber Subnetzidentität und Dienstzugangssteuerung. Das ist eine andere Lösung als eine private Ziel-IP. Wir deployen nur PE, keinen zusätzlichen Service Endpoint. Blob Storage ist für diese Übung geeignet, weil keine dauerhaft laufende Datenbank nötig ist. PE und DNS können trotzdem laufende Kosten verursachen.

Die aktuelle Azure-Dokumentation beschreibt private Defaults neuer VNets API-abhängig; der Kurs setzt `defaultOutboundAccess:false` ausdrücklich. Public IP pro VM ist der explizite Outbound-Pfad. DNS/Route allein ermöglichen noch kein Internet-SNAT. PE-Traffic verbleibt auf privatem Weg; Internet-Egress für apt/pip ist ein eigener Flow.

## D. Architektur oder Ablauf

Client → Azure DNS → Blob-FQDN/CNAME → Private DNS A-Record → dynamische PE-IP im Server-Subnetz → Blob HTTPS/443. PE-Netzwerkpolicies sind in diesem Lab deaktiviert; keine Behauptung, dass server-nsg die PE-NIC schützt. Storage Public Network Access ist Disabled, RBAC bleibt unabhängig.

## E. Befehle mit Erklärung

[AZURE-CLI-TERMINAL — Repository-Wurzel]
```bash
bash scripts/extension.sh private-storage what-if
# KOSTENPFLICHTIG: PE, DNS, Storage; erst Kosten/Plan prüfen.
bash scripts/extension.sh private-storage deploy
source scripts/common.sh
load_lab
guard_rg
BLOB_HOST=$(az deployment group show -g "$RG" --subscription "$SUBSCRIPTION"   -n course-private-storage --query properties.outputs.blobHost.value -o tsv)
printf '%s\n' "$BLOB_HOST"
az network private-endpoint show -g "$RG" -n blob-pe --subscription "$SUBSCRIPTION"   --query '{connections:privateLinkServiceConnections,interfaces:networkInterfaces}' -o json
```
Übertrage nur den harmlosen Hostnamen ins Client-Terminal. PE-Adresse aus DNS/NIC vergleichen, niemals eine vermutete .5 verwenden.

## F. Guided Lab

[CLIENT-VM]
```bash
read -r -p 'blobHost aus Deployment-Output: ' BLOB_HOST
export BLOB_HOST
dig "$BLOB_HOST" A
getent ahostsv4 "$BLOB_HOST"
curl -i --connect-timeout 5 --max-time 15 "https://$BLOB_HOST/?comp=list"
```
1. DNS-Antwort mit private DNS A-Record und PE-NIC vergleichen.
2. Anonymen HTTPS-Request ausführen. Ein Fehlerstatus wegen fehlender Berechtigung ist hier erwartet; keine öffentliche Containerfreigabe erzeugen.
3. Im Azure-CLI-Terminal Storage publicNetworkAccess und allowBlobPublicAccess anzeigen.
4. Optional vom Arbeitsplatz denselben anonymen Request senden: DNS-/Netzpfad kann öffentlich anders aussehen; Ergebnis nicht mit VM-Messpunkt gleichsetzen.
5. Bearbeite den Resolverfehler unten.

## G. Beobachtung und Interpretation

Erwartet im Client: private Zieladresse im konfigurierten Server-Subnetz, erfolgreiche TLS-Verbindung und Storage-HTTP-Fehler ohne Zugang. Exakter 400/403-Code kann je Request/Dienststand variieren; notiere Header und Error Code. Das beweist keinen autorisierten Blob-Zugriff. Eine public IP trotz PE legt DNS-Link-/Resolverfehler nahe, ist aber erst mit Zone/Link/Resolver zu verifizieren.

## H. Break & Fix

Ausgangszustand: PE-DNS im Client funktioniert. Aktivierung verändert nur diese eine Anfrage, keine Hosts-Datei und keinen DNS-Server: [CLIENT-VM]
[CLIENT-VM]
```bash
curl --resolve "$BLOB_HOST:443:127.0.0.1" --connect-timeout 3 --max-time 5 "https://$BLOB_HOST/?comp=list"
```
Symptom: dig zeigt richtige private IP, curl scheitert trotzdem. Diagnoseauftrag: DNS-Abfrage gegenüber tatsächlich verwendetem Verbindungsziel unterscheiden; verbose Ausgabe prüfen.

## I. Selbstständige Challenge

Schreibe einen Plan für „Zone existiert, VNet-Link fehlt“. Welche zwei read-only Abfragen beweisen den Konfigurationsfehler, und welche Messung auf der VM zeigt die Auswirkung? Deaktiviere keinen echten Link, solange du nicht den Restoreplan geprüft hast.

## J. Quiz

1. Warum nicht direkt `https://<PE-IP>`?
2. Erteilt ein PE Blob-Leserechte?
3. Wie unterscheidet sich Service Endpoint von PE?
4. Warum bleibt Internet-Outbound trotz PE nötig?

## K. Erfolgskriterien

Du weist DNS→PE-Ziel nach, erklärst den anonymen HTTP-Fehler als Data-Plane-Problem und dokumentierst explizites Egress. Du löst den temporären falschen Zieladressentest ohne Firewalländerung.

## L. Wiederherstellung und Cleanup

Request ohne `--resolve` wiederholen; keine permanente DNS-Änderung erfolgt. Storage, PE und DNS bleiben für 08 bestehen; wenn du sie nicht brauchst, alle Kursressourcen über bestätigtes RG-Cleanup entfernen. Kein ungesicherter Ad-hoc-Löschbefehl für fremde Zonen.

## M. Weiterführende Quellen

- [Storage Private Endpoints](https://learn.microsoft.com/en-us/azure/storage/common/storage-private-endpoints)
- [Default Outbound](https://learn.microsoft.com/en-us/azure/virtual-network/ip-services/default-outbound-access)
- [Service Endpoints](https://learn.microsoft.com/en-us/azure/virtual-network/virtual-network-service-endpoints-overview)

Lösungen erst nach eigenem Versuch: [separate Hinweise und Lösung](solutions.md).
