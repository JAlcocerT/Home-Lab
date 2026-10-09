---
source_code: https://github.com/lissy93/web-check
post: https://fossengineer.com/selfhosting-web-check/
tags: ["web", "security", "osint"]
---

# Web-Check

Web-Check is an on-demand website intelligence and security-inspection UI.

Start it:

```bash
docker compose up -d
```

Open:

```text
http://localhost:6160
```

The compose maps `${WEB_CHECK_PORT:-6160}` on the host to port `3000` in the container. Copy `.env.sample` to `.env` if you want to change the host port or supply optional keys:

```bash
cp .env.sample .env
```

Optional API keys unlock or improve third-party-backed checks:

| Variable | What it unlocks |
| --- | --- |
| `GOOGLE_CLOUD_API_KEY` | PageSpeed/quality checks and Google Safe Browsing |
| `SHODAN_API_KEY` | host names, server info, and vulnerability findings |
| `CLOUDMERSIVE_API_KEY` | Cloudmersive website threat scan |
| `TRANCO_USERNAME` / `TRANCO_API_KEY` | higher Tranco rank-check limits |
| `GITHUB_TOKEN` | higher GitHub limits for social-presence checks |
| `CERTSPOTTER_TOKEN` | higher CertSpotter limits for subdomain discovery |

Keep `API_BLOCKED_HOSTS` set when exposing this service. Web-Check performs outbound checks against user-supplied targets, so a public instance should be protected with authentication, rate limiting, and private-network block rules.
