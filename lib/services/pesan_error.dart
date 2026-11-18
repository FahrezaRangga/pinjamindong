import 'package:flutter/foundation.dart';

// Mengubah error teknis menjadi pesan yang mudah dipahami
String pesanRamah(Object e) {
  debugPrint('Error transaksi: $e'); // detail asli tetap terlihat di konsol
  final s = e.toString();
  const peta = {
    'Stok tidak cukup': 'Stok alat tidak mencukupi.',
    'Alat tidak terdaftar': 'Alat belum terdaftar di sistem.',
    'Alat sudah dikembalikan': 'Alat ini sudah dikembalikan sebelumnya.',
    'Data tidak ditemukan': 'Data peminjaman tidak ditemukan.',
    'Kode peminjam harus diisi': 'Data peminjam wajib diisi.',
    'Jumlah minimal 1': 'Jumlah minimal 1 unit.',
    'insufficient funds':
        'Saldo Sepolia ETH wallet tidak cukup untuk biaya gas. Isi ulang dari faucet.',
    'exceeds the balance':
        'Saldo Sepolia ETH wallet tidak cukup untuk biaya gas. Isi ulang dari faucet.',
    'nonce too low':
        'Masih ada transaksi yang diproses. Tunggu sebentar lalu coba lagi.',
    'underpriced':
        'Masih ada transaksi yang diproses. Tunggu sebentar lalu coba lagi.',
    'PRIVATE_KEY belum diisi':
        'Wallet belum diatur. Isi PRIVATE_KEY di berkas konfigurasi.',
    'Timeout menunggu transaksi':
        'Transaksi belum terkonfirmasi. Cek hash di Etherscan, lalu muat ulang data.',
    'ditolak oleh kontrak': 'Transaksi ditolak oleh kontrak.',
    'SocketException': 'Koneksi internet bermasalah. Coba lagi.',
    'Failed host lookup': 'Koneksi internet bermasalah. Coba lagi.',
    'XMLHttpRequest': 'Koneksi internet bermasalah. Coba lagi.',
  };
  for (final entry in peta.entries) {
    if (s.contains(entry.key)) return entry.value;
  }
  return 'Transaksi gagal. Silakan coba lagi.';
}