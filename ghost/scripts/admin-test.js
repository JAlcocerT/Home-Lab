require('dotenv').config({ path: '.env' });

const GhostAdminAPI = require('@tryghost/admin-api');

const url = process.env.GHOST_URL;
const adminKey = process.env.GHOST_ADMIN_API_KEY; // format: keyid:hexsecret

if (!url || !adminKey) {
  console.error('Missing env vars. Ensure GHOST_URL and GHOST_ADMIN_API_KEY are set in .env');
  process.exit(1);
}

const admin = new GhostAdminAPI({
  url,
  key: adminKey,
  version: 'v5.0'
});

(async () => {
  try {
    const posts = await admin.posts.browse({ limit: 1, order: 'updated_at desc' });
    console.log('Posts (admin view):', posts.map(p => ({ id: p.id, title: p.title, status: p.status })));
  } catch (e) {
    console.error('Admin SDK error:', e.message);
    if (e.response && e.response.body) {
      console.error('Body:', e.response.body);
    }
    process.exit(1);
  }
})();
