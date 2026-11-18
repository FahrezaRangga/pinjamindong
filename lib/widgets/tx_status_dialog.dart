import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:url_launcher/url_launcher.dart';
import '../config/app_config.dart';
import '../services/blockchain_service.dart';
import '../services/pesan_error.dart';

enum FaseTx { memproses, berhasil, gagal }

// Satu langkah transaksi: label untuk ditampilkan + fungsi yang mengirimnya
class TxLangkah {
  final String label;
  final Future<String> Function() kirim;
  const TxLangkah(this.label, this.kirim);
}

class _TxState {
  final FaseTx fase;
  final String pesan;
  final List<String> hashes;
  const _TxState(this.fase, this.pesan, [this.hashes = const []]);
}

// Menjalankan transaksi satu per satu (menunggu receipt tiap transaksi
// supaya nonce tidak bentrok) sambil menampilkan dialog status.
// Mengembalikan true jika SEMUA transaksi berhasil.
Future<bool> jalankanTransaksi(
  BuildContext context, {
  required String judul,
  required List<TxLangkah> langkah,
}) async {
  final state = ValueNotifier<_TxState>(
      const _TxState(FaseTx.memproses, 'Menyiapkan transaksi…'));
  final dialog = showDialog<void>(
    context: context,
    barrierDismissible: false,
    builder: (_) => _TxDialog(judul: judul, state: state),
  );

  final hashes = <String>[];
  var sukses = false;
  try {
    for (var i = 0; i < langkah.length; i++) {
      final awalan = langkah.length > 1
          ? 'Transaksi ${i + 1} dari ${langkah.length}\n'
          : '';
      final label = langkah[i].label;

      state.value = _TxState(
          FaseTx.memproses, '$awalan$label\nMengirim ke jaringan…', hashes);
      final tx = await langkah[i].kirim();

      state.value = _TxState(FaseTx.memproses,
          '$awalan$label\nMenunggu konfirmasi blok (±15 detik)…', hashes);
      final ok = await BlockchainService.instance.tungguReceipt(tx);
      if (!ok) throw Exception('Transaksi ditolak oleh kontrak');
      hashes.add(tx);
    }
    state.value = _TxState(
        FaseTx.berhasil, 'Transaksi berhasil dicatat di blockchain.', hashes);
    sukses = true;
  } catch (e) {
    state.value = _TxState(FaseTx.gagal, pesanRamah(e), hashes);
  }

  await dialog; // menunggu pengguna menutup dialog
  state.dispose();
  return sukses;
}

class _TxDialog extends StatelessWidget {
  final String judul;
  final ValueNotifier<_TxState> state;
  const _TxDialog({required this.judul, required this.state});

  String _singkat(String h) =>
      h.length > 18 ? '${h.substring(0, 10)}…${h.substring(h.length - 6)}' : h;

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      child: ValueListenableBuilder<_TxState>(
        valueListenable: state,
        builder: (context, s, _) {
          final memproses = s.fase == FaseTx.memproses;
          return AlertDialog(
            title: Text(judul),
            content: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      if (memproses)
                        const SizedBox(
                            width: 24,
                            height: 24,
                            child: CircularProgressIndicator(strokeWidth: 3))
                      else if (s.fase == FaseTx.berhasil)
                        Icon(Icons.check_circle,
                            color: Colors.green.shade700, size: 28)
                      else
                        Icon(Icons.error, color: Colors.red.shade700, size: 28),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          memproses
                              ? s.pesan
                              : (s.fase == FaseTx.berhasil
                                  ? 'Berhasil\n${s.pesan}'
                                  : 'Gagal\n${s.pesan}'),
                        ),
                      ),
                    ],
                  ),
                  if (!memproses && s.hashes.isNotEmpty) ...[
                    const SizedBox(height: 12),
                    Text(
                        s.fase == FaseTx.gagal
                            ? 'Transaksi yang sudah berhasil:'
                            : 'Hash transaksi:',
                        style: const TextStyle(fontWeight: FontWeight.w600)),
                    for (final h in s.hashes)
                      Row(
                        children: [
                          Expanded(
                              child: Text(_singkat(h),
                                  style: const TextStyle(fontSize: 13))),
                          TextButton(
                            onPressed: () {
                              Clipboard.setData(ClipboardData(text: h));
                              ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                      content: Text('Hash disalin')));
                            },
                            child: const Text('Salin'),
                          ),
                          TextButton(
                            onPressed: () => launchUrl(
                                Uri.parse('${AppConfig.etherscanTx}$h'),
                                mode: LaunchMode.externalApplication),
                            child: const Text('Etherscan'),
                          ),
                        ],
                      ),
                  ],
                ],
              ),
            ),
            actions: [
              if (!memproses)
                FilledButton(
                  onPressed: () => Navigator.of(context).pop(),
                  child: const Text('Tutup'),
                ),
            ],
          );
        },
      ),
    );
  }
}