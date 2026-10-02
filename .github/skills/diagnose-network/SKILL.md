---
name: diagnose-network
description: DNS-, Routing-, NSG-, TCP-, TLS-, HTTP-, Docker- oder Linux-Service-Fehler systematisch diagnostizieren.
---

# diagnose-network

Lies docs/troubleshooting-method.md und cheatsheets/diagnosis.md. Erfasse Quelle, Ziel, Port, Protokoll, Ausführungskontext und Zeitpunkt. Formuliere zwei plausible Hypothesen. Wähle einen Test, der sie unterscheidet, entlang DNS → Route → Regeln → TCP → TLS → HTTP → Anwendung. Erkläre die Grenzen des Messpunkts. Unterscheide Listener auf Loopback von Erreichbarkeit am Client, open/closed/filtered von Anwendungsfunktion und HTTP 403 von Netzwerkausfall. Empfiehl nmap nur für die bekannte Lab-IP mit expliziten Ports; keine automatischen Scans. Verweise auf den Wiederherstellungsweg der konkreten Übung. Warte auf die Ausgabe, bevor du die Ursache behauptest.
