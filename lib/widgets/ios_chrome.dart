import 'dart:math' as math;
import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

/// iOS status bar (9:41 + cellular / wifi / battery), 1:1 with the Figma frames.
class IOSStatusBar extends StatelessWidget {
  final Color color;
  final String time;
  const IOSStatusBar({super.key, this.color = AppColors.black, this.time = '9:41'});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 44,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 18),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Text(time,
                style: TextStyle(
                    fontFamily: 'Urbanist',
                    fontWeight: FontWeight.w700,
                    fontSize: 15,
                    letterSpacing: -0.3,
                    color: color)),
            Row(
              children: [
                CustomPaint(size: const Size(18, 11), painter: _CellularPainter(color)),
                const SizedBox(width: 6),
                CustomPaint(size: const Size(16, 11), painter: _WifiPainter(color)),
                const SizedBox(width: 6),
                CustomPaint(size: const Size(25, 12), painter: _BatteryPainter(color)),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _CellularPainter extends CustomPainter {
  final Color color;
  _CellularPainter(this.color);
  @override
  void paint(Canvas canvas, Size size) {
    final p = Paint()..color = color;
    const bars = 4;
    final barW = size.width / (bars * 2 - 1);
    for (var i = 0; i < bars; i++) {
      final h = size.height * (0.45 + i * 0.183);
      final x = i * barW * 2;
      final r = RRect.fromRectAndRadius(
          Rect.fromLTWH(x, size.height - h, barW, h), const Radius.circular(1));
      canvas.drawRRect(r, p);
    }
  }

  @override
  bool shouldRepaint(covariant _CellularPainter old) => old.color != color;
}

class _WifiPainter extends CustomPainter {
  final Color color;
  _WifiPainter(this.color);
  @override
  void paint(Canvas canvas, Size size) {
    final p = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;
    final center = Offset(size.width / 2, size.height);
    for (var i = 0; i < 3; i++) {
      p.strokeWidth = 1.6;
      final radius = size.width / 2 * (0.42 + i * 0.29);
      canvas.drawArc(Rect.fromCircle(center: center, radius: radius), math.pi * 1.25,
          math.pi * 0.5, false, p);
    }
    canvas.drawCircle(center, 0.9, Paint()..color = color);
  }

  @override
  bool shouldRepaint(covariant _WifiPainter old) => old.color != color;
}

class _BatteryPainter extends CustomPainter {
  final Color color;
  _BatteryPainter(this.color);
  @override
  void paint(Canvas canvas, Size size) {
    final body = RRect.fromRectAndRadius(
        Rect.fromLTWH(0, 0, size.width - 3, size.height), const Radius.circular(3));
    canvas.drawRRect(body, Paint()..color = color.withValues(alpha: 0.35)..style = PaintingStyle.stroke..strokeWidth = 1);
    // nub
    canvas.drawRRect(
        RRect.fromRectAndRadius(Rect.fromLTWH(size.width - 2, size.height * 0.3, 2, size.height * 0.4),
            const Radius.circular(1)),
        Paint()..color = color.withValues(alpha: 0.4));
    // fill
    canvas.drawRRect(
        RRect.fromRectAndRadius(
            Rect.fromLTWH(1.5, 1.5, (size.width - 3 - 3), size.height - 3), const Radius.circular(1.5)),
        Paint()..color = color);
  }

  @override
  bool shouldRepaint(covariant _BatteryPainter old) => old.color != color;
}

/// iOS home indicator bar.
class HomeIndicator extends StatelessWidget {
  final Color color;
  const HomeIndicator({super.key, this.color = AppColors.black});
  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 34,
      child: Center(
        child: Container(
          width: 134,
          height: 5,
          decoration: BoxDecoration(color: color, borderRadius: BorderRadius.circular(3)),
        ),
      ),
    );
  }
}
