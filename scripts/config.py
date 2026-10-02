"""Only reads this course's explicitly created JSON configuration."""
import ipaddress
import json
import re
import sys
from pathlib import Path
ROOT = Path(__file__).resolve().parents[1]
CONFIG = ROOT / "config/lab.json"

def load(path=CONFIG):
    c = json.loads(path.read_text())
    for key in ("subscriptionId", "tenantId", "accountName", "labId", "resourceGroup",
                "adminSourceCidr", "sshPublicKeyPath", "imageVersion"):
        if not c.get(key) or "CHANGE-ME" in c[key]:
            raise ValueError(f"config/lab.json: {key} fehlt oder ist ein Platzhalter")
    for key in ("subscriptionId", "tenantId"):
        if not re.fullmatch(r"[0-9a-fA-F-]{36}", c[key]):
            raise ValueError(f"{key}: UUID erwartet")
    if not re.fullmatch(r"[a-z0-9-]{4,32}", c["labId"]):
        raise ValueError("labId: 4–32 Kleinbuchstaben/Ziffern/Bindestriche")
    if c["resourceGroup"] != "rg-azlinux-course-" + c["labId"]:
        raise ValueError("resourceGroup muss rg-azlinux-course-<labId> sein")
    if not re.fullmatch(r"[a-z][a-z0-9]{2,20}", c["adminUsername"]):
        raise ValueError("adminUsername: einfacher Linux-Benutzername erwartet")
    source = ipaddress.ip_network(c["adminSourceCidr"], strict=True)
    if source.version != 4 or source.prefixlen != 32 or not source.network_address.is_global:
        raise ValueError("adminSourceCidr: eigene öffentliche IPv4 mit /32 erforderlich")
    if not re.fullmatch(r"\d+\.\d+\.\d+", c["imageVersion"]):
        raise ValueError("imageVersion: konkrete Azure-Imageversion, kein latest")
    net = ipaddress.ip_network(c["vnetCidr"], strict=True)
    subs = [ipaddress.ip_network(c[k], strict=True) for k in ("clientSubnetCidr", "serverSubnetCidr")]
    if net.version != 4 or not net.is_private or any(s.version != 4 or not s.subnet_of(net) or s.prefixlen > 29 for s in subs):
        raise ValueError("private IPv4-Subnetze innerhalb des VNet, mindestens /29 erforderlich")
    if subs[0].overlaps(subs[1]):
        raise ValueError("Lab-Subnetze überlappen")
    for s,k in zip(subs,("clientIp","serverIp")):
        a=ipaddress.ip_address(c[k]); offset=int(a)-int(s.network_address)
        if a not in s or offset < 4 or a == s.broadcast_address:
            raise ValueError(f"{k}: Azure reserviert erste vier und letzte Adresse")
    for other in c["existingNetworks"]:
        if net.overlaps(ipaddress.ip_network(other,strict=False)):
            raise ValueError(f"VNet überlappt Arbeitsplatz/VPN: {other}")
    return c

def parameters(c):
    pub=Path(c["sshPublicKeyPath"]).expanduser()
    if pub.suffix != ".pub":
        raise ValueError("Nur ausdrücklich angelegte .pub-Datei verwenden")
    key=pub.read_text().strip()
    if not key.startswith(("ssh-ed25519 ","ssh-rsa ")):
        raise ValueError("SSH-Public-Key erwartet; niemals privaten Schlüssel lesen")
    names=("labId","location","adminUsername","adminSourceCidr","imageVersion","vmSize",
           "vnetCidr","clientSubnetCidr","serverSubnetCidr","clientIp","serverIp")
    p={k:{"value":c[k]} for k in names};p["sshPublicKey"]={"value":key}
    return {"$schema":"https://schema.management.azure.com/schemas/2019-04-01/deploymentParameters.json#",
            "contentVersion":"1.0.0.0","parameters":p}

if __name__ == "__main__":
    try:
        c=load()
        if len(sys.argv)>1 and sys.argv[1]=="get":
            print(c[sys.argv[2]])
        elif len(sys.argv)>1 and sys.argv[1]=="prepare":
            state=ROOT/".state";state.mkdir(exist_ok=True)
            (state/"parameters.json").write_text(json.dumps(parameters(c),indent=2)+"\n")
            print("Konfiguration geprüft, .state/parameters.json geschrieben")
        else:
            print("Konfiguration und deklarierte Netzüberschneidungen geprüft")
    except (ValueError,KeyError,OSError) as e:
        sys.exit(str(e))
