import 'package:flutter/material.dart';

import '../core/theme.dart';

/// Full-window cream field with a seamless square grid.
/// Each 120px cell has both diagonals, so neighboring cells form a diamond lattice.
class LatticeScaffold extends StatelessWidget {
  const LatticeScaffold({
    super.key,
    required this.body,
    this.drawer,
  });

  final Widget body;
  final Widget? drawer;

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        const Positioned.fill(
          child: IgnorePointer(
            child: CustomPaint(
              painter: LatticePainter(),
              child: SizedBox.expand(),
            ),
          ),
        ),
        Scaffold(
          backgroundColor: Colors.transparent,
          drawer: drawer,
          body: body,
        ),
      ],
    );
  }
}

class LatticePainter extends CustomPainter {
  const LatticePainter();

  static const double cell = 120;

  @override
  void paint(Canvas canvas, Size size) {
    // Paint the cream field here so the lattice is the page background on every
    // platform, not only where a browser body colour happens to show through.
    canvas.drawRect(Offset.zero & size, Paint()..color = StarkColors.cream);

    final grid = Paint()
      ..color = StarkColors.lattice
      ..strokeWidth = 1
      ..style = PaintingStyle.stroke
      ..isAntiAlias = false;

    final diagonal = Paint()
      ..color = StarkColors.lattice
      ..strokeWidth = 1
      ..style = PaintingStyle.stroke;

    final columns = (size.width / cell).ceil();
    final rows = (size.height / cell).ceil();

    // Half-pixel centres keep the 1px lines solid instead of softly spread
    // over two pixels.
    for (var column = 0; column <= columns; column++) {
      final x = column * cell + 0.5;
      canvas.drawLine(Offset(x, 0), Offset(x, size.height), grid);
    }
    for (var row = 0; row <= rows; row++) {
      final y = row * cell + 0.5;
      canvas.drawLine(Offset(0, y), Offset(size.width, y), grid);
    }
    for (var row = 0; row < rows; row++) {
      final y = row * cell + 0.5;
      for (var column = 0; column < columns; column++) {
        final x = column * cell + 0.5;
        canvas.drawLine(Offset(x, y), Offset(x + cell, y + cell), diagonal);
        canvas.drawLine(Offset(x + cell, y), Offset(x, y + cell), diagonal);
      }
    }
  }

  @override
  bool shouldRepaint(covariant LatticePainter oldDelegate) => false;
}
