import importlib.util
import json
import os
from pathlib import Path
import subprocess
import sys
import threading
from http.server import ThreadingHTTPServer
import urllib.request
import urllib.error
import pytest
from fastapi.testclient import TestClient
ROOT=Path(__file__).resolve().parents[1]
def module(name,path):
    spec=importlib.util.spec_from_file_location(name,path)
    m=importlib.util.module_from_spec(spec);spec.loader.exec_module(m);return m
cfg=module('course_config',ROOT/'scripts/config.py')
app=module('course_app',ROOT/'examples/fastapi/app.py').app
@pytest.mark.parametrize('path,header,status',[('/health',{},200),('/admin',{},401),('/admin',{'X-Lab-Role':'denied'},403),('/admin',{'X-Lab-Role':'reader'},200),('/missing',{},404)])
def test_app_contract(path,header,status):
    with TestClient(app) as c:
        r=c.get(path,headers=header);assert r.status_code==status
        assert len(r.headers['X-Request-ID'])==36

def valid_config(tmp):
    c=json.loads((ROOT/'config/lab.example.json').read_text())
    c.update(subscriptionId='11111111-1111-1111-1111-111111111111',tenantId='22222222-2222-2222-2222-222222222222',accountName='synthetic@example.invalid',labId='test-lab',resourceGroup='rg-azlinux-course-test-lab',adminSourceCidr='8.8.8.8/32',sshPublicKeyPath=str(tmp/'test.pub'),imageVersion='24.04.202601010')
    (tmp/'test.pub').write_text('ssh-ed25519 synthetic-testing-public-key\n')
    return c

def test_prepare_parameters(tmp_path):
    c=valid_config(tmp_path);p=tmp_path/'lab.json';p.write_text(json.dumps(c))
    loaded=cfg.load(p);params=cfg.parameters(loaded)
    assert params['parameters']['clientIp']['value']=='10.10.1.4'
    assert 'sshPublicKey' in params['parameters']
@pytest.mark.parametrize('key,value',[('adminSourceCidr','0.0.0.0/0'),('imageVersion','latest'),('resourceGroup','production'),('clientIp','10.10.1.1'),('serverSubnetCidr','10.10.1.0/24'),('existingNetworks',['10.10.0.0/16'])])
def test_config_rejects_unsafe(tmp_path,key,value):
    c=valid_config(tmp_path);c[key]=value;p=tmp_path/'lab.json';p.write_text(json.dumps(c))
    with pytest.raises(ValueError):cfg.load(p)

def test_refuses_private_key(tmp_path):
    c=valid_config(tmp_path);c['sshPublicKeyPath']=str(tmp_path/'private.key')
    with pytest.raises(ValueError):cfg.parameters(c)

def test_real_synthetic_web_server():
    web=module('course_web',ROOT/'examples/web.py')
    server=ThreadingHTTPServer(('127.0.0.1',0),web.Handler)
    thread=threading.Thread(target=server.serve_forever,daemon=True);thread.start()
    try:
        url='http://127.0.0.1:'+str(server.server_port)
        assert json.load(urllib.request.urlopen(url+'/health'))=={'status':'ok'}
        with pytest.raises(urllib.error.HTTPError) as e:urllib.request.urlopen(url+'/missing')
        assert e.value.code==404
    finally:server.shutdown();server.server_close();thread.join()

@pytest.mark.parametrize('mode,input_text,expected_delete',[('normal','no\n',False),('wrongtag','DELETE 11111111-1111-1111-1111-111111111111/rg-azlinux-course-test-lab\n',False),('wrongaccount','DELETE 11111111-1111-1111-1111-111111111111/rg-azlinux-course-test-lab\n',False),('normal','DELETE 11111111-1111-1111-1111-111111111111/rg-azlinux-course-test-lab\n',True)])
def test_cleanup_with_mocked_azure(tmp_path,mode,input_text,expected_delete):
    root=tmp_path/'course';(root/'scripts').mkdir(parents=True);(root/'config').mkdir()
    for name in ('common.sh','cleanup.sh','config.py'):(root/'scripts'/name).write_text((ROOT/'scripts'/name).read_text())
    (root/'config/lab.json').write_text(json.dumps(valid_config(tmp_path)))
    bindir=tmp_path/'bin';bindir.mkdir();log=tmp_path/'calls.txt';marker=tmp_path/'deleted'
    fake=bindir/'az'
    fake.write_text("""#!/usr/bin/env python3
import sys,os
from pathlib import Path
a=sys.argv[1:];mode=os.environ['MOCK_MODE'];log=Path(os.environ['MOCK_LOG']);marker=Path(os.environ['MOCK_MARKER'])
with log.open('a') as f:f.write(' '.join(a)+'\\n')
if a[:2]==['account','show']:
 q=a[a.index('--query')+1]
 print({'id':'11111111-1111-1111-1111-111111111111','tenantId':'22222222-2222-2222-2222-222222222222','user.name':'wrong@example.invalid' if mode=='wrongaccount' else 'synthetic@example.invalid'}[q])
elif a[:2]==['group','exists']:print('false' if marker.exists() else 'true')
elif a[:2]==['group','show']:print('wrong' if mode=='wrongtag' else 'test-lab')
elif a[:2]==['resource','list']:print('synthetic course inventory')
elif a[:2]==['group','delete']:marker.touch()
else:sys.exit('Unexpected mocked command '+str(a))
""");fake.chmod(0o755)
    env=dict(os.environ,PATH=str(bindir)+os.pathsep+os.environ['PATH'],MOCK_MODE=mode,MOCK_LOG=str(log),MOCK_MARKER=str(marker))
    r=subprocess.run(['bash',str(root/'scripts/cleanup.sh')],input=input_text,capture_output=True,text=True,env=env)
    assert marker.exists()==expected_delete
    assert (r.returncode==0)==expected_delete
    assert ('group delete' in log.read_text())==expected_delete
