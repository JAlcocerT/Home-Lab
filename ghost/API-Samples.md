---
title: Ghost API Samples (Docker setup)
last_updated: 2025-09-06
---

# Ghost API Samples

Practical, copy-pasteable commands and snippets for your Ghost instance in `ghost/`, using environment variables from `.env`.

Assumption: you have loaded environment variables
```bash
# from the ghost/ folder
source .env
# Required:
#   GHOST_URL (e.g., http://192.168.1.8:8018)
#   GHOST_CONTENT_API_KEY (for Content API)
# Optional (Admin):
#   GHOST_ADMIN_API_KEY (keyid:hexsecret)
#   GHOST_ADMIN_JWT (short-lived token if doing raw HTTP Admin calls)
```

---

## Quick health-check

- Root (HTML):
```bash
curl -I "$GHOST_URL/"
```

- Content API (JSON):
```bash
curl "$GHOST_URL/ghost/api/content/posts/?key=$GHOST_CONTENT_API_KEY&limit=1"
```

- Admin API (requires Admin JWT):
```bash
curl -I "$GHOST_URL/ghost/api/admin/posts/?limit=1" \
  -H "Authorization: Ghost $GHOST_ADMIN_JWT"
```

---

## Content API (read-only)

- List latest 5 posts (title + slug):
```bash
curl "$GHOST_URL/ghost/api/content/posts/?key=$GHOST_CONTENT_API_KEY&limit=5&fields=title,slug&order=published_at%20desc"
```

- Include authors and tags:

```bash
curl "$GHOST_URL/ghost/api/content/posts/?key=$GHOST_CONTENT_API_KEY&limit=5&include=authors,tags"
```

- Retrieve a post by slug:
```bash
curl "$GHOST_URL/ghost/api/content/posts/slug/coming-soon/?key=$GHOST_CONTENT_API_KEY"
```

- Browse pages/tags/authors/settings:
```bash
curl "$GHOST_URL/ghost/api/content/pages/?key=$GHOST_CONTENT_API_KEY&limit=5"
curl "$GHOST_URL/ghost/api/content/tags/?key=$GHOST_CONTENT_API_KEY"
curl "$GHOST_URL/ghost/api/content/authors/?key=$GHOST_CONTENT_API_KEY"
curl "$GHOST_URL/ghost/api/content/settings/?key=$GHOST_CONTENT_API_KEY"
```

- Plaintext format (no HTML):
```bash
curl "$GHOST_URL/ghost/api/content/posts/?key=$GHOST_CONTENT_API_KEY&formats=plaintext"
```

- Filtering examples:
```bash
# Posts tagged "news"
curl "$GHOST_URL/ghost/api/content/posts/?key=$GHOST_CONTENT_API_KEY&filter=tag:news"

# Posts by author slug
curl "$GHOST_URL/ghost/api/content/posts/?key=$GHOST_CONTENT_API_KEY&filter=authors.slug:[your-author-slug]"
```

Notes:
- Content API returns only published content.
- Use URL-safe encoding for filters and ordering.

---

## Admin API via SDK (recommended)

The Admin SDK handles JWT creation internally. You need `GHOST_ADMIN_API_KEY` (keyid:hexsecret).

Install:
```bash
npm i @tryghost/admin-api dotenv
```

Minimal script (`admin-test.js` example):
```js
require('dotenv').config({ path: '.env' });
const GhostAdminAPI = require('@tryghost/admin-api');

const admin = new GhostAdminAPI({
  url: process.env.GHOST_URL,
  key: process.env.GHOST_ADMIN_API_KEY, // keyid:hexsecret
  version: 'v5.0'
});

(async () => {
  const posts = await admin.posts.browse({ limit: 1, order: 'updated_at desc' });
  console.log(posts.map(p => ({ id: p.id, title: p.title, status: p.status })));
})();
```

More Admin SDK examples:
```js
// Create a draft post
const created = await admin.posts.add({
  title: 'Hello from Admin SDK',
  html: '<p>Body</p>',
  status: 'draft'
});

// Publish a post
const published = await admin.posts.edit({ id: created.id, status: 'published' });

// Create a page
const page = await admin.posts.add({ title: 'About', html: '<p>About us</p>', page: true, status: 'published' });
```

---

## Admin API via raw HTTP (JWT needed)

If not using the SDK, generate a short-lived JWT signed with the Admin secret.

Generate a JWT (Node one-liner):
```bash
# Ensure jsonwebtoken is installed: npm i jsonwebtoken
export GHOST_ADMIN_JWT="$(node -e 'const jwt=require("jsonwebtoken"); const [id,sec]=(process.env.GHOST_ADMIN_API_KEY||"").split(":"); if(!id||!sec){throw new Error("Set GHOST_ADMIN_API_KEY=keyid:secret");} const t=jwt.sign({}, Buffer.from(sec,"hex"), {keyid:id, algorithm:"HS256", expiresIn:"5m", audience:"/v5/admin/"}); process.stdout.write(t);')"
```

Here-doc alternative (avoids quoting issues):
```bash
export GHOST_ADMIN_JWT="$(node <<'EOF'
const jwt = require('jsonwebtoken');
const [id, sec] = (process.env.GHOST_ADMIN_API_KEY || '').split(':');
if (!id || !sec) { throw new Error('Set GHOST_ADMIN_API_KEY=keyid:secret'); }
const t = jwt.sign({}, Buffer.from(sec, 'hex'), {
  keyid: id,
  algorithm: 'HS256',
  expiresIn: '5m',
  audience: '/v5/admin/'
});
process.stdout.write(t);
EOF
)"
```

Use the JWT:
```bash
# Create a draft post
curl -X POST "$GHOST_URL/ghost/api/admin/posts/" \
  -H "Authorization: Ghost $GHOST_ADMIN_JWT" \
  -H "Content-Type: application/json" \
  -d '{
    "posts": [
      { "title": "Hello via curl", "html": "<p>Created via Admin API</p>", "status": "draft" }
    ]
  }'

# List posts (admin view)
curl "$GHOST_URL/ghost/api/admin/posts/?limit=5" -H "Authorization: Ghost $GHOST_ADMIN_JWT"
```

---

## Troubleshooting

- Unknown Content API Key
  - Using Admin key instead of Content key, or key from another instance.
  - Fix: Copy the Content key from Ghost Admin → Settings → Integrations (your integration) and update `.env`.

- Authorization failed (Content API)
  - Often occurs when there is no published content or the key is missing in the query.
  - Fix: Publish at least one post and ensure you pass `key=...`.

- INVALID_AUTH_HEADER (Admin API)
  - Header was `Authorization: Ghost` with an empty token.
  - Fix: Ensure `$GHOST_ADMIN_JWT` is set and not empty.

- 401 Unauthorized (Admin API)
  - JWT expired (~5 minutes), wrong audience (`/v5/admin/`), wrong secret, or system clock skew.
  - Fix: Re-generate JWT; ensure audience `/v5/admin/`; verify `GHOST_ADMIN_API_KEY` is `keyid:hexsecret`; check system time.

- `.env` sourcing errors
  - Only `KEY=VALUE` lines are allowed. Bare `keyid:secret` lines will cause `command not found`.
  - Wrap secrets with special characters in quotes if needed.

---

## References

- Admin API: https://ghost.org/docs/admin-api/
- Content API: https://ghost.org/docs/content-api/
- SDKs: `@tryghost/admin-api`, `@tryghost/content-api`
