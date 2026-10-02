# 02 – Linux-Services und Betrieb

[Zur Kursübersicht](../../ROADMAP.md) · [Kompetenznachweis](../../PROGRESS.md)

## A. Lernziele

Du unterscheidest Prozess und Service, sendest Signale gezielt, betreibst course-web mit systemd, findest Logs und ordnest CPU-, RAM- und Diskwerte ein.

## B. Voraussetzungen

[01](../01-linux-basics/README.md), Server-VM, `~/course` aus Getting Started. Kein Service lokal auf macOS installieren.

## C. Verständliche Theorie

Ein manuell im Terminal gestarteter Webprozess hängt an deiner Sitzung. Ein Service Manager wie systemd definiert Benutzer, Startbefehl, Restart-Verhalten und Bootstart. `enable` aktiviert Start bei Boot, `start` startet jetzt, `daemon-reload` liest geänderte Unit-Dateien neu; diese Aktionen sind verschieden.

Ein Prozess erhält Signale: SIGTERM bittet um geordnetes Beenden, SIGKILL erzwingt es ohne Cleanup. systemd soll den Prozess verwalten, darum zuerst `systemctl stop`, nicht wahllos `kill -9`. Unser Dienst läuft als eigener Systembenutzer `courseweb` ohne Login-Shell und nutzt nur Port 8080; privilegiertes root ist zum Installieren, nicht zum Bedienen der HTTP-Requests nötig.

Logs sind Messungen am Server. `journalctl -u` grenzt nach Unit ein; Boot/Zeitfenster vermeiden alte Fehler. CPU-Last, Arbeitsspeicher und Datenträger sind getrennte Engpässe: freier RAM alleine erklärt keine Disk-Wartezeit. Linux nutzt RAM als Cache, `available` ist oft aussagekräftiger als nur `free`. Kleine B1s haben wenig RAM und CPU-Burstlimits; dies ist kein Performance-Benchmark.

## D. Architektur oder Ablauf

systemd → `/usr/bin/python3 /opt/course-web/web.py` als courseweb → Listener `0.0.0.0:8080` → `/health` → stdout/stderr ins Journal. Der Clienttest folgt nach lokaler Verifikation.

## E. Befehle mit Erklärung

[SERVER-VM — ~/course]
```bash
cd ~/course
sudo bash scripts/install-service.sh
systemctl is-active course-web
systemctl is-enabled course-web
sudo journalctl -u course-web -b -n 30 --no-pager
ps -eo pid,user,pcpu,pmem,args --sort=-pcpu | head
free -h
df -h /
```
`-b` aktueller Boot, `-n 30` letzte 30 Einträge, `--no-pager` ohne interaktive Ansicht. `df` misst Dateisystemkapazität, nicht Dateigröße eines einzelnen Programms. Installationsskript prüft den Kurs-VM-Marker.

## F. Guided Lab

1. Lies examples/course-web.service und benenne Unit-, Service- und Install-Abschnitt.
2. Installiere mit obigem Skript, prüfe active/enabled und den Prozessbenutzer.
3. Rufe lokal `/health` mit curl auf, danach `/missing`; vergleiche Journal und HTTP-Status.
4. Stoppe und starte den Dienst bewusst. Prüfe jeweils `ss -lntp` und curl.
5. Ermittle die konkrete PID aus systemctl, nicht aus vermuteten Zahlen. Erkläre, warum `Restart=on-failure` einen bewussten systemctl stop nicht automatisch rückgängig macht.

## G. Beobachtung und Interpretation

[SERVER-VM]
```bash
curl -i --max-time 5 http://127.0.0.1:8080/health
curl -i --max-time 5 http://127.0.0.1:8080/missing
sudo ss -lntp '( sport = :8080 )'
```
Erwartet: HTTP 200 + JSON bei health, HTTP 404 bei missing. 404 ist erfolgreicher HTTP-Verkehr zur falschen Ressource. Eine aktive Unit allein garantiert keinen Listener: der Prozess könnte noch initialisieren oder falsch konfiguriert sein.

## H. Break & Fix

Zwei getrennte Fälle; nach jedem wiederherstellen.

Fall 1 Ausgangszustand healthy. [SERVER-VM — ~/course]
[SERVER-VM — ~/course]
```bash
sudo bash scripts/service-fault.sh stopped break
```
Symptom: Client-/Loopback-Aufruf scheitert. Auftrag: Prozessstatus und Listener prüfen.

Fall 2 Ausgangszustand wieder healthy. [SERVER-VM]
[SERVER-VM]
```bash
sudo bash scripts/service-fault.sh unit break
```
Symptom: systemd kann Dienst nicht starten. Auftrag: Hauptunit und Drop-in vergleichen, genaue Startfehlermeldung ermitteln. Kein SSH ändern.

## I. Selbstständige Challenge

Ergänze ein eigenes Drop-in nur für diesen Kursdienst mit `RestartSec=5`. Zeige mit `systemctl cat`, welche Konfiguration effektiv gilt. Entferne es anschließend. Keine absichtliche CPU-/RAM-Erschöpfung erzeugen.

## J. Quiz

1. Warum bewirkt enable nicht zwangsläufig einen sofortigen Start?
2. Wieso nach Änderung der Datei daemon-reload?
3. Was sagt status=203/EXEC typischerweise?
4. Warum ist 404 kein NSG-Beweis?

## K. Erfolgskriterien

Du betreibst einen Service als courseweb, korrelierst Status/Listener/Journal und löst beide Fälle mit dokumentiertem Erfolgstest. Du kannst ein systemd-Drop-in erklären und entfernen.

## L. Wiederherstellung und Cleanup

[SERVER-VM — ~/course]
```bash
sudo bash scripts/service-fault.sh stopped restore
sudo bash scripts/service-fault.sh unit restore
curl --fail --max-time 5 http://127.0.0.1:8080/health
```
Service bleibt für folgende Module aktiv. VMs/RG bestehen; Pausen/Cleanup nach zentraler Anleitung.

## M. Weiterführende Quellen

- [systemd Service-Manpage (Upstream)](https://github.com/systemd/systemd/blob/main/man/systemd.service.xml)
- Ubuntu lokal: `man systemctl`, `man journalctl`, `man systemd.service`

Lösungen erst nach eigenem Versuch: [separate Hinweise und Lösung](solutions.md).
