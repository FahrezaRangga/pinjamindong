import 'alat.dart';
import 'peminjaman.dart';

const dummyAlat = [
  Alat(kode: 'ESP32-01', nama: 'ESP32 Development Board', stokTotal: 20, dipinjam: 10),
  Alat(kode: 'ARD-MEGA-03', nama: 'Arduino Mega 2560', stokTotal: 10, dipinjam: 3),
  Alat(kode: 'SENS-DHT-05', nama: 'Sensor DHT22', stokTotal: 5, dipinjam: 5),
  Alat(kode: 'RPI-04', nama: 'Raspberry Pi 4', stokTotal: 4, dipinjam: 1),
];

final dummyPeminjaman = [
  Peminjaman(
    id: 0, kodeAlat: 'ESP32-01', kodePeminjam: 'a1b2c3d4e5f6a7b8', jumlah: 2,
    waktuPinjam: DateTime(2026, 11, 13, 9, 15), waktuKembali: null,
    sudahDikembalikan: false, pencatat: '0x71C4...9a2F',
  ),
  Peminjaman(
    id: 1, kodeAlat: 'RPI-04', kodePeminjam: '9f8e7d6c5b4a3f2e', jumlah: 1,
    waktuPinjam: DateTime(2026, 11, 12, 10, 30),
    waktuKembali: DateTime(2026, 11, 12, 15, 45),
    sudahDikembalikan: true, pencatat: '0x71C4...9a2F',
  ),
];