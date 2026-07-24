import 'package:flutter/material.dart';
import '../theme/app_theme.dart';
import '../widgets/app_widgets.dart';
import '../widgets/sub_scaffold.dart';

class _Badge {
  final String name;
  final IconData icon;
  final bool unlocked;
  const _Badge(this.name, this.icon, this.unlocked);
}

/// Achievements (Figma 2162:6717).
class AchievementsScreen extends StatelessWidget {
  const AchievementsScreen({super.key});

  static const _groups = {
    'Matchday': [
      _Badge('First Match', Icons.sports_soccer_rounded, true),
      _Badge('10 Matches', Icons.stadium_rounded, true),
      _Badge('Season Pass', Icons.confirmation_number_rounded, true),
      _Badge('Home Hero', Icons.home_rounded, true),
      _Badge('Away Day', Icons.directions_bus_rounded, true),
      _Badge('Super Fan', Icons.star_rounded, false),
    ],
    'Shopping': [
      _Badge('First Buy', Icons.shopping_bag_rounded, true),
      _Badge('Gift Giver', Icons.card_giftcard_rounded, true),
      _Badge('Big Spender', Icons.savings_rounded, false),
    ],
    'Community': [
      _Badge('Referral King', Icons.group_add_rounded, true),
      _Badge('Verified', Icons.verified_rounded, true),
      _Badge('Legende', Icons.emoji_events_rounded, false),
    ],
  };

  @override
  Widget build(BuildContext context) {
    return SubScaffold(
      title: 'Achievements',
      children: [
        Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(gradient: const LinearGradient(colors: AppColors.pointsGradient), borderRadius: BorderRadius.circular(AppRadii.card)),
          child: Row(children: const [
            _Stat('12', 'Unlocked'),
            _Stat('24', 'Total'),
            _Stat('50%', 'Progress'),
          ]),
        ),
        const SizedBox(height: 20),
        for (final g in _groups.entries) ...[
          Align(alignment: Alignment.centerLeft, child: Text(g.key, style: AppText.label2)),
          const SizedBox(height: 12),
          GridView.count(
            crossAxisCount: 3,
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            mainAxisSpacing: 12,
            crossAxisSpacing: 12,
            childAspectRatio: 0.82,
            children: [for (final b in g.value) _BadgeTile(b)],
          ),
          const SizedBox(height: 20),
        ],
      ],
    );
  }
}

class _Stat extends StatelessWidget {
  final String value, label;
  const _Stat(this.value, this.label);
  @override
  Widget build(BuildContext context) => Expanded(
        child: Column(children: [
          Text(value, style: AppText.h4.copyWith(color: Colors.white)),
          const SizedBox(height: 2),
          Text(label, style: AppText.body3.copyWith(color: Colors.white70)),
        ]),
      );
}

class _BadgeTile extends StatelessWidget {
  final _Badge b;
  const _BadgeTile(this.b);
  @override
  Widget build(BuildContext context) {
    return Opacity(
      opacity: b.unlocked ? 1 : 0.4,
      child: SurfaceCard(
        padding: const EdgeInsets.all(8),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Stack(
              children: [
                Container(
                  width: 48, height: 48,
                  decoration: BoxDecoration(color: AppColors.brandLightest, borderRadius: BorderRadius.circular(14)),
                  child: Icon(b.icon, color: b.unlocked ? AppColors.brandPrimary : AppColors.textLight, size: 24),
                ),
                if (b.unlocked)
                  const Positioned(right: -2, top: -2, child: Icon(Icons.check_circle_rounded, size: 16, color: AppColors.success)),
              ],
            ),
            const SizedBox(height: 6),
            Text(b.name, textAlign: TextAlign.center, maxLines: 2, style: AppText.caption1.copyWith(color: AppColors.textNormal, fontSize: 11)),
          ],
        ),
      ),
    );
  }
}
