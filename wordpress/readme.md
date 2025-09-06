---
source_code: https://github.com/WordPress/WordPress
post: https://fossengineer.com/selfhosting-wordpress-docker/
---


This directory contains a `docker-compose.yml` to run a WordPress instance with a MySQL database, structured similarly to the Ghost setup.

Quick Start

1.  **Create `.env` file**

Run the following command to generate a `.env` file with secure, random passwords and the correct site URL. **Note:** If your server IP is not `192.168.1.8`, edit the `.env` file after running.

```sh
echo -e "MYSQL_DATABASE=wordpress\nMYSQL_USER=wpuser\nMYSQL_PASSWORD=$(openssl rand -base64 32)\nMYSQL_ROOT_PASSWORD=$(openssl rand -base64 32)\nWP_HOME=http://192.168.1.8:8082\nWP_SITEURL=http://192.168.1.8:8082" > .env
```

2.  **Start the services**

```sh
docker compose up -d
```

3.  **Complete WordPress Setup**

Open your browser to the URL in your `.env` file (e.g., `http://192.168.1.8:8082`) and complete the famous 5-minute WordPress installation.

## REST API Guide

WordPress includes a powerful REST API by default, allowing you to interact with your site's content programmatically.

-   **Base URL**: `$WP_HOME/wp-json/wp/v2/`
-   **Authentication**: For read-only public content, no auth is needed. For creating/updating content, you need to use **Application Passwords**.

### Setting Up Application Passwords

**Important**: Application Passwords are different from your WordPress login credentials. They are special passwords created specifically for API access.

1.  Log in to your WordPress Admin dashboard (`$WP_HOME/wp-admin`)
2.  Go to **Users** → **Profile**
3.  Scroll down to the "Application Passwords" section (near the bottom of the page)
4.  In the "New Application Password Name" field, enter a descriptive name (e.g., `api-client`)
5.  Click "Add New Application Password"
6.  **Critical**: Copy the generated password immediately - it will only be shown once!
7.  Store this password securely

### Authentication Details

- **Username**: Your WordPress username (not your email address)
- **Password**: The generated application password (not your WordPress login password)
- **User Role**: Ensure your user has sufficient permissions (Administrator role recommended)

### API Examples (using curl)

Assume you have loaded your `.env` file (`source .env`).

-   **List latest 5 posts (public)**

```bash
source .env
curl "$WP_HOME/wp-json/wp/v2/posts?per_page=5"
```

-   **Get a post by its slug**

```bash
# Replace 'hello-world' with your post's slug
curl "$WP_HOME/wp-json/wp/v2/posts?slug=hello-world"
```

-   **Create a draft post (requires auth)**

Replace `your_username` and `your_app_password` with your credentials.

```bash
curl -u 'your_username:your_app_password' -X POST "$WP_HOME/wp-json/wp/v2/posts" \
    -H 'Content-Type: application/json' \
    -d '{
    "title": "Hello from REST API",
    "content": "This post was created programmatically.",
    "status": "draft"
    }'
```

-   **Upload an image (requires auth)**

```bash
# Replace 'my-image.jpg' with your local file path
curl -u 'your_username:your_app_password' -X POST "$WP_HOME/wp-json/wp/v2/media" \
    -H 'Content-Disposition: attachment; filename=my-image.jpg' \
    -H 'Content-Type: image/jpeg' \
    --data-binary "@my-image.jpg"
```
