# Forgejo for AI Agents

A guide to turning Forgejo into a 24/7 autonomous agent workspace — covering setup, task patterns, and domain-specific ideas for engineering repositories.

---

## Why Forgejo + Agents

GitHub is public and rate-limited. Forgejo runs locally, has no rate limits, supports webhooks, has a full REST API, and now supports Actions (GitHub Actions-compatible CI/CD). An agent with a Forgejo account can:

- Read and write code autonomously
- Receive tasks via issues
- Submit work via pull requests for human review
- React to events via webhooks
- Run and monitor CI pipelines
- Never sleep, never forget context stored in the repo

---

## Agent Account Setup

### 1. Create the agent user

```bash
make create-user NEW_USER=hermesagent NEW_USER_EMAIL=agent@local NEW_USER_PASSWORD=changeme123
```

The agent logs in, changes its password, and from that point operates via API token only.

### 2. Generate an agent-scoped API token

The agent should use its own token, not your admin token.

1. Log in as `hermesagent` at `http://localhost:3034`
2. Settings → Applications → Generate Token
3. Scopes: **Repository** (Read and Write), **Issue** (Read and Write), **Notification** (Read)
4. Store it separately from `FORGEJO_TOKEN` — e.g. `AGENT_TOKEN` in your env

### 3. Register the agent's SSH key

So the agent can `git clone/push` without passwords:

```bash
# On the agent machine, generate a key if needed
ssh-keygen -t ed25519 -C "hermesagent" -f ~/.ssh/hermesagent_ed25519

# Register the public key via API (run as admin)
curl -s -X POST "$FORGEJO_URL/api/v1/admin/users/hermesagent/keys" \
  -H "Authorization: token $FORGEJO_TOKEN" \
  -H "Content-Type: application/json" \
  -d "{\"key\":\"$(cat ~/.ssh/hermesagent_ed25519.pub)\",\"read_only\":false,\"title\":\"hermesagent-main\"}"
```

Add to Makefile: `make add-agent-key KEY_FILE=~/.ssh/hermesagent_ed25519.pub`

### 4. Grant repo access

```bash
make add-collaborator NEW_USER=hermesagent REPO_OWNER=JAlcocerT REPO_NAME=mbsd
make add-collaborator NEW_USER=hermesagent REPO_OWNER=JAlcocerT REPO_NAME=electronics-101
# repeat per repo
```

---

## Issues as a Task Queue

The simplest and most reliable interface between you and an agent is the issue tracker.

```
You open an issue  →  agent reads it  →  agent works  →  agent opens PR  →  you review  →  merge
```

### Useful API calls

```bash
# Create a task for the agent
curl -s -X POST "$FORGEJO_URL/api/v1/repos/JAlcocerT/mbsd/issues" \
  -H "Authorization: token $FORGEJO_TOKEN" \
  -H "Content-Type: application/json" \
  -d '{"title":"Refactor integrator module","body":"Split euler.py into its own subpackage. Add docstrings.","assignees":["hermesagent"],"labels":[1]}'

# Agent lists its open assigned issues
curl -s "$FORGEJO_URL/api/v1/repos/JAlcocerT/mbsd/issues?state=open&type=issues&assigned_to=hermesagent" \
  -H "Authorization: token $AGENT_TOKEN" | jq '.[].title'

# Agent closes issue after completing work
curl -s -X PATCH "$FORGEJO_URL/api/v1/repos/JAlcocerT/mbsd/issues/7" \
  -H "Authorization: token $AGENT_TOKEN" \
  -H "Content-Type: application/json" \
  -d '{"state":"closed"}'
```

### Labels to signal task type

Create labels per repo to route work to the right agent or model:

| Label | Meaning |
|---|---|
| `agent:ready` | Task is defined and ready to pick up |
| `agent:in-progress` | Agent is working on it |
| `agent:review` | PR opened, needs human review |
| `agent:blocked` | Agent needs clarification |
| `priority:high` | Work on this first |
| `domain:simulation` | Needs physics/math context |
| `domain:electronics` | Needs EDA/schematic context |
| `domain:blender` | Needs 3D/scripting context |

---

## Pull Requests as Review Gates

The agent never merges its own work. It pushes to a branch and opens a PR.

```bash
# Agent workflow (runs on agent machine)
git clone git@localhost:2235/JAlcocerT/mbsd.git
cd mbsd
git checkout -b agent/fix-integrator-7   # issue number in branch name
# ... agent makes changes ...
git push origin agent/fix-integrator-7

# Open PR via API
curl -s -X POST "$FORGEJO_URL/api/v1/repos/JAlcocerT/mbsd/pulls" \
  -H "Authorization: token $AGENT_TOKEN" \
  -H "Content-Type: application/json" \
  -d '{
    "title": "fix: refactor integrator module (#7)",
    "body": "Closes #7\n\n## Changes\n- Split euler.py\n- Added docstrings\n\n## Tested\n- ran existing test suite, all pass",
    "head": "agent/fix-integrator-7",
    "base": "main"
  }'
```

---

## Webhooks — Event-Driven Agent

Instead of polling, Forgejo pushes events to the agent's HTTP endpoint.

```bash
# Register a webhook on a repo
curl -s -X POST "$FORGEJO_URL/api/v1/repos/JAlcocerT/mbsd/hooks" \
  -H "Authorization: token $FORGEJO_TOKEN" \
  -H "Content-Type: application/json" \
  -d '{
    "type": "forgejo",
    "config": {"url": "http://agent-host:8080/webhook", "content_type": "json"},
    "events": ["push", "issues", "pull_request"],
    "active": true
  }'
```

