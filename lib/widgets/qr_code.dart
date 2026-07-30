import 'dart:math';
import 'package:flutter/material.dart';

/// Deterministic QR-style graphic for the prototype (not a scannable code).
/// Draws three finder patterns + a seeded module grid so each ticket looks
/// unique and convincing without pulling in a QR dependency.
class QrCode extends StatelessWidget {
  final String data;
  final double size;
  final Color color;
  const QrCode(this.data, {super.key, this.size = 120, this.color = const Color(0xFF00132E)});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: size,
      height: size,
      child: CustomPaint(painter: _QrPainter(data, color)),
    );
  }
}

class _QrPainter extends CustomPainter {
  final String data;
  final Color color;
  _QrPainter(this.data, this.color);

  @override
  void paint(Canvas canvas, Size size) {
    const n = 21; // classic QR module count
    final cell = size.width / n;
    final p = Paint()..color = color;
    final rnd = Random(data.hashCode);

    bool inFinder(int x, int y) {
      bool corner(int ox, int oy) => x >= ox && x < ox + 7 && y >= oy && y < oy + 7;
      return corner(0, 0) || corner(n - 7, 0) || corner(0, n - 7);
    }

    // module field
    for (var y = 0; y < n; y++) {
      for (var x = 0; x < n; x++) {
        if (inFinder(x, y)) continue;
        if (rnd.nextDouble() > 0.52) {
          canvas.drawRect(Rect.fromLTWH(x * cell, y * cell, cell, cell), p);
        }
      }
    }

    // finder patterns
    void finder(int ox, int oy) {
      canvas.drawRect(Rect.fromLTWH(ox * cell, oy * cell, 7 * cell, 7 * cell), p);
      canvas.drawRect(Rect.fromLTWH((ox + 1) * cell, (oy + 1) * cell, 5 * cell, 5 * cell), Paint()..color = Colors.white);
      canvas.drawRect(Rect.fromLTWH((ox + 2) * cell, (oy + 2) * cell, 3 * cell, 3 * cell), p);
    }

    finder(0, 0);
    finder(n - 7, 0);
    finder(0, n - 7);
  }

  @override
  bool shouldRepaint(covariant _QrPainter old) => old.data != data || old.color != color;
}
