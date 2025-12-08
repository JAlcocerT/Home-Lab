---
source_code: https://github.com/nuxt/content
post: https://jalcocert.github.io/JAlcocerT/trying-nuxt-themes/#nuxt-content-cms
official_docs: https://content.nuxt.com/
tags: ["static site generator","SSG","File based CMS","Git based CMS","Headless CMS"]
---

> Example Nuxt SGG with Nuxt Content CMS https://content.nuxt.com/templates/canvas

> > Wrote about it [here](https://jalcocert.github.io/JAlcocerT/trying-nuxt-themes/)

Nuxt Content is a module for Nuxt that provides a simple way to manage content for your application. 

It allows developers to write their content in Markdown, YAML or JSON files and then query and display it in their application.

### Interesting Nuxt Themes

* https://github.com/HugoRCD/canvas
* https://github.com/apdev95/bento-portfolio-nuxt
* https://github.com/samkanje/usenuxt-free
    * Includes F/OSS Auth with - https://github.com/lucia-auth/lucia
* https://github.com/Flosciante/nuxt-image-gallery


### Nuxt Content (CMS)

Write pages in markdown - use Vue components and enjoy

* https://github.com/nuxt/content
    * **MIT Licensed**: https://github.com/nuxt/content/blob/main/LICENSE
    * https://www.npmjs.com/package/@nuxt/content

> The **file-based CMS** for your Nuxt application, powered by Markdown and Vue components.

* Why?
    * A Markdown syntax made for Vue components (MDC)
    * Also handles CSV, YAML and JSON(5)
    * Deploy everywhere - Nuxt Content **supports Static Generation**, also Node.js hosting and even Workers environments.

> There is a static blog generator built on top of Nuxt.js and Nuxt-content providing everything you need to start writing your blog hassle-free AND for free -  https://github.com/bloggrify/bloggrify

> > You also have the [Nuxt Canva Theme](https://github.com/JAlcocerT/canvas)


```sh
npx nuxi@latest init content-app -t content
cd content
npm run dev #pnpm run dev #yarn dev
```
> `localhost:3000`