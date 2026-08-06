import 'package:flutter/material.dart';
import '../theme/app_theme.dart';
import '../widgets/sub_scaffold.dart';
import '../widgets/app_widgets.dart';
import '../widgets/hub_widgets.dart';
import '../widgets/asset_img.dart';
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
  final bool isTab;
  const RedeemScreen({super.key, this.isTab = false});

  // Money-can't-buy experiences (title, subtitle, image, points).
  static const _exclusive = <(String, String, String, int)>[
    ('Auf dem Rasen spielen', 'Spiele in der VELTINS-Arena', 'img_experiences', 12000),
    ('Triff die Mannschaft', 'Meet & Greet vor dem Spiel', 'img_rewards', 5000),
    ('VIP-Loge am Spieltag', 'Logenplatz inkl. Catering', 'img_tickets', 8000),
  ];

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

  // Compact balance chip for the tab header (Socios-style token count).
  Widget _pointsChip() => Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
        decoration: BoxDecoration(color: AppColors.brandLightest, borderRadius: BorderRadius.circular(999)),
        child: Row(mainAxisSize: MainAxisSize.min, children: [
          const Icon(Icons.hexagon_rounded, size: 14, color: AppColors.brandPrimary),
          const SizedBox(width: 5),
          Text(FanModel.pointsFormatted, style: AppText.caption1.copyWith(color: AppColors.brandPrimary, fontWeight: FontWeight.w800)),
        ]),
      );

  @override
  Widget build(BuildContext context) {
    return SubScaffold(
      title: tr('Redeem'),
      showBack: !isTab,
      trailing: isTab ? _pointsChip() : null,
      children: [
        // ── Exclusive, money-can't-buy experiences (the emotional heart) ──
        Row(children: [
          Text(tr('Exclusive for fans'), style: AppText.label1),
          const SizedBox(width: 8),
          Pill(gradient: const LinearGradient(colors: AppColors.goldGradient), child: Text(tr('Money-can\'t-buy'), style: AppText.caption1.copyWith(color: AppColors.brandDarkest, fontWeight: FontWeight.w800))),
        ]),
        const SizedBox(height: 4),
        Text(tr('Experiences you can\'t get anywhere else.'), style: AppText.body3Regular),
        const SizedBox(height: 12),
        SizedBox(
          height: 224,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            itemCount: _exclusive.length,
            separatorBuilder: (_, __) => const SizedBox(width: 12),
            itemBuilder: (_, i) {
              final e = _exclusive[i];
              return _ExclusiveCard(
                title: e.$1, sub: e.$2, image: e.$3, points: e.$4,
                onTap: () => redeemForVoucher(context, title: e.$1, category: 'Experience', points: e.$4, sponsor: 'FC Schalke 04'),
              );
            },
          ),
        ),
        const SizedBox(height: 24),
        // ── Ways to redeem (categories) ──
        const SectionHeader('Ways to redeem', action: null),
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
        const SizedBox(height: 12),
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
        const SizedBox(height: 22),
        // ── My Vouchers (reactive open count) — what you've redeemed ──
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
        const SizedBox(height: 16),
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

/// Exclusive experience card — full-bleed photo, dark gradient scrim, a gold
/// "fans only" badge, title and points. The aspirational, money-can't-buy tier.
class _ExclusiveCard extends StatelessWidget {
  final String title;
  final String sub;
  final String image;
  final int points;
  final VoidCallback onTap;
  const _ExclusiveCard({required this.title, required this.sub, required this.image, required this.points, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 250,
        clipBehavior: Clip.antiAlias,
        decoration: BoxDecoration(borderRadius: BorderRadius.circular(AppRadii.card)),
        child: Stack(fit: StackFit.expand, children: [
          AssetImg(image, fit: BoxFit.cover, fallbackIcon: Icons.stadium_rounded),
          // Dark scrim for legibility.
          Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter, end: Alignment.bottomCenter,
                colors: [Color(0x22000000), Color(0x00000000), Color(0xE6000B18)],
                stops: [0, 0.35, 1],
              ),
            ),
          ),
          Positioned(top: 12, left: 12, child: Pill(
            gradient: const LinearGradient(colors: AppColors.goldGradient),
            child: Row(mainAxisSize: MainAxisSize.min, children: [
              const Icon(Icons.lock_open_rounded, size: 11, color: AppColors.brandDarkest),
              const SizedBox(width: 4),
              Text(tr('Fans only'), style: AppText.caption1.copyWith(color: AppColors.brandDarkest, fontWeight: FontWeight.w800)),
            ]),
          )),
          Positioned(left: 14, right: 14, bottom: 14, child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text(tr(title), maxLines: 2, overflow: TextOverflow.ellipsis, style: AppText.label1.copyWith(color: Colors.white, fontSize: 17)),
            const SizedBox(height: 2),
            Text(tr(sub), maxLines: 1, overflow: TextOverflow.ellipsis, style: AppText.body3.copyWith(color: Colors.white70)),
            const SizedBox(height: 10),
            Row(children: [
              const Icon(Icons.hexagon_rounded, size: 14, color: AppColors.gold),
              const SizedBox(width: 5),
              Text('${FanModel.fmtPublic(points)} ${tr('pts')}', style: AppText.body2.copyWith(color: Colors.white, fontWeight: FontWeight.w800)),
              const Spacer(),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
                decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(999)),
                child: Text(tr('Redeem'), style: AppText.caption1.copyWith(color: AppColors.brandDarkest, fontWeight: FontWeight.w800)),
              ),
            ]),
          ])),
        ]),
      ),
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
