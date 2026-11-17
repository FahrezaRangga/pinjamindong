import '../models/alat.dart';
import '../models/dummy_data.dart';
import '../models/peminjaman.dart';
import 'blockchain_service.dart';

class DataRepository {
  // true = pakai data dummy, false = baca dari kontrak di Sepolia
  static bool pakaiDummy = false;

  // Saklar untuk menguji tampilan. Kembalikan ke false setelah dites.
  static bool simulasiError = false;
  static bool simulasiKosong = false;

  static Future<List<Alat>> ambilAlat() async {
    if (simulasiError) throw Exception('Gagal terhubung ke jaringan');
    if (simulasiKosong) return [];
    if (pakaiDummy) {
      await Future.delayed(const Duration(milliseconds: 800));
      return List.of(dummyAlat);
    }
    return BlockchainService.instance.semuaAlat();
  }

  static Future<List<Peminjaman>> ambilPeminjaman() async {
    if (simulasiError) throw Exception('Gagal terhubung ke jaringan');
    if (simulasiKosong) return [];
    if (pakaiDummy) {
      await Future.delayed(const Duration(milliseconds: 800));
      return List.of(dummyPeminjaman);
    }
    return BlockchainService.instance.semuaPeminjaman();
  }
}