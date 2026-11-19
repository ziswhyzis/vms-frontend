import 'package:flutter/material.dart';

import '../core/theme.dart';

/// Stark Group "SG" monogram used on the sign-in panel and application shell.
class BrandMark extends StatelessWidget {
  const BrandMark({super.key, this.size = 40, this.glow = false});

  final double size;
  final bool glow;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(size * 0.28),
        gradient: const LinearGradient(
          colors: [Color(0xFF00C0F0), Color(0xFF0060F0)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        boxShadow: glow
            ? [
                BoxShadow(
                  color: StarkColors.cyan.withValues(alpha: 0.35),
                  blurRadius: size * 0.65,
                  spreadRadius: size * 0.04,
                ),
              ]
            : null,
      ),
      child: Text(
        'SG',
        style: TextStyle(
          color: Colors.white,
          fontWeight: FontWeight.w800,
          fontSize: size * 0.34,
          letterSpacing: size * 0.015,
          height: 1,
        ),
      ),
    );
  }
}

/// Mark + "Stark Group" wordmark, for dark surfaces.
class BrandWordmark extends StatelessWidget {
  const BrandWordmark({super.key, this.markSize = 38, this.compact = false});

  final double markSize;
  final bool compact;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        BrandMark(size: markSize, glow: true),
        const SizedBox(width: 12),
        Flexible(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'STARK GROUP',
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w800,
                  fontSize: compact ? 13 : 15,
                  letterSpacing: compact ? 1.6 : 2.2,
                  height: 1.1,
                ),
              ),
              const SizedBox(height: 3),
              Text(
                compact ? 'VEHICLE MANAGEMENT' : 'VEHICLE MANAGEMENT SYSTEM',
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  color: StarkColors.cyan.withValues(alpha: 0.9),
                  fontWeight: FontWeight.w600,
                  fontSize: compact ? 8.5 : 9.5,
                  letterSpacing: compact ? 1.2 : 1.6,
                  height: 1.1,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
