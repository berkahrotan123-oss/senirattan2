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
