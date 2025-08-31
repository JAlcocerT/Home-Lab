# Gitea Webhooks — Concepts and Workflow

## Important: push vs pull, and what webhooks can do

- Webhooks in Gitea are outbound push-only: Gitea sends HTTP POSTs to your listener.
- Webhooks themselves cannot make Gitea change state. To act inside Gitea, your listener must call the Gitea API.
- "Pull" means polling the API for changes; it's an alternative to webhooks, not a webhook type. Gitea does not "pull" from your service.

**What webhooks are**

- __Push vs pull__: With webhooks, Gitea pushes HTTP POSTs to your endpoint whenever events happen (push, issues, PRs, releases, etc.). You don’t poll.
- __Why__: Trigger CI/CD, notify chats, sync external systems, run automations.

## Communication workflow

1) __Configure the webhook__ (repo/org level) in UI or via API (`POST /repos/{owner}/{repo}/hooks`).
2) __Event occurs__ in Gitea (e.g., push).
3) __Gitea sends HTTP POST__ to your URL with JSON payload + headers.
4) __Your listener verifies__ authenticity (HMAC signature) and __returns 2xx quickly__.
5) __Optionally call Gitea’s API__ if you need more info or to take actions.

> Direction: Webhooks are Gitea -> Your service.

> > To make things happen inside Gitea, you call its API (Your service -> Gitea).

## Key request headers from Gitea

- `X-Gitea-Event`: event type (e.g., `push`, `issues`, `pull_request`).
- `X-Gitea-Delivery`: unique delivery ID.
- `X-Gitea-Signature`: HMAC hex digest of the request body using your shared secret.
- `Content-Type`: typically `application/json`.

## Verifying signatures (security)

- Compute `hex(hmac_sha256(secret, raw_body))` and compare to `X-Gitea-Signature` (constant-time compare).
- Reject if missing/invalid. Always use HTTPS for the webhook URL.

### Minimal Python (Flask) listener

```python
from flask import Flask, request, abort
import hmac, hashlib

app = Flask(__name__)
SECRET = b"s3cr3t"

def verify(sig_header, body):
    if not sig_header:
        return False
    expected = hmac.new(SECRET, body, hashlib.sha256).hexdigest()
    # constant-time compare
    return hmac.compare_digest(expected, sig_header)

@app.route("/hook", methods=["POST"])
def hook():
    sig = request.headers.get("X-Gitea-Signature")
    event = request.headers.get("X-Gitea-Event")
    body = request.get_data()  # raw bytes
    if not verify(sig, body):
        abort(401)
    # TODO: enqueue work; keep handler fast
    print({"event": event, "json": request.json})
    return "ok", 200

if __name__ == "__main__":
    app.run(host="0.0.0.0", port=8080)
```

### Minimal Node (Express) listener

```js
const express = require("express");
const crypto = require("crypto");
const app = express();
const SECRET = Buffer.from("s3cr3t");

app.use(express.raw({ type: "application/json" })); // need raw body for HMAC

function verify(sig, body) {
  if (!sig) return false;
  const h = crypto.createHmac("sha256", SECRET).update(body).digest("hex");
  return crypto.timingSafeEqual(Buffer.from(h), Buffer.from(sig));
}

app.post("/hook", (req, res) => {
  const sig = req.header("X-Gitea-Signature");
  const event = req.header("X-Gitea-Event");
  if (!verify(sig, req.body)) return res.sendStatus(401);
  const payload = JSON.parse(req.body.toString());
  console.log({ event, payload });
  res.send("ok");
});

app.listen(8080, () => console.log("listening on 8080"));
```

## Example payload (push, simplified)

```json
{
  "ref": "refs/heads/main",
  "before": "3f1b...",
  "after": "a9cd...",
  "repository": { "full_name": "owner/repo", "html_url": "http://.../owner/repo" },
  "pusher": { "login": "user" },
  "commits": [ { "id": "a9cd...", "message": "feat: add thing" } ]
}
```

## Configuring a webhook via API

```bash
OWNER="<owner>"; REPO="<repo>"
curl -s -X POST \
  -H "Authorization: token $GITEA_TOKEN" \
  -H "Content-Type: application/json" \
  -d '{
    "type": "gitea",
    "config": { "url": "http://your-host:8080/hook", "content_type": "json", "secret": "s3cr3t" },
    "events": ["push","pull_request"],
    "active": true
  }' \
  "$GITEA_BASE/repos/$OWNER/$REPO/hooks" | jq '.id,.config.url'
```

