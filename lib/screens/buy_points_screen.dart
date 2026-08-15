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
        const SizedBox(height: 20),
        // ── Escalating-bonus explainer (Revolut RevPoints idea) ──
        Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(color: AppColors.successBg, borderRadius: BorderRadius.circular(AppRadii.card)),
          child: Row(children: [
            Container(width: 40, height: 40, decoration: BoxDecoration(color: AppColors.success.withValues(alpha: 0.18), borderRadius: BorderRadius.circular(11)), child: const Icon(Icons.trending_up_rounded, color: AppColors.success, size: 22)),
            const SizedBox(width: 12),
            Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text(tr('The more you buy, the bigger the bonus'), style: AppText.body2.copyWith(color: AppColors.textDarker, fontWeight: FontWeight.w800)),
              Text(tr('Extra points on top — up to +15% free.'), style: AppText.body3Regular),
            ])),
          ]),
        ),
        const SizedBox(height: 20),
        Text(tr('Choose a top-up'), style: AppText.label1),
        const SizedBox(height: 12),
        for (var i = 0; i < _packs.length; i++) ...[
          _PackTile(
            points: _packs[i].$1,
            price: _packs[i].$2,
            bonus: _packs[i].$3,
            badge: _packs[i].$4,
            selected: i == _sel,
            onTap: () => setState(() => _sel = i),
          ),
          const SizedBox(height: 10),
        ],
        const SizedBox(height: 10),

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
    final bonusPts = (points * bonus / 100).round();
    final total = points + bonusPts;
    return Tappable(
      scale: 0.98,
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: selected ? AppColors.brandLightest : AppColors.surface,
          borderRadius: BorderRadius.circular(AppRadii.card),
          border: Border.all(color: selected ? AppColors.brandPrimary : AppColors.borderLightest, width: selected ? 1.8 : 1),
        ),
        child: Row(children: [
          Icon(selected ? Icons.radio_button_checked_rounded : Icons.radio_button_unchecked_rounded,
              color: selected ? AppColors.brandPrimary : AppColors.textLight, size: 22),
          const SizedBox(width: 14),
          Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Row(children: [
              Text('${FanModel.fmtPublic(points)} ${tr('pts')}', style: AppText.label2.copyWith(color: AppColors.textDarker)),
              if (bonus > 0) ...[
                const SizedBox(width: 8),
                Pill(color: AppColors.successBg, padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2), child: Text('+$bonus%', style: AppText.caption1.copyWith(color: AppColors.success, fontWeight: FontWeight.w800, fontSize: 11))),
              ],
              if (badge != null) ...[
                const SizedBox(width: 8),
                Pill(gradient: const LinearGradient(colors: AppColors.goldGradient), child: Text(tr(badge!), style: AppText.caption1.copyWith(color: AppColors.brandDarkest, fontWeight: FontWeight.w800, fontSize: 10))),
              ],
            ]),
            const SizedBox(height: 3),
            Text(bonus > 0 ? trp('You get {n} pts total', n: FanModel.fmtPublic(total)) : tr('No bonus'), style: AppText.body3Regular),
          ])),
          const SizedBox(width: 10),
          Text('€${price.toStringAsFixed(2)}', style: AppText.label1.copyWith(color: AppColors.brandPrimary, fontSize: 18)),
        ]),
      ),
    );
  }
}
