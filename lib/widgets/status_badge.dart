import 'package:flutter/material.dart';

import '../core/theme.dart';
import '../models/vehicle.dart';

class StatusBadge extends StatelessWidget {
  const StatusBadge({super.key, required this.status});

  final VehicleStatus status;

  @override
  Widget build(BuildContext context) {
    final (Color background, Color foreground) = switch (status) {
      VehicleStatus.active => (StarkColors.sage.withValues(alpha: 0.38), StarkColors.sageInk),
      VehicleStatus.inactive => (StarkColors.cream, StarkColors.inkMuted),
      VehicleStatus.maintenance => (StarkColors.rose.withValues(alpha: 0.28), StarkColors.roseInk),
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
        color: StarkColors.sage.withValues(alpha: 0.28),
        borderRadius: BorderRadius.circular(6),
        border: Border.all(color: StarkColors.line),
      ),
      child: Text(
        type.label,
        style: const TextStyle(
          fontSize: 11.5,
          fontWeight: FontWeight.w700,
          color: StarkColors.tealInk,
        ),
      ),
    );
  }
}
