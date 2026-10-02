# Kommandos nach Diagnosefrage

Die Matrix zeigt Syntax; für ausführbare Übungen Module verwenden, dort sind Variablen/Umgebung initialisiert. SERVER_IP, BLOB_HOST und RG sind keine bekannten Konstanten. Scans ausschließlich einzelne eigene Lab-IP8080/8081.

| Frage | Kontext/Werkzeug | Bedeutung / Grenze |
|---|---|---|
| Auf welchem Host bin ich? | VM: `hostname; id; pwd` | vor sudo immer klären |
| Lauscht der Prozess? | SERVER-VM: `sudo ss -lntp '( sport = :8080 )'` | local bind, keine Remote-Garantie |
| Läuft die Unit? | SERVER-VM: `systemctl status course-web` | Status allein kein HTTP-Test |
| Was sagt der Prozess? | SERVER-VM: `sudo journalctl -u course-web -b -n 30 --no-pager` | aktueller Boot/Unit |
| Welche Adressen sind lokal? | VM: `ip -4 addr` | Gastansicht |
| Welche Route wird verwendet? | CLIENT-VM: `ip route get "$SERVER_IP"` | Kernel, nicht gesamte Azure-Fabric |
| Antwortet ICMP? | CLIENT-VM: `ping -c 2 "$SERVER_IP"` | kein TCP-Beweis; hier NSG darf blockieren |
| Welche Hops sehe ich? | CLIENT-VM: `tracepath "$SERVER_IP"` | fehlende Hops bedeuten nicht zwingend Defekt |
| Was liefert DNS? | CLIENT-VM: `dig "$BLOB_HOST" A` | keine TCP-/HTTP-Aussage |
| Was nutzt NSS? | CLIENT-VM: `getent ahostsv4 "$BLOB_HOST"` | Hosts/Resolver-Sicht vergleichen |
| Geht TCP8080? | CLIENT-VM: `nc -vz -w 3 "$SERVER_IP" 8080` | Aufbau, keine Appqualität |
| Welchen Portzustand sieht dieser Client? | CLIENT-VM: `nmap -sT -Pn -n -p 8080,8081 --reason "$SERVER_IP"` | eng begrenzte Connect-Probes |
| Was antwortet HTTP? | CLIENT-VM: `curl -i --max-time 5 "http://$SERVER_IP:8080/health"` | Status/Body/Headers |
| Welche Pakete sehe ich hier? | SERVER-VM: `sudo timeout 15 tcpdump -ni any -c 12 'tcp port 8080'` | Filter/Timing/Namespace/Offload beachten |
| Ist TLS-Name/Trust richtig? | SERVER-VM TLS-Lab: `openssl s_client -connect 127.0.0.1:8443 -servername lab.test -verify_hostname lab.test -CAfile lab.crt -verify_return_error` | explizite strenge Prüfung, Modul10 |
| Was ist Docker-published? | LOKAL: `docker port course-api` | EXPOSE ist nicht publish |
| Welche ACA-Revision antwortet? | CLI: revision list, logs show, exec | kein Host-SSH/capture zugesichert |

Kein erzwungener Browser-/Proxy-/TLS-Bypass gegen Unternehmenszugänge. Bei synthetischen Loopback-Labs kann `--noproxy '*'` sicherstellen, dass nur die lokale Testverbindung gemeint ist; nicht auf fremde Ziele übertragen.
