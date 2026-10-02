# 10 – Systematisches Troubleshooting

[Zur Kursübersicht](../../ROADMAP.md) · [Kompetenznachweis](../../PROGRESS.md)

## A. Lernziele

Du entwickelst prüfbare Hypothesen, grenzt DNS→Route→Regeln→TCP→TLS→HTTP→App ein und belegst einen isolierten Routen- sowie TLS-Fehler.

## B. Voraussetzungen

[09](../09-containers-aca/README.md), healthy Basisservice wieder aktiv; keine anderen Fehler. OpenSSL installiert. HTTPS-Lab nur auf Server-Loopback8443, kein NSG-Webport erweitern.

## C. Verständliche Theorie

Diagnose ist ein Entscheidungsprozess. Ein einzelner negativer Test kann mehrere Ursachen haben. Vergleiche zuerst bekannte Baseline und ein gezielt verändertes Merkmal. Halte Messpunkte getrennt: Client hat andere DNS/Route als Server, Container andere Loopback-Sicht als Host, ARM andere Rechte als Data Plane.

TLS verbindet Verschlüsselung mit Identitätsprüfung. Ein Zertifikat hat Namen (SAN), Gültigkeit und Vertrauenskette. Ein selbstsigniertes Labzertifikat kann explizit mit `--cacert` vertraut werden, ohne System-CA-Speicher zu ändern. Servername/SNI und validierter Hostname müssen zum beabsichtigten Ziel passen. `curl -k` deaktiviert Prüfung; es ist keine dauerhafte Reparatur. Wir benötigen es hier gar nicht.

Eine spezifische UDR /32 zum Server schlägt die größere VNet-Systemroute. Der Linux-Gast sieht dennoch seinen normalen Gateway; der Fehler entsteht erst in Azure-Fabric. Daher können identische `ip route get`-Ausgaben vor/nach Azure-UDR-Änderung auftreten. Direkte SSH-Flows von Arbeitsplatz zu Public-IP bleiben außerhalb des gezielt verworfenen Client→Server-Private-IP-Flows.

## D. Architektur oder Ablauf

Routenfall: client-subnet Route Table → `serverIp/32:None` → verworfene neue private Verbindung. TLS-Fall: Server-Loopback:8443 → synthetisches selbstsigniertes Zertifikat mit SAN `lab.test` → Client auf demselben Server prüft Trust und Name getrennt.

## E. Befehle mit Erklärung

[SERVER-VM]
```bash
mkdir -p ~/course-work/tls
cd ~/course-work/tls
umask 077
openssl req -x509 -newkey rsa:2048 -sha256 -nodes -days 2   -keyout lab.key -out lab.crt -subj '/CN=lab.test' -addext 'subjectAltName=DNS:lab.test'
openssl s_server -accept 127.0.0.1:8443 -cert lab.crt -key lab.key -www
```
Der private Key ist nur synthetisch, bleibt im VM-Home und wird nie committed. `-www` erzeugt Test-HTTP; `s_server` ist kein Produktionswebserver. Vordergrundterminal geöffnet lassen, zweites Server-SSH-Terminal für Tests verwenden.

## F. Guided Lab

[SERVER-VM — zweites Terminal]
```bash
cd ~/course-work/tls
curl --noproxy '*' --resolve lab.test:8443:127.0.0.1 --cacert lab.crt https://lab.test:8443/
openssl s_client -connect 127.0.0.1:8443 -servername lab.test   -verify_hostname lab.test -CAfile lab.crt -verify_return_error </dev/null
```
1. Prüfe TCP und erfolgreiche Namens-/Trust-Prüfung dieser synthetischen Umgebung.
2. Lass `--cacert` weg: default Truststore vertraut dem Labzertifikat nicht. Kein Systemzertifikat installieren.
3. Belasse CA und verbinde mit `wrong.test` statt `lab.test` per resolve auf dieselbe Loopback-IP: nur Name stimmt nicht.
4. Führe separat Routenfehler aus. Verwende [Diagnosemethode](../../docs/troubleshooting-method.md) und schreibe ein Incidentprotokoll.
5. Wiederhole nach jedem Fix denselben Test, nicht nur irgendeinen anderen erfolgreichen Request.

## G. Beobachtung und Interpretation

Bei default Trust scheitert TLS-Validierung, auch wenn TCP offen ist. Mit passender CA und falschem Namen ebenfalls; diese Fälle unterscheiden sich im Fehlermotiv. `openssl s_client` ohne verify_return_error kann trotz Validierungswarnungen weiterlaufen: Exitcode alleine ist dann kein strenger Trustnachweis. HTTP bei s_server ist synthetisch.

## H. Break & Fix

Fall Route, healthy Baseline und beide direkten SSH-Sitzungen offen. [AZURE-CLI-TERMINAL]
[AZURE-CLI-TERMINAL]
```bash
bash scripts/azure-fault.sh route break
```
Symptom: Client health scheitert, Server-Loopback health bleibt gesund. Auftrag: Gast- und Azure-Routing vergleichen, /32-Route nachweisen.

Fall TLS, Ausgangszustand obiger trusted Request klappt. [SERVER-VM]
[SERVER-VM]
```bash
cd ~/course-work/tls
curl --noproxy '*' --resolve wrong.test:8443:127.0.0.1 --cacert lab.crt https://wrong.test:8443/
```
Symptom: Name falsch bei gleichem Ziel/Port. Auftrag: Trust und Hostname getrennt erklären.

## I. Selbstständige Challenge

Du erhältst nur „timeout“, „certificate error“ und „403“ als drei Tickets. Erstelle für jedes mindestens zwei Hypothesen und einen diskriminierenden Test. Behandle 403 nicht automatisch als RBAC und timeout nicht automatisch als NSG.

## J. Quiz

1. Warum kann Linuxroute gesund aussehen, obwohl Azure verwirft?
2. Was macht `--cacert`, was nicht?
3. Warum kein dauerhaftes `-k`?
4. Welche Beobachtung falsifiziert „Service ist aus“, ohne den Remote-Pfad zu beweisen?

## K. Erfolgskriterien

Du löst Route und TLS mit bestätigter Baseline, dokumentierst Messpunkte/Alternativen und verwendest genaue Scope-/Namenskorrektur statt AllowAll oder deaktiviertem Trust.

## L. Wiederherstellung und Cleanup

[AZURE-CLI-TERMINAL]
```bash
bash scripts/azure-fault.sh route restore
```
Client health erneut prüfen. TLS-Terminal Ctrl-C; nur selbst erzeugte `~/course-work/tls/lab.key` und lab.crt entfernen. Kein System-Truststore verändert. VMs und Erweiterungen bleiben bis RG-Cleanup bestehen.

## M. Weiterführende Quellen

- [OpenSSL s_client](https://docs.openssl.org/3.0/man1/openssl-s_client/)
- [Azure UDR](https://learn.microsoft.com/en-us/azure/virtual-network/virtual-networks-udr-overview)
- [WhatTheHack als ergänzende Challenges](https://github.com/microsoft/WhatTheHack)

Lösungen erst nach eigenem Versuch: [separate Hinweise und Lösung](solutions.md).
