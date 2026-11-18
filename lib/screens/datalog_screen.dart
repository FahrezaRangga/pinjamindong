import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../models/alat.dart';
import '../models/peminjaman.dart';
import '../services/blockchain_service.dart';
import '../services/data_repository.dart';
import '../widgets/state_view.dart';
import '../widgets/status_badge.dart';
import '../widgets/tx_status_dialog.dart';

class DatalogScreen extends StatefulWidget {
  const DatalogScreen({super.key});

  @override
  State<DatalogScreen> createState() => _DatalogScreenState();
}

class _DatalogScreenState extends State<DatalogScreen> {
  late Future<(List<Peminjaman>, List<Alat>)> _future;
  String _filter = 'semua';
  bool _sibuk = false;
  final _format = DateFormat('dd MMM yyyy, HH:mm');

  @override
  void initState() {
    super.initState();
    _future = _muat();
  }

  Future<(List<Peminjaman>, List<Alat>)> _muat() async {
    final fPeminjaman = DataRepository.ambilPeminjaman();
    final fAlat = DataRepository.ambilAlat();
    final peminjaman = await fPeminjaman;
    final alat = await fAlat;
    return (peminjaman, alat);
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

  String _namaAlat(List<Alat> alat, String kode) {
    for (final a in alat) {
      if (a.kode == kode) return a.nama;
    }
    return kode;
  }

  Future<void> _kembalikan(Peminjaman p, String namaAlat) async {
    if (_sibuk) return;
    final yakin = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Kembalikan alat?'),
        content: Text(
            '$namaAlat × ${p.jumlah}\n\nTindakan ini dicatat di blockchain dan memakai biaya gas.'),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(ctx, false),
              child: const Text('Batal')),
          FilledButton(
              onPressed: () => Navigator.pop(ctx, true),
              child: const Text('Kembalikan')),
        ],
      ),
    );
    if (yakin != true || !mounted) return;

    setState(() => _sibuk = true);
    await jalankanTransaksi(
      context,
      judul: 'Mengembalikan alat',
      langkah: [
        TxLangkah('$namaAlat × ${p.jumlah}',
            () => BlockchainService.instance.kembalikanAlat(p.id)),
      ],
    );
    if (!mounted) return;
    setState(() => _sibuk = false);
    _muatUlang();
  }

  @override
  Widget build(BuildContext context) {
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
              child: RefreshIndicator(
                onRefresh: _tarikRefresh,
                child: FutureBuilder<(List<Peminjaman>, List<Alat>)>(
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
                    final (peminjaman, alat) = snap.data!;
                    final tampil = peminjaman.where((p) {
                      if (_filter == 'dipinjam') return !p.sudahDikembalikan;
                      if (_filter == 'dikembalikan') return p.sudahDikembalikan;
                      return true;
                    }).toList();

                    if (tampil.isEmpty) {
                      return ScrollableCenter(
                        child: StateView(
                          ikon: Icons.receipt_long_outlined,
                          judul: peminjaman.isEmpty
                              ? 'Belum ada peminjaman'
                              : 'Tidak ada data untuk filter ini',
                        ),
                      );
                    }
                    return ListView.separated(
                      physics: const AlwaysScrollableScrollPhysics(),
                      padding: const EdgeInsets.all(16),
                      itemCount: tampil.length,
                      separatorBuilder: (_, __) => const SizedBox(height: 12),
                      itemBuilder: (_, i) =>
                          _kartu(tampil[i], _namaAlat(alat, tampil[i].kodeAlat)),
                    );
                  },
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _kartu(Peminjaman p, String namaAlat) {
    final kode = p.kodePeminjam.length > 8
        ? '${p.kodePeminjam.substring(0, 8)}…'
        : p.kodePeminjam;
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
                  child: Text('$namaAlat × ${p.jumlah}',
                      style: const TextStyle(
                          fontWeight: FontWeight.w600, fontSize: 16)),
                ),
                p.sudahDikembalikan
                    ? StatusBadge.dikembalikan()
                    : StatusBadge.dipinjam(),
              ],
            ),
            const SizedBox(height: 6),
            Text('Kode alat: ${p.kodeAlat} · Peminjam: $kode',
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
                  onPressed: _sibuk ? null : () => _kembalikan(p, namaAlat),
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