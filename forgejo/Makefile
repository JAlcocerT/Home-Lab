-include .env
export

.PHONY: help up down logs status \
        list-repos migrate-repo migrate-all \
        sync-repo sync-all \
        list-github-repos \
        create-user add-collaborator list-users

# ── Helpers ────────────────────────────────────────────────────────────────────

help:
	@echo ""
	@echo "Forgejo management targets"
	@echo ""
	@echo "  Stack:"
	@echo "    up            Start Forgejo + DB"
	@echo "    down          Stop and remove containers"
	@echo "    logs          Follow container logs"
	@echo "    status        Show running containers"
	@echo ""
	@echo "  Repos:"
	@echo "    list-github-repos  List repos visible to GITHUB_TOKEN"
	@echo "    list-repos         List all repos on Forgejo"
	@echo "    migrate-repo  Migrate one GitHub repo  (REPO_OWNER= REPO_NAME=)"
	@echo "    migrate-all   Migrate all GitHub repos for GITHUB_USER"
	@echo "    sync-repo     Trigger mirror sync for one repo (REPO_OWNER= REPO_NAME=)"
	@echo "    sync-all      Trigger mirror sync for every mirrored repo"
	@echo ""
	@echo "  Users:"
	@echo "    list-users        List all users on Forgejo"
	@echo "    create-user       Create a user with write-only access (NEW_USER= NEW_USER_EMAIL= NEW_USER_PASSWORD=)"
	@echo "    add-collaborator  Add NEW_USER as write collaborator on REPO_NAME"
	@echo ""

# ── Stack ──────────────────────────────────────────────────────────────────────

up:
	docker compose up -d

down:
	docker compose down

logs:
	docker compose logs -f

status:
	docker compose ps

# ── Repo management ────────────────────────────────────────────────────────────

list-github-repos:
	@echo "Repos visible to GITHUB_TOKEN ($(GITHUB_USER))..."
	@page=1; \
	while true; do \
	  result=$$(curl -s -H "Authorization: token $(GITHUB_TOKEN)" \
	    "https://api.github.com/user/repos?per_page=100&type=all&page=$$page" \
	    | jq -r '.[] | "\(.full_name)\t\(if .private then "private" else "public" end)\t\(.visibility)"'); \
	  [ -z "$$result" ] && break; \
	  echo "$$result"; \
	  page=$$((page + 1)); \
	done | column -t

list-repos:
	@curl -s "$(FORGEJO_URL)/api/v1/user/repos?limit=50" \
	  -H "Authorization: token $(FORGEJO_TOKEN)" \
	  | jq -r '.[] | "\(.name)\t\(if .mirror then "mirror" else "local" end)\t\(.private | if . then "private" else "public" end)"' \
	  | column -t

migrate-repo:
	@test -n "$(REPO_NAME)" || (echo "ERROR: REPO_NAME is not set"; exit 1)
	@echo "Migrating $(REPO_OWNER)/$(REPO_NAME)..."
	@curl -s -X POST "$(FORGEJO_URL)/api/v1/repos/migrate" \
	  -H "Authorization: token $(FORGEJO_TOKEN)" \
	  -H "Content-Type: application/json" \
	  -d "{\"clone_addr\":\"https://github.com/$(REPO_OWNER)/$(REPO_NAME)\",\"auth_token\":\"$(GITHUB_TOKEN)\",\"repo_name\":\"$(REPO_NAME)\",\"private\":true,\"mirror\":true,\"wiki\":true,\"issues\":true,\"pull_requests\":true,\"releases\":true,\"labels\":true,\"milestones\":true}" \
	  | jq '{name: .name, mirror: .mirror, html_url: .html_url, error: .message}'

