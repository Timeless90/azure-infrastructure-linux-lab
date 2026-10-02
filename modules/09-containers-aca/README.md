# 09 – Container und Azure Container Apps

[Zur Kursübersicht](../../ROADMAP.md) · [Kompetenznachweis](../../PROGRESS.md)

## A. Lernziele

Du erklärst Prozess-/Netzwerkisolation, Port-Mapping und Container-Loopback. Du betreibst FastAPI lokal in Docker und überträgst dasselbe Image nach ACA mit passenden Diagnosegrenzen.

## B. Voraussetzungen

[08](../08-identity-security/README.md), FastAPI/Python-Kenntnisse. Docker am eigenen Arbeitsplatz vorhanden; Apple Silicon baut für ACA explizit AMD64. Alternativ ausschließlich auf Kurs-Server `sudo apt-get install docker.io` (Ubuntu-Paket) und Dockerbefehle mit sudo ausführen. Kein Umbau bestehender macOS-/Linux-Konfiguration.

## C. Verständliche Theorie

Ein Container ist ein isolierter Prozess mit eigenem Dateisystem und Netzwerk-Namespace, keine vollständige VM mit eigenem Kernel. `127.0.0.1` im Container ist der Container, nicht dein Docker-Host und nicht ein anderer Container. `EXPOSE` dokumentiert einen Port, veröffentlicht ihn aber nicht. `-p 127.0.0.1:18080:8080` bindet Host-Loopback/18080 auf Container/8080. Die App muss im Container an `0.0.0.0:8080` lauschen.

Ein benanntes Docker-Bridge-Netz ermöglicht Containerkommunikation über Dienstnamen; jedes Container-Loopback bleibt separat. Docker-Logs lesen stdout/stderr. Ein funktionierender Container ersetzt keine Port-Veröffentlichung. Docker-Daemonzugriff ist mächtig und oft root-äquivalent; nicht ungeprüft Benutzer zur docker-Gruppe hinzufügen.

ACA übernimmt Hostbetrieb, Ingress, Revisionen und Replicas. Externer HTTPS-Ingress terminiert TLS an der Plattform und leitet zum internen targetPort weiter. Du hast Container-Console und Logs, aber keinen frei verfügbaren SSH-Zugriff auf den Host und keine zugesicherten beliebigen tcpdump-Capabilities. Skalierung auf null kann Kaltstarts verursachen; Requests/Logs/Umgebung können trotzdem Kosten erzeugen.

Die Role-Header-Demo ist keine echte Authentifizierung. Sie erlaubt reproduzierbar 401/403/200, damit du falsche „Netzwerkproblem“-Diagnosen erkennst. Keine Secrets und keine echten Daten.

## D. Architektur oder Ablauf

Docker: Arbeitsplatz `127.0.0.1:18080` → Port-Mapping → Container `0.0.0.0:8080`. ACA: eigene öffentliche IPv4 → HTTPS/443 Plattform-Ingress → Container/8080. ACA hat in diesem Lab kein VNet/PE-Routing, beide Teil-Labs sind bewusst getrennt.

## E. Befehle mit Erklärung

[LOKAL — Repository-Wurzel, bestehender Docker]
```bash
docker version
docker build --platform linux/amd64 -t azure-linux-course-api:1.0 examples/fastapi
docker run -d --name course-api -p 127.0.0.1:18080:8080 azure-linux-course-api:1.0
curl -i http://127.0.0.1:18080/health
curl -i http://127.0.0.1:18080/admin
curl -i -H 'X-Lab-Role: denied' http://127.0.0.1:18080/admin
curl -i -H 'X-Lab-Role: reader' http://127.0.0.1:18080/admin
docker logs --tail 20 course-api
docker port course-api
```
`--platform` ist auf ARM-Host langsamer wegen Emulation, passt aber zum vorgesehenen ACA-Image. Docker-Name muss frei sein; bestehende gleichnamige fremde Container nicht löschen.

## F. Guided Lab

1. Führe Dockerlab aus, ordne 401/403/200 ein und zeige X-Request-ID.
2. Prüfe im Container den Socket über Python, ohne Pakete einzubauen:

[CONTAINER — geöffnet mit `docker exec -it course-api sh`]
```bash
python -c "import urllib.request; print(urllib.request.urlopen('http://127.0.0.1:8080/health').status)"
exit
```

