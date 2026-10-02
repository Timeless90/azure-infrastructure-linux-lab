# 09 – Hinweise und Lösungen

[Zur Aufgabenstellung](README.md)

## Mappingfehler

Hinweis 1: Der Containerstatus sagt nichts über den richtigen Zielport. Hinweis 2: innen health an 8080 prüfen und docker port vergleichen. [LOKAL]:
[LOKAL]
```bash
docker port course-api-fault
docker exec course-api-fault python -c "import urllib.request; print(urllib.request.urlopen('http://127.0.0.1:8080/health').status)"
docker rm -f course-api-fault
docker run -d --name course-api-fault -p 127.0.0.1:18081:8080 azure-linux-course-api:1.0
curl --fail http://127.0.0.1:18081/health
```
Nun Host18081 → Container8080, nicht 8081. Danach benannten Fehlercontainer entfernen.

## Fehlende Berechtigung

Hinweis 1: Liegt eine HTTP-Antwort vor? Hinweis 2: App-Logs/Request-ID korrelieren. Lösung: synthetischen erwarteten Header reader ergänzen. Das ist nur Demo; Header ist frei fälschbar, daher keine Produktionsauthentifizierung. Netzwerkfreigabe löst das nicht.

## Challenge

Hinweis 1: Gemeinsames user-defined Bridge-Netz. Hinweis 2: Server mit Name course-api auf diesem Netz. Referenz [LOKAL — eigene Kurscontainer vorhanden]:
[LOKAL — eigene Kurscontainer vorhanden]
```bash
docker network create course-net
docker network connect course-net course-api
docker run --rm --network course-net azure-linux-course-api:1.0  python -c "import urllib.request; print(urllib.request.urlopen('http://course-api:8080/health').status)"
docker network disconnect course-net course-api
docker network rm course-net
```
Der temporäre Client nutzt dasselbe harmlose Image und überschreibt CMD, kommuniziert intern per Containername/8080. Kein Portmapping für diesen Flow nötig. Wenn course-net schon existiert, Eigentum prüfen und nicht ungeprüft übernehmen.

## Quiz

1. Nein. 2. Nein, verschiedene Namespaces. 3. Nein, Plattformzugriff/Caps nicht voraussetzen. 4. HTTP-Policyentscheidung nach Transport versus TCP-Aufbaufehler.
