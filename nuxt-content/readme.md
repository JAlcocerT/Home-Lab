---
source_code: https://github.com/nuxt/content
post:
tags: ["static site generator","SSG","File based CMS"]
---

Example Nuxt SGG with Nuxt Content CMS https://content.nuxt.com/templates/canvas

### Interesting Nuxt Themes

* https://github.com/apdev95/bento-portfolio-nuxt
* https://github.com/samkanje/usenuxt-free
    * Includes F/OSS Auth with - https://github.com/lucia-auth/lucia
* https://github.com/Flosciante/nuxt-image-gallery
* https://github.com/HugoRCD/canvas

### Nuxt Content (CMS)

Write pages in markdown - use Vue components and enjoy

https://github.com/nuxt/content
https://github.com/nuxt/content/blob/main/LICENSE

https://content.nuxt.com/

https://www.npmjs.com/package/@nuxt/content

> The **file-based CMS** for your Nuxt application, powered by Markdown and Vue components.

* Why?
    * A Markdown syntax made for Vue components (MDC)
    * Also handles CSV, YAML and JSON(5)
    * Deploy everywhere - Nuxt Content **supports Static Generation**, also Node.js hosting and even Workers environments.

> There is a static blog generator built on top of Nuxt.js and Nuxt-content providing everything you need to start writing your blog hassle-free AND for free -  https://github.com/bloggrify/bloggrify

{{< dropdown title="How to use Nuxt Content CMS with Docker ⏬" closed="true" >}}

```yml
# Use the official Node.js image as the base
FROM node:latest 
#20.15.0 # https://hub.docker.com/_/node/tags

# Install Git and nano
RUN apt-get update && \
    apt-get install -y git nano

# Install Bun
RUN curl -fsSL https://bun.sh/install | bash

# Install additional packages using npm
RUN npm install -g npm@latest
RUN npm install -g pnpm
#RUN npm install -g yarn

# Set the working directory in the container
WORKDIR /app

# Copy package.json and package-lock.json (if available) to the working directory
#COPY package*.json ./

# Install project dependencies using npm
#RUN npm install

# Copy the rest of the project files to the working directory
#COPY . .

# Expose the desired port (replace 3000 with your app's port if different)
EXPOSE 3000

# Specify the command to run your application
#CMD ["npm", "start"]
# Keep the container running and wait for a command
CMD ["tail", "-f", "/dev/null"]


#docker build -t node_ssg .
#podman build -t node_ssg .

#docker run -d --name=node_ssg -p 3000:3000 node_ssg 
#podman run -d --name=node_ssg -p 3005:3000 node_ssg 

#docker exec -it node_ssg /bin/bash
#podman exec -it node_ssg /bin/bash


#echo "Node: $(node --version) | npm: $(npm --version) | Yarn: $(yarn --version) | Bun: $(bun --version)"
#podman exec -it loving_babbage /bin/bash -c "echo NPM: \$(npm --version)"
```

And then:

```sh
npx nuxi@latest init content-app -t content
cd content
npm run dev #pnpm run dev #yarn dev
```
`localhost:3000`

{{< /dropdown >}}