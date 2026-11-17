import 'package:flutter/material.dart';
import '../models/dummy_data.dart';

class BerandaScreen extends StatelessWidget {
  // Dipanggil saat tombol cepat ditekan: pindah ke tab dengan indeks tertentu
  final void Function(int) onPindah;
  const BerandaScreen({super.key, required this.onPindah});

  @override
  Widget build(BuildContext context) {
    // Statistik dihitung dari data, bukan ditulis manual
    final totalAlat = dummyAlat.fold<int>(0, (s, a) => s + a.stokTotal);
    final totalDipinjam = dummyAlat.fold<int>(0, (s, a) => s + a.dipinjam);
    final totalTransaksi = dummyPeminjaman.length;

    return Center(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 800),
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            const Text(
              'Sistem Logbook Peminjaman Alat Lab IoT Berbasis Blockchain',
              style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            const Text(
              'Platform pencatatan peminjaman perangkat laboratorium IoT yang transparan, aman, dan anti-manipulasi menggunakan teknologi pencatatan on-chain.',
            ),
            const SizedBox(height: 16),
            Wrap(
              spacing: 12,
              runSpacing: 12,
              children: [
                _stat('Total alat di lab', '$totalAlat', 'Unit'),
                _stat('Sedang dipinjam', '$totalDipinjam', 'Unit'),
                _stat('Transaksi on-chain', '$totalTransaksi', 'Transaksi'),
              ],
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: FilledButton(
                    onPressed: () => onPindah(3),
                    child: const Text('Pinjam Alat'),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: OutlinedButton(
                    onPressed: () => onPindah(1),
                    child: const Text('Kembalikan Alat'),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _stat(String judul, String angka, String satuan) {
    return SizedBox(
      width: 240,
      child: Card(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(judul, style: const TextStyle(fontSize: 13)),
              Text(angka,
                  style: const TextStyle(
                      fontSize: 34,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF0F766E))),
              Text(satuan, style: const TextStyle(fontSize: 13)),
            ],
          ),
        ),
      ),
    );
  }
}