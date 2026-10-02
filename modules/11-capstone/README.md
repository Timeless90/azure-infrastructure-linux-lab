# 11 – Capstone: eigenständiges Abschlussprojekt

[Zur Kursübersicht](../../ROADMAP.md) · [Kompetenznachweis](../../PROGRESS.md)

## A. Lernziele

Du baust eine reproduzierbare eigene Lab-Architektur, betreibst FastAPI als Linux-Service, diagnostizierst unbekannte gezielte Fehler und lieferst überprüfbare Beweise inklusive Cleanup.

## B. Voraussetzungen

[10](../10-troubleshooting/README.md), Kompetenznachweise 00–10. Neue eigene labId/RG oder bestehende ausschließlich Kurs-RG; keine bestehenden Unternehmensressourcen. Kostenfreigabe erneut prüfen.

## C. Verständliche Theorie

Das Capstone verbindet Ebenen statt neue Premiumdienste hinzuzufügen. Der Code beschreibt Netz und Compute, Linux startet den Prozess, ein Client prüft den Datenpfad, Logs machen die Verarbeitung sichtbar. Dein Ergebnis ist nicht nur „läuft“, sondern ein nachvollziehbarer Nachweis, warum es läuft und wie du Fehler eingrenzt.

Arbeite ohne Referenzlösung. Die frühere IaC-Basis darf wiederverwendet werden, du musst aber Ressourcenrollen, Regeln, IPs und Outbound begründen. Das FastAPI-Beispiel liefert health und synthetische Rollenfälle; der Header wird ausdrücklich nicht als echte Auth verwendet. Echte Entra-Endnutzerintegration ist ein separates Produktprojekt.

Ein Diagnosebericht darf nicht aus den Aktivierungsbefehlen abschreiben. Lass nach Möglichkeit einen Lernpartner genau einen Fehler aktivieren oder wähle selbst einen Fall und schließe seine Skriptansicht vor der Untersuchung. Das ist eine Lernmethode, keine Anweisung für fremde Agenten/Remotezugriff.

## D. Architektur oder Ablauf

Pflichtarchitektur: eine getaggte Kurs-RG, VNet mit zwei nicht überlappenden Subnetzen, Client und Server, explizites Outbound, SSH nur eigene Admin-/32. FastAPI auf Server/8080, erreichbar nur Client/32. Optional Blob PE/DNS; ACA ist separate weiterführende Abnahme, keine Capstone-Pflicht.

## E. Befehle mit Erklärung

Befehlsrahmen, keine vollständige Lösung:

[AZURE-CLI-TERMINAL — Repository-Wurzel]
```bash
bash scripts/preflight.sh
bash scripts/deploy.sh what-if
# KOSTENPFLICHTIG, erst nach eigenem Review.
bash scripts/deploy.sh deploy
bash scripts/verify.sh
```
[CLIENT-VM — SERVER_IP aus aktuellen Outputs]
```bash
: "${SERVER_IP:?Aus eigenem Deployment setzen}"
curl -i --max-time 5 "http://$SERVER_IP:8080/health"
```
Für FastAPI muss der bisherige course-web-Prozess durch einen eigenen korrekt definierten Service ersetzt werden. Portkonflikt zuerst erkennen, nicht mit zusätzlicher VM umgehen.

## F. Guided Lab

Aufgabenstellung:
1. Erstelle Architekturzeichnung und Ressourcen-/Kosteninventar mit tatsächlichen eigenen Parametern.
2. Führe IaC-Planreview und eigenes Deployment durch. Alle benötigten Outputs müssen ohne Beispiel-IP-Raten ermittelbar sein.
3. Betreibe FastAPI als unprivilegierten systemd-Service mit projektspezifischer Virtualenv. Logge Request-ID, keine Header/Secrets.
4. Beweise Client→health, Server-Listener/Benutzer, HTTP401/403/200 und geschlossene/unerlaubte Gegenbeispiele.
5. Diagnose eines Service-/Bindingfehlers und eines NSG-/Routingfehlers, jeweils einzeln. Nicht mehr als einen injizierten Fehler gleichzeitig.
6. Dokumentiere Hypothesen, Messungen, Alternativen, Fix und identischen Erfolgstest.
7. Räume die Kurs-RG nach bestätigtem Inventar vollständig auf und überprüfe Nichtvorhandensein.

## G. Beobachtung und Interpretation

health200 ist nur ein Teil. Listener muss als vorgesehener User laufen; effective NSG muss keine öffentliche8080-Freigabe enthalten; Client-Request-ID und Journal gehören zusammen. Wenn pip ohne Egress scheitert, ist das ein Infrastructure-/DNSproblem vor Appstart, kein FastAPI-Endpointfehler. Nicht ausgeführte optionale Checks bleiben als offen markiert.

## H. Break & Fix

Ausgangszustand: eigener FastAPI-Service gesund. Sichere Aktivierung: stoppe nur deine benannte Capstone-Unit. Zweiter getrennt zu bearbeitender Fall: bereits bekannte Azure fault-web-Deny-Regel per Kurs-Skript aktivieren. Diagnoseauftrag: ohne sofortigen Blick in Lösungen entscheiden, ob Appbetrieb oder Strecke gestört ist. Direktes SSH bleibt erhalten.

## I. Selbstständige Challenge

Erweitere den Bericht um „PE-DNS korrekt, anonymer Storage-Request verweigert“. Optional stelle die gleiche FastAPI nach ACA und zeige die andere Diagnosemethodik. Keine Firewall/Bastion/Resolver-Premiumdienste nötig.

## J. Quiz

1. Welche Beobachtung beweist jeweils Compute-, TCP- und HTTP-Erfolg?
2. Welche Daten braucht ein fremder Reviewer zum Reproduzieren ohne deine Secrets?
3. Was bleibt nach VM-Stopp bestehen?
4. Warum ist eine einzelne Erfolgsmessung kein Beweis aller Sicherheitsregeln?

## K. Erfolgskriterien

Abnahme:
- IaC-Build/Plan, eigene Architektur und explizites Egress dokumentiert.
- FastAPI läuft als Serviceuser, health200 vom Client und 401/403 korrekt interpretiert.
- 8080 öffentlich nicht freigegeben; SSH eng begrenzt.
- Zwei Incidentberichte enthalten echte Messungen und überprüfte Restores.
- Cleanup zeigt Subscription/RG und anschließende Nichtvorhandensein-Prüfung.
- Keine Keys/Tokens/Captures in getrackten Dateien.

Beweisvorlage: [Capstone Evidence](evidence-template.md).

## L. Wiederherstellung und Cleanup

Servicefehler gezielt mit systemctl start beheben, Azure-Fehler über Restore. Danach zentrale `bash scripts/cleanup.sh` mit eigener Bestätigung. Lokale Beweisnotizen behalten, sensible Laufzeitartefakte ignorieren. GHCR Package separat, falls erstellt.

## M. Weiterführende Quellen

- [Bicep](https://learn.microsoft.com/en-us/azure/azure-resource-manager/bicep/overview)
- [FastAPI Deployment](https://fastapi.tiangolo.com/deployment/)
- [Systematische Diagnose](../../docs/troubleshooting-method.md)

Lösungen erst nach eigenem Versuch: [separate Hinweise und Lösung](solutions.md).
