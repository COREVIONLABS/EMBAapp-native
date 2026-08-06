import 'package:flutter/material.dart';
import '../theme/app_theme.dart';
import '../widgets/app_widgets.dart';
import '../widgets/sub_scaffold.dart';
import '../widgets/action_sheets.dart';
import '../l10n/strings.dart';

/// All membership benefits (Figma 2194:11585 / 2194:12047) — a grid of
/// claimable partner offers plus a grouped list of what the membership
/// includes (with usage). EMBA/S04 content.
class AllBenefitsScreen extends StatelessWidget {
  final String tierName;
  const AllBenefitsScreen({super.key, this.tierName = 'Super Fan'});

  // (label, icon, badge, colour)
  static const _perks = [
    ('Fanshop', Icons.checkroom_rounded, '15% off', Color(0xFF0A2A5E)),
    ('Tickets', Icons.confirmation_number_rounded, '10% off', AppColors.brandPrimary),
    ('Food & Drink', Icons.fastfood_rounded, '10% off', Color(0xFFE65100)),
    ('Sponsors', Icons.storefront_rounded, 'Voucher', AppColors.brandPrimary),
    ('Experiences', Icons.stadium_rounded, 'VIP', AppColors.brandPrimary),
    ('Content', Icons.play_circle_fill_rounded, 'Free', Color(0xFFC2185B)),
    ('Extra Raffle Tickets', Icons.local_activity_rounded, '+3', AppColors.brandPrimary),
    ('Top up points', Icons.add_rounded, 'Bonus', Color(0xFF2E7D32)),
  ];

  // (icon, title, status)
  static const _included = [
    (Icons.bolt_rounded, 'Priority ticket access', '48–72h before public sale'),
    (Icons.event_seat_rounded, 'Best seats first', 'Matchday seat upgrades'),
    (Icons.local_fire_department_rounded, 'Monthly FOMO drop', '1 exclusive item / month'),
    (Icons.casino_rounded, 'Free spins', '2 / day'),
    (Icons.shield_rounded, 'Streak protection', 'Active'),
    (Icons.block_rounded, 'Ad-free experience', 'Active'),
    (Icons.savings_rounded, 'Rewards value back', 'up to ~€14 / month'),
  ];

  @override
  Widget build(BuildContext context) {
    return SubScaffold(
      title: '${tr(tierName)} · ${tr('Benefits')}',
      children: [
        Text(tr('Partner offers'), style: AppText.label1),
        const SizedBox(height: 12),
        GridView.count(
          crossAxisCount: 4,
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          mainAxisSpacing: 12,
          crossAxisSpacing: 12,
          childAspectRatio: 0.66,
          children: [for (final p in _perks) _PerkTile(label: p.$1, icon: p.$2, badge: p.$3, color: p.$4)],
        ),
        const SizedBox(height: 24),
        Text(tr('In your membership'), style: AppText.label1),
        const SizedBox(height: 12),
        SurfaceCard(
          padding: EdgeInsets.zero,
          child: Column(children: [
            for (var i = 0; i < _included.length; i++) ...[
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                child: Row(children: [
                  Icon(_included[i].$1, color: AppColors.brandPrimary, size: 22),
                  const SizedBox(width: 14),
                  Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                    Text(tr(_included[i].$2), style: AppText.body2.copyWith(color: AppColors.textDarker, fontWeight: FontWeight.w700)),
                    const SizedBox(height: 2),
                    Text(tr(_included[i].$3), style: AppText.body3Regular),
                  ])),
                  const Icon(Icons.check_circle_rounded, color: AppColors.success, size: 18),
                ]),
              ),
              if (i != _included.length - 1) Divider(height: 1, indent: 52, color: AppColors.borderLightest),
            ],
          ]),
        ),
        const SizedBox(height: 12),
        Row(children: [
          Icon(Icons.lock_outline_rounded, size: 14, color: AppColors.textLight),
          const SizedBox(width: 6),
          Expanded(child: Text(tr('Points are never cashed out — they unlock discounts, access and sponsor rewards.'),
              style: AppText.caption1.copyWith(color: AppColors.textLight))),
        ]),
      ],
    );
  }
}

/// Claimable partner-offer tile (Figma 2194:11585): coloured icon, label,
/// discount badge and a claim button.
class _PerkTile extends StatelessWidget {
  final String label;
  final IconData icon;
  final String badge;
  final Color color;
  const _PerkTile({required this.label, required this.icon, required this.badge, required this.color});

  @override
  Widget build(BuildContext context) {
    return Tappable(
      scale: 0.95,
      onTap: () => showSuccessSheet(context, title: 'Perk claimed', message: 'Added to your vouchers — show it at the partner to redeem.'),
      child: Container(
      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 6),
      decoration: BoxDecoration(color: AppColors.brandLightest, borderRadius: BorderRadius.circular(AppRadii.tile)),
      child: Column(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
        Container(
          width: 38, height: 38,
          decoration: BoxDecoration(shape: BoxShape.circle, color: color),
          child: Icon(icon, color: Colors.white, size: 20),
        ),
        const SizedBox(height: 6),
        Text(tr(label), maxLines: 1, overflow: TextOverflow.ellipsis, textAlign: TextAlign.center, style: AppText.caption1.copyWith(color: AppColors.textDarker, fontWeight: FontWeight.w700)),
        Text(badge, maxLines: 1, overflow: TextOverflow.ellipsis, style: AppText.caption1.copyWith(color: AppColors.success, fontSize: 10)),
        const SizedBox(height: 6),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(vertical: 6),
          alignment: Alignment.center,
          decoration: BoxDecoration(color: AppColors.brandPrimary, borderRadius: BorderRadius.circular(999)),
          child: Text(tr('Claim'), style: AppText.caption1.copyWith(color: Colors.white, fontWeight: FontWeight.w700, fontSize: 10)),
        ),
      ]),
      ),
    );
  }
}
