import 'package:flutter/material.dart';

class StatusBadge extends StatelessWidget {
  final String label;
  final Color warnaTeks;
  final Color warnaLatar;
  final IconData? ikon;

  const StatusBadge({
    super.key,
    required this.label,
    required this.warnaTeks,
    required this.warnaLatar,
    this.ikon,
  });

  // Lencana "Dikembalikan" (hijau, dengan centang)
  factory StatusBadge.dikembalikan() => StatusBadge(
        label: 'Dikembalikan',
        warnaTeks: Colors.green.shade900,
        warnaLatar: Colors.green.shade100,
        ikon: Icons.check_circle,
      );

  // Lencana "Dipinjam" (oranye)
  factory StatusBadge.dipinjam() => StatusBadge(
        label: 'Dipinjam',
        warnaTeks: Colors.orange.shade900,
        warnaLatar: Colors.orange.shade100,
      );

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: warnaLatar,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (ikon != null) ...[
            Icon(ikon, size: 14, color: warnaTeks),
            const SizedBox(width: 4),
          ],
          Text(label,
              style: TextStyle(
                  color: warnaTeks,
                  fontWeight: FontWeight.w600,
                  fontSize: 12)),
        ],
      ),
    );
  }
}