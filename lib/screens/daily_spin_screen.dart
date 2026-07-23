import 'dart:math' as math;
import 'package:flutter/material.dart';
import '../theme/app_theme.dart';
import '../widgets/app_widgets.dart';
import '../widgets/sub_scaffold.dart';

/// Daily Spin (Figma 401:2605 / reward / already spun).
class DailySpinScreen extends StatefulWidget {
  const DailySpinScreen({super.key});
  @override
  State<DailySpinScreen> createState() => _DailySpinScreenState();
}

class _DailySpinScreenState extends State<DailySpinScreen> with SingleTickerProviderStateMixin {
  late final AnimationController _c = AnimationController(vsync: this, duration: const Duration(milliseconds: 3200));
  late Animation<double> _anim = const AlwaysStoppedAnimation(0);
  bool _spun = false;
  final _labels = ['25', '50', '10', '100', '5', '75', '20', '250'];

  void _spin() {
    if (_c.isAnimating || _spun) return;
    final target = 5 * 2 * math.pi + (math.pi / 4) * 3; // land on a segment
    _anim = Tween<double>(begin: 0, end: target).animate(CurvedAnimation(parent: _c, curve: Curves.easeOutCubic));
    _c.forward(from: 0).whenComplete(() => setState(() => _spun = true));
    setState(() {});
  }

  @override
  void dispose() {
    _c.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SubScaffold(
      title: 'Daily Spin',
      children: [
        const SizedBox(height: 8),
        Text('Spin to win Fan Points', textAlign: TextAlign.center, style: AppText.h4),
        const SizedBox(height: 6),
        Text('One free spin every day', textAlign: TextAlign.center, style: AppText.body1.copyWith(color: AppColors.textLight)),
        const SizedBox(height: 32),
        SizedBox(
          height: 300,
          child: Stack(
            alignment: Alignment.center,
            children: [
              AnimatedBuilder(
                animation: _anim,
                builder: (_, _) => Transform.rotate(
                  angle: _anim.value,
                  child: CustomPaint(size: const Size(280, 280), painter: _WheelPainter(_labels)),
                ),
              ),
              Positioned(
                top: 0,
                child: Icon(Icons.arrow_drop_down_rounded, size: 48, color: AppColors.gold),
              ),
              Container(
                width: 56,
                height: 56,
                decoration: const BoxDecoration(shape: BoxShape.circle, color: AppColors.white),
                child: const Center(child: Svg('logo_s04', size: 40)),
              ),
            ],
          ),
        ),
        const SizedBox(height: 32),
        if (_spun)
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(color: AppColors.successBg, borderRadius: BorderRadius.circular(AppRadii.tile)),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.celebration_rounded, color: AppColors.success),
                const SizedBox(width: 10),
                Text('You won +100 points!', style: AppText.label2.copyWith(color: AppColors.success)),
              ],
            ),
          )
        else
          PrimaryButton('Spin Now', onTap: _spin),
      ],
    );
  }
}

class _WheelPainter extends CustomPainter {
  final List<String> labels;
  _WheelPainter(this.labels);
  @override
  void paint(Canvas canvas, Size size) {
    final center = size.center(Offset.zero);
    final radius = size.width / 2;
    final n = labels.length;
    final sweep = 2 * math.pi / n;
    const colors = [AppColors.brandPrimary, AppColors.brandDark];
    for (var i = 0; i < n; i++) {
      final paint = Paint()..color = colors[i % 2];
      final start = -math.pi / 2 + i * sweep;
      canvas.drawArc(Rect.fromCircle(center: center, radius: radius), start, sweep, true, paint);
      // label
      final tp = TextPainter(
        text: TextSpan(
            text: labels[i],
            style: const TextStyle(fontFamily: 'Urbanist', fontSize: 16, fontWeight: FontWeight.w700, color: Colors.white)),
        textDirection: TextDirection.ltr,
      )..layout();
      final ang = start + sweep / 2;
      final off = Offset(center.dx + math.cos(ang) * radius * 0.62 - tp.width / 2,
          center.dy + math.sin(ang) * radius * 0.62 - tp.height / 2);
      tp.paint(canvas, off);
    }
    canvas.drawCircle(center, radius, Paint()..color = AppColors.gold..style = PaintingStyle.stroke..strokeWidth = 6);
  }

  @override
  bool shouldRepaint(covariant _WheelPainter old) => false;
}
