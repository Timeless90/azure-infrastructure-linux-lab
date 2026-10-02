# Manueller Upload eines heruntergeladenen Kurses

Ziel ist `Timeless90/azure-infrastructure-linux-lab`. Repository existiert und enthielt beim Start nur `# azure-infrastructure-linux-lab` in README.md. Sichtbarkeit wurde als public beobachtet; Nutzer hat public-Schreiben ausdrücklich freigegeben. Keine Lizenz/Pages aktivieren.

Wenn der Kurs bereits auf einem Pull-Request-Branch gespeichert ist, verwende direkt dessen Dateien. Für ZIP-Import: ZIP entpacken und lokal das Zielrepository klonen. Verzeichnisse inklusive `.github` und `.gitignore` aus dem Archiv in die Arbeitskopie kopieren, niemals `.git` ersetzen. Prüfe vorhandene Änderungen zuerst. Kursversion gehört auf neuen Branch.

[LOKAL — geklonte Ziel-Arbeitskopie]
```bash
git status --short
git switch -c course/manual-import
# Jetzt Kursdateien aus ZIP per Dateimanager kopieren.
python3 scripts/validate.py
git diff --stat
git status --short
git add README.md ROADMAP.md PROGRESS.md SOURCES.md ATTRIBUTIONS.md VALIDATION.md CHANGELOG.md \
  .gitignore Makefile docs modules cheatsheets infra scripts examples tests config/lab.example.json .github
git diff --cached --stat
git commit -m 'Add Azure Linux infrastructure self-learning course'
git push -u origin course/manual-import
```

Keine Secrets konfigurieren, bevor du den Import prüfst. Öffne auf GitHub einen Pull Request dieses Branches nach main, prüfe Dateien/CI; nicht automatisch zusammenführen. Kein Force-Push. Bei einem nicht freigegebenen Zielkonto stoppen. Private Variante: Eigentümer ändert die Repository-Sichtbarkeit selbst bewusst in Settings; das ändert keine Inhalte.
