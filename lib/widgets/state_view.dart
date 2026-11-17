import 'package:flutter/material.dart';

// Tampilan untuk kondisi kosong atau error
class StateView extends StatelessWidget {
  final IconData ikon;
  final String judul;
  final String? pesan;
  final String? labelTombol;
  final VoidCallback? onTombol;

  const StateView({
    super.key,
    required this.ikon,
    required this.judul,
    this.pesan,
    this.labelTombol,
    this.onTombol,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(ikon, size: 56, color: Theme.of(context).colorScheme.primary),
          const SizedBox(height: 12),
          Text(judul,
              textAlign: TextAlign.center,
              style:
                  const TextStyle(fontSize: 18, fontWeight: FontWeight.w600)),
          if (pesan != null) ...[
            const SizedBox(height: 6),
            Text(pesan!, textAlign: TextAlign.center),
          ],
          if (labelTombol != null) ...[
            const SizedBox(height: 16),
            FilledButton(onPressed: onTombol, child: Text(labelTombol!)),
          ],
        ],
      ),
    );
  }
}

// Membuat isi tetap bisa ditarik untuk refresh walaupun hanya berisi satu pesan
class ScrollableCenter extends StatelessWidget {
  final Widget child;
  const ScrollableCenter({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, box) => ListView(
        physics: const AlwaysScrollableScrollPhysics(),
        children: [
          SizedBox(height: box.maxHeight, child: Center(child: child)),
        ],
      ),
    );
  }
}