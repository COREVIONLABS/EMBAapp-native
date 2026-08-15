import 'package:flutter/material.dart';
import '../theme/app_theme.dart';
import '../widgets/sub_scaffold.dart';
import '../widgets/app_widgets.dart';
import '../widgets/hub_widgets.dart';
import '../model/fan_model.dart';
import '../model/voucher_store.dart';
import '../model/partners.dart';
import '../widgets/voucher_flow.dart';
import 'my_vouchers_screen.dart';
import 'buy_points_screen.dart';
import 'raffles_screen.dart';
import 'partners_screen.dart';
import '../l10n/strings.dart';

/// Redeem Points — deliberately simple. Points can only be turned into two
/// things:
///   1. **Vouchers** redeemed at the club — value vouchers (€) or % discount
///      vouchers at the Fanshop, ticket shop and club sponsors.
///   2. **Tombola lots** — entries into the monthly prize draws.
/// Nothing else. That keeps the model easy to understand and easy to run.
///
/// Offer: (badge, title, subtitle, points, category, sponsor, icon)
typedef _Offer = (String, String, String, int, String, String, IconData);

/// Shared redeem action — turns an offer into a voucher (used by the Redeem
/// tab and the "see all" list screen).
void _redeemOffer(BuildContext context, _Offer o) {
  final (badge, title, _, points, category, sponsor, _) = o;
  redeemForVoucher(context, title: '$badge ${tr(title)}', category: category, points: points, sponsor: sponsor);
}

class RedeemScreen extends StatelessWidget {
  final bool isTab;
  const RedeemScreen({super.key, this.isTab = false});

  // ── Value vouchers (Wertgutscheine) — a fixed € amount to spend at the club
  //    Fanshop or a sponsor. Badge = the € value.
  static const _valueVouchers = <_Offer>[
    ('€10', 'Fanshop voucher', 'FC Schalke 04', 1000, 'Fanshop', 'FC Schalke 04', Icons.storefront_rounded),
    ('€25', 'Fanshop voucher', 'FC Schalke 04', 2400, 'Fanshop', 'FC Schalke 04', Icons.storefront_rounded),
    ('€10', 'REWE voucher', 'REWE', 1000, 'Sponsor', 'REWE', Icons.shopping_cart_rounded),
    ('€15', 'VELTINS voucher', 'Veltins', 1400, 'Sponsor', 'Veltins', Icons.sports_bar_rounded),
  ];

  // ── Discount vouchers (Rabatt-Gutscheine) — a fixed % off. Badge = the %.
  static const _discountVouchers = <_Offer>[
    ('-25%', 'Home jersey 25/26', 'Fanshop', 1200, 'Fanshop', 'adidas', Icons.checkroom_rounded),
    ('-50%', 'Home scarf 25/26', 'Fanshop', 500, 'Fanshop', 'adidas', Icons.style_rounded),
    ('-25%', 'Home-match ticket', 'Tickets', 900, 'Tickets', 'FC Schalke 04', Icons.confirmation_number_rounded),
    ('-10%', 'Vivawest living', 'Sponsor', 400, 'Sponsor', 'Vivawest', Icons.apartment_rounded),
  ];

  void _push(BuildContext context, Widget s) =>
      Navigator.of(context).push(MaterialPageRoute(builder: (_) => s));


