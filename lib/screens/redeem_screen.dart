import 'package:flutter/material.dart';
import '../theme/app_theme.dart';
import '../widgets/sub_scaffold.dart';
import '../widgets/hub_widgets.dart';
import 'voucher_screen.dart';
import 'buy_points_screen.dart';
import 'fanshop_screen.dart';
import 'tickets_screen.dart';
import 'experiences_screen.dart';
import 'search_screen.dart';
import '../l10n/strings.dart';

/// Redeem Points — aligned to the RevPoints hub style: search field, a
/// "how you can redeem" category list (white rows), and a sponsor promo.
/// Content is EMBA/S04: club shop, tickets, sponsors, experiences, F&B,
/// extra raffle tickets, donations.
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

  void _push(BuildContext context, Widget s) =>
      Navigator.of(context).push(MaterialPageRoute(builder: (_) => s));

  @override
  Widget build(BuildContext context) {
    return SubScaffold(
      title: tr('Redeem Points'),
      children: [
        HubSearchField(hint: 'Search rewards & sponsors', onTap: () => _push(context, const SearchScreen())),
        const SizedBox(height: 20),
        Text(tr('How you can redeem'), style: AppText.label1),
        const SizedBox(height: 12),
        for (final c in _cats) ...[
          HubListRow(
            icon: c.$1,
            title: c.$2,
            subtitle: c.$3,
            iconColor: c.$4,
            onTap: () {
              final Widget? dest = switch (c.$2) {
                'Fanshop' => const FanshopScreen(),
                'Tickets' => const TicketsScreen(),
                'Experiences' => const ExperiencesScreen(),
                'Sponsors' => const VoucherScreen(),
                _ => null,
              };
              if (dest != null) _push(context, dest);
            },
          ),
          const SizedBox(height: 10),
        ],
        const SizedBox(height: 6),
        // Sponsor promo
        SponsorPromoCard(
          sponsor: 'Veltins',
          category: 'Food & Drink',
          offer: '−20%',
          sub: 'On matchday combos — pay with points',
          color: const Color(0xFF00623A),
          onTap: () => _push(context, const VoucherScreen()),
        ),
        const SizedBox(height: 12),
        HubListRow(
          icon: Icons.add_rounded,
          title: 'Top up points',
          subtitle: 'Buy a package · 100 pts = €1',
          iconColor: AppColors.brandDarkest,
          onTap: () => _push(context, const BuyPointsScreen()),
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
