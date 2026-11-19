// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

contract PinjaminDong {

    struct Alat {
        string kodeAlat;
        string namaAlat;
        uint256 stokTotal;
        uint256 sedangDipinjam;
    }

    struct Peminjaman {
        string kodeAlat;
        string kodePeminjam;      // NIM yang sudah di-hash dari aplikasi, BUKAN NIM asli
        uint256 jumlah;           // jumlah unit yang dipinjam
        uint256 waktuPinjam;
        uint256 waktuKembali;     // 0 = belum dikembalikan
        bool sudahDikembalikan;
        address pencatat;
    }

    Alat[] private daftarAlat;
    mapping(bytes32 => uint256) private indeksAlat; // indeks di daftarAlat + 1 (0 = belum terdaftar)
    Peminjaman[] private daftarPeminjaman;

    uint256 private constant MAKS_KODE = 64;
    uint256 private constant MAKS_NAMA = 100;

    event AlatDitambah(string kodeAlat, string namaAlat, uint256 stok);
    event StokDiubah(string kodeAlat, uint256 stokBaru);
    event AlatDipinjam(
        uint256 indexed id,
        string kodeAlat,
        uint256 jumlah,
        string kodePeminjam,
        address indexed pencatat
    );
    event AlatDikembalikan(uint256 indexed id, uint256 waktuKembali);

    // ---------- Kelola data alat ----------

    function tambahAlat(
        string calldata _kodeAlat,
        string calldata _namaAlat,
        uint256 _stok
    ) external {
        require(bytes(_kodeAlat).length > 0, "Kode alat harus diisi");
        require(bytes(_namaAlat).length > 0, "Nama alat harus diisi");
        require(bytes(_kodeAlat).length <= MAKS_KODE, "Kode alat terlalu panjang");
        require(bytes(_namaAlat).length <= MAKS_NAMA, "Nama alat terlalu panjang");
        require(_stok > 0, "Stok minimal 1");

        bytes32 kunci = keccak256(bytes(_kodeAlat));
        require(indeksAlat[kunci] == 0, "Kode alat sudah terdaftar");

        daftarAlat.push(Alat(_kodeAlat, _namaAlat, _stok, 0));
        indeksAlat[kunci] = daftarAlat.length;

        emit AlatDitambah(_kodeAlat, _namaAlat, _stok);
    }

    function ubahStok(string calldata _kodeAlat, uint256 _stokBaru) external {
        uint256 idx = indeksAlat[keccak256(bytes(_kodeAlat))];
        require(idx != 0, "Alat tidak terdaftar");

        Alat storage a = daftarAlat[idx - 1];
        require(_stokBaru >= a.sedangDipinjam, "Stok kurang dari yang sedang dipinjam");

        a.stokTotal = _stokBaru;
        emit StokDiubah(_kodeAlat, _stokBaru);
    }

    // ---------- Peminjaman ----------

    function pinjamAlat(
        string calldata _kodeAlat,
        string calldata _kodePeminjam,
        uint256 _jumlah
    ) external {
        require(bytes(_kodePeminjam).length > 0, "Kode peminjam harus diisi");
        require(bytes(_kodePeminjam).length <= MAKS_KODE, "Kode peminjam terlalu panjang");
        require(_jumlah > 0, "Jumlah minimal 1");

        uint256 idx = indeksAlat[keccak256(bytes(_kodeAlat))];
        require(idx != 0, "Alat tidak terdaftar");

        Alat storage a = daftarAlat[idx - 1];
        require(a.stokTotal - a.sedangDipinjam >= _jumlah, "Stok tidak cukup");

        a.sedangDipinjam += _jumlah;

        daftarPeminjaman.push(
            Peminjaman({
                kodeAlat: _kodeAlat,
                kodePeminjam: _kodePeminjam,
                jumlah: _jumlah,
                waktuPinjam: block.timestamp,
                waktuKembali: 0,
                sudahDikembalikan: false,
                pencatat: msg.sender
            })
        );

        emit AlatDipinjam(
            daftarPeminjaman.length - 1,
            _kodeAlat,
            _jumlah,
            _kodePeminjam,
            msg.sender
        );
    }

    function kembalikanAlat(uint256 _id) external {
        require(_id < daftarPeminjaman.length, "Data tidak ditemukan");

        Peminjaman storage p = daftarPeminjaman[_id];
        require(!p.sudahDikembalikan, "Alat sudah dikembalikan");

        p.waktuKembali = block.timestamp;
        p.sudahDikembalikan = true;

        uint256 idx = indeksAlat[keccak256(bytes(p.kodeAlat))];
        daftarAlat[idx - 1].sedangDipinjam -= p.jumlah;

        emit AlatDikembalikan(_id, block.timestamp);
    }

    // ---------- Fungsi baca (view, gratis) ----------

    function jumlahJenisAlat() external view returns (uint256) {
        return daftarAlat.length;
    }

    // Urutan return: 0 kodeAlat, 1 namaAlat, 2 stokTotal, 3 sedangDipinjam, 4 tersedia
    function ambilAlat(uint256 _indeks)
        external
        view
        returns (string memory, string memory, uint256, uint256, uint256)
    {
        require(_indeks < daftarAlat.length, "Alat tidak ditemukan");
        Alat memory a = daftarAlat[_indeks];
        return (a.kodeAlat, a.namaAlat, a.stokTotal, a.sedangDipinjam, a.stokTotal - a.sedangDipinjam);
    }

    function jumlahPeminjaman() external view returns (uint256) {
        return daftarPeminjaman.length;
    }

    // Urutan return: 0 kodeAlat, 1 kodePeminjam, 2 jumlah, 3 waktuPinjam,
    // 4 waktuKembali, 5 sudahDikembalikan, 6 pencatat
    function ambilPeminjaman(uint256 _id)
        external
        view
        returns (string memory, string memory, uint256, uint256, uint256, bool, address)
    {
        require(_id < daftarPeminjaman.length, "Data tidak ditemukan");
        Peminjaman memory d = daftarPeminjaman[_id];
        return (d.kodeAlat, d.kodePeminjam, d.jumlah, d.waktuPinjam, d.waktuKembali, d.sudahDikembalikan, d.pencatat);
    }
}