  // Compact balance chip for the tab header (Socios-style points count).
  Widget _pointsChip() => Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
        decoration: BoxDecoration(color: AppColors.brandLightest, borderRadius: BorderRadius.circular(999)),
        child: Row(mainAxisSize: MainAxisSize.min, children: [
          const Icon(Icons.hexagon_rounded, size: 14, color: AppColors.brandPrimary),
          const SizedBox(width: 5),
          ValueListenableBuilder<int>(
            valueListenable: pointsNotifier,
            builder: (_, __, ___) => Text(FanModel.pointsFormatted, style: AppText.caption1.copyWith(color: AppColors.brandPrimary, fontWeight: FontWeight.w800)),
          ),
        ]),
      );

  @override
  Widget build(BuildContext context) {
    return SubScaffold(
      title: tr('Redeem'),
      showBack: !isTab,
      trailing: isTab ? _pointsChip() : null,
      children: [
        // ── What points are for (the first thing a fan reads) — a clean hero
        //    with your balance and the two ways to spend it ──
        Container(
          clipBehavior: Clip.antiAlias,
          decoration: BoxDecoration(borderRadius: BorderRadius.circular(AppRadii.card)),
          child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
            // Headline band — deep brand gradient with the live balance.
            Container(
              padding: const EdgeInsets.fromLTRB(18, 18, 18, 16),
              decoration: const BoxDecoration(gradient: LinearGradient(begin: Alignment.topLeft, end: Alignment.bottomRight, colors: AppColors.pointsGradient)),
              child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Text(tr('Turn points into rewards'), style: AppText.label1.copyWith(color: Colors.white)),
                const SizedBox(height: 4),
                Text(tr('Two simple ways to spend your points.'), style: AppText.body3.copyWith(color: Colors.white70)),
                const SizedBox(height: 14),
                ValueListenableBuilder<int>(
                  valueListenable: pointsNotifier,
                  builder: (context, _, __) => Row(children: [
                    const Icon(Icons.hexagon_rounded, size: 18, color: AppColors.gold),
                    const SizedBox(width: 6),
                    Text(FanModel.pointsFormatted, style: AppText.h4.copyWith(color: Colors.white, fontSize: 26)),
                    const SizedBox(width: 6),
                    Padding(padding: const EdgeInsets.only(top: 4), child: Text('${tr('points')} · ${tr('≈')} ${FanModel.balanceEuro}', style: AppText.body3.copyWith(color: Colors.white70))),
                  ]),
                ),
              ]),
            ),
            // Two pathways.
            Container(
              color: AppColors.surface,
              padding: const EdgeInsets.all(12),
              child: Row(children: [
                Expanded(child: _pathTile(Icons.confirmation_number_rounded, tr('Vouchers'), tr('€-value or % off'))),
                const SizedBox(width: 12),
                Expanded(child: _pathTile(Icons.local_activity_rounded, tr('Tombola lots'), tr('Win monthly prizes'))),
              ]),
            ),
          ]),
        ),
        const SizedBox(height: 24),

        // ── Partners near you — local merchant marketplace (points → voucher) ──
        Row(children: [
          Expanded(child: Text(tr('Partners near you'), style: AppText.label1)),
          Tappable(
            onTap: () => _push(context, const PartnersScreen()),
            child: Row(mainAxisSize: MainAxisSize.min, children: [
              Text(tr('See all'), style: AppText.body3.copyWith(color: AppColors.brandPrimary, fontWeight: FontWeight.w700)),
              Icon(Icons.chevron_right_rounded, size: 18, color: AppColors.brandPrimary),
            ]),
          ),
        ]),
        const SizedBox(height: 4),
        Text(tr('Cafés, restaurants & shops around you — pay with points.'), style: AppText.body3Regular),
        const SizedBox(height: 12),
        Tappable(
          scale: 0.98,
          onTap: () => _push(context, const PartnersScreen()),
          child: Container(
            clipBehavior: Clip.antiAlias,
            decoration: BoxDecoration(color: AppColors.surface, borderRadius: BorderRadius.circular(AppRadii.card), border: Border.all(color: AppColors.borderLightest)),
            child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
              // Mini map strip with a "near me" pill.
              SizedBox(
                height: 96,
                child: Stack(fit: StackFit.expand, children: [
                  CustomPaint(painter: _MiniMapPainter()),
                  Positioned(left: 20, top: 30, child: _pin('🥐', AppColors.gold)),
                  Positioned(left: 120, top: 52, child: _pin('☕', AppColors.surface)),
                  Positioned(right: 40, top: 22, child: _pin('🍕', AppColors.gold)),
                  Positioned(right: 110, bottom: 14, child: _pin('🏋️', AppColors.surface)),
                  Positioned(
                    right: 12, top: 12,
                    child: Pill(color: AppColors.brandPrimary, child: Row(mainAxisSize: MainAxisSize.min, children: [
                      const Icon(Icons.near_me_rounded, size: 12, color: Colors.white),
                      const SizedBox(width: 4),
                      Text(tr('Near me'), style: AppText.caption1.copyWith(color: Colors.white, fontWeight: FontWeight.w800)),
                    ])),
                  ),
                ]),
              ),
              Padding(
                padding: const EdgeInsets.all(14),
                child: Row(children: [
                  Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                    Text(trp('{n} partners with live offers', n: '${partnerStore.partnerCount}'), style: AppText.body2.copyWith(color: AppColors.textDarker, fontWeight: FontWeight.w800)),
                    const SizedBox(height: 2),
                    Text(tr('% off · 1+1 · € vouchers — redeem in-store'), style: AppText.body3Regular),
                  ])),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                    decoration: BoxDecoration(color: AppColors.brandPrimary, borderRadius: BorderRadius.circular(999)),
                    child: Row(mainAxisSize: MainAxisSize.min, children: [
                      const Icon(Icons.map_rounded, size: 15, color: Colors.white),
                      const SizedBox(width: 6),
                      Text(tr('Explore'), style: AppText.body3.copyWith(color: Colors.white, fontWeight: FontWeight.w800)),
                    ]),
                  ),
                ]),
              ),
            ]),
          ),
        ),
        const SizedBox(height: 24),

        // ── 1) Value vouchers — swipeable row + See all ──
        _sectionHead(context, title: tr('Value vouchers'), subtitle: tr('A fixed € amount for the Fanshop or a sponsor.'), list: _valueVouchers, valueBadge: true),
        const SizedBox(height: 12),
        _offerRow(context, _valueVouchers, valueBadge: true),
        const SizedBox(height: 24),

        // ── 2) Discount vouchers — swipeable row + See all ──
        _sectionHead(context, title: tr('Discount vouchers'), subtitle: tr('A fixed % off tickets, Fanshop and sponsors.'), list: _discountVouchers, valueBadge: false),
        const SizedBox(height: 12),
        _offerRow(context, _discountVouchers, valueBadge: false),
        const SizedBox(height: 24),

        // ── 3) Tombola lots ──
        Text(tr('Tombola lots'), style: AppText.label1),
        const SizedBox(height: 12),
        Tappable(
          scale: 0.98,
          onTap: () => _push(context, const RafflesScreen()),
          child: Container(
            clipBehavior: Clip.antiAlias,
            decoration: BoxDecoration(color: AppColors.surface, borderRadius: BorderRadius.circular(AppRadii.card), border: Border.all(color: AppColors.borderLightest)),
            child: Row(children: [
              Container(
                width: 74, height: 74,
                decoration: BoxDecoration(color: AppColors.brandLightest, borderRadius: BorderRadius.circular(16)),
                margin: const EdgeInsets.all(12),
                child: const Icon(Icons.local_activity_rounded, color: AppColors.brandPrimary, size: 32),
              ),
              Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Text(tr('Enter the monthly tombola'), style: AppText.body2.copyWith(color: AppColors.textDarker, fontWeight: FontWeight.w700)),
                const SizedBox(height: 2),
                Text(tr('Spend points on lots to win VIP tickets, signed gear & experiences.'), maxLines: 2, overflow: TextOverflow.ellipsis, style: AppText.body3Regular),
                const SizedBox(height: 6),
                Row(children: [
                  const Icon(Icons.hexagon_rounded, size: 13, color: AppColors.brandPrimary),
                  const SizedBox(width: 4),
                  Text('${tr('from')} 500 ${tr('pts')} / ${tr('lot')}', style: AppText.body3.copyWith(color: AppColors.brandPrimary, fontWeight: FontWeight.w800)),
                ]),
              ])),
              Padding(padding: const EdgeInsets.only(right: 8), child: Icon(Icons.chevron_right_rounded, color: AppColors.textLight)),
            ]),
          ),
        ),
        const SizedBox(height: 24),

        // ── Always available: My Vouchers + Top up ──
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
        const SizedBox(height: 12),
        HubListRow(
          icon: Icons.add_rounded,
          title: 'Top up points',
          subtitle: 'Reach your reward faster · optional',
          iconColor: AppColors.brandDarkest,
          onTap: () => _push(context, const BuyPointsScreen()),
        ),
        const SizedBox(height: 14),
        Row(children: [
          Icon(Icons.lock_outline_rounded, size: 14, color: AppColors.textLight),
          const SizedBox(width: 6),
          Expanded(child: Text(tr('Points are never cashed out — they only become vouchers or tombola lots.'),
              style: AppText.caption1.copyWith(color: AppColors.textLight))),
        ]),
      ],
    );
  }

  // A small map pin (emoji chip) for the Partners mini-map strip.
  Widget _pin(String emoji, Color bg) => Container(
        padding: const EdgeInsets.all(6),
        decoration: BoxDecoration(
          color: bg,
          shape: BoxShape.circle,
          border: Border.all(color: bg == AppColors.surface ? AppColors.borderLightest : bg, width: 2),
          boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.12), blurRadius: 5, offset: const Offset(0, 2))],
        ),
        child: Text(emoji, style: const TextStyle(fontSize: 14)),
      );

  // One of the two "how to spend points" pathway tiles in the intro hero.
  Widget _pathTile(IconData icon, String title, String sub) => Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(color: AppColors.brandLightest, borderRadius: BorderRadius.circular(AppRadii.tile)),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Container(width: 34, height: 34, decoration: BoxDecoration(color: AppColors.surface, borderRadius: BorderRadius.circular(10)), child: Icon(icon, color: AppColors.brandPrimary, size: 18)),
          const SizedBox(height: 10),
          Text(title, maxLines: 1, overflow: TextOverflow.ellipsis, style: AppText.body2.copyWith(color: AppColors.onAccent, fontWeight: FontWeight.w800)),
          const SizedBox(height: 1),
          Text(sub, maxLines: 1, overflow: TextOverflow.ellipsis, style: AppText.body3.copyWith(color: AppColors.onAccent)),
        ]),
      );

  // Section header with a title, a "See all" link, and a subtitle line under it.
  Widget _sectionHead(BuildContext context, {required String title, required String subtitle, required List<_Offer> list, required bool valueBadge}) {
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Row(children: [
        Expanded(child: Text(title, style: AppText.label1)),
        Tappable(
          onTap: () => _push(context, _VoucherListScreen(title: title, subtitle: subtitle, list: list, valueBadge: valueBadge)),
          child: Row(mainAxisSize: MainAxisSize.min, children: [
            Text(tr('See all'), style: AppText.body3.copyWith(color: AppColors.brandPrimary, fontWeight: FontWeight.w700)),
            Icon(Icons.chevron_right_rounded, size: 18, color: AppColors.brandPrimary),
          ]),
        ),
      ]),
      const SizedBox(height: 4),
      Text(subtitle, style: AppText.body3Regular),
    ]);
  }

  // Horizontal, swipeable row of offer cards.
  Widget _offerRow(BuildContext context, List<_Offer> items, {required bool valueBadge}) {
    return SizedBox(
      height: 176,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        clipBehavior: Clip.none,
        itemCount: items.length,
        separatorBuilder: (_, __) => const SizedBox(width: 12),
        itemBuilder: (_, i) => SizedBox(
          width: 168,
          child: _OfferCard(offer: items[i], valueBadge: valueBadge, onTap: () => _redeemOffer(context, items[i])),
        ),
      ),
    );
  }
}

