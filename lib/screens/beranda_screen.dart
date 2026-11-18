import 'package:flutter/material.dart';
import '../models/alat.dart';
import '../models/peminjaman.dart';
import '../services/data_repository.dart';
import '../widgets/state_view.dart';

class BerandaScreen extends StatefulWidget {
  // Dipanggil saat tombol cepat ditekan: pindah ke tab dengan indeks tertentu
  final void Function(int) onPindah;
  const BerandaScreen({super.key, required this.onPindah});

  @override
  State<BerandaScreen> createState() => _BerandaScreenState();
}

class _BerandaScreenState extends State<BerandaScreen> {
  late Future<(List<Alat>, List<Peminjaman>)> _future;

  @override
  void initState() {
    super.initState();
    _future = _muat();
  }

  Future<(List<Alat>, List<Peminjaman>)> _muat() async {
    final fAlat = DataRepository.ambilAlat();
    final fPeminjaman = DataRepository.ambilPeminjaman();
    final alat = await fAlat;
    final peminjaman = await fPeminjaman;
    return (alat, peminjaman);
  }

  void _muatUlang() => setState(() => _future = _muat());

  Future<void> _tarikRefresh() async {
    final f = _muat();
    setState(() => _future = f);
    try {
      await f;
    } catch (_) {
      // error ditampilkan oleh FutureBuilder
    }
  }

  @override
  Widget build(BuildContext context) {
    return RefreshIndicator(
      onRefresh: _tarikRefresh,
      child: FutureBuilder<(List<Alat>, List<Peminjaman>)>(
        future: _future,
        builder: (context, snap) {
          if (snap.connectionState != ConnectionState.done) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snap.hasError) {
            return ScrollableCenter(
              child: StateView(
                ikon: Icons.cloud_off,
                judul: 'Gagal memuat data',
                pesan: 'Periksa koneksi internet, lalu coba lagi.',
                labelTombol: 'Coba lagi',
                onTombol: _muatUlang,
              ),
            );
          }
          final (alat, peminjaman) = snap.data!;
          // Statistik dihitung dari data kontrak, bukan ditulis manual
          final totalAlat = alat.fold<int>(0, (s, a) => s + a.stokTotal);
          final totalDipinjam = alat.fold<int>(0, (s, a) => s + a.dipinjam);
          final totalTransaksi = peminjaman.length;

          return Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 800),
              child: ListView(
                physics: const AlwaysScrollableScrollPhysics(),
                padding: const EdgeInsets.all(16),
                children: [
                  const Text(
                    'Sistem Logbook Peminjaman Alat Lab IoT Berbasis Blockchain',
                    style:
                        TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
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
                      _stat('Transaksi on-chain', '$totalTransaksi',
                          'Transaksi'),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      Expanded(
                        child: FilledButton(
                          onPressed: () => widget.onPindah(3),
                          child: const Text('Pinjam Alat'),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: OutlinedButton(
                          onPressed: () => widget.onPindah(1),
                          child: const Text('Kembalikan Alat'),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          );
        },
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