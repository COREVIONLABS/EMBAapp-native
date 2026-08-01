import 'package:flutter/material.dart';
import '../theme/app_theme.dart';
import '../widgets/app_widgets.dart';
import '../widgets/sub_scaffold.dart';
import '../widgets/hub_widgets.dart';
import 'buy_points_screen.dart';
import 'search_screen.dart';
import '../l10n/strings.dart';

class _Way {
  final IconData icon;
  final String title, sub;
  final Color color;
  const _Way(this.icon, this.title, this.sub, this.color);
}

/// Earn Points — aligned to the RevPoints hub style: search field, a welcome
/// bonus, a "ways to earn" list (rate in the subtitle), a sponsor promo and a
/// top-up shortcut. Content is EMBA/S04.
class EarnPointsScreen extends StatelessWidget {
  const EarnPointsScreen({super.key});

  static const _ways = [
    _Way(Icons.confirmation_number_outlined, 'Attend a Match', '+100 points per home match', Color(0xFF1565C0)),
    _Way(Icons.shopping_bag_outlined, 'Fanshop Purchase', '1 point per €1 spent', Color(0xFF0A2A5E)),
    _Way(Icons.play_circle_outline_rounded, 'Watch a Short Ad', '+15 points per sponsor clip', Color(0xFFE65100)),
    _Way(Icons.sports_soccer_outlined, 'Live Predictions', '+50 points on matchday', Color(0xFF6A1B9A)),
    _Way(Icons.share_outlined, 'Share on Social', '+25 points per share', Color(0xFF00897B)),
    _Way(Icons.group_add_outlined, 'Refer a Friend', '+200 points per friend', Color(0xFFC62828)),
    _Way(Icons.calendar_today_outlined, 'Daily Check-in', '+10 points every day', Color(0xFF2E7D32)),
    _Way(Icons.person_outline_rounded, 'Complete Profile', '+50 points, one-off', Color(0xFF1565C0)),
  ];

  void _push(BuildContext context, Widget s) =>
      Navigator.of(context).push(MaterialPageRoute(builder: (_) => s));

  @override
  Widget build(BuildContext context) {
    return SubScaffold(
      title: tr('Earn Points'),
      children: [
        HubSearchField(hint: 'Search rewards & sponsors', onTap: () => _push(context, const SearchScreen())),
        const SizedBox(height: 16),
        // Welcome bonus
        SurfaceCard(
          color: AppColors.brandLightest,
          child: Row(children: [
            const Icon(Icons.card_giftcard_rounded, color: AppColors.gold),
            const SizedBox(width: 12),
            Expanded(child: Text(tr('Welcome bonus: +500 points to start — annual members get +1,500.'),
                style: AppText.body3.copyWith(color: AppColors.onAccent))),
          ]),
        ),
        const SizedBox(height: 20),
        Align(alignment: Alignment.centerLeft, child: Text(tr('Ways to Earn'), style: AppText.label1)),
        const SizedBox(height: 12),
        for (final w in _ways) ...[
          HubListRow(icon: w.icon, title: w.title, subtitle: w.sub, iconColor: w.color),
          const SizedBox(height: 10),
        ],
        const SizedBox(height: 6),
        // Sponsor promo
        SponsorPromoCard(
          sponsor: 'adidas',
          category: 'Fanshop',
          offer: '5%',
          sub: 'points back on every Fanshop order',
          color: const Color(0xFF111111),
        ),
        const SizedBox(height: 12),
        HubListRow(
          icon: Icons.add_rounded,
          title: 'Top up points',
          subtitle: 'Buy a package · 100 pts = €1',
          iconColor: AppColors.brandDarkest,
          onTap: () => _push(context, const BuyPointsScreen()),
        ),
      ],
    );
  }
}
