import 'package:flutter/material.dart';
import '../theme/app_theme.dart';
import '../widgets/app_widgets.dart';
import '../widgets/hub_widgets.dart';
import '../widgets/sub_scaffold.dart';
import '../widgets/action_sheets.dart';
import '../model/voucher_store.dart';
import 'voucher_screen.dart';
import 'partners_screen.dart';
import '../l10n/strings.dart';

/// A single member-discount partner. `sponsored` flags a paid "Top partner"
/// placement (labelled "Anzeige" per EU 2019/1150). `rating` drives the little
/// star line so the screen reads like a marketplace (noon-style), not a plain
/// list.
class _Partner {
  final String name;
  final String category;
  final String discount;
  final String sub;
  final IconData icon;
  final Color color;
  final String rating;
  final bool sponsored;
  final String distance; // 'm'/'km' near the arena, or 'Online'/'Arena'
  const _Partner(this.name, this.category, this.discount, this.sub, this.icon, this.color, this.rating, this.sponsored, this.distance);
}

/// Member discounts ("Vorteile") — rebuilt as a food-delivery-style marketplace
/// (noon inspired): a search field, a carousel of paid "Top partner" placements
/// (labelled "Anzeige"), category chips to filter, then a rich list of partner
/// offer cards. Every offer is a Fan+ perk: claiming issues a voucher (code)
/// the fan redeems in-store or online — no points spent.
class MemberDiscountsScreen extends StatefulWidget {
  const MemberDiscountsScreen({super.key});

  @override
  State<MemberDiscountsScreen> createState() => _MemberDiscountsScreenState();
}

class _MemberDiscountsScreenState extends State<MemberDiscountsScreen> {
  String _cat = 'All';

  // ── Partner inventory ──
  //  • The first block are paid, sponsored "Top partner" placements — the
  //    sellable ad inventory (McDonald's / Pizza Hut style). Always labelled
  //    "Anzeige".
  //  • The rest are the club's official & regional member partners.
  static const _partners = <_Partner>[
    // Sponsored / paid placements (Anzeige)
    _Partner("McDonald's", 'Fast food', '20% off', 'On every matchday menu', Icons.lunch_dining_rounded, Color(0xFFDA291C), '4.5', true, '300 m'),
    _Partner('Pizza Hut', 'Fast food', '30% off', 'Large pizzas, home delivery', Icons.local_pizza_rounded, Color(0xFFE3000B), '4.3', true, '900 m'),
    _Partner('BURGER KING', 'Fast food', '2-for-1', 'Selected Whopper menus', Icons.fastfood_rounded, Color(0xFFD62300), '4.2', true, '1.1 km'),
    // Club & official
    _Partner('Official Fanshop', 'Club', '15% off', 'Jerseys, scarves & more', Icons.storefront_rounded, Color(0xFF004B9C), '4.8', false, 'Arena'),
    _Partner('adidas', 'Sportswear', '20% off', 'Online & in-store', Icons.sports_soccer_rounded, Color(0xFF111111), '4.7', false, 'Online'),
    _Partner('Veltins', 'Beverages', '10% off', 'Matchday crates & more', Icons.sports_bar_rounded, Color(0xFF00623A), '4.4', false, '1.5 km'),
    _Partner('Vivawest', 'Housing', '10% off', 'Rent & services', Icons.apartment_rounded, Color(0xFF6A1B9A), '4.1', false, '2.0 km'),
    _Partner("Ernsting's family", 'Fashion', '15% off', 'Family fashion', Icons.checkroom_rounded, Color(0xFFE30613), '4.3', false, '1.2 km'),
    _Partner('REWE', 'Groceries', '5% off', 'In all REWE stores', Icons.shopping_cart_rounded, Color(0xFFC8102E), '4.6', false, '650 m'),
    _Partner('ZOOM Erlebniswelt', 'Local', '20% off', 'Gelsenkirchen zoo tickets', Icons.pets_rounded, Color(0xFF2E7D32), '4.7', false, '3.4 km'),
    _Partner('Cineworld GE', 'Local', '25% off', 'Cinema tickets on matchdays', Icons.local_movies_rounded, Color(0xFF5E35B1), '4.5', false, '2.1 km'),
    _Partner('McFit Gelsenkirchen', 'Fitness', '10% off', 'Monthly gym membership', Icons.fitness_center_rounded, Color(0xFFEF6C00), '4.0', false, '1.8 km'),
    _Partner('Trattoria Napoli', 'Dining', '15% off', 'Post-match dinner in GE', Icons.restaurant_rounded, Color(0xFFC62828), '4.6', false, '750 m'),
    _Partner('VRR / Bahn', 'Transport', '10% off', 'Matchday travel to the arena', Icons.directions_bus_rounded, Color(0xFF00695C), '4.2', false, 'Arena'),
  ];

