# 01 – Hinweise und Lösungen

[Zur Aufgabenstellung](README.md)

## Break & Fix

Hinweis 1: Prüfe, wer die Datei besitzt. Hinweis 2: `ls -ld .; ls -l events.txt` unterscheidet Verzeichnis und Datei. Lösung [CLIENT-VM]:
[CLIENT-VM]
```bash
cd ~/course-work/01
chmod 600 events.txt
cat events.txt
```
Die normale Ausgabe muss zurückkehren. Kein root nötig, solange du Owner bist. Bei falschem Owner nicht pauschal rekursiv chown, sondern Entstehung des falschen Eigentums prüfen.

## Challenge

Hinweis 1: Drei Ziffern entsprechen Owner/Group/Other. Hinweis 2: read=4, write=2, execute=1. Referenz [CLIENT-VM]:
[CLIENT-VM]
```bash
mkdir -p ~/course-work/01/shared
printf 'synthetic report
' > ~/course-work/01/shared/report.txt
chmod 640 ~/course-work/01/shared/report.txt
ls -l ~/course-work/01/shared/report.txt
```
Für Traversal müssen alle Elternverzeichnisse `x` für die betreffende Identität erlauben; für Directory Listing zusätzlich `r`. Du hast damit noch keinen realen Gruppenzugriff bewiesen.

## Quiz

1. Ersetzen gegenüber anhängen. 2. Verzeichnis-`x` erlaubt Pfadauflösung. 3. root prüft nicht dieselben Zugriffsvoraussetzungen wie der Serviceuser. 4. Nicht exportierte Variable ist im Kind nicht als Environment gesetzt.

Guided Lab: `grep 'INFO' events.txt | sort -u > info.txt`; die Pipe verarbeitet nur stdout. Ein Fehler von `grep` erscheint weiter auf stderr, solange nicht umgeleitet.
