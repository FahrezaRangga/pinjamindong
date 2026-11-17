import 'package:flutter/material.dart';
import 'beranda_screen.dart';
import 'daftar_alat_screen.dart';
import 'datalog_screen.dart';
import 'form_pinjam_screen.dart';
import 'tentang_screen.dart';

class ShellScreen extends StatefulWidget {
  const ShellScreen({super.key});

  @override
  State<ShellScreen> createState() => _ShellScreenState();
}

class _ShellScreenState extends State<ShellScreen> {
  int _i = 0;

  static const _label = ['Beranda', 'Datalog', 'Alat', 'Pinjam', 'Tentang'];
  static const _ikon = [
    Icons.home,
    Icons.receipt_long,
    Icons.memory,
    Icons.add_circle,
    Icons.info,
  ];

  void _pindah(int v) => setState(() => _i = v);

  // Getter (bukan field) supaya bisa memakai _pindah
  List<Widget> get _halaman => [
        BerandaScreen(onPindah: _pindah),
        const DatalogScreen(),
        const DaftarAlatScreen(),
        const FormPinjamScreen(),
        const TentangScreen(),
      ];

  @override
  Widget build(BuildContext context) {
    final lebar = MediaQuery.of(context).size.width >= 800;
    return Scaffold(
      appBar: AppBar(title: const Text('PinjaminDong')),
      body: Row(
        children: [
          if (lebar)
            NavigationRail(
              selectedIndex: _i,
              onDestinationSelected: _pindah,
              labelType: NavigationRailLabelType.all,
              destinations: [
                for (var k = 0; k < 5; k++)
                  NavigationRailDestination(
                      icon: Icon(_ikon[k]), label: Text(_label[k])),
              ],
            ),
          Expanded(child: _halaman[_i]),
        ],
      ),
      bottomNavigationBar: lebar
          ? null
          : NavigationBar(
              selectedIndex: _i,
              onDestinationSelected: _pindah,
              destinations: [
                for (var k = 0; k < 5; k++)
                  NavigationDestination(icon: Icon(_ikon[k]), label: _label[k]),
              ],
            ),
    );
  }
}