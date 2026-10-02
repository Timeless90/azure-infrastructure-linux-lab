"""Repository-only QA: never logs into or deploys to Azure."""
import ast
import json
import os
from pathlib import Path
import re
import shutil
import subprocess
import sys
import tempfile
ROOT=Path(__file__).resolve().parents[1]
errors=[]
def check(ok,message):
    if not ok: errors.append(message)
def run(args):
    r=subprocess.run(args,cwd=ROOT,text=True,capture_output=True)
    if r.returncode: errors.append(' '.join(args)+': '+r.stdout+r.stderr)
modules=sorted((ROOT/'modules').glob('*/README.md'))
check(len(modules)==12,'Genau 12 Kernmodule erforderlich')
for p in modules:
    text=p.read_text()
    for letter in 'ABCDEFGHIJKLM': check(f'## {letter}. ' in text,f'{p}: Abschnitt {letter} fehlt')
    check((p.parent/'solutions.md').exists(),f'{p}: separate Lösung fehlt')
    check(len(text.split())>=450,f'{p}: zu wenig Unterrichtsinhalt')
for p in ROOT.rglob('*.md'):
    s=p.read_text()
    check(not re.search(r'\bTODO\b',s),f'{p}: TODO-Platzhalter')
    for link in re.findall(r'\]\(([^)]+)\)',s):
        if link.startswith(('https://','http://','#','mailto:')):continue
        target=link.split('#')[0]
        check((p.parent/target).exists(),f'{p}: fehlender Link {link}')
    for m in re.finditer(r'^```(?:bash|sh)\n(.*?)^```',s,re.M|re.S):
        before=s[:m.start()].splitlines()[-5:]
        check(any('[' in x and any(k in x for k in ('LOKAL','CLI','VM','CONTAINER')) for x in before),f'{p}: Ausführungskontext fehlt')
        with tempfile.NamedTemporaryFile('w',suffix='.sh') as f:
            f.write(m.group(1));f.flush();run(['bash','-n',f.name])
for p in (ROOT/'scripts').glob('*.sh'):run(['bash','-n',str(p)])
for p in ROOT.rglob('*.py'):
    if any(part.startswith('.') for part in p.relative_to(ROOT).parts):continue
    try:ast.parse(p.read_text(),filename=str(p))
    except SyntaxError as e:errors.append(str(e))
for p in ROOT.rglob('*.json'):
    if '.state' in p.parts or '.venv' in p.parts:continue
    try:json.loads(p.read_text())
    except ValueError as e:errors.append(f'{p}: {e}')
try:
    import yaml
    for pattern in ('*.yaml','*.yml'):
        for p in ROOT.rglob(pattern):
            if '.venv' in p.parts:continue
            try:yaml.safe_load(p.read_text())
            except yaml.YAMLError as e:errors.append(f'{p}: {e}')
except ImportError:errors.append('PyYAML fehlt: tests/requirements.txt installieren')
run([sys.executable,'-m','pytest','-q','tests'])
if errors:
    print('\n'.join(errors));sys.exit(1)
print('PASS: Modulstruktur, Lösungen, lokale Links, Blockkontexte, Bash/Python/JSON/YAML und Tests')
