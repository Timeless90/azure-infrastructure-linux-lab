# 04 – Linux-Netzwerkdiagnose

[Zur Kursübersicht](../../ROADMAP.md) · [Kompetenznachweis](../../PROGRESS.md)

## A. Lernziele

Du wählst ip/ss/ping/tracepath/curl/dig/nc/nmap/tcpdump/openssl nach einer Hypothese. Du interpretierst Messpunkte und open/closed/filtered mit Grenzen.

## B. Voraussetzungen

[03](../03-network-basics/README.md), healthy course-web, beide SSH-Terminals, SERVER_IP gesetzt. Nur eigene Server-IP und Ports 8080/8081 scannen.

## C. Verständliche Theorie

Ein Listener ist lokal: `ss` fragt Kernel-Sockets des aktuellen Namespace ab. `0.0.0.0:8080` bindet alle IPv4-Interfaces, `127.0.0.1:8080` nur Loopback. `0.0.0.0` ist keine Client-Zieladresse. `ss -p` zeigt Prozessinformationen vollständig häufig erst mit sudo.

Erreichbarkeit misst ein anderer Host. Nmap `open` heißt, dass der gewählte Scan eine annehmende Anwendung sieht; `closed` typischerweise eine erreichbare Adresse mit aktivem Refusal, `filtered` ein nicht eindeutig erreichbares Ziel wegen Filterindikatoren oder fehlender relevanter Antwort. Das ist ein Ergebnis aus diesem Messpunkt, keine globale Porteigenschaft. NSG, Hostfirewall, Route und Rückweg können sich im Symptom überlagern.

Packet Capture sieht nur Pakete am Capture-Punkt. Client-SYN ohne Antwort beweist nicht, wo es verloren ging. Server-SYN und SYN-ACK, aber kein Client-ACK macht einen Rückweg-/Clientfehler plausibel. Ein verschlüsselter TLS-Capture zeigt keine HTTP-Inhalte. Auch NIC-Offloads können scheinbar falsche Prüfsummen verursachen; nicht vorschnell als Schaden werten.

## D. Architektur oder Ablauf

Zwei parallele Messpunkte: CLIENT-VM sendet einen frischen HTTP-Request; SERVER-VM betrachtet nur den eigenen synthetischen Port 8080. DNS-Abfrage, Kernelroute, TCP-Scan und HTTP-Test werden getrennt protokolliert.

## E. Befehle mit Erklärung

[CLIENT-VM]
```bash
: "${SERVER_IP:?Aus Outputs initialisieren}"
ip route get "$SERVER_IP"
ping -c 2 "$SERVER_IP"
tracepath "$SERVER_IP"
nc -vz -w 3 "$SERVER_IP" 8080
nmap -sT -Pn -n -p 8080,8081 --reason "$SERVER_IP"
dig example.invalid A
```
`-Pn` überspringt Host Discovery, `-n` verhindert Reverse-DNS, `-p` beschränkt auf zwei explizite Ports, `-sT` ist TCP Connect. Kein `-A` oder fremdes Netz. `example.invalid` ist eine reservierte synthetische nicht existierende Domain; DNS-Negativtest, kein Scan. Ping/tracepath dürfen hier wegen NSG scheitern.

## F. Guided Lab

1. Auf Server `sudo ss -lntp '( sport = :8080 )'`; notiere Binding.
2. Auf Client nc, Nmap und curl ausführen. Vergleiche: TCP offen, HTTP 200, falscher Port möglicherweise filtered.
3. Server-Capture starten; Client in zweitem Terminal `/health` aufrufen. Capture endet nach Zeit oder Paketgrenze.
4. Löse den Loopback-Fehler unten, indem du mindestens zwei Messpunkte nutzt.
5. Ergänze einen DNS-Abgleich: `getent hosts example.invalid` versus dig. `getent` nutzt NSS, dig fragt DNS; ein Unterschied ist erklärbar, nicht automatisch Defekt.

## G. Beobachtung und Interpretation

[SERVER-VM — Capture nur im Vordergrund]
```bash
sudo timeout 15 tcpdump -ni any -c 12 'tcp port 8080'
```
`-i any` alle Gastinterfaces, `-n` keine Namen, `-c 12` begrenzte Paketanzahl. Kein `-A`, kein Disk-Capture erforderlich. Starte nun den Request vom Client. SYN, SYN-ACK, ACK und Daten sind typische mögliche Beobachtungen, keine behauptete Ausgabe. Filter weiter auf Client-IP einschränken, wenn anderer Lab-Verkehr existiert.

## H. Break & Fix

Ausgangszustand: healthy Service. [SERVER-VM — ~/course]
[SERVER-VM — ~/course]
```bash
sudo bash scripts/service-fault.sh loopback break
curl --max-time 5 http://127.0.0.1:8080/health
```
Symptom: lokales health klappt, vom Client nicht. Diagnoseauftrag: Binding, private Ziel-IP und NSG unterscheiden. SSH bleibt erhalten. Kein Servicecode und keine NSG-Freigabe auf alle Quellen verändern.

## I. Selbstständige Challenge

Untersuche `/missing` vom Client. Belege Transporterfolg und HTTP-Fehler gleichzeitig. Entwickle eine Testmatrix für Listener an 127.0.0.1 gegenüber 0.0.0.0 mit lokalem/entferntem Messpunkt.

## J. Quiz

1. Warum ist open kein HTTP-Healthcheck?
2. Was kann ein leerer Server-Capture bedeuten?
3. Warum `-Pn`, wenn Ping blockiert ist?
4. Warum liefern dig und getent nicht zwingend dieselbe Sicht?

## K. Erfolgskriterien

Du ordnest alle zehn Tools einer Frage zu, löst Loopback anhand von ss+curl, interpretierst die Capture mit mindestens einer alternativen Erklärung und dokumentierst einen Negativtest.

## L. Wiederherstellung und Cleanup

[SERVER-VM — ~/course]
```bash
sudo bash scripts/service-fault.sh loopback restore
```
[CLIENT-VM]
```bash
curl --fail --max-time 5 "http://$SERVER_IP:8080/health"
```
Capture mit Ctrl-C beenden, keine Captures committen. VMs weiter aktiv.

## M. Weiterführende Quellen

- [Nmap Port States](https://nmap.org/book/man-port-scanning-basics.html)
- [tcpdump Upstream-Manpage](https://github.com/the-tcpdump-group/tcpdump/blob/master/tcpdump.1.in)
- [Diagnose-Cheatsheet](../../cheatsheets/diagnosis.md)

Lösungen erst nach eigenem Versuch: [separate Hinweise und Lösung](solutions.md).
