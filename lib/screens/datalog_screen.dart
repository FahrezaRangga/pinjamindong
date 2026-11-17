import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../models/alat.dart';
import '../models/dummy_data.dart';
import '../models/peminjaman.dart';
import '../widgets/status_badge.dart';

class DatalogScreen extends StatefulWidget {
  const DatalogScreen({super.key});

  @override
  State<DatalogScreen> createState() => _DatalogScreenState();
}

class _DatalogScreenState extends State<DatalogScreen> {
  String _filter = 'semua';
  final _format = DateFormat('dd MMM yyyy, HH:mm');

  String _namaAlat(String kode) => dummyAlat
      .firstWhere((a) => a.kode == kode,
          orElse: () =>
              Alat(kode: kode, nama: kode, stokTotal: 0, dipinjam: 0))
      .nama;

  @override
  Widget build(BuildContext context) {
    final tampil = dummyPeminjaman.where((p) {
      if (_filter == 'dipinjam') return !p.sudahDikembalikan;
      if (_filter == 'dikembalikan') return p.sudahDikembalikan;
      return true;
    }).toList();

    return Center(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 720),
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
              child: Align(
                alignment: Alignment.centerLeft,
                child: Wrap(
                  spacing: 8,
                  children: [
                    for (final f in const [
                      ['semua', 'Semua'],
                      ['dipinjam', 'Dipinjam'],
                      ['dikembalikan', 'Dikembalikan'],
                    ])
                      ChoiceChip(
                        label: Text(f[1]),
                        selected: _filter == f[0],
                        onSelected: (_) => setState(() => _filter = f[0]),
                      ),
                  ],
                ),
              ),
            ),
            Expanded(
              child: tampil.isEmpty
                  ? const Center(child: Text('Belum ada data'))
                  : ListView.separated(
                      padding: const EdgeInsets.all(16),
                      itemCount: tampil.length,
                      separatorBuilder: (_, __) => const SizedBox(height: 12),
                      itemBuilder: (_, i) => _kartu(tampil[i]),
                    ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _kartu(Peminjaman p) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Text('${_namaAlat(p.kodeAlat)} × ${p.jumlah}',
                      style: const TextStyle(
                          fontWeight: FontWeight.w600, fontSize: 16)),
                ),
                p.sudahDikembalikan
                    ? StatusBadge.dikembalikan()
                    : StatusBadge.dipinjam(),
              ],
            ),
            const SizedBox(height: 6),
            Text('Kode alat: ${p.kodeAlat} · Peminjam: ${p.kodePeminjam.substring(0, 8)}…',
                style: const TextStyle(fontSize: 12)),
            Text('Pinjam: ${_format.format(p.waktuPinjam)}',
                style: const TextStyle(fontSize: 12)),
            Text(
                'Kembali: ${p.waktuKembali == null ? '-' : _format.format(p.waktuKembali!)}',
                style: const TextStyle(fontSize: 12)),
            if (!p.sudahDikembalikan) ...[
              const SizedBox(height: 10),
              Align(
                alignment: Alignment.centerRight,
                child: FilledButton(
                  onPressed: () => debugPrint('Kembalikan id ${p.id}'),
                  child: const Text('Kembalikan'),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}