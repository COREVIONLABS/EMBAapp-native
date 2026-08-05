import 'package:flutter/material.dart';
import '../theme/app_theme.dart';
import '../widgets/sub_scaffold.dart';
import '../widgets/app_widgets.dart';
import '../widgets/hub_widgets.dart';
import '../model/fan_model.dart';
import '../model/voucher_store.dart';
import '../widgets/voucher_flow.dart';
import 'my_vouchers_screen.dart';
import 'buy_points_screen.dart';
import 'fanshop_screen.dart';
import 'tickets_screen.dart';
import 'experiences_screen.dart';
import 'raffles_screen.dart';
import 'deals_hub_screen.dart';
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

  // Real reward deals with strikethrough pricing (title, category, old, new, badge, glyph, colour)
  static const _deals = <(String, String, int, int, String, IconData, Color, String)>[
    ('Home Jersey 25/26', 'Fanshop', 4500, 3800, '-15%', Icons.checkroom_rounded, Color(0xFF0A2A5E), 'img_fanshop'),
    ('VELTINS matchday crate', 'Sponsor', 1500, 1050, '-30%', Icons.sports_bar_rounded, Color(0xFF00897B), 'img_partner'),
    ('Derby VIP Tombola', 'Tombola', 500, 350, 'Limited', Icons.local_activity_rounded, Color(0xFFC62828), 'img_rewards'),
    ('Home Scarf 25/26', 'Fanshop', 900, 720, '-20%', Icons.style_rounded, Color(0xFF1565C0), 'img_fanshop'),
  ];

  // An aspirational reward to nudge toward (real experience from the catalogue).
  static const _goalReward = 'On the Team Photo';
  static const _goalPts = 15000;

  static const _cats = [
    (Icons.checkroom_rounded, 'Fanshop', 'Jerseys, scarves & more', Color(0xFF0A2A5E)),
    (Icons.confirmation_number_rounded, 'Tickets', 'Matchday & presale access', Color(0xFF1565C0)),
    (Icons.storefront_rounded, 'Sponsors', 'Partner vouchers & offers', Color(0xFF00897B)),
    (Icons.stadium_rounded, 'Experiences', 'Stadium tours, VIP, players', Color(0xFF6A1B9A)),
    (Icons.fastfood_rounded, 'Food & Drink', 'Matchday combos & kiosks', Color(0xFFE65100)),
    (Icons.local_activity_rounded, 'Tombola', 'Monthly ticket & prize draws', Color(0xFFC62828)),
    (Icons.volunteer_activism_rounded, 'Donations', 'Give points to club causes', Color(0xFF2E7D32)),
  ];

  void _push(BuildContext context, Widget s) =>
      Navigator.of(context).push(MaterialPageRoute(builder: (_) => s));

  @override
  Widget build(BuildContext context) {
    final remaining = (_goalPts - FanModel.fanPoints).clamp(0, _goalPts);
    final goalProgress = (FanModel.fanPoints / _goalPts).clamp(0.0, 1.0);
    return SubScaffold(
      title: tr('Redeem Points'),
      children: [
        // ── Balance hero with a goal to redeem toward ──
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(gradient: const LinearGradient(colors: AppColors.pointsGradient), borderRadius: BorderRadius.circular(AppRadii.card)),
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Row(children: [
              Text(tr('Your balance'), style: AppText.body2.copyWith(color: Colors.white70)),
              const Spacer(),
              Pill(color: Colors.white24, child: Text('≈ ${FanModel.balanceEuro}', style: AppText.caption1.copyWith(color: Colors.white, fontWeight: FontWeight.w700))),
            ]),
            const SizedBox(height: 8),
            Row(crossAxisAlignment: CrossAxisAlignment.center, children: [
              const Icon(Icons.hexagon_rounded, color: AppColors.gold, size: 24),
              const SizedBox(width: 8),
              Text('${FanModel.pointsFormatted} ${tr('pts')}', style: AppText.h2.copyWith(color: Colors.white, fontWeight: FontWeight.w800)),
            ]),
            const SizedBox(height: 16),
            Text('${tr('You\'re close to')}: ${tr(_goalReward)}', style: AppText.body3.copyWith(color: Colors.white70)),
            const SizedBox(height: 8),
            ClipRRect(
              borderRadius: BorderRadius.circular(4),
              child: LinearProgressIndicator(value: goalProgress, minHeight: 8, backgroundColor: Colors.white24, valueColor: const AlwaysStoppedAnimation(AppColors.gold)),
            ),
            const SizedBox(height: 8),
            Text('${FanModel.fmtPublic(remaining)} ${tr('pts to go')}', style: AppText.body3.copyWith(color: Colors.white, fontWeight: FontWeight.w700)),
          ]),
        ),
        const SizedBox(height: 16),
        // ── My Vouchers (reactive open count) ──
        AnimatedBuilder(
          animation: voucherStore,
          builder: (context, _) {
            final open = voucherStore.openCount;
            return SurfaceCard(
              onTap: () => _push(context, const MyVouchersScreen()),
              child: Row(children: [
                Container(width: 44, height: 44, decoration: BoxDecoration(color: AppColors.brandLightest, borderRadius: BorderRadius.circular(12)), child: const Icon(Icons.confirmation_number_rounded, color: AppColors.brandPrimary, size: 22)),
                const SizedBox(width: 14),
                Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  Text(tr('My Vouchers'), style: AppText.body2.copyWith(color: AppColors.textDarker, fontWeight: FontWeight.w700)),
                  Text(open > 0 ? '$open ${tr('ready to redeem')}' : tr('Codes you redeemed — show them in the shop'), style: AppText.body3Regular),
                ])),
                if (open > 0) Pill(color: AppColors.successBg, child: Text('$open', style: AppText.caption1.copyWith(color: AppColors.success, fontWeight: FontWeight.w800))),
                const SizedBox(width: 6),
                Icon(Icons.chevron_right_rounded, color: AppColors.textLight),
              ]),
            );
          },
        ),
        const SizedBox(height: 22),
        // ── Reward deals (strikethrough pricing, urgency) ──
        SectionHeader('Reward deals', action: null),
        const SizedBox(height: 12),
        SizedBox(
          height: 194,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            itemCount: _deals.length,
            separatorBuilder: (_, __) => const SizedBox(width: 12),
            itemBuilder: (_, i) {
              final d = _deals[i];
              return DealCard(
                title: d.$1, category: d.$2, oldPts: d.$3, newPts: d.$4, badge: d.$5, glyph: d.$6, color: d.$7, image: d.$8,
                onTap: () {
                  switch (d.$2) {
                    case 'Fanshop':
                      _push(context, const FanshopScreen());
                    case 'Tombola':
                      _push(context, const RafflesScreen());
                    default:
                      redeemForVoucher(context, title: d.$1, category: d.$2, points: d.$4, sponsor: 'Veltins');
                  }
                },
              );
            },
          ),
        ),
        const SizedBox(height: 24),
        SectionHeader('Featured rewards', action: null),
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
                'Tombola' => const RafflesScreen(),
                'Sponsors' => const DealsHubScreen(),
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
          subtitle: 'Reach your reward faster · optional',
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