/// "See all" list for a voucher category — a 2-column grid of every offer.
class _VoucherListScreen extends StatelessWidget {
  final String title;
  final String subtitle;
  final List<_Offer> list;
  final bool valueBadge;
  const _VoucherListScreen({required this.title, required this.subtitle, required this.list, required this.valueBadge});

  @override
  Widget build(BuildContext context) {
    final rows = <Widget>[];
    for (var i = 0; i < list.length; i += 2) {
      rows.add(Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Expanded(child: _OfferCard(offer: list[i], valueBadge: valueBadge, onTap: () => _redeemOffer(context, list[i]))),
        const SizedBox(width: 12),
        Expanded(
          child: i + 1 < list.length
              ? _OfferCard(offer: list[i + 1], valueBadge: valueBadge, onTap: () => _redeemOffer(context, list[i + 1]))
              : const SizedBox(),
        ),
      ]));
      if (i + 2 < list.length) rows.add(const SizedBox(height: 12));
    }
    return SubScaffold(
      title: title,
      children: [
        Text(subtitle, style: AppText.body3Regular),
        const SizedBox(height: 16),
        ...rows,
      ],
    );
  }
}

/// Faint street-grid backdrop for the Partners mini-map strip on the Redeem tab.
class _MiniMapPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    canvas.drawRect(Offset.zero & size, Paint()..color = AppColors.surfaceMinimal);
    final line = Paint()..color = AppColors.borderLightest..strokeWidth = 1;
    for (double x = 0; x < size.width; x += 30) {
      canvas.drawLine(Offset(x, 0), Offset(x, size.height), line);
    }
    for (double y = 0; y < size.height; y += 26) {
      canvas.drawLine(Offset(0, y), Offset(size.width, y), line);
    }
    // One highlighted "road".
    canvas.drawLine(Offset(0, size.height * 0.62), Offset(size.width, size.height * 0.42), Paint()..color = AppColors.brandPrimary.withValues(alpha: 0.18)..strokeWidth = 5);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

