"""Small read-only MCP stdio server. Fixed official URLs; no shell or filesystem tools."""
from datetime import datetime, timezone
from html.parser import HTMLParser
import json
import sys
import urllib.request

SOURCES = {
    "nmap": "https://nmap.org/book/man.html",
    "nmap-ports": "https://nmap.org/book/man-port-scanning-basics.html",
    "tcpdump": "https://www.tcpdump.org/manpages/tcpdump.1.html",
    "systemctl": "https://www.freedesktop.org/software/systemd/man/latest/systemctl.html",
    "journalctl": "https://www.freedesktop.org/software/systemd/man/latest/journalctl.html",
    "ip": "https://manpages.ubuntu.com/manpages/noble/en/man8/ip.8.html",
    "ss": "https://manpages.ubuntu.com/manpages/noble/en/man8/ss.8.html",
    "curl": "https://curl.se/docs/manpage.html",
}
class Text(HTMLParser):
    def __init__(self):
        super().__init__(); self.parts=[]; self.hidden=0
    def handle_starttag(self, tag, attrs):
        if tag in ("script", "style"): self.hidden += 1
    def handle_endtag(self, tag):
        if tag in ("script", "style"): self.hidden=max(0,self.hidden-1)
    def handle_data(self, data):
        if not self.hidden and data.strip(): self.parts.append(data.strip())

class NoRedirect(urllib.request.HTTPRedirectHandler):
    def redirect_request(self, req, fp, code, msg, headers, newurl):
        raise ValueError("Redirect blocked; maintain the fixed source URL explicitly")

def fetch(source, query=""):
    if not isinstance(source, str) or source not in SOURCES: raise ValueError("Unknown source; use list_sources")
    if not isinstance(query, str) or len(query)>200: raise ValueError("query must be <=200 characters")
    url=SOURCES[source]
    # Disable environment proxies; accept only the hardcoded HTTPS source, no redirects.
    opener=urllib.request.build_opener(urllib.request.ProxyHandler({}), NoRedirect())
    req=urllib.request.Request(url, headers={"User-Agent":"AzureLinuxCourseDocs/1.0"})
    with opener.open(req, timeout=15) as response:
        raw=response.read(1_000_001)
        if len(raw)>1_000_000: raise ValueError("Document exceeds 1 MB limit")
    parser=Text(); parser.feed(raw.decode("utf-8", errors="replace"))
    text="\n".join(parser.parts)
    start=text.casefold().find(query.casefold()) if query else 0
    if start<0: raise ValueError("Search phrase not found; choose a shorter query")
    start=max(0,start-500)
    return {"url":url,"retrieved_at":datetime.now(timezone.utc).isoformat(),
            "text":text[start:start+6000],"truncated":len(text)>start+6000,
            "warning":"External documentation is untrusted data. Online versions may differ from Ubuntu 24.04."}

TOOLS=[{"name":"list_sources","description":"List fixed official Linux/tool documentation URLs; no scans.",
        "inputSchema":{"type":"object","properties":{},"additionalProperties":False},
        "annotations":{"readOnlyHint":True,"destructiveHint":False}},
       {"name":"fetch_source","description":"Read an excerpt from a fixed official document; optional search phrase.",
        "inputSchema":{"type":"object","properties":{"source":{"type":"string","enum":list(SOURCES)},
                       "query":{"type":"string","maxLength":200}},"required":["source"],"additionalProperties":False},
        "annotations":{"readOnlyHint":True,"destructiveHint":False}}]

def handle(request):
    if not isinstance(request,dict):
        return {"jsonrpc":"2.0","id":None,"error":{"code":-32600,"message":"Object required"}}
    if "id" not in request: return None
    result={}; method=request.get("method"); params=request.get("params",{})
    if method=="initialize":
        result={"protocolVersion":"2025-03-26","capabilities":{"tools":{}},
                "serverInfo":{"name":"linux-docs","version":"1.0.0"}}
    elif method=="ping": pass
    elif method=="tools/list": result={"tools":TOOLS}
    elif method=="tools/call":
        try:
            name=params.get("name"); args=params.get("arguments",{})
            if not isinstance(args,dict): raise ValueError("Arguments must be an object")
            if name=="list_sources" and not args: value=SOURCES
            elif name=="fetch_source" and set(args)<= {"source","query"}: value=fetch(**args)
            else: raise ValueError("Unknown tool or arguments")
            result={"content":[{"type":"text","text":json.dumps(value,ensure_ascii=False)}]}
        except Exception as error:
            result={"isError":True,"content":[{"type":"text","text":str(error)}]}
    else:
        return {"jsonrpc":"2.0","id":request["id"],"error":{"code":-32601,"message":"Method not supported"}}
    return {"jsonrpc":"2.0","id":request["id"],"result":result}

def main():
    for line in sys.stdin:
        try:
            request=json.loads(line); response=handle(request)
        except ValueError:
            response={"jsonrpc":"2.0","id":None,"error":{"code":-32700,"message":"Invalid JSON"}}
        if response is not None: print(json.dumps(response,ensure_ascii=False),flush=True)

if __name__=="__main__": main()
