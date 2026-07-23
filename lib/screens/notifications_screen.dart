import 'package:flutter/material.dart';
import '../theme/app_theme.dart';
import '../widgets/app_widgets.dart';
import '../widgets/sub_scaffold.dart';

/// Notifications (Figma 385:4892).
class NotificationsScreen extends StatelessWidget {
  const NotificationsScreen({super.key});

  static const _items = [
    ('Matchday reminder', 'Kickoff vs Bayern in 2 hours. Predict the score for +50 pts!', 'Now', Icons.sports_soccer_rounded, true),
    ('You earned points', '+120 Fan Points for your stadium check-in.', '1h ago', Icons.add_circle_outline_rounded, true),
    ('Reward available', 'You can now redeem the Home Jersey 24/25.', '3h ago', Icons.redeem_rounded, false),
    ('Daily spin ready', 'Your free spin is waiting — win up to 250 pts.', 'Yesterday', Icons.casino_rounded, false),
    ('Superfan perk', 'Meet & greet raffle entries are open this week.', '2d ago', Icons.star_rounded, false),
  ];

  @override
  Widget build(BuildContext context) {
    return SubScaffold(
      title: 'Notifications',
      children: [
        for (final n in _items)
          Padding(
            padding: const EdgeInsets.only(bottom: 10),
            child: SurfaceCard(
              color: n.$5 ? AppColors.brandLightest : AppColors.surface,
              border: Border.all(color: n.$5 ? AppColors.brandLightest : AppColors.borderLightest),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(color: AppColors.surface, borderRadius: BorderRadius.circular(12)),
                    child: Icon(n.$4, color: AppColors.brandPrimary, size: 20),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Expanded(child: Text(n.$1, style: AppText.body2.copyWith(color: AppColors.textDarker))),
                            Text(n.$3, style: AppText.body3Regular),
                          ],
                        ),
                        const SizedBox(height: 4),
                        Text(n.$2, style: AppText.body3Regular),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
      ],
    );
  }
}
