const fs = require('fs');
const url = process.env.SUPABASE_URL || '';
const key = process.env.SUPABASE_ANON_KEY || '';
if (!url || !key) {
  console.warn('SUPABASE_URL atau SUPABASE_ANON_KEY belum diatur. config.js dibuat kosong.');
}
fs.writeFileSync('config.js', `window.APP_CONFIG = ${JSON.stringify({SUPABASE_URL:url, SUPABASE_ANON_KEY:key}, null, 2)};\n`);
