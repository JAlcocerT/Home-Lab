---
source_code: https://github.com/frappe/crm
tags: ["CMS"]
---



Frappe (Framework) running a single site for CMS/website via Docker Compose.

- Host: 192.168.1.11
- Frontend: http://192.168.1.11:8089
- Data paths:
  - MariaDB: `/home/docker/frappecms/mariadb`
  - Sites (persistent): Docker named volume `sites`

## Files here

https://github.com/frappe/frappe_docker

- `frappecms/docker-compose.yml`
- `frappecms/.env.example` → copy to `.env` and set passwords/site
- `frappecms/scripts/init_site.sh` → one-time site provisioning

## Quick start
1. Create data dir for MariaDB
   ```sh
   mkdir -p /home/docker/frappecms/mariadb
   ```
2. Copy and edit env
   ```sh
   cd frappecms
   cp .env.example .env
   # Edit .env → set strong MYSQL_ROOT_PASSWORD, SITE_NAME (e.g., mysite.local), ADMIN_PASSWORD
   ```
3. Start stack
   ```sh
   docker compose up -d
   ```
4. Create site (one-time)

```sh
chmod +x scripts/init_site.sh
source .env
./scripts/init_site.sh
```

5. Open frontend
   - http://192.168.1.11:8089

## Notes

- This uses official `frappe/erpnext:v15` images which include Frappe Framework.
- To install extra Frappe apps (e.g., CMS packages), after step 3 run inside backend:
  ```sh
  docker compose exec backend bash -lc "bench get-app <git_url> && bench --site $SITE_NAME install-app <app_name> && bench restart"
  ```
- If you later change `SITE_NAME`, recreate or create a new site accordingly.
- For production: add backups, TLS, and harden DB/Redis.

---

FrappeCMS is a content management system built on top of the **Frappe Framework**, which is a full-stack, low-code web application framework written in Python and JavaScript.

It uses MariaDB (or Postgres) as its database and provides a highly extensible, metadata-driven architecture for rapid application development.

### Key features of FrappeCMS and Frappe Framework:
- **Low-code approach:** Allows building complex web apps and CMS with minimal coding using declarative DocTypes that represent database tables, forms, and business logic.
- **Extensible modular design:** You can add custom apps, define schemas, client-side scripts, and server-side hooks easily.
- **Rich built-in admin UI:** Manage content, create workflows, customize forms/views, and permissions without heavy coding.
- **Full-stack capabilities:** Covers frontend and backend development, with RESTful APIs automatically generated for all models.
- **Role-based permissions:** Fine-grained access control and user management.
- **Multilingual support:** Built-in internationalization (i18n) and localization (l10n) support for global applications.
- **Workflow and notification management:** Automate business processes and send emails or alerts within the system.
- **Dynamic templating:** Uses Jinja2 templating engine for flexible UI rendering.

FrappeCMS leverages the power of the Frappe Framework to provide a scalable and customizable CMS solution suited for businesses seeking a comprehensive, developer-friendly platform beyond traditional CMS options. 

**It is known for its use in ERPNext**, a popular open-source ERP, but the framework itself is versatile for many web applications, including CMS.

In summary, FrappeCMS is an advanced, open-source CMS powered by the Python-based Frappe Framework, focusing on low-code customization, powerful admin features, and extensibility for building complex, modern web applications.

If you'd like, detailed guidance or examples on how to use or deploy FrappeCMS can be provided.

[1](https://frappe.io/framework)
[2](https://www.red-gate.com/simple-talk/development/web/an-introduction-to-frappe-framework-features-and-benefits/)
[3](https://craftinteractive.io/what-is-frappe-framework-and-why-you-should-use-them/)
[4](https://cloud.frappe.io/marketplace/apps/go1_cms)
[5](https://github.com/frappe/frappe)
[6](https://www.reddit.com/r/cms/comments/1i9ru31/understanding_frappe_framework_core_concepts_and/)
[7](https://sanskartechnolab.com/wordpress-to-frappe-migration)
[8](https://medevel.com/frappe-builder/)
[9](https://csirt.sk/frappe-framework-vulnerabilities.html)
[10](https://awesome-frappe.gavv.in)