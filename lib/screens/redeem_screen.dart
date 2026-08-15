import 'package:flutter/material.dart';
import '../theme/app_theme.dart';
import '../widgets/sub_scaffold.dart';
import '../widgets/app_widgets.dart';
import '../widgets/hub_widgets.dart';
import '../widgets/action_sheets.dart';
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

class RedeemScreen extends StatefulWidget {
  final bool isTab;
  const RedeemScreen({super.key, this.isTab = false});
  @override
  State<RedeemScreen> createState() => _RedeemScreenState();
}

class _RedeemScreenState extends State<RedeemScreen> {
  // Selected voucher tab in the merged section: 0 = € value, 1 = % discount.
  int _vTab = 0;

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

  // Clear the quick-access grid (with a confirm so it isn't lost by accident).
  Future<void> _dismissQuickNav(BuildContext context) async {
    final ok = await showConfirmDialog(
      context,
      title: 'Hide quick access?',
      message: 'You can turn this shortcut grid back on anytime under Account → Demo.',
      confirmLabel: 'Hide',
    );
    if (ok) redeemQuickNavNotifier.value = false;
  }

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
      showBack: !widget.isTab,
      trailing: widget.isTab ? _pointsChip() : null,
      children: [
        // ── Quick access — dismissible 2×2 grid (mirrors Home "How Fan+ works")
        //    so a fan can jump straight to a way of spending points, or clear it
        //    away for a cleaner screen. ──
        ValueListenableBuilder<bool>(
          valueListenable: redeemQuickNavNotifier,
          builder: (context, show, __) => show
              ? Padding(
                  padding: const EdgeInsets.only(bottom: 24),
                  child: QuickNavCard(
                    title: 'Redeem your points',
                    onDismiss: () => _dismissQuickNav(context),
                    items: [
                      QuickNavItem(icon: Icons.euro_rounded, color: AppColors.gold, label: tr('Value vouchers'), sub: tr('€ off'),
                          onTap: () => _push(context, _VoucherListScreen(title: tr('Value vouchers'), subtitle: tr('A fixed € amount for the Fanshop or a sponsor.'), list: _valueVouchers, valueBadge: true))),
                      QuickNavItem(icon: Icons.percent_rounded, color: AppColors.brandPrimary, label: tr('% vouchers'), sub: tr('% off'),
                          onTap: () => _push(context, _VoucherListScreen(title: tr('Discount vouchers'), subtitle: tr('A fixed % off tickets, Fanshop and sponsors.'), list: _discountVouchers, valueBadge: false))),
                      QuickNavItem(icon: Icons.storefront_rounded, color: const Color(0xFF2E7D32), label: tr('Partner deals'), sub: tr('Near you'),
                          onTap: () => _push(context, const PartnersScreen())),
                      QuickNavItem(icon: Icons.local_activity_rounded, color: const Color(0xFFC62828), label: tr('Auction & tombola'), sub: tr('Win prizes'),
                          onTap: () => _push(context, const RafflesScreen())),
                    ],
                  ),
                )
              : const SizedBox.shrink(),
        ),

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
        Text(trp('{n} cafés, restaurants & shops near you — pay with points.', n: '${partnerStore.partnerCount}'), style: AppText.body3Regular),
        const SizedBox(height: 12),
        // Real partner rail (nearest few) + an "on the map" tile — previews real
        // inventory instead of a decorative fake map.
        SizedBox(
          height: 150,
          child: ListView(
            scrollDirection: Axis.horizontal,
            clipBehavior: Clip.none,
            children: [
              for (final p in partnerStore.nearest.take(4)) ...[
                _MiniPartnerCard(partner: p, onTap: () => _push(context, PartnerDetailScreen(id: p.id))),
                const SizedBox(width: 12),
              ],
              _MapTile(onTap: () => _push(context, const PartnersScreen())),
            ],
          ),
        ),
        const SizedBox(height: 24),

        // ── Vouchers — one section with a € / % toggle (was two stacked
        //    sections; merging shortens the page and makes the choice clearer) ──
        Row(children: [
          Expanded(child: Text(tr('Vouchers'), style: AppText.label1)),
          Tappable(
            onTap: () {
              final value = _vTab == 0;
              _push(context, _VoucherListScreen(
                title: value ? tr('Value vouchers') : tr('Discount vouchers'),
                subtitle: value ? tr('A fixed € amount for the Fanshop or a sponsor.') : tr('A fixed % off tickets, Fanshop and sponsors.'),
                list: value ? _valueVouchers : _discountVouchers,
                valueBadge: value,
              ));
            },
            child: Row(mainAxisSize: MainAxisSize.min, children: [
              Text(tr('See all'), style: AppText.body3.copyWith(color: AppColors.brandPrimary, fontWeight: FontWeight.w700)),
              Icon(Icons.chevron_right_rounded, size: 18, color: AppColors.brandPrimary),
            ]),
          ),
        ]),
        const SizedBox(height: 10),
        // € / % segmented toggle.
        SegmentedToggle(labels: [tr('€ value'), tr('% off')], selected: _vTab, onTap: (i) => setState(() => _vTab = i)),
        const SizedBox(height: 8),
        Text(_vTab == 0 ? tr('A fixed € amount for the Fanshop or a sponsor.') : tr('A fixed % off tickets, Fanshop and sponsors.'), style: AppText.body3Regular),
        const SizedBox(height: 12),
        _offerRow(context, _vTab == 0 ? _valueVouchers : _discountVouchers, valueBadge: _vTab == 0),
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
                  Text('${tr('Free with membership')} · +200 ${tr('pts')} / ${tr('extra lot')}', style: AppText.body3.copyWith(color: AppColors.brandPrimary, fontWeight: FontWeight.w800)),
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

/// Compact partner card for the Redeem-tab "near you" rail — real partner data
/// (emoji, name, best offer, distance, recommend %). Taps into partner detail.
class _MiniPartnerCard extends StatelessWidget {
  final Partner partner;
  final VoidCallback onTap;
  const _MiniPartnerCard({required this.partner, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final p = partner;
    return Tappable(
      scale: 0.97,
      onTap: onTap,
      child: Container(
        width: 156,
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(AppRadii.card),
          border: Border.all(color: p.sponsored ? AppColors.gold.withValues(alpha: 0.5) : AppColors.borderLightest),
        ),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Row(children: [
            Container(width: 40, height: 40, decoration: BoxDecoration(color: p.color.withValues(alpha: 0.14), borderRadius: BorderRadius.circular(11)), alignment: Alignment.center, child: Text(p.emoji, style: const TextStyle(fontSize: 20))),
            const Spacer(),
            if (p.sponsored) ...[
              Container(padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2), decoration: BoxDecoration(color: AppColors.gold, borderRadius: BorderRadius.circular(5)), child: Text(tr('Ad'), style: AppText.caption1.copyWith(color: AppColors.brandDarkest, fontWeight: FontWeight.w800, fontSize: 9))),
              const SizedBox(width: 5),
            ],
            Pill(color: AppColors.brandLightest, child: Text(p.bestOffer.badge, style: AppText.caption1.copyWith(color: AppColors.brandPrimary, fontWeight: FontWeight.w800))),
          ]),
          const SizedBox(height: 10),
          Text(p.name, maxLines: 1, overflow: TextOverflow.ellipsis, style: AppText.body2.copyWith(color: AppColors.textDarker, fontWeight: FontWeight.w800)),
          const SizedBox(height: 3),
          Row(children: [
            Icon(Icons.near_me_rounded, size: 12, color: AppColors.textLight),
            const SizedBox(width: 3),
            Text(p.distanceLabel, style: AppText.caption1.copyWith(color: AppColors.textLight)),
            const SizedBox(width: 8),
            const Icon(Icons.thumb_up_rounded, size: 11, color: AppColors.success),
            const SizedBox(width: 3),
            Text('${p.recommendPct}%', style: AppText.caption1.copyWith(color: AppColors.textNormal, fontWeight: FontWeight.w700)),
          ]),
        ]),
      ),
    );
  }
}

/// Trailing "on the map" tile that opens the full partner marketplace.
class _MapTile extends StatelessWidget {
  final VoidCallback onTap;
  const _MapTile({required this.onTap});
  @override
  Widget build(BuildContext context) {
    return Tappable(
      scale: 0.97,
      onTap: onTap,
      child: Container(
        width: 128,
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          gradient: const LinearGradient(begin: Alignment.topLeft, end: Alignment.bottomRight, colors: AppColors.pointsGradient),
          borderRadius: BorderRadius.circular(AppRadii.card),
        ),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
          Container(width: 40, height: 40, decoration: BoxDecoration(color: Colors.white.withValues(alpha: 0.16), borderRadius: BorderRadius.circular(11)), child: const Icon(Icons.map_rounded, color: Colors.white, size: 22)),
          Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text(tr('All partners'), style: AppText.body2.copyWith(color: Colors.white, fontWeight: FontWeight.w800)),
            const SizedBox(height: 2),
            Row(children: [
              Text(tr('On the map'), style: AppText.caption1.copyWith(color: Colors.white70)),
              const Icon(Icons.chevron_right_rounded, size: 14, color: Colors.white70),
            ]),
          ]),
        ]),
      ),
    );
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
