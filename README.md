# SENI RATTAN — Pembukuan Online

Versi online untuk Netlify + Supabase.

## 1. Siapkan Supabase
1. Buka proyek Supabase.
2. Masuk ke **SQL Editor**.
3. Jalankan seluruh isi file `supabase-schema.sql`.
4. Buka **Authentication > Users**, lalu buat akun email/password untuk pengguna aplikasi.
5. Buka **Project Settings > API**, salin Project URL dan anon/publishable key.

## 2. Deploy ke Netlify
1. Upload folder ini ke GitHub atau deploy ZIP/folder melalui Netlify.
2. Di Netlify, buka **Site configuration > Environment variables**.
3. Tambahkan:
   - `SUPABASE_URL`
   - `SUPABASE_ANON_KEY`
4. Build command: `npm run build`
5. Publish directory: `.`
6. Jalankan **Deploy** atau **Trigger deploy**.

File `build-config.js` akan membuat `config.js` otomatis saat build.

## 3. Penggunaan
- Login memakai akun dari Supabase Authentication.
- Semua pengguna yang sudah login berbagi database perusahaan yang sama.
- Sisa kas harian dikembalikan kepada owner pada saat penutupan.
- Pembelian supplier dapat cash atau tempo.
- Tagihan tempo dan pengeluaran mingguan dapat dibayar penuh atau sebagian.

## Keamanan
- Jangan pernah memasukkan Supabase service-role key ke frontend atau Netlify public build.
- Aplikasi hanya memakai anon/publishable key dan tabel dilindungi Row Level Security.

## 4. Atur dua pengguna dan role
Pengguna aplikasi:
- **Aan — Sekretaris:** dapat melihat, menginput, dan memperbarui data operasional. Tidak dapat menghapus data.
- **Febri — Owner:** akses penuh, termasuk menghapus data dan mengisi data contoh.

Langkah:
1. Buat dua user email/password di **Supabase > Authentication > Users**.
2. Buka `setup-users.sql`.
3. Ganti `EMAIL_AAN` dan `EMAIL_FEBRI` dengan email login yang sebenarnya.
4. Jalankan file tersebut di SQL Editor.

Nama dan role pengguna akan tampil di bagian kanan atas aplikasi setelah login.
