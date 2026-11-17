import 'package:flutter/material.dart';

class TentangScreen extends StatelessWidget {
  const TentangScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 700),
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            const Text('Tentang PinjaminDong',
                style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
            const SizedBox(height: 12),
            _kartu('Proyek',
                'PinjaminDong adalah logbook peminjaman alat Lab IoT yang datanya disimpan di smart contract, bukan di server. Riwayat tidak bisa diubah diam-diam dan bisa diperiksa lewat Etherscan.'),
            _kartu('Teknologi',
                'Flutter untuk antarmuka, web3dart untuk menghubungkan ke blockchain, Solidity untuk smart contract, Remix IDE untuk deploy, dan jaringan uji Sepolia.'),
          ],
        ),
      ),
    );
  }

  Widget _kartu(String judul, String isi) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(judul,
                style:
                    const TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
            const SizedBox(height: 6),
            Text(isi),
          ],
        ),
      ),
    );
  }
}