3. Erzeuge optional ein isoliertes Bridge-Netz `docker network create course-net`, prüfe per `docker network inspect course-net`, verbinde nur Kurscontainer; kein Hostrouting ändern. Kommunikation zweier Container braucht gemeinsames Netz und Containername, nicht Loopback. Die Challenge entwickelt diesen Plan.
4. Für ACA brauchst du ein erreichbar veröffentlichtes **synthetisches Lab-Image**. Folge [Image-Transfer](../../docs/container-image.md), pinne dessen Digest. Keine automatisch ausführende Build-/Deploy-Action.
5. **Kostenpflichtig:** eigener ACA-Plan und Deployment:

[AZURE-CLI-TERMINAL — Repository-Wurzel]
```bash
read -r -p 'Eigenes GHCR-Lab-Image mit @sha256:...: ' COURSE_IMAGE
bash scripts/extension.sh container-app what-if "$COURSE_IMAGE"
bash scripts/extension.sh container-app deploy "$COURSE_IMAGE"
source scripts/common.sh
load_lab
guard_rg
FQDN=$(az deployment group show -g "$RG" --subscription "$SUBSCRIPTION" -n course-container-app --query properties.outputs.fqdn.value -o tsv)
curl -i --connect-timeout 10 --max-time 60 "https://$FQDN/health"
az containerapp logs show -g "$RG" -n course-api --subscription "$SUBSCRIPTION" --type console --tail 20
az containerapp revision list -g "$RG" -n course-api --subscription "$SUBSCRIPTION" -o table
```

Keine externe Anwendungsdaten oder Tokens senden.

## G. Beobachtung und Interpretation

Docker health sollte 200 sein; /admin ohne Header 401, falsche Rolle 403, reader 200. Alle drei Status bestätigen HTTP-Konnektivität zu einer antwortenden Komponente; Logs/Request-ID helfen zu prüfen, ob es die richtige App war. ACA kann bei privatem/unpassendem Image nicht starten: Image Pull/Architektur/Ingress targetPort und Revision prüfen, nicht blind NSG ändern.

## H. Break & Fix

Ausgangszustand: korrektes course-api läuft. Aktiviere falsches Mapping als separaten benannten Kurscontainer, healthy bleibt zum Vergleich bestehen. [LOKAL]
[LOKAL]
```bash
docker run -d --name course-api-fault -p 127.0.0.1:18081:8081 azure-linux-course-api:1.0
curl -i --max-time 5 http://127.0.0.1:18081/health
```
Symptom: Hostrequest scheitert trotz laufendem Container. Auftrag: published port, Appport und Containerinnenraum vergleichen. Zweiter Fehler: rufe /admin ohne Header auf; darf das als Netzwerkausfall gelten?

## I. Selbstständige Challenge

Entwirf und optional betreibe einen zweiten eigenen Clientcontainer im `course-net`, der `http://course-api:8080/health` aufruft. Begründe, warum Hostport18080 hierfür irrelevant ist. Keine fremden Images/Netze scannen.

## J. Quiz

1. Öffnet EXPOSE einen Hostport?
2. Ist Container-Loopback Host-Loopback?
3. Kannst du auf ACA beliebig Host-pcap erzeugen?
4. Warum ist ein 403 anders als Connection refused?

## K. Erfolgskriterien

Du behebst Mappingfehler, zeigst Containerinnenraum-vs-Hosttest und interpretierst Authstatus. Für selbst ausgeführtes ACA: Image-Digest, gesunde Revision, HTTPS und Logs dokumentiert. Nicht ausgeführte Cloudschritte bleiben offen in PROGRESS.

## L. Wiederherstellung und Cleanup

[LOKAL — nur diese Kurscontainer]
```bash
docker rm -f course-api-fault
docker rm -f course-api
```
Optional course-net erst von Kurscontainern trennen, dann entfernen; keine fremden Netzwerke entfernen. ACA läuft weiter bis bestätigt getaggte Kurs-RG gelöscht wird. Image-/Package-Lifecycle separat behandeln.

## M. Weiterführende Quellen

- [Docker-Netzwerke](https://docs.docker.com/engine/network/)
- [FastAPI Docker](https://fastapi.tiangolo.com/deployment/docker/)
- [ACA Ingress](https://learn.microsoft.com/en-us/azure/container-apps/ingress-overview)
- [ACA Console](https://learn.microsoft.com/en-us/azure/container-apps/container-console)

Lösungen erst nach eigenem Versuch: [separate Hinweise und Lösung](solutions.md).
