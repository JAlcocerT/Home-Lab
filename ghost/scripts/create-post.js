#!/usr/bin/env node
require('dotenv').config({ path: '.env' });

const fs = require('fs');
const path = require('path');
const matter = require('gray-matter');
const { marked } = require('marked');
const GhostAdminAPI = require('@tryghost/admin-api');

const GHOST_URL = process.env.GHOST_URL;
const GHOST_ADMIN_API_KEY = process.env.GHOST_ADMIN_API_KEY; // keyid:hexsecret

if (!GHOST_URL || !GHOST_ADMIN_API_KEY) {
  console.error('Missing env vars. Ensure GHOST_URL and GHOST_ADMIN_API_KEY are set in .env');
  process.exit(1);
}

const fileArg = process.argv[2] || path.join(__dirname, '..', 'samples', 'sample-post.md');
const mdPath = path.isAbsolute(fileArg) ? fileArg : path.resolve(process.cwd(), fileArg);

if (!fs.existsSync(mdPath)) {
  console.error(`Markdown file not found: ${mdPath}`);
  process.exit(1);
}

const admin = new GhostAdminAPI({
  url: GHOST_URL,
  key: GHOST_ADMIN_API_KEY,
  version: 'v5.0'
});

(async () => {
  try {
    const raw = fs.readFileSync(mdPath, 'utf8');
    const parsed = matter(raw);
    const fm = parsed.data || {};
    const md = parsed.content || '';

    // Required fields
    const title = fm.title || 'Untitled Post';
    let html = marked.parse(md);
    const htmlLen = (html || '').length;
    if (!htmlLen) {
      console.warn('Markdown converted to empty HTML, applying fallback.');
      const safe = (md || '').trim();
      html = safe ? `<p>${safe.replace(/\n\n+/g, '</p><p>')}</p>` : '<p></p>';
    }
    console.log('HTML length:', html.length);

    // Optional fields
    const slug = fm.slug || undefined;
    const status = fm.status || 'draft'; // draft | published | scheduled
    const custom_excerpt = fm.excerpt || fm.custom_excerpt || undefined;
    let feature_image = fm.feature_image || undefined; // URL or set after upload
    const feature_image_alt = fm.feature_image_alt || undefined;
    const feature_image_caption = fm.feature_image_caption || undefined;
    const published_at = fm.published_at || undefined; // ISO string if scheduled/published

    // Tags: can be array or comma-separated string
    let tags = undefined;
    if (Array.isArray(fm.tags)) {
      tags = fm.tags.map(t => (typeof t === 'string' ? { name: t } : t));
    } else if (typeof fm.tags === 'string') {
      tags = fm.tags.split(',').map(s => s.trim()).filter(Boolean).map(name => ({ name }));
    }

    // Optional: upload a local image and set as feature_image
    const feature_image_path = fm.feature_image_path || fm.image_path || fm.image;
    if (feature_image_path) {
      const absImg = path.isAbsolute(feature_image_path)
        ? feature_image_path
        : path.resolve(path.dirname(mdPath), feature_image_path);
      if (fs.existsSync(absImg)) {
        try {
          // Pass a file path; the Admin SDK will handle creating the stream/form-data
          const upload = await admin.images.upload({ file: absImg });
          feature_image = upload && upload.url ? upload.url : feature_image;
          if (feature_image) {
            console.log('Uploaded feature image ->', feature_image);
          }
          if (!feature_image) {
            console.warn('Image upload returned no URL; leaving feature_image unset.');
          }
        } catch (imgErr) {
          console.error('Feature image upload failed:', imgErr.message);
        }
      } else {
        console.warn('feature_image_path not found on disk:', absImg);
      }
    }

    const postPayload = {
      title,
      html,
      status,
      ...(slug ? { slug } : {}),
      ...(custom_excerpt ? { custom_excerpt } : {}),
      ...(feature_image ? { feature_image } : {}),
      ...(feature_image_alt ? { feature_image_alt } : {}),
      ...(feature_image_caption ? { feature_image_caption } : {}),
      ...(published_at ? { published_at } : {}),
      ...(tags ? { tags } : {})
    };

    const created = await admin.posts.add(postPayload, { source: 'html' });
    console.log('Created post:', { id: created.id, slug: created.slug, status: created.status, url: created.url });
  } catch (e) {
    console.error('Failed to create post:', e.message);
    if (e.response && e.response.body) {
      console.error('Body:', e.response.body);
    }
    process.exit(1);
  }
})();
