# curl flags for API calls — quick reference

Use this as a companion to `gitea-api.md` to understand the curl options you see.

## Core flags you see in examples

- __-s__ (silent)
  - Hides progress meter and errors. Combine with `-S` to still show errors.
  - Example: `curl -s "$GITEA_BASE/user"`

- __-H "Header: value"__ (add HTTP header)
  - Set request headers (e.g., auth, content type).
  - Examples:
    - `-H "Authorization: token $GITEA_TOKEN"`
    - `-H "Content-Type: application/json"`

- __-X METHOD__ (HTTP method)
  - Overrides the HTTP method. curl defaults to GET, or POST when `-d/--data` is used.
  - Examples:
    - `-X GET` (rarely needed)
    - `-X POST`, `-X PATCH`, `-X PUT`, `-X DELETE`

- __-d DATA__ or __--data DATA__ (request body)
  - Sends a request body; implies `-X POST` if method not set.
  - Use with JSON APIs and set `Content-Type: application/json`.
  - Example: `-d '{"name":"demo"}' -H "Content-Type: application/json"`

- __URL with query params__
  - `"$GITEA_BASE/user/repos?limit=50&page=1"`

- __Pipe to jq__
  - Pretty-print/parse JSON: `| jq`, `| jq '.[].full_name'`

## Other useful flags

- __-u user:pass__
  - Basic auth. Alternative to token header.

- __-i__ / __-I__
  - `-i` include response headers in output.
  - `-I` HEAD request (headers only).

- __-L__
  - Follow redirects (3xx). Useful when an endpoint redirects.

- __--fail__ (aka `-f`)
  - Fail on HTTP errors (exit non-zero for 4xx/5xx). Doesn’t print body.

- __-o FILE__ / __-O__
  - Save response to file. `-O` uses remote name.

- __--data-binary__
  - Send data exactly as provided (no form-encoding). Good for raw JSON/files.

- __--compressed__
  - Request a compressed response and decompress automatically.

- __-S__
  - Show errors even if `-s` is used.

- __-w FORMAT__
  - Write out metrics after the transfer (e.g., `%{http_code}\n`).
  - Example: `-w '\nstatus=%{http_code}\n'`

## Common patterns for REST APIs

- __GET with auth header__ (read data):
  ```bash
  curl -s -H "Authorization: token $GITEA_TOKEN" \
    "$GITEA_BASE/user"
  ```

- __POST with JSON body__ (create):
  ```bash
  curl -s -X POST \
    -H "Authorization: token $GITEA_TOKEN" \
    -H "Content-Type: application/json" \
    -d '{"name":"demo-repo","private":true}' \
    "$GITEA_BASE/user/repos"
  ```

- __PATCH/PUT with JSON body__ (update):
  ```bash
  curl -s -X PATCH \
    -H "Authorization: token $GITEA_TOKEN" \
    -H "Content-Type: application/json" \
    -d '{"description":"New desc"}' \
    "$GITEA_BASE/repos/$OWNER/$REPO"
  ```

- __DELETE__ (remove):
  ```bash
  curl -s -X DELETE \
    -H "Authorization: token $GITEA_TOKEN" \
    "$GITEA_BASE/repos/$OWNER/$REPO"
  ```

## Tips

- __Method vs data__: if you pass `-d` without `-X`, curl uses POST by default. Explicit `-X` is clearer, especially for PATCH/PUT/DELETE.
- __Headers matter__: JSON APIs usually require `Content-Type: application/json` for request bodies.
- __Exit codes__: combine `--fail -s -S` for scripts: quiet output, but non-zero on HTTP errors and prints errors.
- __Quote carefully__: wrap JSON with single quotes in bash and escape inner quotes.

## Examples applied to Gitea

- List repos: `curl -s -H "Authorization: token $GITEA_TOKEN" "$GITEA_BASE/user/repos" | jq`.
- Create repo: include `-X POST`, auth header, content-type, and `-d` with JSON.
- Create webhook: also `-X POST` + JSON body with `config`, `events`, `active`.
