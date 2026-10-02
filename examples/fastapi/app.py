"""Network vs authorization demo. X-Lab-Role is NOT real authentication."""
import logging
from uuid import uuid4
from fastapi import FastAPI, Header, HTTPException, Request
app = FastAPI(title="Azure Linux infrastructure lab")
log = logging.getLogger("uvicorn.error")
@app.middleware("http")
async def correlation(request: Request, call_next):
    request_id = str(uuid4())
    response = await call_next(request)
    response.headers["X-Request-ID"] = request_id
    # No headers, tokens, query values or body contents in logs.
    log.info("request_id=%s method=%s status=%s",request_id,request.method,response.status_code)
    return response
@app.get("/health")
def health():
    return {"status":"ok"}
@app.get("/admin")
def admin(x_lab_role: str | None = Header(default=None)):
    if x_lab_role is None:
        raise HTTPException(401,"lab role missing")
    if x_lab_role != "reader":
        raise HTTPException(403,"lab role denied")
    return {"message":"synthetic lab access granted"}
