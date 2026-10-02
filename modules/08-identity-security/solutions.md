# 08 – Hinweise und Lösungen

[Zur Aufgabenstellung](README.md)

## Break & Fix und positiver Vault-Test

Hinweis 1: Prüfe, ob du ARM oder Secret-Endpunkt benutzt. Hinweis 2: Netzwerkfirewall und Data-Plane-Rolle getrennt betrachten. Lösung: Rolle am Kurs-Vault nachweisen, nicht durch NetworkAllowAll ersetzen.

[AZURE-CLI-TERMINAL — eigene Kurskonfiguration]
```bash
source scripts/common.sh
load_lab
guard_rg
VAULT_NAME=$(az deployment group show -g "$RG" --subscription "$SUBSCRIPTION" -n course-key-vault --query properties.outputs.vaultName.value -o tsv)
VAULT_ID=$(az keyvault show -g "$RG" -n "$VAULT_NAME" --subscription "$SUBSCRIPTION" --query id -o tsv)
USER_ID=$(az ad signed-in-user show --query id -o tsv)
```
Falls Directory-Read blockiert ist, eigene Object-ID vom Administrator bestätigen lassen, nicht raten.

[AZURE-CLI-TERMINAL — nur mit Role-Assignment-Rechten, bewusste Berechtigungsänderung]
```bash
az role assignment create --assignee-object-id "$USER_ID" --assignee-principal-type User   --role 'Key Vault Secrets Officer' --scope "$VAULT_ID" --subscription "$SUBSCRIPTION"
```
Ausgabe/Assignment-ID privat notieren, niemals fremde bestehende Zuweisungen entfernen. Nach Propagation [AZURE-CLI-TERMINAL]:
[AZURE-CLI-TERMINAL]
```bash
az keyvault secret set --vault-name "$VAULT_NAME" --name course-message --value synthetic-course-value --output none
az keyvault secret show --vault-name "$VAULT_NAME" --name course-message --query id -o tsv
```
Es wird nur der synthetische Wert erstellt; Query zeigt ID statt Secretinhalt.

## Challenge: Managed Identity optional tatsächlich testen

Hinweis 1: server-vm.identity.principalId. Hinweis 2: Key Vault Secrets User genügt für Lesen. [AZURE-CLI-TERMINAL — wie oben initialisiert, mit Zuweisungsrechten]:
[AZURE-CLI-TERMINAL — wie oben initialisiert, mit Zuweisungsrechten]
```bash
PRINCIPAL_ID=$(az vm show -g "$RG" -n server-vm --subscription "$SUBSCRIPTION" --query identity.principalId -o tsv)
SERVER_PUBLIC_IP=$(az network public-ip show -g "$RG" -n server-pip --subscription "$SUBSCRIPTION" --query ipAddress -o tsv)
az role assignment create --assignee-object-id "$PRINCIPAL_ID" --assignee-principal-type ServicePrincipal   --role 'Key Vault Secrets User' --scope "$VAULT_ID" --subscription "$SUBSCRIPTION"
az keyvault network-rule add -g "$RG" -n "$VAULT_NAME" --subscription "$SUBSCRIPTION" --ip-address "$SERVER_PUBLIC_IP/32"
```
Kopiere nur den Vault-Namen auf server-vm, keine Tokens. Optionaler Lesetest ohne Tokenausgabe [SERVER-VM]:
[SERVER-VM]
```bash
read -r -p 'Eigener Kurs-Vault-Name: ' VAULT_NAME
export VAULT_NAME
python3 - <<'EOF'
import json,os,re,urllib.request,urllib.parse
name=os.environ['VAULT_NAME']
assert re.fullmatch(r'kv-[a-z0-9]{13}',name), 'Nur Kurs-Vault verwenden'
q=urllib.parse.urlencode({'api-version':'2018-02-01','resource':'https://vault.azure.net'})
# IMDS ist nur in der eigenen Azure-VM; Proxies bewusst umgehen.
http=urllib.request.build_opener(urllib.request.ProxyHandler({}))
r=urllib.request.Request('http://169.254.169.254/metadata/identity/oauth2/token?'+q,headers={'Metadata':'true'})
token=json.load(http.open(r,timeout=10))['access_token']
r=urllib.request.Request('https://'+name+'.vault.azure.net/secrets/course-message?api-version=7.4',headers={'Authorization':'Bearer '+token})
data=json.load(http.open(r,timeout=10))
assert data['value']=='synthetic-course-value'
print('Synthetischer Managed-Identity-Lesetest erfolgreich; Token nicht ausgegeben')
EOF
```
Fehlermeldung und HTTP-Status ohne Credentialausgabe prüfen. Die Standardbibliothek testet hier bewusst den Tokenweg; produktiv passende Azure SDK Credential-Bibliothek verwenden. Nach Lab neue Server-/32-Regel gezielt entfernen und neu angelegte Role-Assignments anhand eigener IDs entfernen; RG-Cleanup entfernt ressourcenspezifische Scopes.

## Quiz

1. Workload- und Endnutzeridentität sind verschieden. 2. Unter RBAC keine automatische Secret-Data-Plane-Berechtigung. 3. Nein, auch App/Vault/RBAC können 403 liefern. 4. NSG-Entscheidung für beschriebenen Flow, keine TLS-/HTTP-/App-Prüfung.
