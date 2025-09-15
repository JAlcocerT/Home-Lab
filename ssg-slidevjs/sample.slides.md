---
theme: seriph
background: https://cover.sli.dev
title: Welcome to Slidev
info: |
  ## Slidev Starter Template
  Presentation slides for developers.
  Learn more at [Sli.dev](https://sli.dev)
class: text-center
drawings:
  persist: false
transition: slide-left
mdc: true
---

# Welcome to Slidev

Presentation slides for developers with 🐋

<div @click="$slidev.nav.next" class="mt-12 py-1" hover:bg="white op-10">
  Press Space for next page <carbon:arrow-right />
</div>

<div class="abs-br m-6 text-xl">
  <button @click="$slidev.nav.openInEditor()" title="Open in Editor" class="slidev-icon-btn">
    <carbon:edit />
  </button>
  <a href="https://github.com/slidevjs/slidev" target="_blank" class="slidev-icon-btn">
    <carbon:logo-github />
  </a>
</div>

---
transition: fade-out
---

# What is Slidev?

Slidev is a slides maker and presenter designed for developers

- 📝 **Text-based** - focus on the content with Markdown
- 🎨 **Themable** - themes can be shared and re-used
- 🧑‍💻 **Developer Friendly** - code highlighting, live coding
- 🤹 **Interactive** - embed Vue components
- 🎥 **Recording** - built-in recording and camera view
- 📤 **Portable** - export to PDF, PPTX, PNGs
- 🛠 **Hackable** - virtually anything is possible

Read more about [Why Slidev?](https://sli.dev/guide/why)

---
layout: center
class: text-center
---

# Learn More

[Documentation](https://sli.dev) · [GitHub](https://github.com/slidevjs/slidev)

<PoweredBySlidev mt-10 />