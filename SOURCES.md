# Quellenprüfung

Prüfdatum: **2026-10-02**. Primärquellen wurden vor der technischen Ausarbeitung per Dokumentenabruf geprüft. Website-Upstreamstände können vom Ubuntu24.04-Paketstand abweichen. Das ist kein Azure-Integrationstest und keine live aus deiner Subscription ermittelte Kapazitäts-/Image-Prüfung. Betriebssystem und regionale Imageversion: [Versionen](docs/versions.md).

## Technische Quellen und Verwendung

| Quelle | Geprüfter Inhalt / Verwendung |
|---|---|
| [Canonical Ubuntu Images](https://ubuntu.com/azure/docs/azure-how-to/instances/find-ubuntu-images/) | 24.04-LTS-Familie `Canonical:ubuntu-24_04-lts:server`, AMD64 Gen2; numerische regionale Version muss Lernender ermitteln |
| [CLI VM image](https://learn.microsoft.com/en-us/cli/azure/vm/image?view=azure-cli-latest) | list/show für regionales Pinning |
| [Default Outbound](https://learn.microsoft.com/en-us/azure/virtual-network/ip-services/default-outbound-access) | private Defaults sind API-abhängig, nach31.03.2026 veröffentlichte API; bestehende VNets nicht pauschal verändert; explizite IP/Outbound-Methoden |
| [NSG](https://learn.microsoft.com/en-us/azure/virtual-network/network-security-groups-overview) | Priorität und stateful Flows, effektive Regelinterpretation |
| [UDR](https://learn.microsoft.com/en-us/azure/virtual-network/virtual-networks-udr-overview) | Fabric/Systemrouten und spezifische None-Route |
| [Network Template2024-05-01](https://learn.microsoft.com/en-us/azure/templates/microsoft.network/2024-05-01/virtualnetworks) | explizite VNet/Subnet-Properties |
| [Compute Template2024-07-01](https://learn.microsoft.com/en-us/azure/templates/microsoft.compute/2024-07-01/virtualmachines) | VM/NIC/SSH/cloud-init-Schema |
| [Bicep Installation](https://learn.microsoft.com/en-us/azure/azure-resource-manager/bicep/install), [Module](https://learn.microsoft.com/en-us/azure/azure-resource-manager/bicep/modules), [what-if](https://learn.microsoft.com/en-us/azure/azure-resource-manager/bicep/deploy-what-if) | lokale Build- und Planprüfung, Module/Outputs |
| [Storage PE](https://learn.microsoft.com/en-us/azure/storage/common/storage-private-endpoints) | Blob Subresource, private DNS und Data-Plane-Abgrenzung |
| [Service Endpoint](https://learn.microsoft.com/en-us/azure/virtual-network/virtual-network-service-endpoints-overview) | Konzeptvergleich, kein zweites Pflichtdeployment |
| [Key Vault RBAC](https://learn.microsoft.com/en-us/azure/key-vault/general/rbac-guide), [Managed Identity](https://learn.microsoft.com/en-us/entra/identity/managed-identities-azure-resources/overview) | Planes und Least-Privilege-Labrollen |
| [IP flow verify](https://learn.microsoft.com/en-us/azure/network-watcher/ip-flow-verify-overview), [NSG Flow Logs](https://learn.microsoft.com/en-us/azure/network-watcher/nsg-flow-logs-overview) | Diagnosegrenzen; keine neue NSG-Flow-Log-Pflichtübung |
| [Budgets](https://learn.microsoft.com/en-us/azure/cost-management-billing/costs/tutorial-acm-create-budgets) | Alerts und Kostenkontrolle, keine harte Sperre |
| [Nmap Reference](https://nmap.org/book/man-port-scanning-basics.html) | scan-/messpunktabhängige Portstates, enger TCP-Connect-Scan |
| [tcpdump Manpage-Quelltext](https://github.com/the-tcpdump-group/tcpdump/blob/master/tcpdump.1.in) | begrenzter Capture, Optionen, Messpunkt; direkte tcpdump.org-Seite war nicht abrufbar |
| [systemd Manpage-Quelltext](https://github.com/systemd/systemd/blob/main/man/systemd.service.xml) | Unit/ExecStart/Restart; freedesktop-Seite lieferte403, Quelltext als Primäralternative |
| [ip-route Manpage](https://man7.org/linux/man-pages/man8/ip-route.8.html) | get versus show und Route-Typen; ergänzend Ubuntu-Paketmanpage lokal benutzen |
| [OpenSSL3.0 s_client](https://docs.openssl.org/3.0/man1/openssl-s_client/) | explizite Hostname-/Trust-Prüfung |
| [Docker Network](https://docs.docker.com/engine/network/), [Ubuntu Installation](https://docs.docker.com/engine/install/ubuntu/) | Namespace/Bridge/Portmapping und Plattformvoraussetzungen |
| [FastAPI Docker](https://fastapi.tiangolo.com/deployment/docker/) | Uvicorn-Containerbetrieb; App/Service sind eigene Beispiele |
| [ACA Ingress](https://learn.microsoft.com/en-us/azure/container-apps/ingress-overview), [Console](https://learn.microsoft.com/en-us/azure/container-apps/container-console), [Environment Schema](https://learn.microsoft.com/en-us/azure/templates/microsoft.app/2024-03-01/managedenvironments) | targetPort, Revision/Replica, Containerconsole statt Hostzugriff |
| [GHCR](https://docs.github.com/en/packages/working-with-a-github-packages-registry/working-with-the-container-registry) | manueller synthetischer Image-Transfer und Digest |

## Didaktische Ergänzungen

- [MicrosoftLearning/AZ-700](https://github.com/MicrosoftLearning/AZ-700-Designing-and-Implementing-Microsoft-Azure-Networking-Solutions): Netzwerk-Labumfang als Vergleich, kein Kursmaterial kopiert.
- [microsoft/WhatTheHack](https://github.com/microsoft/WhatTheHack): Challenge-/Coach-Trennung als didaktische Anregung, keine Aufgaben/Code übernommen.
- [Linux Upskill Challenge](https://linuxupskillchallenge.org/): zusätzliche eigenständige Linux-Übungen, keine Kapitelübersetzung/Übernahme.

Lizenzen wurden an den jeweiligen tatsächlichen LICENSE-/Manpage-Dateien geprüft, Ergebnisse in [ATTRIBUTIONS](ATTRIBUTIONS.md). Keine Preise aus fremden Blogs übernommen. Optionalthemen verlinken Einstiegspunkte, sind keine als komplett ausgearbeitet bewerteten Zusatzkurse.

## Copilot-Erweiterung — geprüft 2026-10-02

Offizielle Konfigurationsquellen: [VS Code MCP](https://code.visualstudio.com/docs/agent-customization/mcp-servers), [Skills](https://code.visualstudio.com/docs/agent-customization/agent-skills), [Custom Agents](https://code.visualstudio.com/docs/agent-customization/custom-agents), [Local Hooks](https://code.visualstudio.com/docs/agent-customization/hooks), [Learn MCP](https://learn.microsoft.com/en-us/training/support/mcp-developer-reference), [MCP stdio](https://modelcontextprotocol.io/specification/2025-03-26/basic/transports). Eigenständige Implementierung; keine fremden Code- oder Textpassagen übernommen. Weitere feste Linux-Quellen stehen in scripts/linux_docs_mcp.py; deren Live-Erreichbarkeit hängt vom Arbeitsplatznetz ab.
