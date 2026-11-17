class Alat {
  final String kode;
  final String nama;
  final int stokTotal;
  final int dipinjam;

  const Alat({
    required this.kode,
    required this.nama,
    required this.stokTotal,
    required this.dipinjam,
  });

  int get tersedia => stokTotal - dipinjam;
}