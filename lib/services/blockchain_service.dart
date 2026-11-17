import 'package:flutter/services.dart';
import 'package:http/http.dart';
import 'package:wallet/wallet.dart';
import 'package:web3dart/web3dart.dart';
import '../config/app_config.dart';
import '../models/alat.dart';
import '../models/peminjaman.dart';

class BlockchainService {
  BlockchainService._();
  static final BlockchainService instance = BlockchainService._();

  Web3Client? _client;
  DeployedContract? _contract;

  // Menyiapkan koneksi sekali saja, dipakai ulang oleh semua halaman
  Future<void> _siap() async {
    if (_contract != null) return;
    final client = Web3Client(AppConfig.rpcUrl, Client());
    final abi = await rootBundle.loadString('assets/abi/PinjaminDong.json');
    _client = client;
    _contract = DeployedContract(
      ContractAbi.fromJson(abi, 'PinjaminDong'),
      EthereumAddress.fromHex(AppConfig.contractAddress),
    );
  }

  Future<List> _baca(String fn, [List params = const []]) async {
    await _siap();
    return _client!.call(
      contract: _contract!,
      function: _contract!.function(fn),
      params: params,
    );
  }

  int _int(Object? v) => (v as BigInt).toInt();

  // Waktu di kontrak dalam DETIK, Dart butuh milidetik
  DateTime _waktu(int detik) =>
      DateTime.fromMillisecondsSinceEpoch(detik * 1000);

  // ---------- Alat ----------
  Future<List<Alat>> semuaAlat() async {
    final n = _int((await _baca('jumlahJenisAlat')).first);
    final tugas = <Future<Alat>>[];
    for (var i = 0; i < n; i++) {
      tugas.add(_alatKe(i));
    }
    return Future.wait(tugas);
  }

  Future<Alat> _alatKe(int i) async {
    final r = await _baca('ambilAlat', [BigInt.from(i)]);
    return Alat(
      kode: r[0] as String,
      nama: r[1] as String,
      stokTotal: _int(r[2]),
      dipinjam: _int(r[3]),
    );
  }

  // ---------- Peminjaman ----------
  Future<List<Peminjaman>> semuaPeminjaman() async {
    final n = _int((await _baca('jumlahPeminjaman')).first);
    final tugas = <Future<Peminjaman>>[];
    for (var i = 0; i < n; i++) {
      tugas.add(_peminjamanKe(i));
    }
    final hasil = await Future.wait(tugas);
    return hasil.reversed.toList(); // terbaru di atas
  }

  Future<Peminjaman> _peminjamanKe(int i) async {
    final r = await _baca('ambilPeminjaman', [BigInt.from(i)]);
    final kembali = _int(r[4]);
    return Peminjaman(
      id: i,
      kodeAlat: r[0] as String,
      kodePeminjam: r[1] as String,
      jumlah: _int(r[2]),
      waktuPinjam: _waktu(_int(r[3])),
      waktuKembali: kembali == 0 ? null : _waktu(kembali),
      sudahDikembalikan: r[5] as bool,
      pencatat: r[6].toString(),
    );
  }
}