  List<_Partner> get _sponsored => _partners.where((p) => p.sponsored).toList();

  // Partners with a real metric distance — for the "near you" rail & map.
  List<_Partner> get _nearby =>
      _partners.where((p) => p.distance.endsWith('m') || p.distance.endsWith('km')).toList();

  // Chip categories: "All" + the distinct categories, in first-seen order.
  List<String> get _categories {
    final seen = <String>['All'];
    for (final p in _partners) {
      if (!seen.contains(p.category)) seen.add(p.category);
    }
    return seen;
  }

  List<_Partner> get _filtered =>
      _cat == 'All' ? _partners : _partners.where((p) => p.category == _cat).toList();

  Future<void> _claim(String partner, String discount) async {
    final ok = await showConfirmDialog(
      context,
      title: 'Get this member voucher?',
      message: '$discount ${tr('at')} $partner · ${tr('redeem in-store or online.')}',
      confirmLabel: 'Get voucher',
    );
    if (!ok || !mounted) return;
    final v = voucherStore.issue(title: '$partner · $discount', category: 'Sponsor', points: 0, sponsor: partner);
    if (!mounted) return;
    await Navigator.of(context).push(MaterialPageRoute(builder: (_) => VoucherScreen.fromIssued(v)));
  }

  @override
  Widget build(BuildContext context) {
    final list = _filtered;
    return SubScaffold(
      title: tr('Member discounts'),
      children: [
        // ── Search ──
        HubSearchField(hint: 'Search partners & offers'),
        const SizedBox(height: 16),

        // ── Brand shortcut buttons (noon top-icon style) — the premium, separately
        //    sellable ad slots. Each is one sponsor's own tappable placement. ──
        SizedBox(
          height: 92,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            clipBehavior: Clip.none,
            itemCount: _sponsored.length,
            separatorBuilder: (_, __) => const SizedBox(width: 14),
            itemBuilder: (_, i) => _BrandButton(partner: _sponsored[i], onTap: () => _claim(_sponsored[i].name, _sponsored[i].discount)),
          ),
        ),
        const SizedBox(height: 18),

        // ── Intro strip: what these are ──
        Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(color: AppColors.brandLightest, borderRadius: BorderRadius.circular(AppRadii.card)),
          child: Row(children: [
            Container(width: 40, height: 40, decoration: BoxDecoration(color: AppColors.gold.withValues(alpha: 0.16), borderRadius: BorderRadius.circular(11)), child: const Icon(Icons.workspace_premium_rounded, color: AppColors.gold, size: 22)),
            const SizedBox(width: 12),
            Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text(tr('Free member discounts'), style: AppText.body2.copyWith(color: AppColors.onAccent, fontWeight: FontWeight.w800)),
              Text(tr('Claim a voucher, redeem it at the partner. As often as you like.'), style: AppText.body3.copyWith(color: AppColors.onAccent)),
            ])),
          ]),
        ),
        const SizedBox(height: 22),

        // ── Top partners — paid placements, labelled "Anzeige" ──
        Row(children: [
          Text(tr('Top partners'), style: AppText.label1),
          const SizedBox(width: 8),
          Pill(color: AppColors.surfaceMinimal, child: Text(tr('Ad'), style: AppText.caption1.copyWith(color: AppColors.textLight, fontWeight: FontWeight.w800, fontSize: 10))),
        ]),
        const SizedBox(height: 4),
        Text(tr('Featured offers from our sponsors.'), style: AppText.body3Regular),
        const SizedBox(height: 12),
        SizedBox(
          height: 184,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            clipBehavior: Clip.none,
            itemCount: _sponsored.length,
            separatorBuilder: (_, __) => const SizedBox(width: 12),
            itemBuilder: (_, i) => _FeaturedCard(partner: _sponsored[i], onTap: () => _claim(_sponsored[i].name, _sponsored[i].discount)),
          ),
        ),
        const SizedBox(height: 24),

        // ── Near you — a map preview + a rail of the closest partners ──
        Row(children: [
          Expanded(child: Text(tr('Near you'), style: AppText.label1)),
          Tappable(
            onTap: () => Navigator.of(context).push(MaterialPageRoute(builder: (_) => const PartnersScreen())),
            child: Row(mainAxisSize: MainAxisSize.min, children: [
              Text(tr('Map'), style: AppText.body3.copyWith(color: AppColors.brandPrimary, fontWeight: FontWeight.w700)),
              Icon(Icons.chevron_right_rounded, size: 18, color: AppColors.brandPrimary),
            ]),
          ),
        ]),
        const SizedBox(height: 4),
        Text(tr('Partners around the VELTINS-Arena.'), style: AppText.body3Regular),
        const SizedBox(height: 12),
        SizedBox(
          height: 150,
          child: ListView(
            scrollDirection: Axis.horizontal,
            clipBehavior: Clip.none,
            children: [
              _MapTile(onTap: () => Navigator.of(context).push(MaterialPageRoute(builder: (_) => const PartnersScreen()))),
              const SizedBox(width: 12),
              for (final p in _nearby.take(6)) ...[
                _NearbyCard(partner: p, onTap: () => _claim(p.name, p.discount)),
                const SizedBox(width: 12),
              ],
            ],
          ),
        ),
        const SizedBox(height: 24),

        // ── Category chips ──
        SizedBox(
          height: 36,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            clipBehavior: Clip.none,
            itemCount: _categories.length,
            separatorBuilder: (_, __) => const SizedBox(width: 8),
            itemBuilder: (_, i) {
              final c = _categories[i];
              final sel = c == _cat;
              return Tappable(
                onTap: () => setState(() => _cat = c),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    color: sel ? AppColors.brandPrimary : AppColors.surface,
                    borderRadius: BorderRadius.circular(999),
                    border: Border.all(color: sel ? AppColors.brandPrimary : AppColors.borderLightest),
                  ),
                  child: Text(tr(c), style: AppText.body3.copyWith(color: sel ? Colors.white : AppColors.textNormal, fontWeight: FontWeight.w700)),
                ),
              );
            },
          ),
        ),
        const SizedBox(height: 18),

        // ── Partner list ──
        Row(children: [
          Expanded(child: Text(_cat == 'All' ? tr('All partners') : tr(_cat), style: AppText.label1)),
          Text('${list.length} ${tr('partners')}', style: AppText.body3.copyWith(color: AppColors.textLight)),
        ]),
        const SizedBox(height: 12),
        for (final p in list) ...[
          _PartnerRow(partner: p, onClaim: () => _claim(p.name, p.discount)),
          const SizedBox(height: 12),
        ],
        const SizedBox(height: 4),
        Row(children: [
          Icon(Icons.info_outline_rounded, size: 14, color: AppColors.textLight),
          const SizedBox(width: 6),
          Expanded(child: Text(tr('Discounts are a Fan+ perk — free to claim, as often as you like.'), style: AppText.caption1.copyWith(color: AppColors.textLight))),
        ]),
      ],
    );
  }
}

