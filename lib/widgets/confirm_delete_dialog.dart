import 'package:flutter/material.dart';

import '../core/theme.dart';
import '../models/vehicle.dart';

class ConfirmDeleteDialog extends StatelessWidget {
  const ConfirmDeleteDialog({super.key, required this.vehicle});

  final Vehicle vehicle;

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      titlePadding: const EdgeInsets.fromLTRB(24, 24, 24, 0),
      contentPadding: const EdgeInsets.fromLTRB(24, 16, 24, 8),
      title: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: StarkColors.red.withValues(alpha: 0.10),
              borderRadius: BorderRadius.circular(9),
            ),
            child: const Icon(Icons.delete_outline, size: 20, color: StarkColors.red),
          ),
          const SizedBox(width: 12),
          const Text('Delete vehicle?', style: TextStyle(fontSize: 19, fontWeight: FontWeight.w700, color: StarkColors.ink)),
        ],
      ),
      content: SizedBox(
        width: 400,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'This permanently removes the vehicle from the Stark Group register.',
              style: TextStyle(fontSize: 13.5, color: StarkColors.inkMuted, height: 1.5),
            ),
            const SizedBox(height: 18),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: StarkColors.canvas,
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: StarkColors.line),
              ),
              child: Row(
                children: [
                  const Icon(Icons.directions_car_filled, size: 20, color: StarkColors.cyanDeep),
                  const SizedBox(width: 12),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        vehicle.vehicleNumber,
                        style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 14, color: StarkColors.ink, letterSpacing: 0.4),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        '${vehicle.brandAndModel} · ${vehicle.type.label}',
                        style: const TextStyle(fontSize: 12, color: StarkColors.inkMuted),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 14),
            const Text(
              'This action cannot be undone.',
              style: TextStyle(fontSize: 12, color: StarkColors.red, fontWeight: FontWeight.w600),
            ),
          ],
        ),
      ),
      actionsPadding: const EdgeInsets.fromLTRB(24, 8, 24, 20),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(false),
          child: const Text('Cancel'),
        ),
        FilledButton(
          key: const Key('delete.confirm'),
          style: FilledButton.styleFrom(backgroundColor: StarkColors.red),
          onPressed: () => Navigator.of(context).pop(true),
          child: const Text('Delete vehicle'),
        ),
      ],
    );
  }
}
