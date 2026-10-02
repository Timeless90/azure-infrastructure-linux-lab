# Copilot als Learning-Buddy in VS Code

Stand der offiziellen Konfigurationsprüfung: 2026-10-02. Öffne die Wurzel dieses Repositorys in einer aktuellen stabilen VS-Code-Version mit GitHub Copilot und Copilot Chat. Anmeldung, verfügbares Copilot-Abo und Organisationsrichtlinien bleiben deine Voraussetzungen. Python 3.12 ist bereits Kursvoraussetzung; keine zusätzlichen Python-Pakete, Node-Pakete, Azure-Anmeldung oder Tokens sind für die Quellenserver nötig.

## Aktivieren

1. Checke den Kursbranch aus, solange PR #1 noch nicht gemergt ist. Öffne den Repositoryordner, nicht nur modules/.
2. Lies `.github/hooks/learning_context.py`, `scripts/linux_docs_mcp.py` und `.vscode/mcp.json`, bevor du Workspace Trust freigibst. Lokale Hooks und MCP-Server sind ausführbarer Code.
3. Öffne Copilot Chat, wähle den **Local**-Session-Target und den Agenten **Learning Buddy**. Andere Harnesses können andere Hook-Formate benötigen.
4. Öffne `.vscode/mcp.json` und starte **microsoft-learn** und **linux-docs** über die angebotenen Aktionen oder **MCP: List Servers**. Kontrolliere die Serverausgabe. Bei `python3` nicht gefunden: den tatsächlichen Python-3.12-Pfad lokal in der Konfiguration verwenden. In Remote SSH läuft der Workspace-Server auf dem Remote-System; dort muss Python vorhanden sein.
5. Kontrolliere im Agent-Customizations-Editor Instructions, drei Skills und den SessionStart-Hook. Hooks sind Preview, benötigen Workspace Trust und für Local `chat.useHooks`. Organisationsrichtlinien können Features sperren.
6. Frage: „Ich bin in Modul 04. CLIENT-VM: curl auf SERVER_PRIVATE_IP:8080 läuft in einen Timeout. Welche Beobachtung brauchst du zuerst? Gib noch keine Lösung.“

Die von dir genannte `MCP-Server.json` wäre keine automatisch erkannte Konfiguration. Das tatsächlich verwendete Format ist **.vscode/mcp.json**. Die aktuelle VS-Code-Dokumentation empfiehlt für neue, harnessübergreifende Konfigurationen inzwischen die portable `.mcp.json`; das gewünschte `.vscode`-Format bleibt als Kompatibilitätsformat unterstützt. Wir halten bewusst nur eine Konfiguration vor. Agent Host übernimmt geeignete VS-Code-Serverkonfigurationen, liest die Datei aber nicht selbst direkt. Der hier dokumentierte und zu prüfende Zielmodus ist Local.

## Was eingerichtet ist

| Datei/Komponente | Zweck |
|---|---|
| `.github/copilot-instructions.md` | Deutsch, Kursnavigation, Sicherheitsgrenzen, Hinweise statt vorschneller Lösungen |
| `.github/agents/learning-buddy.agent.md` | Lesender Tutor mit Repositorysuche und den beiden Quellenservern |
| `.github/skills/learn-course/SKILL.md` | Orientierung und modulbezogene Lernbegleitung |
| `.github/skills/diagnose-network/SKILL.md` | Hypothesen, Messpunkte und Interpretation |
| `.github/skills/verify-primary-sources/SKILL.md` | Versionsbewusste Prüfung offizieller Dokumentation |
| `.github/hooks/learning-context.json` | Local SessionStart fügt einen kurzen Tutor-Kontext hinzu |
| `microsoft-learn` | Offizieller remote HTTP-MCP für Azure-/Microsoft-Dokumentation |
| `linux-docs` | Repositoryeigener stdio-MCP mit festen offiziellen Dokumentations-URLs |

