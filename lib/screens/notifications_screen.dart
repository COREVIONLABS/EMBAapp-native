import 'package:flutter/material.dart';
import '../theme/app_theme.dart';
import '../widgets/app_widgets.dart';
import '../widgets/sub_scaffold.dart';
import '../widgets/empty_state.dart';
import 'predictions_screen.dart';
import 'points_history_screen.dart';
import 'redeem_screen.dart';
import 'raffles_screen.dart';
import 'daily_spin_screen.dart';
import '../l10n/strings.dart';

/// Notifications (Figma 385:4892). Clearable — clearing shows the empty state.
/// Each notification deep-links to where it can be acted on (predict, redeem,
/// spin, tombola, points history) so an alert is never a dead end.
class NotificationsScreen extends StatefulWidget {
  const NotificationsScreen({super.key});
  @override
  State<NotificationsScreen> createState() => _NotificationsScreenState();
}

class _NotificationsScreenState extends State<NotificationsScreen> {
  // (title, body, time, icon, unread, route)
  static const _seed = [
    ('Matchday reminder', 'Kickoff vs Dortmund in 2 hours. Predict the score for +50 pts!', 'Now', Icons.sports_soccer_rounded, true, 'predict'),
    ('You earned points', '+120 Fan Points for your stadium check-in.', '1h ago', Icons.add_circle_outline_rounded, true, 'points'),
    ('Reward available', 'You have enough points for a Fanshop voucher.', '3h ago', Icons.redeem_rounded, false, 'redeem'),
    ('Daily spin ready', 'Your free spin is waiting — win up to 250 pts.', 'Yesterday', Icons.casino_rounded, false, 'spin'),
    ('Superfan perk', 'Tombola lots are ready — place them for this week\'s draws.', '2d ago', Icons.star_rounded, false, 'tombola'),
  ];

  late List<(String, String, String, IconData, bool, String)> _items = List.of(_seed);

  void _open(String route) {
    switch (route) {
      case 'predict':
        Navigator.of(context).push(MaterialPageRoute(builder: (_) => const PredictionsScreen()));
      case 'points':
        Navigator.of(context).push(MaterialPageRoute(builder: (_) => const PointsHistoryScreen()));
      case 'redeem':
        Navigator.of(context).push(MaterialPageRoute(builder: (_) => const RedeemScreen()));
      case 'spin':
        showDailySpin(context);
      case 'tombola':
        Navigator.of(context).push(MaterialPageRoute(builder: (_) => const RafflesScreen()));
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_items.isEmpty) {
      return SubScaffold(
        title: tr('Notifications'),
        children: [
          EmptyState(
            icon: Icons.notifications_none_rounded,
            title: "You're all caught up",
            message: 'No new notifications. Matchday reminders and rewards will show up here.',
          ),
        ],
      );
    }
    return SubScaffold(
      title: tr('Notifications'),
      children: [
        Align(
          alignment: Alignment.centerRight,
          child: GestureDetector(
            onTap: () => setState(() => _items = []),
            child: Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: Text(tr('Clear all'), style: AppText.body3.copyWith(color: AppColors.brandPrimary, fontWeight: FontWeight.w700)),
            ),
          ),
        ),
        for (final n in _items)
          Padding(
            padding: const EdgeInsets.only(bottom: 10),
            child: SurfaceCard(
              color: n.$5 ? AppColors.brandLightest : AppColors.surface,
              border: Border.all(color: n.$5 ? AppColors.brandLightest : AppColors.borderLightest),
              onTap: () => _open(n.$6),
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
                            Expanded(child: Text(tr(n.$1), style: AppText.body2.copyWith(color: AppColors.textDarker))),
                            Text(tr(n.$3), style: AppText.body3Regular),
                          ],
                        ),
                        const SizedBox(height: 4),
                        Text(tr(n.$2), style: AppText.body3Regular),
                      ],
                    ),
                  ),
                  const SizedBox(width: 8),
                  Icon(Icons.chevron_right_rounded, size: 18, color: AppColors.textLight),
                ],
              ),
            ),
          ),
      ],
    );
  }
}