/// A clean voucher-offer card: a small icon, a value/discount badge, the title
/// and sub, and the points price with a "Get voucher" arrow. No busy photos —
/// calm and premium, so the badge does the talking.
class _OfferCard extends StatelessWidget {
  final _Offer offer;
  final bool valueBadge;
  final VoidCallback onTap;
  const _OfferCard({required this.offer, required this.valueBadge, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final (badge, title, sub, points, _, _, icon) = offer;
    return Tappable(
      scale: 0.97,
      onTap: onTap,
      child: Container(
        height: 176,
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(AppRadii.card),
          border: Border.all(color: AppColors.borderLightest),
        ),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Row(children: [
            Container(width: 38, height: 38, decoration: BoxDecoration(color: AppColors.brandLightest, borderRadius: BorderRadius.circular(11)), child: Icon(icon, color: AppColors.brandPrimary, size: 20)),
            const Spacer(),
            // Value = gold pill; discount = brand pill.
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 5),
              decoration: BoxDecoration(
                color: valueBadge ? AppColors.gold.withValues(alpha: 0.16) : AppColors.brandPrimary,
                borderRadius: BorderRadius.circular(AppRadii.chip),
              ),
              child: Text(badge, style: AppText.caption1.copyWith(color: valueBadge ? const Color(0xFF9A6B00) : Colors.white, fontWeight: FontWeight.w800, fontSize: 12)),
            ),
          ]),
          const Spacer(),
          Text(tr(title), maxLines: 2, overflow: TextOverflow.ellipsis, style: AppText.body2.copyWith(color: AppColors.textDarker, fontWeight: FontWeight.w700, height: 1.15)),
          const SizedBox(height: 2),
          Text(tr(sub), maxLines: 1, overflow: TextOverflow.ellipsis, style: AppText.body3Regular),
          const SizedBox(height: 10),
          Row(children: [
            const Icon(Icons.hexagon_rounded, size: 15, color: AppColors.brandPrimary),
            const SizedBox(width: 5),
            Expanded(child: Text(FanModel.fmtPublic(points), maxLines: 1, overflow: TextOverflow.ellipsis, style: AppText.body2.copyWith(color: AppColors.textDarker, fontWeight: FontWeight.w800))),
            Container(
              width: 30, height: 30,
              decoration: BoxDecoration(color: AppColors.brandPrimary, borderRadius: BorderRadius.circular(9)),
              child: const Icon(Icons.arrow_forward_rounded, color: Colors.white, size: 17),
            ),
          ]),
        ]),
      ),
    );
  }
}