The agent receives a POST on every push, issue open/close, or PR event and can react immediately.

---

## Forgejo Actions (CI/CD)

Forgejo Actions is GitHub Actions-compatible. Drop a `.forgejo/workflows/` YAML and it runs on push.

### Example: auto-test on push

```yaml
# .forgejo/workflows/test.yml
on: [push]
jobs:
  test:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v3
      - run: python -m pytest
```

### Ideas per domain

**Multibody / simulation repos:**
```yaml
# Run simulation smoke test, save output artifact
- run: python simulate.py --steps 100 --output results/smoke.csv
- uses: actions/upload-artifact@v3
  with:
    name: smoke-results
    path: results/
```

**Electronics repos:**
```yaml
# Lint KiCad schematics, run ERC check
- run: kicad-cli sch erc --output erc_report.txt schematic.kicad_sch
```

**Blender repos:**
```yaml
# Render a preview frame headlessly
- run: blender -b scene.blend -o //renders/ -f 1 -- --cycles-device CPU
```

---

## Domain-Specific Agent Ideas

### Multibody Dynamics (`mbsd`, `Bike_dynamic_simulator`, `Slider-Crank`)

- Agent watches issues tagged `domain:simulation` and generates new test cases
- On each push, CI runs the integrator and posts a plot of the trajectory as a PR comment
- Agent monitors numerical stability metrics over time and opens an issue if error grows
- Auto-generate parameter sweep reports and commit them to a `results/` branch
- Agent reads a `TODO.md` in the repo and converts items into issues automatically

### Electronics (`electronics-101`)

- Agent monitors a `components/` folder and auto-generates a BOM (bill of materials) on each push
- On new schematic commit, run ERC and post the report as a PR comment
- Agent watches for new datasheets dropped in `datasheets/` and extracts key specs into a structured YAML
- Auto-generate wiring diagrams from netlist files and commit the SVG
- Agent cross-references components against a local JLCPCB parts database

### Blender / 3D (`VideoEditingRemotion`, creative repos)

- Agent renders a low-res preview frame on every scene commit and posts it as a comment
- On tag push, agent triggers a full render job and uploads the output as a release asset
- Watch for new `.blend` files and auto-extract metadata (camera, lights, objects) into a manifest
- Agent generates a changelog of scene modifications by diffing `.blend` XML exports

### Data / Analysis repos (`eda-f1`, `eda-geospatial`, `Py_Stocks`, `R_Stocks`)

- Agent runs notebooks on schedule and commits the output (papermill or quarto)
- On new data file pushed to `data/`, agent runs the pipeline and opens a PR with updated figures
- Agent monitors for drift in data schema and opens an issue if column types change
- Auto-generate a `REPORT.md` summarising key metrics after each pipeline run

### Web / Astro repos (the many website projects)

- Agent runs Lighthouse CI on every PR and comments the scores
- On push to `main`, agent builds and checks for broken links
- Agent watches `content/` for new MDX/markdown files and validates frontmatter schema
- Auto-generate an `og-image` for new blog posts using a headless browser

---

## Polling vs Event-Driven

| Pattern | How | Best for |
|---|---|---|
| Polling | Agent calls `/issues?assigned_to=hermesagent` on a cron | Simple, no infra needed |
| Webhooks | Forgejo POSTs to agent HTTP endpoint | Low latency, reactive |
| Forgejo Actions | YAML workflow triggered by git events | CI/CD, reproducible runs |
| Scheduled Actions | `on: schedule: cron` in workflow YAML | Recurring reports, data pipelines |

---

## Security Checklist for Agent Accounts

- [ ] Agent uses its own token (`AGENT_TOKEN`), never the admin token
- [ ] Token scoped to minimum required permissions (no `write:admin`)
- [ ] SSH key is `read_only: false` only on repos the agent needs to push to
- [ ] Agent account is not admin (`is_admin: false`)
- [ ] Webhook endpoints validate the `X-Forgejo-Signature` header
- [ ] Agent branches follow a naming convention (`agent/*`) so they're easy to audit
- [ ] PRs from agent require at least one human approval before merge
- [ ] Rotate agent token periodically

---

## Quick Reference

```bash
# Check what the agent is assigned to across all repos
curl -s "$FORGEJO_URL/api/v1/repos/search?limit=50" \
  -H "Authorization: token $FORGEJO_TOKEN" \
  | jq -r '.data[].full_name' | while read repo; do
    curl -s "$FORGEJO_URL/api/v1/repos/$repo/issues?state=open&type=issues" \
      -H "Authorization: token $FORGEJO_TOKEN" \
      | jq -r --arg repo "$repo" '.[] | select(.assignees[]?.login == "hermesagent") | "\($repo)\t#\(.number)\t\(.title)"'
  done | column -t

# List all open PRs from the agent
curl -s "$FORGEJO_URL/api/v1/repos/search?limit=50" \
  -H "Authorization: token $FORGEJO_TOKEN" \
  | jq -r '.data[].full_name' | while read repo; do
    curl -s "$FORGEJO_URL/api/v1/repos/$repo/pulls?state=open" \
      -H "Authorization: token $FORGEJO_TOKEN" \
      | jq -r --arg repo "$repo" '.[] | select(.user.login == "hermesagent") | "\($repo)\t#\(.number)\t\(.title)"'
  done | column -t
```
