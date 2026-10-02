# Getting Started

Alle `[LOKAL]`- und `[AZURE-CLI-TERMINAL]`-Blöcke verwenden Bash im Repository-Wurzelverzeichnis. `[AZURE-CLI-TERMINAL]` ist derselbe Arbeitsplatz, aber mit von dir bewusst ausgeführtem `az login`. Verwende hier nicht blind Cloud Shell: lokale Schlüsselpfade und Outputs gehören zum gewählten Arbeitsplatz. `[CLIENT-VM]` und `[SERVER-VM]` sind getrennte SSH-Terminals. `pwd`, `hostname` und `id` vor privilegierten Befehlen prüfen.

## 1. Kurs laden und Arbeitsplatz prüfen — kostenlos

[LOKAL]
```bash
git clone https://github.com/Timeless90/azure-infrastructure-linux-lab.git
cd azure-infrastructure-linux-lab
# Falls der Kurs noch im Pull Request liegt: dessen angezeigten Branch auschecken.
git branch -a
bash --version
python3 --version
git --version
ssh -V
```

Mindestens Python 3.12, Bash 3.2 ist ausreichend für die Skripte (Arrays ohne mapfile). macOS: keine systemd-Dienste lokal installieren. Verwende bestehende Tools; falls etwas fehlt, installiere gezielt Git, Python oder Azure CLI anhand offizieller Anleitungen. Ubuntu-VM-Pakete installiert cloud-init, nicht dein Mac/Omarchy. Docker ist erst für Modul 09 nötig. Python-Virtualenv bleibt projektspezifisch.

[LOKAL]
```bash
python3 -m venv .venv
source .venv/bin/activate
python -m pip install -r examples/fastapi/requirements.txt -r tests/requirements.txt
python scripts/validate.py
cp config/lab.example.json config/lab.json
mkdir -p .state
ssh-keygen -t ed25519 -f .state/course_ed25519 -C azure-linux-course
```

Vergib eine Passphrase. `.state/` ist ignoriert. Notiere den absoluten Pfad von `.state/course_ed25519.pub` in der Konfiguration; nur diese Public-Key-Datei liest `config.py`. Private Key niemals ins Repository oder auf VM kopieren.

## 2. Identität und Adressräume erfassen — keine Bereitstellung

[AZURE-CLI-TERMINAL]
```bash
az login
az account list --query '[].{name:name,id:id,tenant:tenantId}' -o table
```

Wähle die gewünschte Subscription bewusst. Beispielsyntax, `SUBSCRIPTION_ID` erst auf die tatsächlich ausgewählte ID setzen:

[AZURE-CLI-TERMINAL]
```bash
read -r -p 'Eigene Lab-Subscription-ID: ' SUBSCRIPTION_ID
az account set --subscription "$SUBSCRIPTION_ID"
az account show --query '{subscription:id,tenant:tenantId,user:user.name}' -o json
az bicep install --version v0.34.44
```

