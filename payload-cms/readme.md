---
source_code: https://github.com/payload-cms/payload
official_docs: https://payloadcms.com/docs
tags: ["Headless CMS","OSS for Business","Web","WYSIWYG"]
---


```sh
# Build the Docker image
docker build -t payload-cms .

# Run the PayloadCMS container 
# docker run -p 3000:3000 \
#   -e DATABASE_URI=mongodb://your-mongo-host:27017/payload?authSource=admin \
#   -e PAYLOAD_SECRET=your-secret-key \
#   payload-cms
```

> Thanks to https://sliplane.io/blog/how-to-run-payload-cms-in-docker

---

Yes, there are several other notable self-hosted CMS alternatives, and the answer to whether PocketBase can be used as a CMS is a qualified **Yes**.

Here is a breakdown of the two tools you asked about, plus a summary of the landscape:

---

## 1. Payload CMS (The TypeScript/Next.js Favorite)

Payload is a modern, open-source (MIT licensed) platform that functions as a powerful Headless CMS, Application Backend, and Admin UI. It has rapidly gained popularity, especially among developers working with TypeScript and React-based frontends like Next.js.

| Aspect | Payload CMS |
| :--- | :--- |
| **Core Philosophy** | **Schema-as-Code.** You define all content collections, fields, and access rules entirely in **TypeScript/JavaScript** files. |
| **Self-Hosted Experience** | Excellent. Since the entire app is built on **Node.js/Next.js**, it can be deployed anywhere you can run a Node app (Docker, Vercel, AWS). |
| **Developer Experience** | **Exceptional.** Offers strong type safety, great IDE auto-completion, and deep integration with React for custom components. |
| **Content Modeling** | Uses **Blocks** (like Strapi's Dynamic Zones) and full control over fields to build complex content structures. |
| **Target User** | Development teams who want their CMS config to be version-controlled, highly customized, and fully integrated with a TypeScript monorepo. |

---

## 2. PocketBase (The All-in-One Powerhouse)

PocketBase is a single, compact, open-source application that combines **an embedded SQLite database, a real-time API (REST/GraphQL), file storage, and an Admin UI** into one easy-to-deploy Go executable.

| Aspect | PocketBase as a CMS |
| :--- | :--- |
| **Core Philosophy** | **Backend-in-a-File.** A lightweight backend-as-a-service (BaaS) that's designed for simplicity and speed. |
| **CMS Suitability** | **Yes, for small to medium projects.** It can define collections (content types), relationships, and manage content via a built-in admin panel, which are the core functions of a CMS. |
| **Self-Hosted Experience** | **Unmatched Simplicity.** It's a single binary file. You run it, and you have your entire backend and CMS interface. |
| **Limitations (Scalability)** | Its use of **SQLite** means it is restricted in how large and complex a dataset it can handle, making it less suitable for high-traffic, massive enterprise-level applications compared to Strapi or Directus running on PostgreSQL. |
| **Target User** | Developers building MVPs (Minimum Viable Products), prototypes, hobby projects, or small-to-medium static websites where **speed and ease of deployment** are the highest priority. |

---

## Other Notable Self-Hosted Alternatives

Besides Directus, Strapi, Payload, and PocketBase, the self-hosted landscape includes:

* **TinaCMS:** A Git-based CMS that allows for in-context, visual editing directly on the frontend (like a page builder experience), but with the content stored in local Markdown/MDX/JSON files within a Git repository.
* **KeystoneJS:** An open-source CMS built with Node.js and GraphQL. It is highly flexible and developer-focused, using code to define schemas and fields.


That's an excellent question, as the quality and type of the rich text editor dramatically affects the content team's experience!

When you ask about a "WYSIWYG Markdown editor," you are looking for an interface that allows visual formatting (WYSIWYG) but saves the content as plain Markdown or a structured JSON format that can easily be rendered as Markdown.

Here is how the four main self-hosted CMS options handle rich text/Markdown editing:

---

### 📝 Rich Text / Markdown Editor Comparison

| CMS | Default Editor Type | WYSIWYG/Visual Editing? | Markdown Support |
| :--- | :--- | :--- | :--- |
| **Payload CMS** | **Rich Text Field (Lexical/Slate)** | **Yes (Full WYSIWYG).** Its modern editor (defaulting to Lexical) provides a powerful, highly customizable visual editing experience. | The editor is primarily structured **JSON**, but it has deep support for converting the content to HTML, or rendering it to Markdown via custom converters. |
| **Directus** | **Markdown** and **WYSIWYG (separate fields)** | **Yes, via separate "Interfaces."** You can choose a field interface: **`WYSIWYG`** (a full HTML editor) or **`Markdown`** (a dedicated Markdown editor, often with live preview). | It supports a dedicated **`Markdown`** interface for pure Markdown input and a separate **`WYSIWYG`** (HTML) editor. |
| **Strapi** | **Rich Text Editor (Default)** | **Yes.** Strapi's built-in editor offers a visual experience. Historically, it has used a basic Markdown editor, but it is typically replaced with or functions like a WYSIWYG for a better editor experience (often using plugins like CKEditor or TinyMCE). | It is highly common to use **plugins** to replace the default editor with a fully-featured WYSIWYG (like CKEditor 5) that outputs structured content or enhanced HTML/Markdown. |
| **PocketBase** | **Textarea (Simple)** | **Limited / None.** The basic built-in Admin UI provides a simple `textarea` field for content. | To get a proper WYSIWYG or Markdown editor, you would need to **build and host your own custom Admin UI** that uses a third-party editor (like TinyMCE or Tiptap) and connects to PocketBase's API. |

### Conclusion on WYSIWYG Markdown:

1.  **For Best Out-of-the-Box Experience:** **Payload CMS** is considered the most modern, offering a powerful, type-safe Rich Text editor (Lexical) that provides a great visual experience while storing structured content (JSON).
2.  **For Pure Markdown with Preview:** **Directus** offers a dedicated `Markdown` interface that is often the most direct choice if you need to guarantee the output is clean Markdown.
3.  **For Extensibility:** **Strapi** and **Payload** both shine, allowing you to easily swap in popular third-party editors (CKEditor, TinyMCE) if the default isn't sufficient.

Would you like to see a comparison specifically between **Payload's rich text field** and **Directus's Markdown interface** for an author's workflow?