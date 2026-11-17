import '../models/alat.dart';
import '../models/dummy_data.dart';
import '../models/peminjaman.dart';

// Sementara mengembalikan data dummy.
// Di Tahap E, isi dua fungsi ini diganti pembacaan dari kontrak.
class DataRepository {
  // Saklar untuk menguji tampilan. Kembalikan ke false setelah dites.
  static bool simulasiError = false;
  static bool simulasiKosong = false;

  static Future<List<Alat>> ambilAlat() async {
    await Future.delayed(const Duration(milliseconds: 800));
    if (simulasiError) throw Exception('Gagal terhubung ke jaringan');
    if (simulasiKosong) return [];
    return List.of(dummyAlat);
  }

  static Future<List<Peminjaman>> ambilPeminjaman() async {
    await Future.delayed(const Duration(milliseconds: 800));
    if (simulasiError) throw Exception('Gagal terhubung ke jaringan');
    if (simulasiKosong) return [];
    return List.of(dummyPeminjaman);
  }
}