Installiert nur den Compiler; erstellt keine Cloud-Ressourcen. Wenn diese Version nicht mehr für deinen CLI-Stand verfügbar ist, dokumentiere eine geprüfte neue Version in deinem Lernprotokoll und führe alle Builds erneut aus. CLI-Installation: [Microsoft](https://learn.microsoft.com/en-us/cli/azure/install-azure-cli). Keine Zugangsdaten in `lab.json`: nur Subscription-, Tenant- und Kontoname, nicht Tokens.

Übertrage reale `subscriptionId`, `tenantId`, `accountName`. Wähle eine neue `labId`, z. B. Datum plus zufälliger Suffix, und `resourceGroup=rg-azlinux-course-<labId>`. Ermittle deine eigene öffentliche IPv4 über dein Router/VPN-Portal; keine unbenannten fremden Messdienste abfragen. Trage `/32` als `adminSourceCidr` ein. Bei wechselnder IPv4 vorher neu prüfen, NSG nie auf `0.0.0.0/0` erweitern.

[LOKAL — Linux]
```bash
ip -4 addr
ip -4 route
```

[LOKAL — macOS]
```bash
ifconfig
netstat -rn -f inet
```

Notiere alle lokalen/VPN-Präfixe in `existingNetworks` (auch nicht aktive, geplante VPNs). Wenn `10.10.0.0/16` überlappt: VNet, beide Subnetze und beide VM-IP-Adressen gemeinsam ändern. Das Lab baut kein Peering/VPN zum Arbeitsplatz auf, aber du lernst adressraumsauberes Design.

## 3. Image und Voraussetzungen prüfen

[AZURE-CLI-TERMINAL]
```bash
az vm image list --location swedencentral --publisher Canonical \
  --offer ubuntu-24_04-lts --sku server --all --query '[].{urn:urn,version:version}' -o table
```

Bei anderer konfigurierter Region diese statt `swedencentral` einsetzen. Wähle eine tatsächlich gelistete numerische Version (`major.minor.build`) und trage `imageVersion` ein. Kein erfundener Build, kein `latest`. Dieser Schritt pinnt die konkrete regionale Imageversion für wiederholbare Deployments. Ubuntu-24.04/AMD64/Gen2 ist bewusst gewählt, auch wenn der Arbeitsplatz ARM64 ist.

[AZURE-CLI-TERMINAL]
```bash
bash scripts/preflight.sh
```

Prüft Identität, Konfiguration, Image-Abfrage, SKU-Restriktionen, Providerstatus und Quota. **Keine Garantie** für spätere Kapazität oder Policy-Erlaubnis. Bei `NotRegistered`: zuständige Person kann den betreffenden Provider registrieren; das Skript registriert nicht automatisch. Contributor auf der Kurs-RG genügt für Basisressourcen; erstmaliges Anlegen der RG muss dir erlaubt sein oder vom Admin vorgenommen werden, mit korrektem Tag. Kein pauschales Owner erforderlich.

## 4. Basis bereitstellen — kostenpflichtig ab Deployment

Lies [Kosten](costs-and-cleanup.md), setze ein Budget mit Alerts und öffne Bicep vor Ausführung. `what-if` legt bei fehlender RG nach Bestätigung nur die leere RG an; es deployt keine VMs. Es verlangt dieselben relevanten Änderungsrechte wie das eigentliche Deployment.

[AZURE-CLI-TERMINAL]
```bash
bash scripts/deploy.sh what-if
# KOSTENPFLICHTIG: nur nach eigener Prüfung des Plans und der Kosten.
bash scripts/deploy.sh deploy
bash scripts/verify.sh
```

Warte nach Deployment auf cloud-init. Ein Azure-Provisioning-Erfolg heißt nicht, dass Gastpakete fertig installiert sind. Das Skript speichert Outputs nach `.state/outputs.json`. Bicep incremental Deployment bewahrt nicht deklarierte Ressourcen; einzelne manuelle Fehlerregeln müssen explizit wiederhergestellt werden.

## 5. SSH und Pakete nachweisen

[LOKAL]
```bash
bash scripts/ssh.sh client
```

Prüfe bei erstem Zugriff den Host-Key-Fingerprint, bevor du ihn akzeptierst. Vergleich über unabhängig aufgerufenes VM Run Command im Azure Portal, Befehl `ssh-keygen -lf /etc/ssh/ssh_host_ed25519_key.pub` auf der jeweiligen Kurs-VM. Run Command benötigt entsprechende Rechte/VM-Agent; keine Secret-Inhalte lesen. Nicht `StrictHostKeyChecking=no` benutzen.

[CLIENT-VM]
```bash
hostname
id
sudo cloud-init status --wait
command -v ip ss curl dig nc nmap tcpdump openssl
cat /etc/os-release
```

Öffne ein zweites lokales Terminal:

[LOKAL]
```bash
bash scripts/ssh.sh server
```

[SERVER-VM]
```bash
hostname
sudo cloud-init status --wait
```

Falls Paketinstallation fehlschlägt: `sudo journalctl -u cloud-final --no-pager`, `sudo tail -n 60 /var/log/cloud-init-output.log`, DNS und expliziten Outbound prüfen. Nur synthetische Fehlermeldungen in Lernnotizen, keine Tokens/Keys.

## 6. Kurscode auf VMs

Solange der Kurs nur auf PR-Branch liegt, wähle dessen tatsächlichen Namen, der im Abschlussbericht steht. Nach Merge `main` verwenden.

[CLIENT-VM und SERVER-VM — jeweils separat]
```bash
git clone https://github.com/Timeless90/azure-infrastructure-linux-lab.git ~/course
cd ~/course
git branch -a
read -r -p 'Kurs-Branch (main nach Merge): ' COURSE_BRANCH
git checkout "$COURSE_BRANCH"
```

Keine Lab-Konfiguration vom Arbeitsplatz übertragen. Für Client-Datenverkehr erhältst du die tatsächliche Server-Private-IP aus den Outputs. In jedem neuen Client-Terminal:

[CLIENT-VM]
```bash
read -r -p 'serverPrivateIp aus Outputs: ' SERVER_IP
export SERVER_IP
python3 -c 'import os,ipaddress; print(ipaddress.IPv4Address(os.environ["SERVER_IP"]))'
```

IP gehört ausschließlich der eigenen Kurs-VM. Modul 02 installiert den Webdienst. Vorher ist 8080 noch geschlossen. Jetzt [Modul 01](../modules/01-linux-basics/README.md) bearbeiten. Abbruch/Ende: [Cleanup](costs-and-cleanup.md), Cloud bleibt sonst kostenpflichtig.
