import 'package:flutter/material.dart';
import '../theme/app_theme.dart';
import '../widgets/sub_scaffold.dart';
import '../widgets/app_widgets.dart';
import '../widgets/hub_widgets.dart';
import '../model/fan_model.dart';
import '../widgets/voucher_flow.dart';
import 'voucher_screen.dart';
import 'my_vouchers_screen.dart';
import 'buy_points_screen.dart';
import 'fanshop_screen.dart';
import 'tickets_screen.dart';
import 'experiences_screen.dart';
import '../l10n/strings.dart';

/// Redeem Points (Figma 2194:10804) — featured sponsor reward cards on top,
/// then a "how you can redeem" category list. EMBA/S04 content with real club
/// sponsors and symbolic category icons.
class RedeemScreen extends StatelessWidget {
  const RedeemScreen({super.key});

  // Featured sponsor rewards: (sponsor, category, from-points)
  static const _featured = [
    ('Veltins', 'Food & Drink', 500),
    ('adidas', 'Fanshop', 900),
    ('REWE', 'Groceries', 400),
    ("Ernsting's", 'Fashion', 600),
  ];

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
        HubListRow(
          icon: Icons.confirmation_number_rounded,
          title: 'My Vouchers',
          subtitle: 'Codes you redeemed — show them in the shop',
          iconColor: AppColors.brandPrimary,
          onTap: () => _push(context, const MyVouchersScreen()),
        ),
        const SizedBox(height: 16),
        SectionHeader('Featured rewards', onAction: () => _push(context, const MyVouchersScreen())),
        const SizedBox(height: 12),
        SizedBox(
          height: 168,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            itemCount: _featured.length,
            separatorBuilder: (_, __) => const SizedBox(width: 12),
            itemBuilder: (_, i) {
              final f = _featured[i];
              return _FeaturedCard(
                sponsor: sponsorByName(f.$1),
                name: f.$1,
                category: f.$2,
                fromPts: f.$3,
                onTap: () => redeemForVoucher(context, title: '${f.$1} · ${f.$2}', category: f.$2, points: f.$3, sponsor: f.$1),
              );
            },
          ),
        ),
        const SizedBox(height: 24),
        const SectionHeader('How you can redeem', action: null),
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

/// Featured reward card: coloured sponsor header (symbol) + white body with
/// name, category and the points price.
class _FeaturedCard extends StatelessWidget {
  final Sponsor? sponsor;
  final String name;
  final String category;
  final int fromPts;
  final VoidCallback onTap;
  const _FeaturedCard({required this.sponsor, required this.name, required this.category, required this.fromPts, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final color = sponsor?.color ?? AppColors.brandPrimary;
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 172,
        clipBehavior: Clip.antiAlias,
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(AppRadii.card),
          border: Border.all(color: AppColors.borderLightest),
        ),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          // Coloured header
          Container(
            height: 76,
            width: double.infinity,
            color: color,
            alignment: Alignment.center,
            child: Icon(sponsor?.icon ?? Icons.card_giftcard_rounded, color: Colors.white, size: 34),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(12, 10, 12, 12),
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text(name, maxLines: 1, overflow: TextOverflow.ellipsis, style: AppText.body1.copyWith(color: AppColors.textDarker, fontSize: 15, fontWeight: FontWeight.w700)),
              const SizedBox(height: 2),
              Text(tr(category), maxLines: 1, overflow: TextOverflow.ellipsis, style: AppText.body3Regular),
              const SizedBox(height: 8),
              Row(children: [
                const Icon(Icons.hexagon_rounded, size: 15, color: AppColors.brandPrimary),
                const SizedBox(width: 5),
                Text('${tr('From')} ${FanModel.fmtPublic(fromPts)}', style: AppText.body2.copyWith(color: AppColors.textDarker, fontWeight: FontWeight.w700)),
              ]),
            ]),
          ),
        ]),
      ),
    );
  }
}
