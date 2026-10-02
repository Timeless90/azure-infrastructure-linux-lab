# 02 – Hinweise und Lösungen

[Zur Aufgabenstellung](README.md)

## Fall 1: stopped

Hinweis 1: Ist die Unit aktiv? Hinweis 2: Gibt es überhaupt einen Listener? Lösung [SERVER-VM]: `sudo systemctl start course-web`. Erfolg: is-active und curl `/health` 200. Kein Netzwerkfix erforderlich.

## Fall 2: unit

Hinweis 1: Journal enthält präzisere Gründe als Client-Timeout. Hinweis 2: Ein Drop-in überschreibt ExecStart; `systemctl cat course-web` zeigt beides. Lösung [SERVER-VM — ~/course]:
[SERVER-VM — ~/course]
```bash
sudo journalctl -u course-web -b -n 40 --no-pager
systemctl cat course-web
sudo bash scripts/service-fault.sh unit restore
curl --fail --max-time 5 http://127.0.0.1:8080/health
```
Nicht existierender ausführbarer Pfad ist die injizierte Ursache; 203/EXEC ist ein möglicher systemd-Hinweis, nicht eine hier gemessene Ausgabe. Die Lösung entfernt ausschließlich course-fault.conf, lädt neu und startet wieder.

## Challenge

Hinweis 1: Drop-in-Verzeichnis ist `<unit>.d`. Hinweis 2: Editieren und daemon-reload sind zwei Schritte. Referenz [SERVER-VM]:
[SERVER-VM]
```bash
printf '[Service]
RestartSec=5
' | sudo tee /etc/systemd/system/course-web.service.d/challenge.conf
sudo systemctl daemon-reload
systemctl cat course-web
sudo rm /etc/systemd/system/course-web.service.d/challenge.conf
sudo systemctl daemon-reload
```
Kein Neustart erforderlich, um nur die geladene Konfiguration zu zeigen; für Laufzeitänderungen danach bewusst restart.

## Quiz

1. Bootstart-Symlink und aktueller Prozesszustand sind unabhängig. 2. systemd hält die geladene Konfiguration, bis sie neu gelesen wird. 3. Ausführungsproblem wie falscher Pfad/Rechte; genaue Journalmeldung prüfen. 4. Eine HTTP-Antwort impliziert bereits erfolgreichen Transport für diesen Request.
