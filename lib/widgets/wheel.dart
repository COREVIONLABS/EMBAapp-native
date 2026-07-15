import 'dart:math' as math;
import 'package:flutter/material.dart';
import '../theme.dart';

class WheelPainter extends CustomPainter {
  final List<int> prizes;
  WheelPainter(this.prizes);

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2;
    final n = prizes.length;
    final sweep = 2 * math.pi / n;
    final colors = [AppColors.navy, AppColors.blue];

    for (int i = 0; i < n; i++) {
      final paint = Paint()..color = colors[i % 2]..style = PaintingStyle.fill;
      final start = i * sweep;
      canvas.drawArc(Rect.fromCircle(center: center, radius: radius), start, sweep, true, paint);
    }

    // segment dividers
    final divider = Paint()
      ..color = Colors.white.withOpacity(0.25)
      ..strokeWidth = 2
      ..style = PaintingStyle.stroke;
    for (int i = 0; i < n; i++) {
      final a = i * sweep;
      canvas.drawLine(center, center + Offset(math.cos(a) * radius, math.sin(a) * radius), divider);
    }

    // labels
    for (int i = 0; i < n; i++) {
      final a = i * sweep + sweep / 2;
      final tp = TextPainter(
        text: TextSpan(
          text: '${prizes[i]}',
          style: TextStyle(
            color: i % 2 == 0 ? AppColors.gold : Colors.white,
            fontWeight: FontWeight.w800,
            fontSize: 20,
          ),
        ),
        textDirection: TextDirection.ltr,
      )..layout();
      canvas.save();
      canvas.translate(center.dx, center.dy);
      canvas.rotate(a);
      canvas.translate(radius * 0.60, 0);
      canvas.rotate(math.pi / 2);
      tp.paint(canvas, Offset(-tp.width / 2, -tp.height / 2));
      canvas.restore();
    }

    // outer ring
    canvas.drawCircle(center, radius - 1, Paint()
      ..color = AppColors.gold
      ..style = PaintingStyle.stroke
      ..strokeWidth = 6);

    // hub
    canvas.drawCircle(center, radius * 0.12, Paint()..color = Colors.white);
    canvas.drawCircle(center, radius * 0.12, Paint()
      ..color = AppColors.gold
      ..style = PaintingStyle.stroke
      ..strokeWidth = 4);
  }

  @override
  bool shouldRepaint(covariant WheelPainter oldDelegate) => false;
}
