import 'dart:math' as math;
import 'package:flutter/material.dart';
import '../theme/app_theme.dart';
import '../widgets/app_widgets.dart';
import '../model/fan_model.dart';
import '../l10n/strings.dart';

/// Presents Daily Spin as a modal sheet over the current screen (Figma 2145:8385).
void showDailySpin(BuildContext context) {
  Navigator.of(context).push(PageRouteBuilder(
    opaque: false,
    barrierColor: Colors.black54,
    barrierDismissible: true,
    pageBuilder: (_, a, _) => const DailySpinScreen(),
    transitionsBuilder: (_, a, _, child) =>
        SlideTransition(position: Tween(begin: const Offset(0, 1), end: Offset.zero).animate(CurvedAnimation(parent: a, curve: Curves.easeOutCubic)), child: child),
  ));
}

class DailySpinScreen extends StatefulWidget {
  const DailySpinScreen({super.key});
  @override
  State<DailySpinScreen> createState() => _DailySpinScreenState();
}

class _DailySpinScreenState extends State<DailySpinScreen> with SingleTickerProviderStateMixin {
  late final AnimationController _c = AnimationController(vsync: this, duration: const Duration(milliseconds: 3400));
  Animation<double> _anim = const AlwaysStoppedAnimation(0);
  bool _spun = false;
  int _reward = 0;

  // Points-only wheel (no fake "Extra Spin / 25 Tickets" units). Weighted so
  // small wins are common and the jackpot is rare.
  static const _values = [20, 25, 30, 50, 75, 100, 150, 250];
  static const _labels = ['20 Points', '25 Points', '30 Points', '50 Points', '75 Points', '100 Points', '150 Points', '250 Points'];
  static const _weights = [26, 22, 18, 14, 9, 6, 3, 2]; // sums to 100

  int _rollReward() {
    var r = math.Random().nextInt(100);
    for (var i = 0; i < _weights.length; i++) {
      if (r < _weights[i]) return _values[i];
      r -= _weights[i];
    }
    return _values.first;
  }

  void _spin() {
    if (_c.isAnimating || _spun) return;
    final extra = math.Random().nextDouble() * 2 * math.pi; // vary where it stops
    _anim = Tween<double>(begin: 0, end: 6 * 2 * math.pi + extra).animate(CurvedAnimation(parent: _c, curve: Curves.easeOutCubic));
    _c.forward(from: 0).whenComplete(() {
      final reward = _rollReward();
      FanModel.addPoints(reward); // credit the balance for real
      if (mounted) setState(() { _reward = reward; _spun = true; });
    });
    setState(() {});
  }

  @override
  void dispose() {
    _c.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      body: Column(
        children: [
          Expanded(child: GestureDetector(onTap: () => Navigator.of(context).maybePop(), behavior: HitTestBehavior.opaque)),
          Container(
            width: double.infinity,
            decoration: BoxDecoration(color: AppColors.surface, borderRadius: BorderRadius.vertical(top: Radius.circular(28))),
            padding: const EdgeInsets.fromLTRB(24, 12, 24, 32),
            child: SafeArea(
              top: false,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(width: 40, height: 5, decoration: BoxDecoration(color: AppColors.surfaceLowContrast, borderRadius: BorderRadius.circular(3))),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      const Spacer(),
                      Text(tr('Daily Spin'), style: AppText.label1),
                      Expanded(
                        child: Align(
                          alignment: Alignment.centerRight,
                          child: GestureDetector(
                            onTap: () => Navigator.of(context).maybePop(),
                            child: Icon(Icons.close_rounded, color: AppColors.textLight),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(tr('Spin the wheel to win rewards!'), style: AppText.body2.copyWith(color: AppColors.textLight)),
                  const SizedBox(height: 12),
                  Pill(
                    color: AppColors.brandLightest,
                    child: Text(tr('1 Spin Left'), style: AppText.caption1.copyWith(color: AppColors.brandPrimary, fontSize: 11)),
                  ),
                  const SizedBox(height: 20),
                  SizedBox(
                    height: 290,
                    child: Stack(
                      alignment: Alignment.center,
                      children: [
                        AnimatedBuilder(
                          animation: _anim,
                          builder: (_, _) => Transform.rotate(angle: _anim.value, child: CustomPaint(size: const Size(280, 280), painter: _WheelPainter(_labels))),
                        ),
                        Positioned(top: -2, child: Icon(Icons.arrow_drop_down_rounded, size: 44, color: AppColors.gold)),
                        GestureDetector(
                          onTap: _spin,
                          child: Container(
                            width: 64,
                            height: 64,
                            decoration: const BoxDecoration(shape: BoxShape.circle, gradient: LinearGradient(colors: AppColors.goldGradient)),
                            alignment: Alignment.center,
                            child: Text(tr('SPIN'), style: AppText.caption1.copyWith(color: AppColors.brandDarkest, fontWeight: FontWeight.w800, fontSize: 13)),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 20),
                  if (_spun)
                    Container(
                      padding: const EdgeInsets.all(14),
                      decoration: BoxDecoration(color: AppColors.successBg, borderRadius: BorderRadius.circular(AppRadii.tile)),
                      child: Row(mainAxisAlignment: MainAxisAlignment.center, children: [
                        const Icon(Icons.celebration_rounded, color: AppColors.success),
                        const SizedBox(width: 10),
                        Text('${tr('You won')} +$_reward ${tr('points')}!', style: AppText.label2.copyWith(color: AppColors.success)),
                      ]),
                    )
                  else
                    PrimaryButton(tr('Spin Now'), onTap: _spin),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _WheelPainter extends CustomPainter {
  final List<String> labels;
  _WheelPainter(this.labels);
  static const _colors = [AppColors.brandPrimary, AppColors.gold, AppColors.brandDark, Color(0xFFFF8C00)];
  @override
  void paint(Canvas canvas, Size size) {
    final center = size.center(Offset.zero);
    final radius = size.width / 2;
    final n = labels.length;
    final sweep = 2 * math.pi / n;
    for (var i = 0; i < n; i++) {
      final start = -math.pi / 2 + i * sweep;
      canvas.drawArc(Rect.fromCircle(center: center, radius: radius), start, sweep, true, Paint()..color = _colors[i % _colors.length]);
      final divider = Paint()
        ..color = Colors.white.withValues(alpha: 0.35)
        ..strokeWidth = 1.5
        ..style = PaintingStyle.stroke;
      canvas.drawLine(center, center + Offset(math.cos(start) * radius, math.sin(start) * radius), divider);
      final ang = start + sweep / 2;
      final gold = _colors[i % _colors.length] == AppColors.gold;
      final tp = TextPainter(
        text: TextSpan(text: labels[i], style: TextStyle(fontFamily: 'Urbanist', fontSize: 10, fontWeight: FontWeight.w700, color: gold ? AppColors.brandDarkest : Colors.white)),
        textDirection: TextDirection.ltr,
        textAlign: TextAlign.center,
      )..layout(maxWidth: 64);
      canvas.save();
      canvas.translate(center.dx, center.dy);
      canvas.rotate(ang);
      canvas.translate(radius * 0.58, 0);
      canvas.rotate(math.pi / 2);
      tp.paint(canvas, Offset(-tp.width / 2, -tp.height / 2));
      canvas.restore();
    }
    canvas.drawCircle(center, radius, Paint()..color = AppColors.gold..style = PaintingStyle.stroke..strokeWidth = 6);
  }

  @override
  bool shouldRepaint(covariant _WheelPainter old) => false;
}
