# 00 – Hinweise und Lösungen

[Zur Aufgabenstellung](README.md)

## Guided Lab und Break & Fix

Hinweis 1: Ein gültiger JSON-Syntaxbaum bedeutet nicht, dass die Werte sicher sind.
Hinweis 2: Lies die erste vom Konfigurationsprüfer benannte Variable und ihre Validierungsregel in `scripts/config.py`.
Lösung: fehlende Subscription-, Tenant-, Account-, labId-, Quell-IP-, Key- und Imagewerte einzeln durch eigene geprüfte Werte ersetzen. Das Lab-RG-Präfix und Tag binden die spätere Löschung an deine Kursidentität. Keine Default-Subscription raten. Fehler und Erfolg mit `python3 scripts/config.py` wiederholen.

## Challenge

Hinweis 1: systemd ist eine Linux-Gastfunktion. Hinweis 2: macOS-Routen liest du mit `netstat`; Linux-Routen mit `ip`. Referenz: zweiter Arbeitsplatz benötigt Git/SSH/CLI, die Linux-Labs bleiben unverändert auf Ubuntu. Eine VPN-Route `10.10.0.0/16` überlappt das Standard-VNet; verwende stattdessen einen geprüften freien privaten Bereich und ändere Subnetze/IPs zusammen.

## Quiz

1. RG verwaltet Lebenszyklus/RBAC; VNet, NSG und Dienstregeln steuern Konnektivität.
2. Ignore verhindert Standard-Staging, keinen absichtlichen Force-Add und keine Geheimnisse in bereits getrackten Dateien.
3. Alerts sind Benachrichtigungen mit Verzögerungen; die Ressourcen laufen weiter.
4. Disks, IPs und Erweiterungsdienste bleiben bestehen, bis sie gelöscht werden.