/// A square brand shortcut button (noon top-icon style): a rounded brand-coloured
/// tile with the logo and the name underneath. Each is a sponsor's own sellable
/// placement — a tiny "Anzeige" dot marks it as paid.
class _BrandButton extends StatelessWidget {
  final _Partner partner;
  final VoidCallback onTap;
  const _BrandButton({required this.partner, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final p = partner;
    return Tappable(
      scale: 0.95,
      onTap: onTap,
      child: SizedBox(
        width: 66,
        child: Column(children: [
          Stack(children: [
            Container(
              width: 64, height: 64,
              decoration: BoxDecoration(color: p.color, borderRadius: BorderRadius.circular(18)),
              alignment: Alignment.center,
              child: Icon(p.icon, color: Colors.white, size: 30),
            ),
            Positioned(right: 3, top: 3, child: Container(padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 1), decoration: BoxDecoration(color: Colors.black.withValues(alpha: 0.35), borderRadius: BorderRadius.circular(4)), child: Text(tr('Ad'), style: AppText.caption1.copyWith(color: Colors.white, fontWeight: FontWeight.w800, fontSize: 8)))),
          ]),
          const SizedBox(height: 6),
          Text(p.name, maxLines: 1, overflow: TextOverflow.ellipsis, textAlign: TextAlign.center, style: AppText.caption1.copyWith(color: AppColors.textDarker, fontWeight: FontWeight.w700, fontSize: 11)),
        ]),
      ),
    );
  }
}

