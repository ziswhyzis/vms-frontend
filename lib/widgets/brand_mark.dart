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
        borderRadius: BorderRadius.circular(size * 0.22),
        gradient: const LinearGradient(
          colors: [StarkColors.sage, StarkColors.teal],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        boxShadow: glow
            ? [
                BoxShadow(
                  color: StarkColors.teal.withValues(alpha: 0.22),
                  blurRadius: size * 0.45,
                  spreadRadius: 0,
                ),
              ]
            : null,
      ),
      child: Text(
        'SG',
        style: TextStyle(
          color: StarkColors.cream,
          fontFamily: 'Nunito',
          fontWeight: FontWeight.w800,
          fontSize: size * 0.34,
          letterSpacing: size * 0.01,
          height: 1,
        ),
      ),
    );
  }
}

/// Mark plus the Stark Group name, for the light workbench surfaces.
class BrandWordmark extends StatelessWidget {
  const BrandWordmark({super.key, this.markSize = 38, this.compact = false});

  final double markSize;
  final bool compact;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        BrandMark(size: markSize),
        const SizedBox(width: 12),
        Flexible(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'Stark Group',
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  fontFamily: 'Fraunces',
                  color: StarkColors.ink,
                  fontWeight: FontWeight.w500,
                  fontSize: compact ? 15 : 18,
                  height: 1.1,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                compact ? 'Vehicles' : 'Vehicle management',
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  fontFamily: 'Nunito',
                  color: StarkColors.tealInk,
                  fontWeight: FontWeight.w600,
                  fontSize: compact ? 11 : 12,
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
