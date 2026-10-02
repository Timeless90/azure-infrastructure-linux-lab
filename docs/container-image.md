# Dasselbe FastAPI-Image nach ACA übertragen

ACA kann ein lokales Docker-Image nicht von deinem Laptop laden. Dieser Kurs nutzt ein separat von dir veröffentlichtes **öffentliches GHCR-Package** mit ausschließlich dem generischen FastAPI-Beispiel. Es enthält keine Konfiguration/Secrets. Veröffentlichung ist optional und deine bewusste Aktion; der Kursautor lädt kein Package hoch. Wer keinen öffentlichen Image-Upload möchte, kann ACR mit Managed-Identity-Pull-Rechten als eigenes Zusatzprojekt wählen; ACR kostet und ist nicht stillschweigend Voraussetzung.

## 1. Bereits lokal geprüften Code bauen

[LOKAL — Repository-Wurzel, Docker vorhanden]
```bash
docker build --platform linux/amd64 -t azure-linux-course-api:1.0 examples/fastapi
docker tag azure-linux-course-api:1.0 ghcr.io/timeless90/azure-linux-course-api:1.0
```

Tag ist eine Version, aber überschreibbar; ACA erhält anschließend einen unveränderlichen Digest. Prüfe `docker history` und Buildcontext: nur app.py/requirements.txt/Dockerfile, keine Keys/Outputs.

## 2. Eigene GHCR-Anmeldung und Upload

Folge [GitHub Container Registry](https://docs.github.com/en/packages/working-with-a-github-packages-registry/working-with-the-container-registry) für aktuelle Authentifizierung und minimale Package-Schreibrechte. Gib Credential interaktiv ein, nicht als Kommandoargument, Shellvariable in Beispieldatei oder Commit. `docker login` kann Credentials im lokalen Docker-Credential-Store verwalten; nur ein ausdrücklich für diesen Schritt angelegtes Credential nutzen. Bestehende Secretdateien nicht auslesen.

[LOKAL — eigene ausdrückliche Package-Publikation]
```bash
docker login ghcr.io --username Timeless90
docker push ghcr.io/timeless90/azure-linux-course-api:1.0
```

GHCR-Package kann trotz public Repository zunächst privat sein. Im GitHub-Package unter Settings die Sichtbarkeit **nur dieses harmlosen Lab-Packages** bewusst auf public setzen, wenn du diesen Weg wählst. Ein public Repo macht das Package nicht automatisch public. Keine anderen Packages verändern.

## 3. Digest und öffentlichen Pull nachweisen

[LOKAL]
```bash
docker inspect ghcr.io/timeless90/azure-linux-course-api:1.0 --format '{{json .RepoDigests}}'
```

Wähle den tatsächlich angezeigten `ghcr.io/timeless90/azure-linux-course-api@sha256:<64-hex>`-Wert. Niemals den Beispielmarker wörtlich verwenden. Prüfe im Packageportal, dass dieser Digest und AMD64-Manifest veröffentlicht sind. Optional mit einem temporären leeren Docker-Konfigurationsverzeichnis einen Pull ohne Credential testen:

[LOKAL — echter eigener Digest]
```bash
read -r -p 'Lab-Image mit @sha256:...: ' COURSE_IMAGE
TEMP_DOCKER_CONFIG=$(mktemp -d)
DOCKER_CONFIG="$TEMP_DOCKER_CONFIG" docker pull "$COURSE_IMAGE"
rmdir "$TEMP_DOCKER_CONFIG"
```

Wenn der Pull scheitert, kein ACA-Deployment ausführen. Auf Mac kann der vorhandene Docker-Credential-/Context-Aufbau diesen separaten Konfigurationstest beeinflussen; im Zweifel Package-Sichtbarkeit/Manifest im Portal prüfen. SHA-Digest an extension.sh übergeben (Modul09). `docker logout ghcr.io` nach Upload, falls du keine weitere Anmeldung brauchst. Keine Azure-Secrets oder GitHub Actions für Deployment.
