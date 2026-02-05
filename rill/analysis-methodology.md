# Repository Analysis Methodology: Architecture & Self-Hosting

This guide outlines the systematic approach used to analyze Rill, which can be applied to any modern software repository to understand its "DNA" and deployment requirements.

---

## Phase 1: Structural Discovery

The goal is to understand the project's layout and technology choices without reading every file.

1.  **Entry Points**: Read `README.md` (purpose), `CONTRIBUTING.md` (dev setup), and `LICENSE` (legal constraints).
2.  **Manifest Analysis**:
    -   `package.json`: Shows frontend/Node.js stack and workspaces.
    -   `go.mod` / `requirements.txt` / `pom.xml`: Identifies core language and critical dependencies.
    -   `Makefile` / `Taskfile.yml`: Reveals the primary build targets and automation shortcuts.
3.  **Monorepo Mapping**: Identify top-level directories.
    -   Lookup: `/backend`, `/frontend`, `/cli`, `/runtime`, `/proto`, `/docs`.
    -   Identify "Shared" vs "Isolated" components (e.g., `web-common` vs `web-local`).

---

## Phase 2: Architecture Decomposition

Define how data and commands flow through the system.

1.  **API Schema**: Search for `.proto` files, OpenAPI specs, or GraphQL schemas. This defines the "Contract" between services.
2.  **Data Layer**: Search for database drivers or configuration files to find:
    -   Primary OLAP/OLTP engine (e.g., DuckDB, Postgres, ClickHouse).
    -   State storage vs. Transient storage.
3.  **System Actors**: Identify the "Planes":
    -   **Control Plane**: Admin dashboards, auth, project management.
    -   **Data Plane**: Engines that process the actual payload/data.
    -   **CLI/App Plane**: How the user triggers actions.

---

## Phase 3: Deployment & Infrastructure Analysis

Determine what is required to get the code running in production.

1.  **Container Audit**: Analyze `Dockerfile` and `docker-compose.yml`.
    -   Check base images (Ubuntu, Alpine, Scratch).
    -   Check for multi-stage builds (is the app built *inside* or *outside* the image?).
    -   Check `USER` declarations for permission constraints.
2.  **Install Scripts**: Read files like `install.sh` or `setup.py`. They often reveal hidden OS dependencies (e.g., `curl`, `unzip`, specific CPU flags).
3.  **Environment Configuration**: Audit code and READMEs for `ENV` variables. These are the "knobs" that control the app's behavior.

---

## Phase 4: The "Stress Test" (Verification)

The only way to truly understand architecture is to build it and break it.

1.  **Full Build**: Run `make` or the equivalent.
    -   Monitor resources (RAM/CPU) using `htop`.
    -   Watch for "Heap Out of Memory" or "Missing Link" errors.
2.  **Permission Testing**: Run the Docker container with various volume mounts.
    -   Identify UID/GID mismatches between host and container.
3.  **Log Analysis**: Run with `LOG_LEVEL=debug`. Watch how components signal "Ready" and how they heartbeat.

---

## Phase 5: Documentation Synthesis

Structure the findings into standard artifacts:

-   **ARCHITECTURE.md**: Focus on the *Why* and the *Flow*. (Mermaid diagrams are essential here).
-   **SELFHOST.md**: Focus on the *How*. Standardize on categories (Pre-reqs, Docker-Compose, Troubleshooting).
-   **What-Worked.md**: A "Cheat Sheet" for your specific environment.

---

## Key Questions to Ask Every Repo

-   **Build Context**: Is the frontend embedded in the binary or served separately?
-   **Security**: Does the container run as root or a limited user?
-   **State**: Is the app stateless, or do I need to mount a volume?
-   **Communication**: Is it synchronous (REST/gRPC) or asynchronous (NATS/Kafka)?
-   **Dependencies**: Can it run offline, or does it reach out for extensions/licenses (like DuckDB extensions)?
