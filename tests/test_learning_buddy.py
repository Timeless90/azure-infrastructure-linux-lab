"""Offline protocol, hook and configuration checks; no Azure or scans."""
import importlib.util
import json
from pathlib import Path
import subprocess
import sys
import pytest
ROOT=Path(__file__).resolve().parents[1]
spec=importlib.util.spec_from_file_location("docs_mcp",ROOT/"scripts/linux_docs_mcp.py")
m=importlib.util.module_from_spec(spec);spec.loader.exec_module(m)

def test_stdio_roundtrip():
    messages=[{"jsonrpc":"2.0","id":1,"method":"initialize","params":{"protocolVersion":"2025-03-26"}},
              {"jsonrpc":"2.0","method":"notifications/initialized"},
              {"jsonrpc":"2.0","id":2,"method":"tools/list"},
              {"jsonrpc":"2.0","id":3,"method":"tools/call","params":{"name":"list_sources"}}]
    p=subprocess.run([sys.executable,str(ROOT/"scripts/linux_docs_mcp.py")],input="\n".join(map(json.dumps,messages))+"\n",text=True,capture_output=True,check=True)
    replies=list(map(json.loads,p.stdout.splitlines()))
    assert [r["id"] for r in replies]==[1,2,3]
    assert replies[0]["result"]["protocolVersion"]=="2025-03-26"
    assert len(replies[1]["result"]["tools"])==2
    assert "nmap" in json.loads(replies[2]["result"]["content"][0]["text"])

def test_unknown_tool_and_source_rejected():
    for name,args in [("scan",{}),("fetch_source",{"source":"http://localhost"}),("fetch_source",{"source":"nmap","url":"https://example.com"})]:
        r=m.handle({"id":1,"method":"tools/call","params":{"name":name,"arguments":args}})
        assert r["result"]["isError"]

def test_redirect_blocked():
    with pytest.raises(ValueError):
        m.NoRedirect().redirect_request(None,None,302,"",{},"http://localhost")

def test_fetch_with_mock(monkeypatch):
    class Response:
        def __enter__(self): return self
        def __exit__(self,*args): pass
        def read(self,size): return b"<html><script>secret</script><p>filtered means uncertain</p></html>"
    class Opener:
        def open(self,req,timeout):
            assert req.full_url==m.SOURCES["nmap-ports"] and timeout==15
            return Response()
    monkeypatch.setattr(m.urllib.request,"build_opener",lambda *args:Opener())
    r=m.fetch("nmap-ports","filtered")
    assert "filtered" in r["text"] and "secret" not in r["text"]
    assert r["url"].startswith("https://nmap.org/")
    with pytest.raises(ValueError): m.fetch("nmap-ports","absent")

def test_hook_context_without_side_effects():
    p=subprocess.run([sys.executable,str(ROOT/".github/hooks/learning_context.py")],input='{"prompt":"synthetic"}',text=True,capture_output=True,check=True)
    r=json.loads(p.stdout)
    assert r["hookSpecificOutput"]["hookEventName"]=="SessionStart"
    assert "synthetic" not in p.stdout

def test_mcp_configuration_and_skill_metadata():
    import yaml
    c=json.loads((ROOT/".vscode/mcp.json").read_text())
    assert set(c["servers"])=={"microsoft-learn","linux-docs"}
    assert c["servers"]["microsoft-learn"]["url"]=="https://learn.microsoft.com/api/mcp"
    assert (ROOT/"scripts/linux_docs_mcp.py").exists()
    for p in (ROOT/".github/skills").glob("*/SKILL.md"):
        f=yaml.safe_load(p.read_text().split("---")[1])
        assert f["name"]==p.parent.name and f["description"]
