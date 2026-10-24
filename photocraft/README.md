# PhotoCraft

PhotoCraft is a local-first Rust image editor and a static WebAssembly application. This profile serves the browser build with nginx on port `3860`.

## Start

```sh
docker compose config
docker compose build
docker compose up -d
```

Open `http://localhost:3860` or `http://192.168.1.2:3860`.

The first build is resource-intensive because it compiles the Rust/WASM editor and runs `wasm-opt`; the reviewed build took about nine minutes on the review host. Later builds use Docker/Cargo cache. The compose context is pinned to the reviewed PhotoCraft commit, not `main`.

## Important behavior

This container serves static files only. PhotoCraft edits run in the visitor's browser, and Open/Save/Export use local browser file access and downloads. There is no account system, server-side document storage, shared library, autosave, or persistent document volume. Save your work before closing or reloading the page.

For a public deployment, use HTTPS so WebGPU and clipboard APIs are available. Cloudflare Pages can host the official release zip directly; the project splits compressed WASM into parts below the Pages/Workers 25 MiB per-file limit.
