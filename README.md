# PinjaminDong

Logbook peminjaman alat Lab IoT berbasis blockchain. Data peminjaman disimpan di smart contract pada jaringan uji **Sepolia**, dan diakses lewat aplikasi **Flutter** (Android, dengan versi web untuk pengembangan).

Proyek kelompok mata kuliah Pemrograman Mobile 2, D4 Teknologi Rekayasa Komputer, Politeknik Negeri Samarinda.

- Kelompok: [ISI NAMA KELOMPOK]
- Anggota: [Anggota 1], [Anggota 2], [Anggota 3]

## Fitur

- Halaman Welcome dan 5 menu: Beranda, Datalog, Alat, Pinjam, Tentang
- Daftar alat dengan stok per jenis (total, dipinjam, tersedia)
- Pinjam alat beberapa unit sekaligus, selama stok tersedia
- Kembalikan alat
- Riwayat peminjaman dengan filter (Semua, Dipinjam, Dikembalikan)
- Dialog status transaksi: memproses, berhasil (hash transaksi, tombol salin dan Etherscan), gagal (pesan error mudah dipahami)
- Tampilan loading, kosong, dan error, plus tarik-untuk-muat-ulang
- NIM di-hash sebelum dikirim ke blockchain, nama peminjam tidak disimpan on-chain

## Smart contract

| Item | Nilai |
|---|---|
| Alamat | `0x26Aa3eF8149ac93ab725908444ED0ecbb038cd29` |
| Etherscan | https://sepolia.etherscan.io/address/0x26Aa3eF8149ac93ab725908444ED0ecbb038cd29 |
| Jaringan | Sepolia (chain ID `11155111`) |
| Compiler | Solidity 0.8.20 |
| Verifikasi | Source Code Verified (Exact Match) |

Fungsi utama: `tambahAlat`, `ubahStok`, `pinjamAlat`, `kembalikanAlat` (tulis) dan `jumlahJenisAlat`, `ambilAlat`, `jumlahPeminjaman`, `ambilPeminjaman` (baca).

Berkas kontrak: [ISI PATH BERKAS .sol DI REPOSITORI]

## Versi

Flutter 3.50.0 (Dart 3.14.0). Paket utama:

| Paket | Versi |
|---|---|
| web3dart | 3.0.3 |
| wallet | 0.0.18 |
| http | 1.6.0 |
| flutter_dotenv | 6.0.2 |
| crypto | 3.0.8 |
| intl | 0.20.3 |
| url_launcher | [ISI DARI pubspec.yaml] |

Cek angka persisnya di `pubspec.yaml` dan perbarui tabel ini bila berbeda.

## Cara menjalankan

Prasyarat: Flutter SDK, Android Studio (untuk Android SDK), dan akun RPC Sepolia (misalnya Alchemy, gratis).

1. Ambil kode dan pasang paket:
   ```bash
   git clone [ISI URL REPOSITORI]
   cd pinjamindong
   flutter pub get
   ```
2. Salin `assets/config.env.example` menjadi `assets/config.env`, lalu isi:
   ```
   RPC_URL=URL_RPC_SEPOLIA_KAMU
   PRIVATE_KEY=PRIVATE_KEY_WALLET_KHUSUS_TUGAS
   CONTRACT_ADDRESS=0x26Aa3eF8149ac93ab725908444ED0ecbb038cd29
   CHAIN_ID=11155111
   HASH_SALT=teks-acak-bebas
   ```
   Wallet yang dipakai harus punya sedikit Sepolia ETH (gratis dari faucet) untuk biaya gas.
3. Jalankan:
   ```bash
   flutter run -d chrome          # versi web, untuk pengembangan
   flutter run -d ID_PERANGKAT    # HP Android (lihat: flutter devices)
   ```
4. Build APK:
   ```bash
   flutter build apk --release
   ```
   Hasil: `build/app/outputs/flutter-apk/app-release.apk`

Pastikan `AndroidManifest.xml` memuat izin `INTERNET`.

## Struktur proyek

```
lib/
  config/        konfigurasi (membaca config.env)
  models/        model Alat dan Peminjaman
  screens/       halaman aplikasi
  services/      BlockchainService (web3dart), DataRepository, pesan error
  widgets/       komponen bersama (lencana status, dialog transaksi, dan lain-lain)
assets/
  abi/PinjaminDong.json   ABI kontrak
  config.env.example      contoh konfigurasi (tanpa nilai)
```

## Keamanan

- Hanya jaringan uji Sepolia. Tidak ada penggunaan mainnet atau pembelian kripto.
- Wallet khusus tugas, terpisah dari wallet pribadi dan dari akun yang men-deploy kontrak.
- `assets/config.env` masuk `.gitignore` dan tidak ada di repositori. Hanya `config.env.example` yang diunggah.
- NIM di-hash (SHA-256 dengan salt) sebelum dikirim. Data blockchain publik dan permanen, jadi NIM dan nama asli tidak disimpan di sana.

### Keterbatasan

- `config.env` dimasukkan sebagai aset aplikasi, sehingga private key wallet testnet ikut terbawa di dalam APK dan versi web. Karena itu APK hanya dibagikan ke dosen dan kelompok, dan jangan men-deploy versi web ke internet.
- Solusi yang tepat adalah koneksi wallet lewat WalletConnect/Reown sehingga private key tidak berada di aplikasi.
- Fungsi tulis kontrak tidak dibatasi per pengguna. Untuk tugas ini hal itu disengaja agar pengujian mudah.

## Pembagian tugas

| Anggota | Tanggung jawab |
|---|---|
| Anggota 1 | Rancangan dan kode smart contract, pengujian, deploy ke Sepolia, verifikasi Etherscan, data alat awal |
| Anggota 2 | Rancangan UI, kode Flutter, integrasi web3dart, fitur transaksi, pengujian bersama, APK, laporan, video demo |
| Anggota 3 | [ISI] |

## Luaran

- Repositori kode: [ISI LINK]
- Video demo: [ISI LINK YOUTUBE UNLISTED/DRIVE]
- APK dan laporan: dikumpulkan sebagai berkas terpisah sesuai ketentuan tugas

## Sumber dan bantuan AI

- Lima video wajib dari dokumen tugas, serta dokumentasi paket web3dart dan Flutter.
- [ISI tutorial atau kode lain yang diadaptasi.]
- Asisten AI dipakai untuk menyusun rancangan, kerangka kode, dan pemecahan masalah. Seluruh anggota memahami dan dapat menjelaskan kode yang dikumpulkan.