## Testing locally

- __Expose your listener__: use a tunnel (e.g., `ssh -R`, cloudflared, or ngrok) to expose `http://localhost:8080/hook` to the internet.
- __Redeliver__: In the repo’s Webhooks UI, review deliveries and re-deliver.
- __Use a test endpoint__: temporarily point the webhook to a request inspector (e.g., webhook.site) to see raw requests.

## Delivery behavior

- __Retries__: Gitea retries limited times on non-2xx responses.
- __Timeouts__: keep handler fast; offload heavy work to a queue.
- __Idempotency__: deduplicate using `X-Gitea-Delivery` if needed.

## Common patterns

- __CI/CD__: push -> listener triggers build (then calls back Gitea API to set commit status).
- __Chat notifications__: issues/PRs -> listener posts to Slack/Matrix.
- __Sync/mirroring__: push -> listener kicks off downstream sync.
- __Automation__: push/PR -> run linters, labelers, backport bots.

## Webhooks vs API

- __Webhooks__: Gitea -> you. Event notifications only. Keep state outside and call API if you need to act.
- __API__: you -> Gitea. Perform reads/writes (create repos, issues, set statuses, etc.).

## Hardening & best practices

- Verify `X-Gitea-Signature` for every request.
- Use HTTPS and firewall/allowlist the source if possible.
- Return 2xx quickly; push long tasks to a worker.
- Log event type and delivery ID, not secrets.
- Rate limit and set timeouts on your side.

## See also

- `gitea/gitea-api.md` for API calls you might make from your webhook handler.
- Official docs: https://docs.gitea.com/usage/webhooks

## Practical Webhook Example with FastAPI

This repo includes a minimal FastAPI-based webhook listener that validates Gitea signatures and triggers an npm build on push events.

- Location: `gitea/user-creator-fastapi/main.py`
- Endpoint: `POST /webhook`
- Env vars (set in `gitea/user-creator-fastapi/.env`):
  - `WEBHOOK_SECRET`: shared secret for HMAC verification
  - `BUILD_ROOT`: base directory where repos will be cloned/built
  - `REPO_MAP`: optional JSON mapping of `"owner/repo"` to absolute build paths

### What the handler does

1) Reads headers `X-Gitea-Event`, `X-Gitea-Delivery`, `X-Gitea-Signature` and the JSON body.
2) Verifies `X-Gitea-Signature` as `hex(hmac_sha256(WEBHOOK_SECRET, raw_body))` using constant-time compare.
3) If event is `push`, extracts `repository.full_name` (e.g., `owner/repo`) and branch from `ref`.
4) Queues a background build task that:
   - Ensures repo exists under `BUILD_ROOT/owner/repo` (clones if missing).
   - Checks out the pushed branch and pulls latest.
   - Runs `npm ci` and then `npm run build` in that directory.

See functions `verify_signature()` and `run_build()` in `main.py`.

### Configure the webhook in Gitea

In the repository Settings → Webhooks:

- URL: `http://<host>:<port>/webhook` (e.g., `http://localhost:8055/webhook`)
- Content type: `application/json`
- Secret: the same value as `WEBHOOK_SECRET`
- Events: at minimum enable Push events

Keep your handler fast: it returns immediately after queuing the build.

### Testing locally (without Gitea)

Compute the signature over the exact raw JSON you will POST.

```bash
BODY='{"ref":"refs/heads/main","repository":{"full_name":"owner/repo"}}'
SIG=$(python - <<'PY'
import hmac, hashlib, os
secret=os.environ.get('WEBHOOK_SECRET','change_me').encode()
body=os.environ['BODY'].encode()
print(hmac.new(secret, body, hashlib.sha256).hexdigest())
PY
)

curl -sS -X POST \
  -H "Content-Type: application/json" \
  -H "X-Gitea-Event: push" \
  -H "X-Gitea-Signature: $SIG" \
  --data "$BODY" \
  http://localhost:8055/webhook | jq
```

If verification passes, the response includes `{ "queued": true }` and the background job will run the git/npm steps.

### Notes and hardening

- Ensure Node and npm are installed on the machine running the webhook service.
- For private repos, configure credentials for `git clone` (e.g., tokenized HTTPS URL or deploy keys). The current example uses unauthenticated HTTP clone.
- Restrict access to the webhook endpoint (IP allowlist/Gitea only), and always verify `X-Gitea-Signature`.
