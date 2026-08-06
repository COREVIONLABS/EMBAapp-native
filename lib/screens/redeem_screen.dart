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
import 'raffles_screen.dart';
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

  void _redeem(BuildContext context, _Offer o) {
    final (badge, title, _, points, category, sponsor, _) = o;
    redeemForVoucher(context, title: '$badge ${tr(title)}', category: category, points: points, sponsor: sponsor);
  }

  // Compact balance chip for the tab header (Socios-style points count).
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
                Row(children: [
                  const Icon(Icons.hexagon_rounded, size: 18, color: AppColors.gold),
                  const SizedBox(width: 6),
                  Text(FanModel.pointsFormatted, style: AppText.h4.copyWith(color: Colors.white, fontSize: 26)),
                  const SizedBox(width: 6),
                  Padding(padding: const EdgeInsets.only(top: 4), child: Text(tr('points'), style: AppText.body3.copyWith(color: Colors.white70))),
                ]),
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

        // ── 1) Value vouchers ──
        Row(children: [
          Expanded(child: Text(tr('Value vouchers'), style: AppText.label1)),
          _hint(tr('Redeem at the club')),
        ]),
        const SizedBox(height: 4),
        Text(tr('A fixed € amount for the Fanshop or a sponsor.'), style: AppText.body3Regular),
        const SizedBox(height: 12),
        _grid(context, _valueVouchers, valueBadge: true),
        const SizedBox(height: 24),

        // ── 2) Discount vouchers ──
        Text(tr('Discount vouchers'), style: AppText.label1),
        const SizedBox(height: 4),
        Text(tr('A fixed % off tickets, Fanshop and sponsors.'), style: AppText.body3Regular),
        const SizedBox(height: 12),
        _grid(context, _discountVouchers, valueBadge: false),
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

  Widget _hint(String text) => Row(mainAxisSize: MainAxisSize.min, children: [
        Icon(Icons.storefront_rounded, size: 13, color: AppColors.textLight),
        const SizedBox(width: 4),
        Text(text, style: AppText.caption1.copyWith(color: AppColors.textLight, fontWeight: FontWeight.w700)),
      ]);

  // 2-column offer grid.
  Widget _grid(BuildContext context, List<_Offer> items, {required bool valueBadge}) {
    final rows = <Widget>[];
    for (var i = 0; i < items.length; i += 2) {
      rows.add(Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Expanded(child: _OfferCard(offer: items[i], valueBadge: valueBadge, onTap: () => _redeem(context, items[i]))),
        const SizedBox(width: 12),
        Expanded(
          child: i + 1 < items.length
              ? _OfferCard(offer: items[i + 1], valueBadge: valueBadge, onTap: () => _redeem(context, items[i + 1]))
              : const SizedBox(),
        ),
      ]));
      if (i + 2 < items.length) rows.add(const SizedBox(height: 12));
    }
    return Column(children: rows);
  }
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
