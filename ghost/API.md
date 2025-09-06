---
title: Ghost API Guide for Docker Setup
last_updated: 2025-09-06
---

# Ghost API Guide

This document explains how to interact with the Ghost APIs provided by your Docker deployment in `ghost/`.

Assumptions: you have loaded environment variables from `.env` (see `.env.sample`) in your shell:
```bash
source .env
# Expecting (at minimum):
# GHOST_URL, GHOST_CONTENT_API_KEY (for Content API), and optionally GHOST_ADMIN_API_KEY or GHOST_ADMIN_JWT
```

Your compose maps Ghost to:

- External URL: `$GHOST_URL` (e.g., `http://192.168.1.8:8018`)
- Container port: `2368`
- Compose service: `ghost-app`

Note: If accessing from the same host, `http://localhost:8018` may also work depending on your network.

## What kind of API does Ghost provide?

Ghost exposes two primary HTTP APIs:

- Content API (read-only)
  - Purpose: Public, read-only access to published content (posts, pages, tags, authors, settings).
  - Auth: Content API Key (public-ish). Passed as `key=YOUR_CONTENT_API_KEY` query parameter.
  - Base path: `/ghost/api/content/`
  - Version: Ghost 5.x uses v5 endpoints (no explicit `v5/` path segment; versioning is handled server-side). Using `v5` SDKs is appropriate.

- Admin API (read-write)
  - Purpose: Administrative access for managing content, settings, users, etc.
  - Auth: Admin API Key (private). Requests must be authenticated with a short-lived JWT signed with your Admin API key secret, sent as `Authorization: Ghost <JWT>`.
  - Base path: `/ghost/api/admin/`

Ghost also supports:

- Webhooks: Configure in Admin UI to receive events.
- Members/Subscriptions: Client-side libraries for site membership; not covered in depth here.

Official docs: https://ghost.org/docs/

---

## Getting API Keys

1) Sign in to your Ghost Admin: `$GHOST_URL/ghost` (or `http://localhost:8018/ghost`).
2) Go to: Settings → Integrations → Add custom integration.
3) You'll get:
   - Content API Key
   - Admin API Key (format: `<key_id>:<secret>`)

Keep the Admin API key secret safe. 

**Do not commit it to version control!**

### How to get the Content API key (step-by-step)

1) Open the admin UI: `http://192.168.1.8:8018/ghost` and sign in.
2) Navigate to `Settings → Integrations`.
3) Click `Add custom integration` and give it a name (e.g., `Local Dev`).
4) After creating it, the panel will show both:
   - Content API Key (use this for read-only Content API calls)
   - Admin API Key (keep this private for Admin API; it has the form `key_id:secret`)
5) You can revisit this integration later to view, regenerate, or revoke keys.

Quick verify with curl:
```bash
curl "http://192.168.1.8:8018/ghost/api/content/posts/?key=PASTE_CONTENT_KEY_HERE&limit=1"
```
If it returns JSON with a `posts` array, the key works. If you get 403/401, double-check the `key` parameter and that at least one post is published.

Tip: Create separate integrations (and keys) per environment or app for easier rotation and revocation.

---

## Base URLs (with your compose values)

- Site URL: `$GHOST_URL` (from compose `url`)
- Content API base: `$GHOST_URL/ghost/api/content/`
- Admin API base: `$GHOST_URL/ghost/api/admin/`

If you prefer localhost:

- `http://localhost:8018/ghost/api/content/`
- `http://localhost:8018/ghost/api/admin/`

---

## Quick health-check (ping)

You can quickly verify the instance is reachable and the APIs respond:

1) Root (should return HTML with 200 OK):
```bash
curl -I "$GHOST_URL/"
```

2) Content API (requires Content API key; returns JSON):

```bash
curl "$GHOST_URL/ghost/api/content/posts/?key=$GHOST_CONTENT_API_KEY&limit=1"
```

3) Admin API (requires Admin JWT; returns JSON):

```bash
curl -I "$GHOST_URL/ghost/api/admin/posts/?limit=1" \
  -H "Authorization: Ghost $GHOST_ADMIN_JWT"
```

If you see 401 for Admin API, ensure your JWT is valid and not expired. If you see 403 for Content API, check that the `key` query parameter is present and correct.

## Content API Examples (read-only)

The Content API uses a query parameter `key` for authentication.

### List posts (basic)

Curl:
```bash
curl "$GHOST_URL/ghost/api/content/posts/?key=$GHOST_CONTENT_API_KEY"
```

JavaScript (browser/node):
```js
const base = process.env.GHOST_URL;
const key = process.env.GHOST_CONTENT_API_KEY;

async function listPosts() {
  const res = await fetch(`${base}/ghost/api/content/posts/?key=${key}`);
  if (!res.ok) throw new Error(await res.text());
  const data = await res.json();
  return data.posts; // [{id, title, slug, ...}]
}

listPosts().then(console.log).catch(console.error);
```

### Include extra fields and related entities

```bash
curl "$GHOST_URL/ghost/api/content/posts/?key=$GHOST_CONTENT_API_KEY&fields=title,slug,excerpt,reading_time&include=tags,authors"
```

### Retrieve a single post by slug

```bash
curl "$GHOST_URL/ghost/api/content/posts/slug/welcome/?key=$GHOST_CONTENT_API_KEY"
```

### Pagination and filtering

```bash
# Page 2, 10 per page
curl "$GHOST_URL/ghost/api/content/posts/?key=$GHOST_CONTENT_API_KEY&page=2&limit=10"

# Filter by tag
curl "$GHOST_URL/ghost/api/content/posts/?key=$GHOST_CONTENT_API_KEY&filter=tag:news"

# Order by published_at desc
curl "$GHOST_URL/ghost/api/content/posts/?key=$GHOST_CONTENT_API_KEY&order=published_at%20desc"
```

