---
source_code: https://github.com/directus/directus
tags: ["Headless CMS","OSS for Business","Web"]
official_docs: https://directus.io/docs/getting-started/create-a-project
---

Spin up a Directus instance via container:

```sh
docker compose -f docker-compose.yml up -d
```
> `http://localhost:8055/admin/content`

Use the DirectusCMS API: https://directus.io/docs/getting-started/use-the-api

Directus and Strapi are two of the most popular open-source, **self-hosted headless CMS platforms**, but they operate with fundamentally different philosophies.

The choice often comes down to whether you prefer a **Database-First** approach (Directus) or a **Code-First** approach (Strapi).

Here is a side-by-side comparison of their key differences:

---

## 🆚 Directus vs. Strapi: A Key Comparison

| Feature | Directus (The "Data Engine") | Strapi (The "Code-First CMS") |
| :--- | :--- | :--- |
| **Core Philosophy** | **Database-First.** It wraps a SQL database (Postgres, MySQL, SQLite, etc.) and provides a CMS and API layer on top. | **Code-First.** You define content models in code/JSON, and Strapi manages the database schema for you. |
| **Database Control** | **Full Control.** You can use an **existing** database schema. Directus reflects your raw database tables instantly. | **Schema Manager.** Strapi creates and manages the schema. You typically start a new, empty database. |
| **Admin UI** | Built with **Vue.js**. Generally considered more customizable and **data-centric** (e.g., custom data views, conditional fields). | Built with **React**. Has a clean, user-friendly interface that feels very **content-centric**. |
| **Open Source Model** | **Truly Open-Source Core (Apache 2.0).** Virtually all core features (RBAC, API, Versioning) are free to self-host. | **Freemium Core (MIT License).** Key enterprise features like Content Versioning, and advanced RBAC limits are often restricted to paid plans. |
| **Access Control (RBAC)** | **More Granular in Free Tier.** Offers unlimited roles, fine-grained field-level permissions, and row-level data filtering out-of-the-box. | **Limited in Free Tier.** The Community Edition limits you to only **3 roles**. |
| **Development** | Relies on **Flows** (a no-code visual automation builder) and **Hooks** to add custom logic close to the data layer. | Relies heavily on **Plugins** and **custom controllers/middleware** written in JavaScript/Node.js. |
| **High-Level Use Case** | Best for **Data-Driven Applications** or when you need a CMS on top of a legacy or pre-existing relational database (e.g., internal tools, IoT data, product catalogs). | Best for **Content-Driven Applications** and development teams fully invested in the Node.js/JavaScript ecosystem (e.g., blogs, marketing sites, rapid prototyping). |

### When to Choose Which CMS

| Choose **Directus** When... | Choose **Strapi** When... |
| :--- | :--- |
| **You already have data** in a SQL database that you need a CMS/API for. | **You are starting a project fresh** and prefer defining your data model in code. |
| You need **advanced, custom Role-Based Access Control (RBAC)** without paying for an enterprise plan. | You want a **larger plugin ecosystem** with hundreds of ready-to-use community extensions. |
| You want your entire application, including the content administration, to feel very **data-centric and flexible.** | You prefer a **code-first workflow** and want a larger community of developers familiar with the platform. |

Would you like to explore the specifics of **Directus Flows** or find out more about **Strapi's plugin ecosystem**?