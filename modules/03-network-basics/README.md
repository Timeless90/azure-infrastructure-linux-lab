# 03 – Netzwerkgrundlagen

[Zur Kursübersicht](../../ROADMAP.md) · [Kompetenznachweis](../../PROGRESS.md)

## A. Lernziele

Du erklärst IPv4/CIDR, Next Hop, TCP/UDP, Port, DNS, NAT und HTTP/TLS an einer eigenen Verbindung. Du unterscheidest private Adresse, Public IP und Loopback.

## B. Voraussetzungen

[02](../02-linux-services/README.md), healthy course-web; Client-Terminal mit SERVER_IP wie Getting Started initialisiert. Python3/ip/curl sind auf VMs installiert.

## C. Verständliche Theorie

Ein FastAPI-Request besteht aus mehreren Entscheidungen. Ein DNS-Name muss auf eine Adresse abgebildet werden; eine Route wählt Interface und Next Hop; Netzwerkregeln lassen Pakete zu; ein Prozess muss am Zielport lauschen; optional TLS authentifiziert den Server; HTTP trägt Pfad/Status; die Anwendung prüft Identität und Berechtigungen. Diese Schritte sind nicht austauschbar.

IPv4 hat 32 Bits. Bei `/24` sind 24 Netzbits fest, 8 Hostbits variabel: 256 Adressen insgesamt. Ein VNet `/16` kann viele `/24` enthalten. Das heißt nicht, dass alle Adressen verwendbar sind: Azure reserviert fünf pro Subnetz. `10.10.1.4` und `10.10.2.4` liegen in unterschiedlichen /24-Netzen, aber innerhalb desselben /16-VNet. Azure routet zwischen Subnetzen, sofern keine andere wirksame Route/Regel den Verkehr verhindert.

TCP baut mit SYN, SYN-ACK und ACK einen zustandsbehafteten Transport auf. Der Quellport des Clients ist typischerweise dynamisch, der Zielport 8080 ist unser Listener. UDP hat keinen entsprechenden Handshake; aus fehlender Antwort ist dessen Portzustand schwerer abzuleiten. Ping verwendet ICMP, nicht TCP. DNS nutzt häufig UDP/53, kann aber TCP verwenden. Eine erfolgreiche DNS-Antwort baut noch keine HTTP-Verbindung auf.

NAT übersetzt Adressen. Internet-Egress der VM nutzt hier die zugewiesene Public IP; VM-zu-VM-Verkehr nutzt private Adressen und benötigt diesen Internet-NAT-Weg nicht. TLS auf 443 ist eine Konvention, kein Naturgesetz. HTTP auf 8080 ist in der Basis unverschlüsselt, enthält aber ausschließlich synthetische Daten.

## D. Architektur oder Ablauf

Beispiel eines einzelnen Flows: Client `10.10.1.4:<dynamisch>` → Server `10.10.2.4:8080`; die Antwort läuft zurück zu genau diesem Quellport. Von Arbeitsplatz → Public IP/22 ist ein anderer Flow mit anderer Quelle und anderen Regeln.

## E. Befehle mit Erklärung

[CLIENT-VM]
```bash
: "${SERVER_IP:?Server-IP zuerst aus Outputs setzen}"
ip -4 addr
ip -4 route
ip route get "$SERVER_IP"
curl -v --connect-timeout 3 --max-time 5 "http://$SERVER_IP:8080/health"
```
`ip route get` fragt die Kernelentscheidung für genau dieses Ziel ab. Es zeigt oft Gateway/Interface und gewählte Source-Adresse. `curl -v` zeigt Verbindungs- und HTTP-Schritte, ist bei echten Tokens ungeeignet für öffentliche Lognotizen.

## F. Guided Lab

1. Berechne mit Python die beiden Beispielnetze und vergleiche Membership. Keine Netzwerkeinstellungen verändern.
2. Führe route get aus und zeichne Quelle/Ziel/Next Hop. Vergleiche deine realen Werte mit der Architektur.
3. Rufe `/health` über private IP auf; erkläre, warum DNS hierfür nicht gebraucht wird.
4. Rufe die gleiche IP mit falschem Port 8081 auf. Ordne einen Refusal/Timeout erst nach Server-Listenerprüfung ein.
5. Auf Server: Loopback-Aufruf und private-IP-Aufruf vergleichen. Ein funktionierendes Loopback ist noch kein Nachweis vom Client.

## G. Beobachtung und Interpretation

[CLIENT-VM]
```bash
python3 - <<'EOF'
import ipaddress
n=ipaddress.ip_network('10.10.0.0/16')
for s in ('10.10.1.0/24','10.10.2.0/24'):
    x=ipaddress.ip_network(s)
    print(s, 'Adressen:',x.num_addresses,'im VNet:',x.subnet_of(n))
EOF
```
Diese Zahlen sind berechnete Beispiele. Eine Traceroute kann wegen Azure-Fabric/ICMP-Filter keine Zwischenhops anzeigen, obwohl TCP funktioniert. Die Linux-Gastroute zeigt den Azure-NIC-Gateway, nicht alle Fabric-Routen.

## H. Break & Fix

Ausgangszustand: health auf 8080 funktioniert. Sichere Aktivierung: verwende nur im einzelnen Request 8081 statt 8080. [CLIENT-VM]
[CLIENT-VM]
```bash
curl -v --connect-timeout 3 --max-time 5 "http://$SERVER_IP:8081/health"
```
Symptom: Request schlägt fehl. Diagnoseauftrag: stimmt Zielport mit Anwendung und NSG überein? Keine pauschale Freigabe hinzufügen.

## I. Selbstständige Challenge

Berechne Adressmenge und Azure-nutzbare Menge für ein eigenes /27 und zeige, ob zwei gewählte private IPs darin liegen. Erkläre, warum ein Netzmaskenfehler die Route ändern kann, ohne dass du eine fehlerhafte Maske auf deinem Rechner setzt.

## J. Quiz

1. Warum zeigt DNS-Erfolg keinen Listener?
2. Welcher Port ist für die Rückantwort relevant?
3. Warum schließt fehlender Ping TCP-Erfolg nicht aus?
4. Wie viele Adressen hat /27, wie viele reserviert Azure?

## K. Erfolgskriterien

Du zeichnest einen vollständigen TCP-Flow mit Quelle/Ziel/Ports; berechnest /24 und /27; erklärst IP-, HTTP- und Berechtigungsfehler als unterschiedliche Ebenen.

## L. Wiederherstellung und Cleanup

Wieder 8080 im Request verwenden; keine Infrastruktur geändert. Service/VMs bleiben aktiv. Keine Default-Route auf Arbeitsplatz oder VM verändern.

## M. Weiterführende Quellen

- [Azure Routing](https://learn.microsoft.com/en-us/azure/virtual-network/virtual-networks-udr-overview)
- [ip route Manpage](https://man7.org/linux/man-pages/man8/ip-route.8.html)

Lösungen erst nach eigenem Versuch: [separate Hinweise und Lösung](solutions.md).
