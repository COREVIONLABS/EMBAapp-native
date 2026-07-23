import 'package:flutter/material.dart';
import '../theme/app_theme.dart';
import '../widgets/app_widgets.dart';
import '../widgets/asset_img.dart';
import '../widgets/sub_scaffold.dart';

/// Redeem Points / Rewards catalog (Figma 386:7492).
class RedeemScreen extends StatelessWidget {
  const RedeemScreen({super.key});

  static const _rewards = [
    ('Home Jersey 24/25', '1,500', Icons.checkroom_rounded),
    ('Match Ticket', '2,000', Icons.confirmation_number_rounded),
    ('Signed Ball', '3,500', Icons.sports_soccer_rounded),
    ('Stadium Tour', '900', Icons.tour_rounded),
    ('Scarf', '450', Icons.style_rounded),
    ('VIP Lounge', '5,000', Icons.star_rounded),
  ];

  @override
  Widget build(BuildContext context) {
    return SubScaffold(
      title: 'Redeem',
      children: [
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            gradient: const LinearGradient(colors: AppColors.pointsGradient),
            borderRadius: BorderRadius.circular(AppRadii.card),
          ),
          child: Row(
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Your balance', style: AppText.body3.copyWith(color: Colors.white70)),
                  const SizedBox(height: 2),
                  Text('2,850 pts', style: AppText.h4.copyWith(color: Colors.white)),
                ],
              ),
              const Spacer(),
              Pill(
                gradient: const LinearGradient(colors: AppColors.goldGradient),
                child: Text('Superfan', style: AppText.caption1.copyWith(color: AppColors.brandDarkest)),
              ),
            ],
          ),
        ),
        const SizedBox(height: 20),
        const SectionHeader('Available Rewards', action: null),
        const SizedBox(height: 12),
        GridView.count(
          crossAxisCount: 2,
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          mainAxisSpacing: 12,
          crossAxisSpacing: 12,
          childAspectRatio: 0.82,
          children: [
            for (final r in _rewards) _RewardTile(name: r.$1, cost: r.$2, icon: r.$3),
          ],
        ),
      ],
    );
  }
}

class _RewardTile extends StatelessWidget {
  final String name;
  final String cost;
  final IconData icon;
  const _RewardTile({required this.name, required this.cost, required this.icon});
  @override
  Widget build(BuildContext context) {
    return SurfaceCard(
      padding: const EdgeInsets.all(12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Container(
              width: double.infinity,
              decoration: BoxDecoration(
                color: AppColors.brandLightest,
                borderRadius: BorderRadius.circular(AppRadii.chip),
              ),
              alignment: Alignment.center,
              child: AssetImg('reward_${name.hashCode}', width: 56, height: 56, fallbackIcon: icon),
            ),
          ),
          const SizedBox(height: 10),
          Text(name, maxLines: 1, overflow: TextOverflow.ellipsis, style: AppText.body2.copyWith(color: AppColors.textDarker)),
          const SizedBox(height: 6),
          Row(
            children: [
              Text(cost, style: AppText.label2.copyWith(color: AppColors.brandPrimary)),
              const SizedBox(width: 4),
              Text('pts', style: AppText.body3Regular),
            ],
          ),
        ],
      ),
    );
  }
}