/// A "see the map" tile that opens the full partner marketplace (real map).
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
            Text(tr('On the map'), style: AppText.body2.copyWith(color: Colors.white, fontWeight: FontWeight.w800)),
            const SizedBox(height: 2),
            Row(children: [
              Text(tr('Open'), style: AppText.caption1.copyWith(color: Colors.white70)),
              const Icon(Icons.chevron_right_rounded, size: 14, color: Colors.white70),
            ]),
          ]),
        ]),
      ),
    );
  }
}

/// Compact "near you" partner card: brand thumbnail, name, distance + discount.
class _NearbyCard extends StatelessWidget {
  final _Partner partner;
  final VoidCallback onTap;
  const _NearbyCard({required this.partner, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final p = partner;
    return Tappable(
      scale: 0.97,
      onTap: onTap,
      child: Container(
        width: 158,
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(AppRadii.card),
          border: Border.all(color: p.sponsored ? AppColors.gold.withValues(alpha: 0.5) : AppColors.borderLightest),
        ),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Row(children: [
            Container(width: 40, height: 40, decoration: BoxDecoration(color: p.color, borderRadius: BorderRadius.circular(11)), alignment: Alignment.center, child: Icon(p.icon, color: Colors.white, size: 20)),
            const Spacer(),
            Pill(color: AppColors.brandLightest, child: Text(tr(p.discount), style: AppText.caption1.copyWith(color: AppColors.brandPrimary, fontWeight: FontWeight.w800))),
          ]),
          const SizedBox(height: 10),
          Text(p.name, maxLines: 1, overflow: TextOverflow.ellipsis, style: AppText.body2.copyWith(color: AppColors.textDarker, fontWeight: FontWeight.w800)),
          const SizedBox(height: 3),
          Row(children: [
            Icon(Icons.near_me_rounded, size: 12, color: AppColors.textLight),
            const SizedBox(width: 3),
            Text(p.distance, style: AppText.caption1.copyWith(color: AppColors.textLight)),
            const SizedBox(width: 8),
            const Icon(Icons.star_rounded, size: 12, color: AppColors.gold),
            const SizedBox(width: 2),
            Text(p.rating, style: AppText.caption1.copyWith(color: AppColors.textNormal, fontWeight: FontWeight.w700)),
          ]),
        ]),
      ),
    );
  }
}

/// A featured, paid "Top partner" placement card (noon promo-tile style): a bold
/// brand-coloured gradient, a white logo chip, an "Anzeige" tag, a big discount
/// headline and a claim CTA.
class _FeaturedCard extends StatelessWidget {
  final _Partner partner;
  final VoidCallback onTap;
  const _FeaturedCard({required this.partner, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final p = partner;
    return Tappable(
      scale: 0.98,
      onTap: onTap,
      child: Container(
        width: 260,
        clipBehavior: Clip.antiAlias,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(AppRadii.card),
          gradient: LinearGradient(begin: Alignment.topLeft, end: Alignment.bottomRight, colors: [p.color, Color.lerp(p.color, Colors.black, 0.42)!]),
        ),
        child: Stack(children: [
          Positioned(right: -24, bottom: -24, child: Icon(p.icon, size: 128, color: Colors.white.withValues(alpha: 0.12))),
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Row(children: [
                Container(width: 40, height: 40, decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(11)), alignment: Alignment.center, child: Icon(p.icon, color: p.color, size: 22)),
                const SizedBox(width: 10),
                Expanded(child: Text(p.name, maxLines: 1, overflow: TextOverflow.ellipsis, style: AppText.body2.copyWith(color: Colors.white, fontWeight: FontWeight.w800))),
                Container(padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2), decoration: BoxDecoration(color: Colors.black.withValues(alpha: 0.28), borderRadius: BorderRadius.circular(5)), child: Text(tr('Ad'), style: AppText.caption1.copyWith(color: Colors.white, fontWeight: FontWeight.w800, fontSize: 9))),
              ]),
              const Spacer(),
              Text(tr(p.discount), style: AppText.h1.copyWith(color: Colors.white, fontSize: 32, fontWeight: FontWeight.w800)),
              const SizedBox(height: 2),
              Text(tr(p.sub), maxLines: 1, overflow: TextOverflow.ellipsis, style: AppText.body3.copyWith(color: Colors.white70)),
              const SizedBox(height: 12),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(999)),
                child: Row(mainAxisSize: MainAxisSize.min, children: [
                  Icon(Icons.confirmation_number_rounded, size: 14, color: p.color),
                  const SizedBox(width: 6),
                  Text(tr('Get voucher'), style: AppText.caption1.copyWith(color: p.color, fontWeight: FontWeight.w800)),
                ]),
              ),
            ]),
          ),
        ]),
      ),
    );
  }
}

