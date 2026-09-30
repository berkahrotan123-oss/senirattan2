SENI RATTAN Finance Online v30

# SENI RATTAN Finance Online v23

Perbaikan:
- Menu dan halaman Sales untuk Fariz sudah ditambahkan ke index.html.
- Fariz role `sales` akan diarahkan ke Dashboard Sales setelah login.
- Menu Sales berisi Dashboard Sales, Sektor Penjualan, Uang Masuk Penjualan, dan Laporan Penjualan.

Jika halaman Sales belum muncul, pastikan `migration-v22-sales-user.sql` dan `setup-users.sql` sudah dijalankan dengan email Fariz yang benar.


## v24
- Menambahkan halaman owner **Rekap Profit**.
- Tabel menampilkan Nama Siklus, Uang Keluar Total, Uang Masuk Sales, dan Profit.
- Profit dihitung dari Uang Masuk Sales dikurangi Uang Keluar Total.
- Tidak membutuhkan SQL tambahan.


## Versi v27
- Khusus Bayaran Sabtu: tanggal pembayaran boleh berbeda dari siklus tagihan yang sedang dipilih.
- Validasi siklus tetap berlaku untuk input transaksi lain.
- Pembayaran cash tetap memeriksa sisa kas pada tanggal pembayaran dan ditolak jika tanggal tersebut sudah ditutup atau saldo tidak cukup.


## v31
- Memperbaiki data transaksi terbaru yang sudah masuk database tetapi tidak tampil di aplikasi ketika jumlah data sudah banyak.
- Aplikasi sekarang mengambil data secara bertahap/pagination dari Supabase, tidak hanya 1000 baris pertama.
