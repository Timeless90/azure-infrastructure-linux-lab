# Optionale Vertiefungen – keine Kernlab-Voraussetzung

Diese Themen sind Architekturstudien mit eigener Challenge, keine zusätzlich vorab deployten oder cloudvalidierten Voll-Labs. Alle können Grundkosten verursachen; vor jeder Umsetzung Preise, Region, Quota und vollständige Rückbauschritte separat planen.

| Thema | Welches Problem löst es? | Eigene Designchallenge | Kosten-/Betriebsgrenze |
|---|---|---|---|
| NAT Gateway | gemeinsames explizites Egress ohne VM-Public-IP | Wie ersetzt du beide IPs, ohne SSH-Zugang zu verlieren? | Gateway-Stunden, IP und Daten, kein Inboundzugang |
| Bastion | verwalteter SSH-Zugang zu privaten VMs | Vergleiche nutzbaren SKU/Region mit eingeschränktem direktem SSH | SKU/Region unterschiedlich, laufende Kosten möglich |
| Azure Firewall | zentrale Policy und kontrolliertes Egress | Zeichne UDR + Firewall + Rückweg | teuerer als Kernlab, eigener Subnetzentwurf |
| Hub-and-Spoke | zentrale Dienste für mehrere VNets | Erkläre nichttransitives Peering und Transit | Peeringdaten, ggf. Gateway/Firewall zusätzlich |
| Private DNS Resolver | hybride Namensauflösung ohne selbst betriebene Forwarder | Welche Richtung braucht Inbound/Outbound Endpoint? | dedizierte Subnetze, laufende Dienstkosten |
| Application Gateway | regionales HTTP-Routing/TLS/WAF | Trenne Client→Gateway und Gateway→Backend mit Healthprobe | Gateway/Capacity/TLS-Konfiguration |
| Front Door | globaler Edge-Einstieg, Routing und optional WAF | Zeichne Public Origin versus Private Link Origin | SKU, Requests/Daten und ggf. Premium-Features |

Bewerte pro Thema zuerst Nutzen, Daten-/Managementpfad und Cleanupgrenze. Keine dieser Erweiterungen wird automatisch durch Makefile oder Actions erstellt. Offizielle Einstiegspunkte: [Azure Networking](https://learn.microsoft.com/en-us/azure/networking/), [NAT](https://learn.microsoft.com/en-us/azure/nat-gateway/nat-overview), [Bastion](https://learn.microsoft.com/en-us/azure/bastion/bastion-overview).
