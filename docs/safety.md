# Sichere Lernregeln

Vier Kontexte auseinanderhalten: Arbeitsplatz, Azure CLI am Arbeitsplatz, Client-VM, Server-VM. `sudo` erhält Administratorrechte nur für den aufgerufenen Befehl; prüfe Zielpfad und Host. `sudo echo ... > /etc/datei` scheitert oft, weil die Umleitung von deiner Shell ausgeführt wird. Der Kurs verwendet geprüfte Skripte oder `sudo tee` für exakt benannte Lab-Dateien. Kein `sudo rm -rf` gegen Variablen ohne Grenzen, kein lokaler Firewall-Umbau, keine Änderung an SSH-Konfigurationen.

Scans nur von CLIENT-VM auf die in Outputs genannte SERVER-VM-IP mit Ports 8080/8081. Kein Subnetzscan, keine Internet- oder Firmennetze. TCP Connect Scan `-sT` braucht keinen privilegierten SYN-Scan. Capture nur synthetischen Client-Web-Traffic mit Host-/Port-Filter, Paketzahl und kurzer Dauer. Schon HTTP-Header/Antwortkörper können vertraulich sein; Captures und Logs bleiben ignoriert und werden nicht hochgeladen.

Keine realen Secrets in Beispielen. `X-Lab-Role` ist bewusst eine manipulierbare Unterrichtssimulation und keine Authentifizierung. Produktiv JWT-Signatur, Issuer, Audience, Gültigkeit und Claims mit geeigneter Bibliothek prüfen; Netzwerkregeln ersetzen das nicht.

Cleanup prüft aktive Azure-Identität, Subscription und den eindeutigen RG-Tag, zeigt das Inventar und verlangt eine exakt benannte Löschbestätigung. Das schützt gegen viele Verwechslungen, erkennt aber nicht automatisch jede versehentlich in die RG gelegte Fremdressource. Enthält das Inventar Fremdressourcen: abbrechen. Nur Kursressourcen in diese RG legen.

Wiederherstellung bei Verwaltungsproblem: zuerst andere direkt erreichbare Kurs-VM prüfen. Portal/CLI effektive NSG-Regeln und Public IP prüfen. Bei geänderter Administrator-IP nur die `/32` aktualisieren. VM Run Command kann das Course-Service-Skript ersetzen, sofern VM-Agent funktioniert und deine Rolle es erlaubt. Keine Übung blockiert absichtlich Port 22 oder Standardroute des Arbeitsplatzes.
