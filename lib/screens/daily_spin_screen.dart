import 'dart:math' as math;
import 'package:flutter/material.dart';
import '../theme/app_theme.dart';
import '../widgets/app_widgets.dart';
import '../model/fan_model.dart';
import '../model/daily_games.dart';
import '../model/voucher_store.dart';
import '../widgets/sponsor_banner.dart';
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
  int _prizeIdx = 0;

  void _spin() {
    if (_c.isAnimating || _spun) return;
    // Roll the segment first, then stop the wheel *on it* — so the pointer
    // always lands on the prize actually awarded (fairness/trust).
    final idx = rollPrizeIndex(kSpinWeights);
    const twoPi = 2 * math.pi;
    final sweep = twoPi / kSpinPrizes.length;
    final stop = (twoPi - ((idx + 0.5) * sweep) % twoPi) % twoPi;
    _anim = Tween<double>(begin: 0, end: 6 * twoPi + stop).animate(CurvedAnimation(parent: _c, curve: Curves.easeOutCubic));
    _c.forward(from: 0).whenComplete(() {
      _award(kSpinPrizes[idx]);
      if (mounted) setState(() { _prizeIdx = idx; _spun = true; });
    });
    setState(() {});
  }

  void _award(DailyPrize p) {
    switch (p.type) {
      case DailyPrizeType.points:
        FanModel.addPoints(p.points);
        break;
      case DailyPrizeType.ticket:
        voucherStore.issue(title: p.label, category: 'Tickets', points: 0, detail: tr('Won on the Daily Spin'));
        break;
      case DailyPrizeType.sponsor:
        voucherStore.issue(title: p.label, category: 'Sponsor', points: 0, sponsor: p.sponsor, detail: tr('Won on the Daily Spin'));
        break;
    }
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
                  Text(tr('Spin to win points, tickets or sponsor prizes!'), textAlign: TextAlign.center, style: AppText.body2.copyWith(color: AppColors.textLight)),
                  const SizedBox(height: 14),
                  const SponsorAdBanner(),
                  const SizedBox(height: 18),
                  SizedBox(
                    height: 290,
                    child: Stack(
                      alignment: Alignment.center,
                      children: [
                        AnimatedBuilder(
                          animation: _anim,
                          builder: (_, _) => Transform.rotate(angle: _anim.value, child: CustomPaint(size: const Size(280, 280), painter: _WheelPainter(kSpinPrizes))),
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
                    _WinBanner(prize: kSpinPrizes[_prizeIdx])
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

/// The win result — points, ticket or a branded sponsor reward.
class _WinBanner extends StatelessWidget {
  final DailyPrize prize;
  const _WinBanner({required this.prize});
  @override
  Widget build(BuildContext context) {
    final isPoints = prize.type == DailyPrizeType.points;
    final accent = isPoints ? AppColors.success : prize.color;
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(color: accent.withValues(alpha: 0.12), borderRadius: BorderRadius.circular(AppRadii.tile)),
      child: Column(children: [
        Row(mainAxisAlignment: MainAxisAlignment.center, children: [
          Icon(isPoints ? Icons.celebration_rounded : prize.icon, color: accent),
          const SizedBox(width: 10),
          Flexible(child: Text(
            isPoints ? '${tr('You won')} +${prize.points} ${tr('points')}!' : '${tr('You won')}: ${prize.label}!',
            textAlign: TextAlign.center, style: AppText.label2.copyWith(color: accent))),
        ]),
        if (!isPoints) ...[
          const SizedBox(height: 4),
          Text(prize.type == DailyPrizeType.sponsor ? '${tr('Sponsor prize')} · ${tr('saved to My Vouchers')}' : tr('saved to My Vouchers'), style: AppText.caption1.copyWith(color: AppColors.textLight)),
        ],
      ]),
    );
  }
}

class _WheelPainter extends CustomPainter {
  final List<DailyPrize> prizes;
  _WheelPainter(this.prizes);
  @override
  void paint(Canvas canvas, Size size) {
    final center = size.center(Offset.zero);
    final radius = size.width / 2;
    final n = prizes.length;
    final sweep = 2 * math.pi / n;
    for (var i = 0; i < n; i++) {
      final start = -math.pi / 2 + i * sweep;
      canvas.drawArc(Rect.fromCircle(center: center, radius: radius), start, sweep, true, Paint()..color = prizes[i].color);
      final divider = Paint()
        ..color = Colors.white.withValues(alpha: 0.35)
        ..strokeWidth = 1.5
        ..style = PaintingStyle.stroke;
      canvas.drawLine(center, center + Offset(math.cos(start) * radius, math.sin(start) * radius), divider);
      final ang = start + sweep / 2;
      final tp = TextPainter(
        text: TextSpan(text: prizes[i].short, style: const TextStyle(fontFamily: 'Urbanist', fontSize: 11, fontWeight: FontWeight.w800, color: Colors.white)),
        textDirection: TextDirection.ltr,
        textAlign: TextAlign.center,
      )..layout(maxWidth: 64);
      canvas.save();
      canvas.translate(center.dx, center.dy);
      canvas.rotate(ang);
      canvas.translate(radius * 0.60, 0);
      canvas.rotate(math.pi / 2);
      tp.paint(canvas, Offset(-tp.width / 2, -tp.height / 2));
      canvas.restore();
    }
    canvas.drawCircle(center, radius, Paint()..color = AppColors.gold..style = PaintingStyle.stroke..strokeWidth = 6);
  }

  @override
  bool shouldRepaint(covariant _WheelPainter old) => false;
}
