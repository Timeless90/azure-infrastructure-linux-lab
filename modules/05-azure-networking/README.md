# 05 – Azure-Infrastruktur und Networking

[Zur Kursübersicht](../../ROADMAP.md) · [Kompetenznachweis](../../PROGRESS.md)

## A. Lernziele

Du erklärst Subscription/RG/Region, VM/NIC/Public IP, VNet/Subnet, NSG, UDR und Peering. Du prüfst effektive Regeln/Routen und diagnostizierst einen NSG-Fehler.

## B. Voraussetzungen

[04](../04-network-diagnostics/README.md), Basis bereitgestellt, Azure CLI lokal angemeldet, lab.json vorhanden. VMs laufen; effective route/NSG kann bei deallocated VMs nicht verfügbar sein.

## C. Verständliche Theorie

Subscription ist die Abrechnungs-/Verwaltungsgrenze; RG fasst Lebenszyklen zusammen, Region bestimmt Standort/Verfügbarkeit. VM ist Compute, NIC verbindet Compute und Netzwerk, Public IP ist eine explizite externe Adresse. VNet definiert Adressraum, Subnet segmentiert ihn. Keines dieser Objekte allein ist ein Anwendungslogin.

NSG-Regeln bewerten Quelle, Ziel, Protokoll und Ports; kleinere Prioritätszahl gewinnt vor größerer. Regeln an Subnetz und NIC müssen gemeinsam passen. Unsere NSGs liegen an Subnetzen; NICs haben keine zusätzliche NSG. NSGs sind stateful: Änderungen unterbrechen vorhandene erlaubte Flows nicht zwangsläufig. Darum teste frische Verbindungen.

Eine Route Table enthält User Defined Routes (UDR). Effektive Routen enthalten außerdem Azure-Systemrouten. Longest Prefix Match wählt zuerst den spezifischsten Zielbereich; bei gleicher Präfixlänge gilt die jeweilige Azure-Priorität von UDR/BGP/System. Eine `None`-Route verwirft Verkehr. Eine leere Route Table im Basislab ändert die Standardrouten nicht.

Peering verbindet zwei nicht überlappende VNets über private Adressen, ist kein automatisches transitives Netzwerk. Wir bauen kein zweites VNet im Kernlab: du kannst die Konsequenz anhand des Adress- und Routenmodells erklären. Für Produktion kommen separate Gateway-/Transitentscheidungen dazu.

## D. Architektur oder Ablauf

Siehe [Architektur](../../docs/architecture.md). Regeln: admin-ssh 100, client-web 200, deny-other-inbound 4096. Der Fehler ergänzt Deny 150 nur Client/32 → Server/32:8080, schlägt also die Allow-Regel 200, ohne 22 zu beeinflussen.

## E. Befehle mit Erklärung

[AZURE-CLI-TERMINAL — Repository-Wurzel]
```bash
source scripts/common.sh
load_lab
guard_rg
az network nic list-effective-nsg -g "$RG" -n server-nic --subscription "$SUBSCRIPTION" -o json
az network nic show-effective-route-table -g "$RG" -n client-nic --subscription "$SUBSCRIPTION" -o table
az network vnet subnet show -g "$RG" --vnet-name course-vnet -n client-subnet   --subscription "$SUBSCRIPTION" --query '{nsg:networkSecurityGroup.id,route:routeTable.id,outbound:defaultOutboundAccess}' -o json
```
`-g` ist RG, `-n` Ressourcenname, `--query` JMESPath selektiert Ausgabe. Explizite Subscription verhindert versteckte Default-Wechsel. Regeln/Routen sind Management-Sicht, kein Diensttest.

## F. Guided Lab

1. Zeichne Ressourcenabhängigkeiten aus main.bicep ohne es zu verändern.
2. Zeige effective NSG und Route Table. Finde die custom rules sowie Standardregeln.
3. Führe frischen Client-curl mit `Connection: close` aus; healthy ist Referenz.
4. Aktiviere den Fehler, vergleiche Regeln und Client-/Server-Messungen.
5. Stelle wieder her, prüfe denselben Test. Warum schafft serverseitiges ss keine Aussage über Fabric-NSG?

## G. Beobachtung und Interpretation

Ein Deny kann Client-Timeout verursachen, obwohl Dienst gesund bleibt. Rule-Output muss Richtung, IPs, Port und Priorität zusammen bestätigen. Effektive Routen zeigen VNet-Systemroute und Standard-Internetroute; Linuxroute alleine bildet diese nicht vollständig ab. Portal/CLI-Ausgaben können verzögert aktualisiert sein.

## H. Break & Fix

Ausgangszustand healthy. [AZURE-CLI-TERMINAL]
[AZURE-CLI-TERMINAL]
```bash
bash scripts/azure-fault.sh nsg break
```
[CLIENT-VM]
```bash
curl -H 'Connection: close' --connect-timeout 3 --max-time 5 "http://$SERVER_IP:8080/health"
```
Symptom: neuer Request scheitert. Diagnoseauftrag: konkrete wirksame Regel identifizieren, Dienststatus separat prüfen. Nur benannten Fehler wiederherstellen.

## I. Selbstständige Challenge

Entwirf auf Papier eine neue Allow-Regel für genau einen zweiten Lab-Client und einen anderen Port. Welche Parameter ändern sich? Warum muss der Listener ebenfalls vorhanden sein? Optional keine zweite VM kostenpflichtig erstellen.

## J. Quiz

1. Welche Regel gewinnt: Allow 200 oder Deny 150?
2. Warum kann ein bestehender Request weiter funktionieren?
3. Sind Peerings transitiv?
4. Warum ist NIC-Routing nicht mit Linuxroute identisch?

## K. Erfolgskriterien

Du erklärst jedes Basisobjekt, weist eine wirksame Regel anhand tatsächlicher Ausgabe nach, behebst Deny ohne Port22-/Internetöffnung und beweist HTTP nach Restore.

## L. Wiederherstellung und Cleanup

[AZURE-CLI-TERMINAL]
```bash
bash scripts/azure-fault.sh nsg restore
```
Frischen Clienttest wiederholen. `fault-web` ist gelöscht, Basisregeln/VMs bestehen. Kein automatischer Merge und kein Cloud-Cleanup aus CI.

## M. Weiterführende Quellen

- [NSG Überblick](https://learn.microsoft.com/en-us/azure/virtual-network/network-security-groups-overview)
- [Routing](https://learn.microsoft.com/en-us/azure/virtual-network/virtual-networks-udr-overview)
- [AZ-700 ergänzende Labs](https://github.com/MicrosoftLearning/AZ-700-Designing-and-Implementing-Microsoft-Azure-Networking-Solutions)

Lösungen erst nach eigenem Versuch: [separate Hinweise und Lösung](solutions.md).
