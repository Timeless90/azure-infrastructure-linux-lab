# 05 – Hinweise und Lösungen

[Zur Aufgabenstellung](README.md)

## Break & Fix

Hinweis 1: Ein unveränderter Listener bei neuem Timeout spricht für die Strecke, beweist aber nicht NSG. Hinweis 2: effective-nsg muss `fault-web`, Deny, Inbound, TCP/8080, Client/32 und Server/32 enthalten. Referenz [AZURE-CLI-TERMINAL]:
[AZURE-CLI-TERMINAL]
```bash
source scripts/common.sh
load_lab
guard_rg
az network nsg rule show -g "$RG" --nsg-name server-nsg -n fault-web --subscription "$SUBSCRIPTION" -o json
bash scripts/azure-fault.sh nsg restore
```
Neue curl-Verbindung muss wieder 200 liefern. Keine generische AllowAll-Regel: damit verdeckst du die Ursache und überschreitest die Architektur.

## Challenge

Hinweis 1: Sicherheitsregel und Socket sind unabhängige Voraussetzungen. Hinweis 2: Quelle /32 und Ziel /32 statt VNet-All. Referenz: Source=zweite eigene Client-IP/32, Destination=Server-IP/32, TCP, benötigter Zielport, eng begrenzte Priorität oberhalb Deny4096. Ohne Listener kommt trotz Allow kein App-Erfolg. Dies ist Designnachweis, keine tatsächlich ausgeführte Infrastrukturänderung.

## Quiz

1. 150. 2. NSG stateful, schon angelegter Flow kann bestehen. 3. Nein, separater Transitentwurf nötig. 4. Azure Fabric kombiniert System-, UDR- und ggf. BGP-Routen außerhalb des Gastkernels.
