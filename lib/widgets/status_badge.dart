import 'package:flutter/material.dart';

import '../core/theme.dart';
import '../models/vehicle.dart';

class StatusBadge extends StatelessWidget {
  const StatusBadge({super.key, required this.status});

  final VehicleStatus status;

  @override
  Widget build(BuildContext context) {
    final (Color background, Color foreground) = switch (status) {
      VehicleStatus.active => (const Color(0xFFEAF8E3), const Color(0xFF2C7A1D)),
      VehicleStatus.inactive => (const Color(0xFFEEF1F5), const Color(0xFF5B6B80)),
      VehicleStatus.maintenance => (const Color(0xFFFFF3DC), const Color(0xFF9A6207)),
    };

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: background,
        borderRadius: BorderRadius.circular(999),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 6,
            height: 6,
            decoration: BoxDecoration(color: foreground, shape: BoxShape.circle),
          ),
          const SizedBox(width: 6),
          Text(
            status.label,
            style: TextStyle(
              fontSize: 11.5,
              fontWeight: FontWeight.w700,
              color: foreground,
              letterSpacing: 0.2,
            ),
          ),
        ],
      ),
    );
  }
}

class TypeChip extends StatelessWidget {
  const TypeChip({super.key, required this.type});

  final VehicleType type;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 4),
      decoration: BoxDecoration(
        color: StarkColors.navy.withValues(alpha: 0.06),
        borderRadius: BorderRadius.circular(6),
      ),
      child: Text(
        type.label,
        style: const TextStyle(
          fontSize: 11.5,
          fontWeight: FontWeight.w600,
          color: StarkColors.navySoft,
          letterSpacing: 0.4,
        ),
      ),
    );
  }
}
