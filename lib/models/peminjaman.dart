class Peminjaman {
  final int id;
  final String kodeAlat;
  final String kodePeminjam;
  final int jumlah;
  final DateTime waktuPinjam;
  final DateTime? waktuKembali;
  final bool sudahDikembalikan;
  final String pencatat;

  const Peminjaman({
    required this.id,
    required this.kodeAlat,
    required this.kodePeminjam,
    required this.jumlah,
    required this.waktuPinjam,
    required this.waktuKembali,
    required this.sudahDikembalikan,
    required this.pencatat,
  });
}