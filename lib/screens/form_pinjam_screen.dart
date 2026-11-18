import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../models/alat.dart';
import '../services/blockchain_service.dart';
import '../services/data_repository.dart';
import '../widgets/state_view.dart';
import '../widgets/tx_status_dialog.dart';

class FormPinjamScreen extends StatefulWidget {
  const FormPinjamScreen({super.key});

  @override
  State<FormPinjamScreen> createState() => _FormPinjamScreenState();
}

class _FormPinjamScreenState extends State<FormPinjamScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nama = TextEditingController();
  final _nim = TextEditingController();
  late Future<List<Alat>> _future;

  // kode alat -> jumlah unit yang dipilih
  final Map<String, int> _pilihan = {};
  // kode alat -> nama alat (untuk label di dialog)
  final Map<String, String> _namaPerKode = {};
  String? _errorAlat;
  bool _sibuk = false;

  @override
  void initState() {
    super.initState();
    _future = DataRepository.ambilAlat();
  }

  @override
  void dispose() {
    _nama.dispose();
    _nim.dispose();
    super.dispose();
  }

  void _muatUlang() {
    setState(() {
      _pilihan.clear();
      _future = DataRepository.ambilAlat();
    });
  }

  Future<void> _kirim() async {
    if (_sibuk) return;
    final formOk = _formKey.currentState!.validate();
    final alatOk = _pilihan.isNotEmpty;
    setState(() => _errorAlat = alatOk ? null : 'Pilih minimal satu alat');
    if (!formOk || !alatOk) return;

    final svc = BlockchainService.instance;
    final nim = _nim.text;
    final langkah = _pilihan.entries
        .map((e) => TxLangkah(
              '${_namaPerKode[e.key] ?? e.key} × ${e.value}',
              () => svc.pinjamAlat(e.key, nim, e.value),
            ))
        .toList();

    setState(() => _sibuk = true);
    final ok = await jalankanTransaksi(
      context,
      judul: 'Mencatat peminjaman',
      langkah: langkah,
    );
    if (!mounted) return;
    setState(() => _sibuk = false);

    if (ok) {
      _nama.clear();
      _nim.clear();
    }
    // Muat ulang stok, juga saat gagal (bisa jadi sebagian transaksi sukses)
    _muatUlang();
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<Alat>>(
      future: _future,
      builder: (context, snap) {
        if (snap.connectionState != ConnectionState.done) {
          return const Center(child: CircularProgressIndicator());
        }
        if (snap.hasError) {
          return Center(
            child: StateView(
              ikon: Icons.cloud_off,
              judul: 'Gagal memuat data alat',
              pesan: 'Periksa koneksi internet, lalu coba lagi.',
              labelTombol: 'Coba lagi',
              onTombol: _muatUlang,
            ),
          );
        }
        final semua = snap.data!;
        for (final a in semua) {
          _namaPerKode[a.kode] = a.nama;
        }
        final alatTersedia = semua.where((a) => a.tersedia > 0).toList();
        if (alatTersedia.isEmpty) {
          return const Center(
            child: StateView(
              ikon: Icons.inventory_2_outlined,
              judul: 'Tidak ada alat yang tersedia',
              pesan: 'Semua alat sedang dipinjam atau belum didaftarkan.',
            ),
          );
        }
        return _formulir(alatTersedia);
      },
    );
  }

  Widget _formulir(List<Alat> alatTersedia) {
    return Center(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 600),
        child: Form(
          key: _formKey,
          child: ListView(
            padding: const EdgeInsets.all(16),
            children: [
              const Text('Form Peminjaman',
                  style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
              const SizedBox(height: 16),
              TextFormField(
                controller: _nama,
                decoration: const InputDecoration(
                    labelText: 'Nama peminjam', border: OutlineInputBorder()),
                validator: (v) =>
                    (v == null || v.trim().isEmpty) ? 'Nama wajib diisi' : null,
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _nim,
                keyboardType: TextInputType.number,
                inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                decoration: const InputDecoration(
                    labelText: 'NIM', border: OutlineInputBorder()),
                validator: (v) =>
                    (v == null || v.trim().isEmpty) ? 'NIM wajib diisi' : null,
              ),
              const SizedBox(height: 20),
              const Text('Pilih alat dan jumlah unit',
                  style: TextStyle(fontWeight: FontWeight.w600)),
              const SizedBox(height: 4),
              for (final a in alatTersedia)
                _barisAlat(a.kode, a.nama, a.tersedia),
              if (_errorAlat != null)
                Padding(
                  padding: const EdgeInsets.only(top: 4),
                  child: Text(_errorAlat!,
                      style: TextStyle(
                          color: Theme.of(context).colorScheme.error)),
                ),
              const SizedBox(height: 16),
              const TextField(
                enabled: false,
                decoration: InputDecoration(
                    labelText: 'Waktu pinjam',
                    hintText: 'Otomatis saat dikirim',
                    border: OutlineInputBorder()),
              ),
              const SizedBox(height: 8),
              const Text(
                'NIM di-hash sebelum dikirim, nama tidak disimpan di blockchain. '
                'Setiap alat dikirim sebagai satu transaksi dan memakai biaya gas.',
                style: TextStyle(fontSize: 12),
              ),
              const SizedBox(height: 16),
              SizedBox(
                height: 48,
                child: FilledButton(
                  onPressed: _sibuk ? null : _kirim,
                  child: Text(_sibuk
                      ? 'Memproses…'
                      : 'Konfirmasi & Catat On-Chain'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _barisAlat(String kode, String nama, int tersedia) {
    final dipilih = _pilihan.containsKey(kode);
    final jumlah = _pilihan[kode] ?? 1;
    return Row(
      children: [
        Checkbox(
          value: dipilih,
          onChanged: (v) => setState(() {
            if (v == true) {
              _pilihan[kode] = 1;
            } else {
              _pilihan.remove(kode);
            }
          }),
        ),
        Expanded(
          child: Text('$nama\nTersedia $tersedia unit',
              style: const TextStyle(fontSize: 13)),
        ),
        if (dipilih) ...[
          IconButton(
            tooltip: 'Kurangi',
            onPressed: jumlah > 1
                ? () => setState(() => _pilihan[kode] = jumlah - 1)
                : null,
            icon: const Icon(Icons.remove_circle_outline),
          ),
          Text('$jumlah',
              style:
                  const TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
          IconButton(
            tooltip: 'Tambah',
            onPressed: jumlah < tersedia
                ? () => setState(() => _pilihan[kode] = jumlah + 1)
                : null,
            icon: const Icon(Icons.add_circle_outline),
          ),
        ],
      ],
    );
  }
}