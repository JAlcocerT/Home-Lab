---
source_code: https://github.com/growchief/growchief
official_docs: https://docs.growchief.com/quickstart
tags: ["Social Media","Outreach","Automation"]
---

# GrowChief

GrowChief is an open-source social media outreach automation tool. This Compose file pins the public image and keeps database passwords and auth secrets in `.env`.

```sh
cp .env.sample .env
# edit .env and replace the placeholder secrets
docker compose up -d
```

Open GrowChief:

```text
http://localhost:5002
```

Open Temporal UI:

```text
http://localhost:8080
```

For a local-only first run, leave optional provider keys empty. Add Google OAuth, enrichment, proxy, storage, email, and LLM keys only when you need those integrations.
