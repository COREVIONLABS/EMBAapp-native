import 'package:flutter/material.dart';
import '../theme/app_theme.dart';
import '../widgets/app_widgets.dart';
import '../widgets/sub_scaffold.dart';
import '../widgets/action_sheets.dart';
import '../model/fan_model.dart';
import 'payment_methods_screen.dart';
import '../l10n/strings.dart';

/// Buy Points (top-up) — a premium fintech-style top-up (Revolut RevPoints
/// inspired): a live balance hero, selectable packs with a bonus + effective
/// value, a payment method row and an optional auto top-up. Priced transparently
/// at 100 pts = €1; bought points unlock rewards but never affect the leaderboard.
class BuyPointsScreen extends StatefulWidget {
  const BuyPointsScreen({super.key});
  @override
  State<BuyPointsScreen> createState() => _BuyPointsScreenState();
}

class _BuyPointsScreenState extends State<BuyPointsScreen> {
  int _sel = 1;
  bool _recurring = false;

  // (points, price €, bonus %, badge)
  static const _packs = <(int, double, int, String?)>[
    (500, 5.00, 0, null),
    (1000, 10.00, 5, 'Popular'),
    (2500, 24.00, 10, null),
    (5000, 45.00, 15, 'Best value'),
  ];

  int get _bonus => (_packs[_sel].$1 * _packs[_sel].$3 / 100).round();
  int get _total => _packs[_sel].$1 + _bonus;

  Future<void> _pay() async {
    FanModel.addPoints(_total); // credit the balance for real
    await showSuccessSheet(context,
        title: 'Points added',
        message: _recurring
            ? '${FanModel.fmtPublic(_total)} ${tr('points added — and topped up automatically every month.')}'
            : '${FanModel.fmtPublic(_total)} ${tr('points are now in your balance.')}');
    if (mounted) Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    final p = _packs[_sel];
    return SubScaffold(
      title: tr('Top up points'),
      bottomBar: Column(mainAxisSize: MainAxisSize.min, children: [
        PrimaryButton(
          '${tr('Pay')} €${p.$2.toStringAsFixed(2)}${_recurring ? ' / ${tr('mo')}' : ''} · ${FanModel.fmtPublic(_total)} ${tr('pts')}',
          onTap: _pay,
        ),
        const SizedBox(height: 8),
        Text(tr('100 points = €1 · bought points never affect the leaderboard'),
            textAlign: TextAlign.center, style: AppText.caption1.copyWith(color: AppColors.textLight)),
      ]),
      children: [
        // ── Balance hero ──
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(gradient: const LinearGradient(begin: Alignment.topLeft, end: Alignment.bottomRight, colors: AppColors.pointsGradient), borderRadius: BorderRadius.circular(AppRadii.card)),
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text(tr('Your balance'), style: AppText.body3.copyWith(color: Colors.white70)),
            const SizedBox(height: 6),
            ValueListenableBuilder<int>(
              valueListenable: pointsNotifier,
              builder: (context, _, __) => Row(crossAxisAlignment: CrossAxisAlignment.baseline, textBaseline: TextBaseline.alphabetic, children: [
                const Icon(Icons.hexagon_rounded, size: 22, color: AppColors.gold),
                const SizedBox(width: 8),
                Text(FanModel.pointsFormatted, style: AppText.h2.copyWith(color: Colors.white)),
                const SizedBox(width: 8),
                Padding(padding: const EdgeInsets.only(bottom: 3), child: Text('${tr('pts')} · ${tr('≈')} ${FanModel.balanceEuro}', style: AppText.body3.copyWith(color: Colors.white60))),
              ]),
            ),
            const SizedBox(height: 14),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              decoration: BoxDecoration(color: Colors.white.withValues(alpha: 0.12), borderRadius: BorderRadius.circular(999)),
              child: Row(mainAxisSize: MainAxisSize.min, children: [
                const Icon(Icons.arrow_upward_rounded, size: 14, color: AppColors.gold),
                const SizedBox(width: 6),
                Text(trp('After top-up: {n} pts', n: FanModel.fmtPublic(FanModel.fanPoints + _total)), style: AppText.caption1.copyWith(color: Colors.white, fontWeight: FontWeight.w700)),
              ]),
            ),
          ]),
        ),
        const SizedBox(height: 24),
        // ── Choose a pack (RevPoints-style tile grid) ──
        Row(crossAxisAlignment: CrossAxisAlignment.end, children: [
          Expanded(child: Text(tr('Choose a top-up'), style: AppText.label1)),
          Text(tr('The more you buy, the more you save'), style: AppText.caption1.copyWith(color: AppColors.textLight)),
        ]),
        const SizedBox(height: 14),
        for (var r = 0; r < _packs.length; r += 2) ...[
          IntrinsicHeight(
            child: Row(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
              Expanded(child: _PackTile(
                points: _packs[r].$1, price: _packs[r].$2, bonus: _packs[r].$3, badge: _packs[r].$4,
                selected: r == _sel, onTap: () => setState(() => _sel = r),
              )),
              const SizedBox(width: 12),
              if (r + 1 < _packs.length)
                Expanded(child: _PackTile(
                  points: _packs[r + 1].$1, price: _packs[r + 1].$2, bonus: _packs[r + 1].$3, badge: _packs[r + 1].$4,
                  selected: r + 1 == _sel, onTap: () => setState(() => _sel = r + 1),
                ))
              else
                const Expanded(child: SizedBox()),
            ]),
          ),
          const SizedBox(height: 12),
        ],
        const SizedBox(height: 8),
        // ── Selected-pack summary ──
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(color: AppColors.brandLightest, borderRadius: BorderRadius.circular(AppRadii.card)),
          child: Row(children: [
            Container(width: 44, height: 44, decoration: BoxDecoration(color: AppColors.surface, borderRadius: BorderRadius.circular(12)), child: const Icon(Icons.hexagon_rounded, color: AppColors.brandPrimary, size: 24)),
            const SizedBox(width: 14),
            Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text(trp('You get {n} pts', n: FanModel.fmtPublic(_total)), style: AppText.label2.copyWith(color: AppColors.textDarker, fontWeight: FontWeight.w800)),
              const SizedBox(height: 2),
              Text(_bonus > 0 ? trp('incl. {n} bonus points free', n: FanModel.fmtPublic(_bonus)) : tr('No bonus on this pack'), style: AppText.body3Regular),
            ])),
            Text('€${p.$2.toStringAsFixed(2)}', style: AppText.h2.copyWith(color: AppColors.brandPrimary, fontSize: 24)),
          ]),
        ),
        const SizedBox(height: 24),

        // ── Payment method ──
        Text(tr('Payment method'), style: AppText.label2),
        const SizedBox(height: 10),
        SurfaceCard(
          onTap: () => Navigator.of(context).push(MaterialPageRoute(builder: (_) => const PaymentMethodsScreen())),
          child: Row(children: [
            Container(width: 44, height: 30, decoration: BoxDecoration(color: AppColors.brandDarkest, borderRadius: BorderRadius.circular(6)), alignment: Alignment.center, child: const Icon(Icons.credit_card_rounded, color: Colors.white, size: 18)),
            const SizedBox(width: 12),
            Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text(tr('Visa •••• 4921'), style: AppText.body2.copyWith(color: AppColors.textDarker, fontWeight: FontWeight.w700)),
              Text(tr('Change'), style: AppText.body3.copyWith(color: AppColors.brandPrimary, fontWeight: FontWeight.w700)),
            ])),
            Icon(Icons.chevron_right_rounded, color: AppColors.textLight),
          ]),
        ),
        const SizedBox(height: 12),

        // ── Auto top-up ──
        SurfaceCard(
          child: Row(children: [
            Container(width: 40, height: 40, decoration: BoxDecoration(color: AppColors.brandLightest, borderRadius: BorderRadius.circular(11)), child: const Icon(Icons.autorenew_rounded, color: AppColors.brandPrimary, size: 22)),
            const SizedBox(width: 12),
            Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text(tr('Auto top-up monthly'), style: AppText.body2.copyWith(color: AppColors.textDarker, fontWeight: FontWeight.w700)),
              const SizedBox(height: 2),
              Text(tr('Never run out — recharge this pack every month. Cancel anytime.'), style: AppText.body3Regular),
            ])),
            Switch(value: _recurring, activeThumbColor: Colors.white, activeTrackColor: AppColors.brandPrimary, onChanged: (v) => setState(() => _recurring = v)),
          ]),
        ),
      ],
    );
  }
}

