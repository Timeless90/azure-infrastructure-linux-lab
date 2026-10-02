# Versionen und Annahmen

Quellenprüfung 2026-10-02. Ubuntu 24.04 LTS Noble, Azure Canonical `ubuntu-24_04-lts`, SKU `server`, AMD64 Gen2. Canonical bestätigt diese Imagefamilie; die konkrete numerische Imageversion wird vom Lernenden regional mit Azure CLI ermittelt und in lab.json festgehalten. Ohne diese Version verweigert der Kurs Deployment. Es wurde kein regionales Image über deine Subscription abgefragt.

- Python 3.12 auf Ubuntu; Container `python:3.12.10-slim-bookworm`. Pin ist ein Unterrichtsstand, keine Zusage aktueller Security-Fixes. Vor längerem Einsatz unterstützten Patchstand und Image-Digest prüfen, Tests wiederholen. Nicht produktiv übernehmen.
- FastAPI 0.115.12, Uvicorn 0.34.2; pytest 8.3.5, httpx 0.28.1, PyYAML 6.0.2. Direkte Pakete gepinnt, transitive Pakete nicht vollständig gelockt. Daher kein byteidentischer Python-Build garantiert.
- Bicep Zielcompiler 0.34.44; Azure CLI 2.x mit den dokumentierten Befehlen. `az version` im Preflight protokollieren. CLI/Extensions sind absichtlich nicht als angeblich aktuell getestete Installation bezeichnet. Bei Parameteränderungen `--help` prüfen.
- Ubuntu-Pakete aus 24.04-Repositories: systemd 255-Reihe, iproute2 6.1-Reihe, tcpdump 4.99-Reihe, Nmap 7.94-Reihe, OpenSSL 3.0-Reihe. Security-Updates/Distribution-Revisions können abweichen. `dpkg-query -W` als eigene Messung erfassen. Laufende aktuelle Manpages nicht mit jeder Ubuntu-Option gleichsetzen.
- Docker Engine gemäß offizieller Ubuntu-Anleitung oder bestehender Docker Desktop auf Mac. CLI-Funktionen `build`, `run`, `inspect`, `exec` benötigen kein experimentelles Feature. Linux-VM-Docker darf als Alternative `docker.io` aus Ubuntu nutzen; genaue Version selbst erfassen.
- Bicep API-Versionen sind explizit: Network 2024-05-01, Compute 2024-07-01, Storage 2023-05-01, Key Vault 2023-07-01, Container Apps 2024-03-01. `defaultOutboundAccess:false` wird unabhängig vom API-Default gesetzt.

Region/Subscription können Public IP, B1s, Storage/PE, ACA und RBAC aufgrund von Quota, Policy, Capacity, Locks oder Berechtigungen verbieten. Keine Umgehung: SKU/Region in lab.json dokumentiert anpassen oder Admin um freigegebenes Lab bitten. Azure Public Cloud ist vorgesehen; Sovereign Clouds haben andere Endpunktnamen und Verfügbarkeit und wurden nicht validiert.

Ubuntu-Gastpakete werden bewusst mit Updates installiert. Eine echte Produktionsreproduzierbarkeit würde Paketrepository-Snapshot, transitive Locks und Container-Digest einschließen. Dieser Kurs pinnt Plattformfamilie, explizite Imageversion bei Deployment und deklarative Ressourcen; er verspricht keine unveränderlichen Paketmirror-Inhalte.
