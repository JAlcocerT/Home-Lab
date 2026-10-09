---
source_code: https://github.com/linkcraftstudio/feedlog
post: https://fossengineer.com/selfhosting-feedlog/
tags: ["feedback", "roadmap", "changelog", "docker", "cloudflare", "vercel"]
---

FeedLog is an open-source feedback, roadmap, and changelog tool.

It can run on Cloudflare Workers, Vercel, or Docker. This Home-Lab folder uses
the Docker path with:

- FeedLog app image: `ghcr.io/linkcraftstudio/feedlog:v0.5.0`
- PostgreSQL 17 with `pgvector`: `pgvector/pgvector:pg17`
- Persistent local upload fallback mounted at `/app/.data`

The UI exposes:

- feedback boards for ideas, votes, comments, statuses, and board filters;
- a roadmap with Kanban-style status columns;
- published changelog pages;
- a dashboard for board management, feedback triage, changelog publishing,
  widget configuration, and inbox review.

Create your env file:

```bash
cp .env.sample .env
openssl rand -hex 32
```

Fill `POSTGRES_PASSWORD`, `BETTER_AUTH_SECRET`, and `SYSTEM_ADMIN_EMAILS`,
then start it:

```bash
docker compose up -d
```

Open:

```text
http://localhost:3030
```

Sign up using an email listed in `SYSTEM_ADMIN_EMAILS`; that first matching
user becomes admin.

With the sample config, the admin bootstrap email is:

```text
admin@example.com
```

There is no default admin password. You choose the password on the first signup
screen while registering with that email.

Access model:

- public visitors can read published feedback, roadmap, and changelog pages;
- creating feedback, voting, comments, and changelog reactions need a signed-in
  user, unless guest actions are explicitly enabled in FeedLog settings;
- guest posting, guest voting, and guest comments default to off upstream;
- dashboard/admin actions require organization membership and moderation or
  owner permissions;
- authentication is handled by `better-auth` with email/password enabled here
  via `AUTH_EMAIL_ENABLED=true`;
- optional Google/GitHub OAuth can be enabled through the matching client ID
  and secret variables;
- `BETTER_AUTH_SECRET` protects sessions, and rotating it invalidates existing
  sessions.

Optional production additions:

- set `BETTER_AUTH_URL` to the public URL behind your reverse proxy;
- configure `RESEND_API_KEY` and `EMAIL_FROM` for password reset and
  notification email;
- configure `OPENAI_API_KEY` for similar-idea detection and AI changelog
  drafting;
- configure S3-compatible storage for uploads, or keep the local `/app/.data`
  volume for a single-host setup.