/// A selectable top-up pack: points + bonus, price, effective value, and an
/// optional "Popular / Best value" badge.
class _PackTile extends StatelessWidget {
  final int points;
  final double price;
  final int bonus;
  final String? badge;
  final bool selected;
  final VoidCallback onTap;
  const _PackTile({required this.points, required this.price, required this.bonus, required this.badge, required this.selected, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Tappable(
      scale: 0.98,
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 160),
        padding: const EdgeInsets.fromLTRB(16, 14, 16, 16),
        decoration: BoxDecoration(
          color: selected ? AppColors.brandLightest : AppColors.surface,
          borderRadius: BorderRadius.circular(AppRadii.card),
          border: Border.all(color: selected ? AppColors.brandPrimary : AppColors.borderLightest, width: selected ? 2 : 1),
          boxShadow: selected ? [BoxShadow(color: AppColors.brandPrimary.withValues(alpha: 0.22), blurRadius: 18, offset: const Offset(0, 6))] : null,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Top row: hexagon token + selected check
            Row(children: [
              Container(
                width: 34, height: 34,
                decoration: BoxDecoration(gradient: const LinearGradient(colors: AppColors.pointsGradient), borderRadius: BorderRadius.circular(10)),
                child: const Icon(Icons.hexagon_rounded, color: AppColors.gold, size: 18),
              ),
              const Spacer(),
              if (selected)
                const Icon(Icons.check_circle_rounded, color: AppColors.brandPrimary, size: 22)
              else if (badge != null)
                Pill(gradient: const LinearGradient(colors: AppColors.goldGradient), padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3), child: Text(tr(badge!), style: AppText.caption1.copyWith(color: AppColors.brandDarkest, fontWeight: FontWeight.w800, fontSize: 9))),
            ]),
            const SizedBox(height: 12),
            // Big amount
            Text(FanModel.fmtPublic(points), style: AppText.h2.copyWith(color: AppColors.textDarkest, fontSize: 28, height: 1.0)),
            const SizedBox(height: 2),
            Text(tr('pts'), style: AppText.body3.copyWith(color: AppColors.textLight)),
            const SizedBox(height: 12),
            // Bonus chip + price
            Row(children: [
              if (bonus > 0)
                Pill(color: AppColors.successBg, padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3), child: Text('+$bonus% ${tr('free')}', style: AppText.caption1.copyWith(color: AppColors.success, fontWeight: FontWeight.w800, fontSize: 11)))
              else
                Pill(color: AppColors.surfaceMinimal, padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3), child: Text(tr('Starter'), style: AppText.caption1.copyWith(color: AppColors.textLight, fontWeight: FontWeight.w700, fontSize: 11))),
              const Spacer(),
              Text('€${price.toStringAsFixed(2)}', style: AppText.label2.copyWith(color: AppColors.brandPrimary, fontWeight: FontWeight.w800)),
            ]),
          ],
        ),
      ),
    );
  }
}
