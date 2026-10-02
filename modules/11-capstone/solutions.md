# 11 – Hinweise und Lösungen

[Zur Aufgabenstellung](README.md)

## Gestufte Hinweise

1. Zeichne vor Installation den benötigten Port und Prozessbenutzer.
2. Wenn course-web bereits8080 belegt, stoppe ausschließlich diese Unit. Der neue Service erhält eigene Unit/WorkingDirectory/Virtualenv.
3. Erfolgreiche Installation ist nicht erfolgreicher Bootstart; enabled, active, ss und health getrennt prüfen.

## Referenzlösung: FastAPI als Service

[SERVER-VM — ~/course, Kurs-VM mit Python venv]
```bash
cd ~/course
sudo systemctl stop course-web
sudo systemctl disable course-web
sudo install -d -o courseweb -g courseweb /opt/course-api
sudo install -m 644 examples/fastapi/app.py examples/fastapi/requirements.txt /opt/course-api/
sudo -u courseweb python3 -m venv /opt/course-api/.venv
sudo -u courseweb /opt/course-api/.venv/bin/python -m pip install -r /opt/course-api/requirements.txt
```
Befehle setzen voraus, dass courseweb aus Modul02 existiert; ansonsten zuerst install-service.sh ausführen und wieder stoppen.

[SERVER-VM — hier wird genau eine eigene Unit geschrieben]
```bash
cat <<'EOF' | sudo tee /etc/systemd/system/course-api.service
[Unit]
Description=Capstone FastAPI lab
After=network.target
[Service]
User=courseweb
Group=courseweb
WorkingDirectory=/opt/course-api
ExecStart=/opt/course-api/.venv/bin/python -m uvicorn app:app --host 0.0.0.0 --port 8080
Restart=on-failure
RestartSec=3
NoNewPrivileges=true
PrivateTmp=true
ProtectSystem=strict
ProtectHome=true
Environment=PYTHONDONTWRITEBYTECODE=1
[Install]
WantedBy=multi-user.target
EOF
sudo systemctl daemon-reload
sudo systemctl enable --now course-api
sudo ss -lntp '( sport = :8080 )'
curl --fail http://127.0.0.1:8080/health
```

[CLIENT-VM — aktuelle SERVER_IP aus Outputs gesetzt]
```bash
curl -i "http://$SERVER_IP:8080/health"
curl -i "http://$SERVER_IP:8080/admin"
curl -i -H 'X-Lab-Role: denied' "http://$SERVER_IP:8080/admin"
curl -i -H 'X-Lab-Role: reader' "http://$SERVER_IP:8080/admin"
```
HTTP200/401/403/200 und X-Request-ID jeweils mit Journal korrelieren. `X-Lab-Role` bleibt Simulation. Servicefehler per `sudo systemctl stop course-api`, Restore `sudo systemctl start course-api`. Die service-fault.sh-Szenarien aus Modul02 ändern nur course-web, daher für diese neue Unit nicht unbemerkt wiederverwenden.

## Netzfehler

azure-fault.sh nsg/route trifft dieselbe IP8080 unabhängig vom Appprozess. Bestehende Flows schließen, frischen curl starten; ss/Loopback/effective NSG/effective routes kombinieren. Restore entfernt nur fault-web, Clienthealth wieder prüfen.

## Rückkehr zur Kursbasis ohne RG-Löschung

[SERVER-VM]
```bash
sudo systemctl disable --now course-api
sudo systemctl enable --now course-web
curl --fail http://127.0.0.1:8080/health
```
Unit und /opt/course-api bleiben bis expliziter gezielter Entfernung oder VM-Löschung vorhanden. Für Abschluss regulär RG-Cleanup mit Inventar/Bestätigung. Keine unbestätigte Cloudlöschung.

## Quiz

1. VM-Status/Prozess, TCPHandshake, HTTPAntwort sind getrennte Nachweise. 2. generische Code-/Toolversionen, Netzpräfixe und anonymisierte Beobachtung ohne Credentials. 3. Disks/IPs/PE/DNS/Storage/ACA. 4. Ein erlaubter Flow testet nicht alle verbotenen Quellen/Ports, unterschiedliche Messpunkte beachten.