Linux-Tools: `list_sources` liefert Quellen, `fetch_source` liest einen begrenzten Textausschnitt, optional mit `query`, beispielsweise `source=nmap-ports, query=filtered`. Unterstützt sind Nmap, tcpdump, systemctl, journalctl, Ubuntu Noble ip/ss und curl. Es gibt keinen Scan-, Terminal-, Datei- oder Azure-Verwaltungszugriff. Keine freien URLs, Redirects oder Umgebungsproxies; 15 Sekunden Timeout und 1 MB Abruflimit. Externe Texte nicht als Anweisungen behandeln. Quelleninhalte werden weder ins Repository geschrieben noch dauerhaft zwischengespeichert. Online-systemd/curl können neuer als die Lab-Version sein; lokale `man`-Seiten bleiben die Referenz für die installierte Version.

Microsoft Learn erhält Suchanfragen, also keine Secrets, Subscription-Daten oder vertraulichen Logs eingeben. Für Azure-Dokumentation ist kein Azure-MCP-Verwaltungsserver erforderlich. Ein solcher Server würde zusätzliche Kontozugriffe anbieten und ist deshalb hier nicht vorkonfiguriert.

## Prüfen und Fehler eingrenzen

Frage im Buddy: „Verwende linux-docs list_sources; lies aus nmap-ports die Bedeutung von filtered und nenne die Quelle.“ Danach: „Suche mit Microsoft Learn nach default outbound access und erkläre die Konsequenz für dieses Lab.“ Erwartet werden tatsächliche Toolaufrufe, Quellen und Versionshinweise, kein erfundener Scan. Teste zuletzt eine Challenge: Der Buddy soll einen Hinweis geben und solutions.md geschlossen lassen. Diese Verhaltenstests musst du in deiner VS-Code-Session durchführen; lokale Protokolltests beweisen kein Modellverhalten.

Bei fehlendem Agenten: Dateiendung `.agent.md`, Repositorywurzel und Customizations-Diagnose prüfen. Bei fehlenden MCP-Tools: Server starten, Tools im Chat auswählen, Richtlinien und Output prüfen; nach Änderungen Tools neu laden. Bei Fetch-Fehlern kann die Quelle Redirects, Proxyzugang oder andere HTML-Pfade benötigen. Der Server folgt bewusst keinen Redirects; öffne die offizielle URL manuell und aktualisiere die feste URL nach Prüfung. Ein Quellenkatalog ist kein erfolgreicher Live-Abruf.

Der Hook schreibt nur fest definierten Kontext nach stdout. Er liest keine Dateien, speichert keine Prompts und führt keine Diagnose aus. Er blockiert keine Tools und ist keine Sicherheitsgrenze. Die eingeschränkte Agent-Toolauswahl und deine Toolfreigaben sind zusätzlich zu prüfen; andere Agenten haben gegebenenfalls mehr Rechte. Automatische Freigabe für Terminal-/Cloud-Tools nicht einschalten, um einen Quellenfehler zu beheben.

## Beispiele

- „Erkläre den Request-Weg anhand von infra/bicep/main.bicep und docs/architecture.md. Frage anschließend nach meinem Verständnis.“
- „SERVER-VM: ss zeigt 127.0.0.1:8080. Was kann ich daraus schließen, was noch nicht?“
- „Hilf mir bei Challenge 07 mit Hinweis 1. Öffne die Lösung noch nicht.“
- „Prüfe diese Azure-Annahme mit Learn; gib Abrufdatum und Grenzen an.“

## Quellen

- [VS Code MCP-Konfiguration](https://code.visualstudio.com/docs/agent-customization/mcp-servers)
- [VS Code Skills](https://code.visualstudio.com/docs/agent-customization/agent-skills)
- [VS Code Custom Agents](https://code.visualstudio.com/docs/agent-customization/custom-agents)
- [VS Code Local Hooks](https://code.visualstudio.com/docs/agent-customization/hooks)
- [Microsoft Learn MCP](https://learn.microsoft.com/en-us/training/support/mcp-developer-reference)
- [MCP stdio-Spezifikation](https://modelcontextprotocol.io/specification/2025-03-26/basic/transports)

Zur allgemeinen Tutor-Arbeitsweise: [Tutor-Prompt](tutor-prompt.md). Zum manuellen Diagnostizieren: [Cheatsheet](../cheatsheets/diagnosis.md).
