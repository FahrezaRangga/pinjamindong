import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../models/dummy_data.dart';

class FormPinjamScreen extends StatefulWidget {
  const FormPinjamScreen({super.key});

  @override
  State<FormPinjamScreen> createState() => _FormPinjamScreenState();
}

class _FormPinjamScreenState extends State<FormPinjamScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nama = TextEditingController();
  final _nim = TextEditingController();

  // kode alat -> jumlah unit yang dipilih
  final Map<String, int> _pilihan = {};
  String? _errorAlat;

  @override
  void dispose() {
    _nama.dispose();
    _nim.dispose();
    super.dispose();
  }

  void _kirim() {
    final formOk = _formKey.currentState!.validate();
    final alatOk = _pilihan.isNotEmpty;
    setState(() => _errorAlat = alatOk ? null : 'Pilih minimal satu alat');
    if (!formOk || !alatOk) return;

    // Sementara hanya dicetak. Diganti transaksi blockchain di Tahap F.
    debugPrint('Pinjam: nim=${_nim.text} alat=$_pilihan');
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Form valid (data dummy, belum dikirim)')),
    );
  }

  @override
  Widget build(BuildContext context) {
    final alatTersedia = dummyAlat.where((a) => a.tersedia > 0).toList();

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
              for (final a in alatTersedia) _barisAlat(a.kode, a.nama, a.tersedia),
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
              const SizedBox(height: 20),
              SizedBox(
                height: 48,
                child: FilledButton(
                  onPressed: _kirim,
                  child: const Text('Konfirmasi & Catat On-Chain'),
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