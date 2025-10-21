* https://github.com/thesubtleties/atria

>  Virtual and Hybrid Event management platform with real-time networking features. Create events, manage sessions, facilitate attendee connections, and enable live chat. Built with Flask, React, and Socket.IO. 

* https://github.com/HectorPulido/pequeroku

A lightweight container management platform empowering community members to spin up isolated QEMU environments for experiments and learning. 🚀


* https://github.com/alexcastrodev/shortener

Project     |  Ease of Self-Hosting  |  Notes                                                                                                               
------------+------------------------+----------------------------------------------------------------------------------------------------------------------
Dub.co      |  Moderate              |  Powerful link management but primarily a commercial platform, open source backend exists, may require more setup.   
Eastlake    |  Easy                  |  Cloudflare Worker-based, very lightweight, simple deployment via Cloudflare, good if you have Cloudflare experience.
Kutt.it     |  Moderate              |  Open source Node.js app, requires Node environment but well documented, Docker images available.                    
Lstu.fr     |  Easy                  |  Lightweight, written in OCaml, minimal dependencies, official instance available, simple setup.                     
Polr        |  Easy to Moderate      |  PHP/MySQL based, lightweight and popular, easy to deploy on typical LAMP stacks or Docker.                          
pygmy       |  Moderate              |  Python-based with analytics, moderate complexity but well structured for self-hosting.                              
reduced.to  |  Moderate              |  Open source with analytics, requires standard web stack, some setup needed.                                         
san.aq      |  Easy                  |  Minimalistic API-based shortener, very simple tool for curl/HTTP API users.                                         
shlink      |  Moderate              |  PHP-based with rich features, requires some setup, Docker deployments exist.                                        
Sink        |  Easy                  |  Cloudflare-based like Eastlake, cloud-native simple deployment on Cloudflare platform.                              
YOURLS      |  Easy                  |  Most popular self-hosted URL shortener, PHP/MySQL based, simple installation, highly documented.                   


Existen múltiples alternativas open source y autoalojadas a Shopify y WordPress con WooCommerce en 2025, cada una con distintos enfoques según la escala del negocio, el nivel técnico y la arquitectura deseada (monolítica o headless).

### Principales alternativas open source a Shopify

1. **Medusa.js**  
   Basada en Node.js, con arquitectura *headless*, Medusa permite crear tiendas con React, Vue o Next.js manteniendo el backend separado. Ofrece API REST y GraphQL, soporte para plugins y control total de datos y diseño.[1]

2. **Bagisto**  
   Construida sobre Laravel y Vue.js, ofrece multicanal, multi-almacén, API GraphQL y una interfaz moderna. Es ideal para proyectos personalizables y escalables a nivel empresarial.[2]

3. **Saleor**  
   Framework de eCommerce *headless* basado en GraphQL y Django (Python). Es utilizado para tiendas modernas con integraciones JAMstack y gran rendimiento.[1]

4. **Spree Commerce**  
   Plataforma Ruby on Rails pensada para desarrolladores. Es estable, modular y permite integraciones B2B o B2C sin coste de licencia.[3]

5. **PrestaShop**  
   Solución PHP madura con una comunidad muy activa y muchos módulos. Se instala fácilmente en cualquier hosting y ofrece gestión de catálogos, marketing y SEO.[4][2]

### Alternativas autoalojadas a WooCommerce

1. **Magento Open Source (Adobe Commerce)**  
   Potente y personalizable, escrita en PHP. Ideal para empresas con desarrolladores internos o agencias. Ofrece multi-tienda, gestión avanzada de pedidos e integración ERP.[5][6]

2. **OpenCart**  
   Opción ligera y sencilla para usuarios sin experiencia técnica. Ofrece buena base de extensiones, interfaz fácil y soporte multitienda.[7]

3. **nopCommerce**  
   Basada en .NET, soporta B2B, B2C y marketplaces. Muy flexible y con API REST nativa. Adecuada para quienes usan infraestructura Microsoft.[6]

4. **Odoo eCommerce**  
   Forma parte del ecosistema ERP Odoo. Permite administrar inventarios, facturación y ventas desde un mismo entorno, con interfaz moderna y modular.[2]

5. **Drupal Commerce**  
   Extiende el CMS Drupal para manejar eCommerce. Ideal si se requiere un sistema de contenido robusto junto con funcionalidades de tienda.[8]

### Comparativa general

| Plataforma | Lenguaje base | Arquitectura | Ideal para | Observaciones |
|-------------|----------------|----------------|----------------|----------------|
| Medusa.js [1] | Node.js | Headless | Desarrolladores modernos | Integración con React, Next.js |
| Bagisto [2] | PHP (Laravel) | Modular/Headless | Pymes y empresas | Multi-almacén, multilingüe |
| Saleor [1] | Python (Django) | Headless | Tiendas JAMstack | API GraphQL avanzada |
| Magento Open Source [5] | PHP | Monolítica | Grandes comercios | Comunidad amplia, alto consumo de recursos |
| PrestaShop [2] | PHP | Tradicional | Pymes | Fácil instalación, buen SEO |
| nopCommerce [6] | C# (.NET) | Modular | Negocios Microsoft | Soporta multi-tienda y B2B |
| OpenCart [7] | PHP | Tradicional | Pequeñas tiendas | Sencilla y ligera |

En resumen, **Medusa.js**, **Bagisto** y **Saleor** representan la nueva generación de plataformas headless modernas, mientras que **Magento**, **PrestaShop** y **nopCommerce** siguen siendo las opciones más sólidas para quienes buscan ecosistemas maduros y autogestionados.


---

```
Add one folder with a docker file to selfhost https://github.com/ente-io/ente
and in the readme just keep a simple front matter with source_code: do this for any other repo ill provide
```