More: https://ghost.org/docs/content-api/

---

## Admin API Examples (read-write)

The Admin API requires a JWT signed using your Admin API key secret. The Admin API key has the format `<key_id>:<secret>`.

### Create a JWT (Node.js)

Install `jsonwebtoken` in your environment:
```bash
npm i jsonwebtoken
```

Generate a token:
```js
const jwt = require('jsonwebtoken');

// Admin API key from Ghost Admin → Integrations (load from env)
const ADMIN_API_KEY = process.env.GHOST_ADMIN_API_KEY; // "<key_id>:<secret>"
const [id, secret] = (ADMIN_API_KEY || '').split(':');

// JWT header and payload per Ghost spec
const token = jwt.sign(
  {
    // Ghost requires `kid` in header (set via sign options), and `iat`/`exp` in payload
  },
  Buffer.from(secret, 'hex'),
  {
    keyid: id,
    algorithm: 'HS256',
    expiresIn: '5m',
    audience: '/v5/admin/' // for Ghost 5.x
  }
);

console.log(token);
```

Note: The `audience` should be `/v5/admin/` for Ghost 5.x. Some examples omit `v5`; Ghost 5 will accept `/v5/admin/` or `/admin/` depending on version. If you see 401s, set the audience to `/v5/admin/`.

### Use the JWT to call Admin API

Create a post:
```bash
BASE="$GHOST_URL"

curl -X POST "$BASE/ghost/api/admin/posts/" \
  -H "Authorization: Ghost $GHOST_ADMIN_JWT" \
  -H "Content-Type: application/json" \
  -d '{
    "posts": [
      {
        "title": "Hello from API",
        "slug": "hello-from-api",
        "html": "<p>Created via Admin API</p>",
        "status": "draft"
      }
    ]
  }'
```

List posts (admin view):
```bash
curl "$BASE/ghost/api/admin/posts/?limit=5" -H "Authorization: Ghost $GHOST_ADMIN_JWT"
```

Publish a post:
```bash
# Replace :id with the post id returned from create/list
curl -X PUT "$BASE/ghost/api/admin/posts/:id/" \
  -H "Authorization: Ghost $GHOST_ADMIN_JWT" \
  -H "Content-Type: application/json" \
  -d '{
    "posts": [
      { "id": ":id", "status": "published" }
    ]
  }'
```

Admin API reference: https://ghost.org/docs/admin-api/

---

## CORS and Browser Access

- Content API is designed for client-side access and includes CORS headers.
- Admin API is typically used server-to-server. If you must call it from the browser, you may hit CORS restrictions and you must protect your Admin key. Prefer a backend proxy that injects the Admin JWT.

---

## SDKs and Tools

- JavaScript Content API SDK: https://ghost.org/docs/content-api/javascript/
- JavaScript Admin API SDK: https://ghost.org/docs/admin-api/
- Postman Collections: Available from Ghost docs.

Example using the official Content API SDK:
```bash
npm i @tryghost/content-api
```
```js
const GhostContentAPI = require('@tryghost/content-api');

const api = new GhostContentAPI({
  url: process.env.GHOST_URL,
  key: process.env.GHOST_CONTENT_API_KEY,
  version: 'v5.0'
});

async function run() {
  const posts = await api.posts.browse({ limit: 5, include: ['authors', 'tags'] });
  console.log(posts.map(p => p.title));
}

run().catch(console.error);
```

Example using the official Admin API SDK (handles JWT for you):

```bash
npm i @tryghost/admin-api
```

```js
const GhostAdminAPI = require('@tryghost/admin-api');

const admin = new GhostAdminAPI({
  url: process.env.GHOST_URL,            // e.g. http://192.168.1.8:8018
  key: process.env.GHOST_ADMIN_API_KEY,  // format: keyid:hexsecret
  version: 'v5.0'
});

async function runAdmin() {
  // Browse posts with admin privileges (includes drafts)
  const posts = await admin.posts.browse({ limit: 1 });
  console.log(posts.map(p => ({ id: p.id, title: p.title, status: p.status })));

  // Example: create a draft post
  // const created = await admin.posts.add({ title: 'Hello from Admin SDK', html: '<p>Body</p>', status: 'draft' });
  // console.log('Created:', created.id);
}

runAdmin().catch(console.error);
```

Notes:
- The Admin SDK uses the Admin API key to generate the required short-lived JWT internally. You do not need to set `GHOST_ADMIN_JWT` when using the SDK.
- Ensure `GHOST_ADMIN_API_KEY` is exactly `keyid:hexsecret` copied from Ghost Admin → Settings → Integrations.

---

## Troubleshooting

- 401 Unauthorized
  - For Content API: check the `key` parameter and that the post is published/visible.
  - For Admin API: ensure JWT audience is `/v5/admin/`, token not expired (`exp` ~5 minutes), system clock correct, and `Authorization: Ghost <JWT>` header is present.

- 404 Not Found
  - Ensure your base URL matches the configured `url` in compose.
  - Check the endpoint path: Content = `/ghost/api/content/...`, Admin = `/ghost/api/admin/...`.

- Mixed Content (HTTPS)
  - If you put Ghost behind a reverse proxy (e.g., Traefik) with HTTPS, ensure the `url` is set to the public HTTPS URL and that `X-Forwarded-*` headers are forwarded.

---

## Compose context (from `ghost/docker-compose.yml`)

```yaml
services:
  ghost-app:
    image: ghost:5.7.0-alpine
    ports:
      - "8018:2368"
    environment:
      url: http://192.168.1.8:8018
```

This document assumes those values.