/// A marketplace-style partner row (noon restaurant-card style): a rounded-square
/// brand thumbnail, name, star rating + category, a discount pill and a claim
/// button. Sponsored partners carry a gold frame and an "Anzeige" tag.
class _PartnerRow extends StatelessWidget {
  final _Partner partner;
  final VoidCallback onClaim;
  const _PartnerRow({required this.partner, required this.onClaim});

  @override
  Widget build(BuildContext context) {
    final p = partner;
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppRadii.card),
        border: Border.all(color: p.sponsored ? AppColors.gold.withValues(alpha: 0.55) : AppColors.borderLightest),
      ),
      child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
        // Brand thumbnail.
        Container(
          width: 62, height: 62,
          decoration: BoxDecoration(color: p.color, borderRadius: BorderRadius.circular(14)),
          alignment: Alignment.center,
          child: Icon(p.icon, color: Colors.white, size: 28),
        ),
        const SizedBox(width: 12),
        Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Row(children: [
            Expanded(child: Text(p.name, maxLines: 1, overflow: TextOverflow.ellipsis, style: AppText.body2.copyWith(color: AppColors.textDarker, fontWeight: FontWeight.w800))),
            if (p.sponsored) ...[
              const SizedBox(width: 6),
              Container(padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2), decoration: BoxDecoration(color: AppColors.surfaceMinimal, borderRadius: BorderRadius.circular(5)), child: Text(tr('Ad'), style: AppText.caption1.copyWith(color: AppColors.textLight, fontWeight: FontWeight.w800, fontSize: 9))),
            ],
          ]),
          const SizedBox(height: 3),
          Row(children: [
            const Icon(Icons.star_rounded, size: 14, color: AppColors.gold),
            const SizedBox(width: 3),
            Text(p.rating, style: AppText.caption1.copyWith(color: AppColors.textDarker, fontWeight: FontWeight.w800)),
            const SizedBox(width: 6),
            Flexible(child: Text('· ${tr(p.category)}', maxLines: 1, overflow: TextOverflow.ellipsis, style: AppText.caption1.copyWith(color: AppColors.textLight))),
          ]),
          const SizedBox(height: 2),
          Text(tr(p.sub), maxLines: 1, overflow: TextOverflow.ellipsis, style: AppText.body3Regular),
          const SizedBox(height: 10),
          Row(children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 5),
              decoration: BoxDecoration(color: AppColors.brandLightest, borderRadius: BorderRadius.circular(AppRadii.chip)),
              child: Text(tr(p.discount), style: AppText.caption1.copyWith(color: AppColors.brandPrimary, fontWeight: FontWeight.w800, fontSize: 12)),
            ),
            const Spacer(),
            Tappable(
              onTap: onClaim,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                decoration: BoxDecoration(color: AppColors.brandPrimary, borderRadius: BorderRadius.circular(999)),
                child: Row(mainAxisSize: MainAxisSize.min, children: [
                  const Icon(Icons.confirmation_number_rounded, size: 14, color: Colors.white),
                  const SizedBox(width: 6),
                  Text(tr('Get voucher'), style: AppText.caption1.copyWith(color: Colors.white, fontWeight: FontWeight.w800)),
                ]),
              ),
            ),
          ]),
        ])),
      ]),
    );
  }
}
