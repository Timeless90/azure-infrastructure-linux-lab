# 06 – Hinweise und Lösungen

[Zur Aufgabenstellung](README.md)

## Break & Fix

Hinweis 1: VM-SKU ist ein String. Hinweis 2: Stelle nur den veränderten hardwareProfile-Wert zurück. Lösung: `vmSize: vmSize` (Parameter vom Typ string) wiederherstellen; erneut kompilieren. Nicht „testen“ durch ein fehlerhaftes kostenpflichtiges Deployment.

## Challenge

Hinweis 1: Tags sind Objekte. Hinweis 2: main übergibt `tags` bereits an vm.bicep. Referenz: Parameter `environment string = 'learning'` in main, `environment: environment` im gemeinsamen tags-Objekt; VM bekommt das aktualisierte Objekt automatisch. Build und what-if prüfen, dass Tags der Kursressourcen geändert werden. Planreview vor echter Ausführung.

## Quiz

1. Quota/Policy/Capacity werden vom lokalen Compiler nicht ausgeführt. 2. Deployment-Output bzw. aktuelle Ressourcenabfrage, nicht kopiertes Beispiel. 3. Erstprovisionierung und deklarativer Ressourcenstatus unterscheiden sich. 4. Azure muss die erwarteten Management-Änderungen im konkreten Scope bewerten; read-only Ansicht allein genügt nicht stets.
