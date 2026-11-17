import 'package:flutter/material.dart';
import '../models/alat.dart';
import '../services/data_repository.dart';
import '../widgets/state_view.dart';
import '../widgets/status_badge.dart';

class DaftarAlatScreen extends StatefulWidget {
  const DaftarAlatScreen({super.key});

  @override
  State<DaftarAlatScreen> createState() => _DaftarAlatScreenState();
}

class _DaftarAlatScreenState extends State<DaftarAlatScreen> {
  late Future<List<Alat>> _future;

  @override
  void initState() {
    super.initState();
    _future = DataRepository.ambilAlat();
  }

  void _muatUlang() {
    setState(() => _future = DataRepository.ambilAlat());
  }

  Future<void> _tarikRefresh() async {
    final f = DataRepository.ambilAlat();
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
      child: FutureBuilder<List<Alat>>(
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
          final data = snap.data!;
          if (data.isEmpty) {
            return const ScrollableCenter(
              child: StateView(
                ikon: Icons.inventory_2_outlined,
                judul: 'Belum ada data alat',
                pesan: 'Data alat belum didaftarkan ke sistem.',
              ),
            );
          }
          return GridView.builder(
            physics: const AlwaysScrollableScrollPhysics(),
            padding: const EdgeInsets.all(16),
            gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
              maxCrossAxisExtent: 380,
              mainAxisExtent: 190,
              crossAxisSpacing: 12,
              mainAxisSpacing: 12,
            ),
            itemCount: data.length,
            itemBuilder: (_, i) => _AlatCard(alat: data[i]),
          );
        },
      ),
    );
  }
}

class _AlatCard extends StatelessWidget {
  final Alat alat;
  const _AlatCard({required this.alat});

  @override
  Widget build(BuildContext context) {
    final habis = alat.tersedia == 0;
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(alat.nama,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                    fontWeight: FontWeight.w600, fontSize: 16)),
            const SizedBox(height: 2),
            Text(alat.kode, style: const TextStyle(fontSize: 12)),
            const SizedBox(height: 10),
            LinearProgressIndicator(
              value: alat.stokTotal == 0 ? 0 : alat.tersedia / alat.stokTotal,
              minHeight: 6,
              borderRadius: BorderRadius.circular(3),
            ),
            const SizedBox(height: 6),
            Text(
                'Total ${alat.stokTotal} · Dipinjam ${alat.dipinjam} · Tersedia ${alat.tersedia}',
                style: const TextStyle(fontSize: 12)),
            const Spacer(),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                habis
                    ? StatusBadge(
                        label: 'Stok habis',
                        warnaTeks: Colors.orange.shade900,
                        warnaLatar: Colors.orange.shade100)
                    : StatusBadge(
                        label: 'Tersedia ${alat.tersedia}',
                        warnaTeks: Colors.green.shade900,
                        warnaLatar: Colors.green.shade100),
                FilledButton(
                  onPressed: habis ? null : () {},
                  child: const Text('Pinjam'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}