"""Small synthetic lab server; no external dependencies."""
from http.server import BaseHTTPRequestHandler, ThreadingHTTPServer
import argparse
import json
class Handler(BaseHTTPRequestHandler):
    def do_GET(self):
        status = 200 if self.path == "/health" else 404
        body = json.dumps({"status": "ok"} if status == 200 else {"detail":"not found"}).encode()
        self.send_response(status)
        self.send_header("Content-Type", "application/json")
        self.send_header("Content-Length", str(len(body)))
        self.end_headers()
        self.wfile.write(body)
if __name__ == "__main__":
    p=argparse.ArgumentParser();p.add_argument("--host",default="0.0.0.0");p.add_argument("--port",type=int,default=8080)
    a=p.parse_args();ThreadingHTTPServer((a.host,a.port),Handler).serve_forever()
