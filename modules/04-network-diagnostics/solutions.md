# 04 – Hinweise und Lösungen

[Zur Aufgabenstellung](README.md)

## Break & Fix

Hinweis 1: Lokaler Erfolg schließt ein Bindingproblem nicht aus. Hinweis 2: `ss` zeigt die lokale Socketadresse. Lösung [SERVER-VM]:
[SERVER-VM]
```bash
sudo ss -lntp '( sport = :8080 )'
systemctl cat course-web
cd ~/course
sudo bash scripts/service-fault.sh loopback restore
```
Der Drop-in setzt `--host 127.0.0.1`; entferne ihn gezielt. Danach Client-curl und Server-ss erneut. Der Managementzugang wurde nicht verändert.

## Challenge

Hinweis 1: `curl -i` trennt Status und Body. Hinweis 2: Der Testpfad ist nicht health. Referenz: TCP offen und HTTP 404 sind gleichzeitig möglich, weil die Anwendung eine Ressource nicht kennt. Matrix: 127-Bind → Loopback ja, eigene NIC nein, remote nein. 0.0.0.0-Bind → beide lokal ja, remote nur bei erlaubtem Pfad/Regeln. Keine Behauptung „remote immer ja“.

## Quiz

1. TCP-Annahme ≠ korrekte HTTP-Ressource. 2. Kein Paket, falscher Filter/Interface/Namespace, falsches Ziel oder Timing. 3. Host Discovery kann negativ sein, obwohl erlaubter TCP-Port erreichbar ist. 4. NSS kann Hosts-Datei/Cache einbeziehen, dig fragt einen DNS-Resolver.

## Toolfragen

`ip addr`: welche lokalen Adressen? `ip route`: welche Regeln? `route get`: welche konkrete Auswahl? `ss`: welcher Socket? `ping`: ICMP-Antwort? `tracepath`: sichtbare Hops/MTU-Hinweise? `dig`: DNS-Antwort? `nc`: TCP-Aufbau? `nmap`: Zustandsinterpretation für benannte Ports? `tcpdump`: welche Pakete hier? `curl`: HTTP/optional TLS? `openssl s_client`: TLS-Vertrauen und Name? TLS-Praxis kommt in Modul 10.
