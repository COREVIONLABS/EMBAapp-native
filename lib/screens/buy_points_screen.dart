import 'package:flutter/material.dart';
import '../theme/app_theme.dart';
import '../widgets/app_widgets.dart';
import '../widgets/sub_scaffold.dart';
import '../model/fan_model.dart';
import '../l10n/strings.dart';

/// Buy Points (top-up) — packages priced transparently at 100 pts = €1, with
/// a volume bonus on bigger packs. Bought points can be redeemed for rewards
/// but never count toward the Top Supporter leaderboard (no pay-to-win).
class BuyPointsScreen extends StatefulWidget {
  const BuyPointsScreen({super.key});
  @override
  State<BuyPointsScreen> createState() => _BuyPointsScreenState();
}

class _BuyPointsScreenState extends State<BuyPointsScreen> {
  int _sel = 1;

  // (points, price €, bonus %)
  static const _packs = [
    (500, 5.00, 0),
    (1000, 10.00, 5),
    (2500, 24.00, 10),
    (5000, 45.00, 15),
  ];

  @override
  Widget build(BuildContext context) {
    final p = _packs[_sel];
    final bonus = (p.$1 * p.$3 / 100).round();
    final total = p.$1 + bonus;
    return SubScaffold(
      title: tr('Buy Points'),
      bottomBar: PrimaryButton('${tr('Pay')} €${p.$2.toStringAsFixed(2)}'),
      children: [
        SurfaceCard(
          color: AppColors.brandLightest,
          child: Row(children: [
            const Icon(Icons.info_outline_rounded, color: AppColors.brandPrimary),
            const SizedBox(width: 12),
            Expanded(child: Text(tr('100 points = €1. Bought points unlock rewards but never affect the Top Supporter leaderboard.'),
                style: AppText.body3.copyWith(color: AppColors.brandDarkest))),
          ]),
        ),
        const SizedBox(height: 20),
        Text(tr('Choose a package'), style: AppText.label1),
        const SizedBox(height: 12),
        for (var i = 0; i < _packs.length; i++) ...[
          _PackTile(
            points: _packs[i].$1,
            price: _packs[i].$2,
            bonus: _packs[i].$3,
            selected: i == _sel,
            onTap: () => setState(() => _sel = i),
          ),
          const SizedBox(height: 10),
        ],
        const SizedBox(height: 6),
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(gradient: const LinearGradient(colors: AppColors.pointsGradient), borderRadius: BorderRadius.circular(AppRadii.card)),
          child: Row(children: [
            Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text(tr("You'll receive"), style: AppText.body3.copyWith(color: Colors.white70)),
              const SizedBox(height: 2),
              Text('${FanModel.fmtPublic(total)} pts', style: AppText.h4.copyWith(color: Colors.white)),
            ])),
            if (bonus > 0)
              Pill(gradient: const LinearGradient(colors: AppColors.goldGradient), child: Text('+${FanModel.fmtPublic(bonus)} ${tr('bonus')}', style: AppText.caption1.copyWith(color: AppColors.brandDarkest, fontWeight: FontWeight.w700))),
          ]),
        ),
      ],
    );
  }
}

class _PackTile extends StatelessWidget {
  final int points;
  final double price;
  final int bonus;
  final bool selected;
  final VoidCallback onTap;
  const _PackTile({required this.points, required this.price, required this.bonus, required this.selected, required this.onTap});
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(AppRadii.tile),
          border: Border.all(color: selected ? AppColors.brandPrimary : AppColors.borderLightest, width: selected ? 1.8 : 1),
        ),
        child: Row(children: [
          Icon(selected ? Icons.radio_button_checked_rounded : Icons.radio_button_unchecked_rounded,
              color: selected ? AppColors.brandPrimary : AppColors.textLight, size: 22),
          const SizedBox(width: 14),
          Expanded(child: Row(children: [
            Text('${FanModel.fmtPublic(points)} pts', style: AppText.label2.copyWith(color: AppColors.textDarker)),
            if (bonus > 0) ...[
              const SizedBox(width: 8),
              Pill(color: AppColors.successBg, padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2), child: Text('+$bonus%', style: AppText.caption1.copyWith(color: AppColors.success, fontWeight: FontWeight.w700, fontSize: 11))),
            ],
          ])),
          Text('€${price.toStringAsFixed(2)}', style: AppText.label2.copyWith(color: AppColors.brandPrimary)),
        ]),
      ),
    );
  }
}
