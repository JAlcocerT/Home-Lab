---
source_code: https://github.com/gotenberg/gotenberg
tags: ["PDF", "Document Processing"]
moto: A developer-friendly API for converting numerous document formats into PDF files, and more!
---

**Gotenberg** (with a "t") is **not** Project Gutenberg (which is the digital library).

**Gotenberg is an independent, open-source project and a containerized API specifically designed for seamless PDF conversion.**

In the context of your `docker-compose.yml` file, it serves as a **PDF service dependency** for your main application, `rachoon`.

1.  **Containerized API:** It runs entirely inside a Docker container (as you see with `image: gotenberg/gotenberg:8`). This makes it extremely easy to deploy and integrate into any application stack without having to worry about installing complex dependencies on your host machine.
2.  **PDF Conversion:** Its sole purpose is to convert various document types into PDF files.
3.  **Core Capabilities:**
    * **HTML/Markdown to PDF:** It can take web content (HTML) and turn it into a high-quality PDF, often using a headless browser like Chromium internally.
    * **Office Documents to PDF:** It can convert formats like Word (.docx), Excel (.xlsx), and PowerPoint (.pptx) into PDFs using LibreOffice internally.
    * **URLs to PDF:** It can snapshot an entire webpage directly from a URL and convert it into a PDF.
4.  **How it Works in Your Setup:** Your `rachoon` application sends a request (likely a piece of HTML or a document file) to the `gotenberg` container using the internal network address (`http://gotenberg`). Gotenberg processes the request and sends the resulting PDF file back to `rachoon`.

I see you're asking about the data handling and resources for Gotenberg in a container environment!

Here are the answers to your questions about Gotenberg:

### 1. Does all stay local when using Gotenberg via a container?

Yes, by default, Gotenberg is a **stateless API** designed to perform the conversion job and immediately return the result.

* **During Conversion:** When you send a document (like an HTML file or a Word document) or a URL to the Gotenberg container, it processes that data internally within the container's temporary filesystem.
* **No Permanent Storage:** It is not designed to permanently store the input files or the resulting PDF files after the HTTP request is completed. The container usually cleans up its temporary files after the conversion is finished.
* **Security:** This stateless, "fire-and-forget" behavior is a key feature, as it helps maintain security and prevents residual data from accumulating within the container. You handle the security and long-term storage of the resulting PDF in your own application (like the `rachoon` service you might run next to it).

### 2. What is the project URL?

The official project website and documentation for Gotenberg is:

* **Website:** `https://gotenberg.dev/` 
* **GitHub Repository:** `https://github.com/gotenberg/gotenberg`