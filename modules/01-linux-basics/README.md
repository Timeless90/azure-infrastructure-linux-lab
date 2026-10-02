# 01 – Linux-Grundlagen

[Zur Kursübersicht](../../ROADMAP.md) · [Kompetenznachweis](../../PROGRESS.md)

## A. Lernziele

Du navigierst sicher, leitest Ausgaben um, kombinierst Pipes und prüfst Rechte. Du erklärst Benutzer-/Gruppenidentität, sudo und die Rolle von SSH-Schlüsseln.

## B. Voraussetzungen

[Modul 00](../00-setup/README.md), fertige Client-VM mit cloud-init und SSH. Benutze ein nicht privilegiertes Client-Terminal. Keine Änderung am Arbeitsplatz.

## C. Verständliche Theorie

Dein FastAPI-Projekt ist eine Sammlung von Dateien; Linux interpretiert deren Pfade unabhängig vom Python-Importmodell. `/` ist der Dateisystemanfang, `~` dein Home, `.` der aktuelle Ort, `..` der übergeordnete. `/etc` enthält Konfiguration, `/var/log` veränderliche Logs, `/opt` hier unseren Kursdienst.

Ein Prozess hat Benutzer-ID und Gruppen. Dateirechte `rwx` gelten getrennt für Eigentümer, Gruppe und andere: an Dateien lesen/schreiben/ausführen; an Verzeichnissen Namen lesen/Einträge ändern/durchqueren. Eine Datei kann lesbar sein, aber ohne `x` am übergeordneten Verzeichnis trotzdem unerreichbar. `sudo` ist eine gezielte Rechteerhöhung; sudo vor jede Zeile zu setzen verdeckt Eigentumsfehler.

Standardausgabe (stdout) und Fehlerausgabe (stderr) sind getrennte Kanäle. Eine Pipe `|` transportiert standardmäßig stdout zum nächsten Prozess. `>` ersetzt eine Datei, `>>` hängt an; `2>` leitet stderr um. Umgebungsvariablen gehen nur nach `export` an Kindprozesse und werden nicht automatisch in anderen Terminals gesetzt. Ein SSH-Key ist kein allgemeines Azure-Passwort.

## D. Architektur oder Ablauf

Arbeitsbereich dieser Übung: ausschließlich `~/course-work/01`. Pipeline: synthetische Textdatei → `grep` → `sort` → Ergebnisdatei. Rechtefehler liegt an einer eigenen Datei, nicht an `/etc` oder SSH.

## E. Befehle mit Erklärung

[CLIENT-VM]
```bash
mkdir -p ~/course-work/01
cd ~/course-work/01
pwd
printf 'INFO ready
ERROR synthetic
INFO ready
' > events.txt
grep -n 'ERROR' events.txt
find . -type f -name '*.txt'
export COURSE_STAGE=linux
python3 -c 'import os; print(os.getenv("COURSE_STAGE"))'
id
ls -l events.txt
```
`-p` erstellt fehlende Verzeichnisse, `grep -n` zeigt Zeilennummern, `find .` bleibt im aktuellen Baum. Anführungszeichen verhindern ungewollte Shell-Auswertung. `ls -l` zeigt Rechte, Owner und Group; tatsächliche Werte protokollieren.

## F. Guided Lab

1. Erzeuge events.txt mit obigem Inhalt. Filtere `INFO`, sortiere und entferne doppelte Zeilen mit `sort -u`. Schreibe das Ergebnis nach info.txt.
2. Wechsle nach `~` und lies dieselbe Datei über absoluten Pfad. Erkläre, warum `cat events.txt` dort scheitert.
3. Setze `chmod 600 events.txt`, prüfe mit `ls -l`, lies als eigener Benutzer.
4. Erzeuge ein kleines Skript, das die Variable ausgibt, und starte es mit `bash`; vergleiche gesetzte/unset Variable. Keine geheimen Umgebungsvariablen ausgeben.
5. Prüfe `sudo -l`, interpretiere erlaubte Befehle. Nicht die vorhandenen Systemeinstellungen verändern.

## G. Beobachtung und Interpretation

Beispielinhalt des Filters: `INFO ready` einmal. Das ist ein vorgegebenes synthetisches Ergebnis, keine gemessene Ausgabe. Modus 600 bedeutet Owner read/write, andere keine Rechte; root kann häufig trotzdem zugreifen. Eine leere Variable ist nicht automatisch leerer Prozesskontext: eventuell wurde nicht exportiert.

## H. Break & Fix

Ausgangszustand: eigene events.txt lesbar. [CLIENT-VM]
[CLIENT-VM]
```bash
cd ~/course-work/01
chmod 000 events.txt
cat events.txt
```
Symptom: `Permission denied` als normaler Benutzer. Diagnoseauftrag: überprüfe Owner, Dateirechte und Verzeichnisrechte ohne sudo-Lesen. Stelle genau die nötigen Rechte wieder her.

## I. Selbstständige Challenge

Baue `~/course-work/01/shared/report.txt`: eigene Datei soll read/write für Owner, read für Group, keine Rechte für Other erhalten. Erkläre zusätzlich, welche Verzeichnisrechte eine Gruppenperson benötigen würde. Erzeuge keine neuen Systembenutzer für diesen Nachweis.

## J. Quiz

1. Was ist der Unterschied zwischen `>` und `>>`?
2. Warum ist Verzeichnis-`x` nicht „ein Verzeichnis starten“?
3. Warum kann `sudo cat` einen Rechtefehler verstecken?
4. Was sieht ein Kindprozess bei einer nicht exportierten Shellvariablen?

## K. Erfolgskriterien

Du reproduzierst Filter und Rechtefehler, begründest Modus 640/600 und verwendest absolute/relative Pfade ohne Raten. Notiere mindestens eine eigene Beobachtung zu Pipe, Variable und Rechten.

## L. Wiederherstellung und Cleanup

`chmod 600 events.txt` stellt Owner-Zugriff wieder her. Optional eigene Dateien unter `~/course-work/01` einzeln entfernen, kein rekursives privilegiertes Löschen. VMs und Cloud-Ressourcen bleiben bestehen.

## M. Weiterführende Quellen

- [Ubuntu Linux Upskill Challenge](https://linuxupskillchallenge.org/) als zusätzliche Übungspraxis
- Lokal auf Ubuntu: `man chmod`, `man bash`, `man find`

Lösungen erst nach eigenem Versuch: [separate Hinweise und Lösung](solutions.md).