migrate-all:
	@echo "Fetching repos for $(GITHUB_USER)..."
	@repos=$$(curl -s -H "Authorization: token $(GITHUB_TOKEN)" \
	    "https://api.github.com/user/repos?per_page=100&type=all" \
	    | jq -r '.[].name'); \
	for repo in $$repos; do \
	  echo "  -> $$repo"; \
	  curl -s -X POST "$(FORGEJO_URL)/api/v1/repos/migrate" \
	    -H "Authorization: token $(FORGEJO_TOKEN)" \
	    -H "Content-Type: application/json" \
	    -d "{\"clone_addr\":\"https://github.com/$(GITHUB_USER)/$$repo\",\"auth_token\":\"$(GITHUB_TOKEN)\",\"repo_name\":\"$$repo\",\"private\":true,\"mirror\":true,\"wiki\":true,\"issues\":true,\"pull_requests\":true,\"releases\":true,\"labels\":true,\"milestones\":true}" \
	    | jq -r '"    status: \(.message // "ok")"'; \
	done

sync-repo:
	@test -n "$(REPO_NAME)" || (echo "ERROR: REPO_NAME is not set"; exit 1)
	@echo "Syncing $(REPO_OWNER)/$(REPO_NAME)..."
	@curl -s -X POST "$(FORGEJO_URL)/api/v1/repos/$(REPO_OWNER)/$(REPO_NAME)/mirror-sync" \
	  -H "Authorization: token $(FORGEJO_TOKEN)"
	@echo "Done."

sync-all:
	@echo "Syncing all mirrored repos..."
	@repos=$$(curl -s "$(FORGEJO_URL)/api/v1/user/repos?limit=50" \
	    -H "Authorization: token $(FORGEJO_TOKEN)" \
	    | jq -r '.[] | select(.mirror == true) | .name'); \
	for repo in $$repos; do \
	  echo "  -> $$repo"; \
	  curl -s -X POST "$(FORGEJO_URL)/api/v1/repos/$(GITHUB_USER)/$$repo/mirror-sync" \
	    -H "Authorization: token $(FORGEJO_TOKEN)"; \
	done
	@echo "Done."

# ── User management ────────────────────────────────────────────────────────────

list-users:
	@curl -s "$(FORGEJO_URL)/api/v1/admin/users?limit=50" \
	  -H "Authorization: token $(FORGEJO_TOKEN)" \
	  | jq -r '.[] | "\(.login)\t\(.email)\t\(if .is_admin then "admin" else "user" end)"' \
	  | column -t

create-user:
	@test -n "$(NEW_USER)"          || (echo "ERROR: NEW_USER is not set"; exit 1)
	@test -n "$(NEW_USER_EMAIL)"    || (echo "ERROR: NEW_USER_EMAIL is not set"; exit 1)
	@test -n "$(NEW_USER_PASSWORD)" || (echo "ERROR: NEW_USER_PASSWORD is not set"; exit 1)
	@echo "Creating user $(NEW_USER)..."
	@curl -s -X POST "$(FORGEJO_URL)/api/v1/admin/users" \
	  -H "Authorization: token $(FORGEJO_TOKEN)" \
	  -H "Content-Type: application/json" \
	  -d "{\"username\":\"$(NEW_USER)\",\"email\":\"$(NEW_USER_EMAIL)\",\"password\":\"$(NEW_USER_PASSWORD)\",\"must_change_password\":true,\"send_notify\":false,\"source_id\":0,\"login_name\":\"$(NEW_USER)\"}" \
	  | jq '{login: .login, email: .email, is_admin: .is_admin, error: .message}'

# Permission levels: read | write | admin
# "write" = push access, cannot delete repo or change settings (no admin)
add-collaborator:
	@test -n "$(NEW_USER)"  || (echo "ERROR: NEW_USER is not set"; exit 1)
	@test -n "$(REPO_NAME)" || (echo "ERROR: REPO_NAME is not set"; exit 1)
	@echo "Adding $(NEW_USER) as write collaborator on $(REPO_OWNER)/$(REPO_NAME)..."
	@curl -s -X PUT "$(FORGEJO_URL)/api/v1/repos/$(REPO_OWNER)/$(REPO_NAME)/collaborators/$(NEW_USER)" \
	  -H "Authorization: token $(FORGEJO_TOKEN)" \
	  -H "Content-Type: application/json" \
	  -d "{\"permission\":\"write\"}" \
	  && echo "Done." || echo "Failed."
