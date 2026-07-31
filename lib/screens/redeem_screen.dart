import 'package:flutter/material.dart';
import '../theme/app_theme.dart';
import '../widgets/app_widgets.dart';
import '../widgets/sub_scaffold.dart';
import '../model/fan_model.dart';
import '../l10n/strings.dart';

/// Redeem hub — a Revolut-style category grid so fans always know *where*
/// their points can go: club shop, tickets, sponsors, experiences, food &
/// drink, extra raffle tickets, and donations.
class RedeemScreen extends StatelessWidget {
  const RedeemScreen({super.key});

  static const _cats = [
    (Icons.checkroom_rounded, 'Fanshop', 'Jerseys, scarves & more', Color(0xFF0A2A5E)),
    (Icons.confirmation_number_rounded, 'Tickets', 'Matchday & presale access', Color(0xFF1565C0)),
    (Icons.storefront_rounded, 'Sponsors', 'Partner vouchers & offers', Color(0xFF00897B)),
    (Icons.stadium_rounded, 'Experiences', 'Stadium tours, VIP, players', Color(0xFF6A1B9A)),
    (Icons.fastfood_rounded, 'Food & Drink', 'Matchday combos & kiosks', Color(0xFFE65100)),
    (Icons.local_activity_rounded, 'Extra Raffle Tickets', 'Boost your odds on draws', Color(0xFFC62828)),
    (Icons.volunteer_activism_rounded, 'Donations', 'Give points to club causes', Color(0xFF2E7D32)),
  ];

  @override
  Widget build(BuildContext context) {
    return SubScaffold(
      title: tr('Redeem Points'),
      children: [
        // Balance banner with transparent € value
        Container(
          padding: const EdgeInsets.all(18),
          decoration: BoxDecoration(gradient: const LinearGradient(colors: AppColors.pointsGradient), borderRadius: BorderRadius.circular(AppRadii.card)),
          child: Row(children: [
            Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text(tr('Available to redeem'), style: AppText.body3.copyWith(color: Colors.white70)),
              const SizedBox(height: 4),
              Text('${FanModel.pointsFormatted} pts', style: AppText.h2.copyWith(color: Colors.white)),
              Text('≈ ${FanModel.balanceEuro} · 100 pts = €1', style: AppText.body3.copyWith(color: Colors.white70)),
            ])),
            const Icon(Icons.savings_rounded, color: AppColors.gold, size: 32),
          ]),
        ),
        const SizedBox(height: 20),
        Text(tr('Where to redeem'), style: AppText.label1),
        const SizedBox(height: 12),
        for (final c in _cats)
          Padding(
            padding: const EdgeInsets.only(bottom: 10),
            child: SurfaceCard(
              onTap: () {},
              child: Row(children: [
                Container(
                  width: 46, height: 46,
                  decoration: BoxDecoration(color: c.$4.withValues(alpha: 0.12), borderRadius: BorderRadius.circular(13)),
                  child: Icon(c.$1, color: c.$4, size: 24),
                ),
                const SizedBox(width: 14),
                Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  Text(tr(c.$2), style: AppText.body1.copyWith(color: AppColors.textDarker, fontSize: 15)),
                  const SizedBox(height: 2),
                  Text(tr(c.$3), style: AppText.body3Regular),
                ])),
                const Icon(Icons.chevron_right_rounded, color: AppColors.textLight),
              ]),
            ),
          ),
        const SizedBox(height: 8),
        Row(children: [
          const Icon(Icons.lock_outline_rounded, size: 14, color: AppColors.textLight),
          const SizedBox(width: 6),
          Expanded(child: Text(tr('Points are never cashed out — they unlock discounts, access and sponsor rewards.'),
              style: AppText.caption1.copyWith(color: AppColors.textLight))),
        ]),
      ],
    );
  }
}
