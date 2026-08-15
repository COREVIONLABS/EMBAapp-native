import 'package:flutter/material.dart';
import '../theme/app_theme.dart';
import '../widgets/app_widgets.dart';
import '../widgets/hub_widgets.dart';
import '../widgets/sub_scaffold.dart';
import '../widgets/action_sheets.dart';
import '../widgets/floating_sponsor_ads.dart';
import '../model/consent.dart';
import '../model/fan_model.dart';
import '../model/voucher_store.dart';
import 'voucher_screen.dart';
import 'partners_screen.dart';
import 'raffles_screen.dart';
import 'redeem_screen.dart' show openValueVouchers, openDiscountVouchers;
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
  /// When true this is the Redeem tab (top-level): no back button, a points
  /// chip in the header, redemption entries (vouchers + tombola) at the top,
  /// and no contextual bottom bar (the app's global nav is already there).
  final bool isTab;
  const MemberDiscountsScreen({super.key, this.isTab = false});

  @override
  State<MemberDiscountsScreen> createState() => _MemberDiscountsScreenState();
}

class _MemberDiscountsScreenState extends State<MemberDiscountsScreen> {
  String _cat = 'All';
  // The page has its own contextual bottom nav (noon style). 0 Home · 1 Favorites
  // · 2 Pizza Hut (sponsored centre) · 3 Top partners · 4 New partners.
  int _nav = 0;
  final Set<String> _fav = <String>{};
  static const _newNames = <String>{'Vivawest', 'REWE'};

  List<_Partner> get _favPartners => _partners.where((p) => _fav.contains(p.name)).toList();
  List<_Partner> get _newPartners => _partners.where((p) => _newNames.contains(p.name)).toList();
  List<_Partner> get _fastFood => _partners.where((p) => p.category == 'Fast food').toList();
  void _toggleFav(String name) => setState(() => _fav.contains(name) ? _fav.remove(name) : _fav.add(name));

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
    _Partner('REWE', 'Groceries', '5% off', 'In all REWE stores', Icons.shopping_cart_rounded, Color(0xFFC8102E), '4.6', false, '650 m'),
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

  // The real "Home": leave the marketplace and return to the app's Home tab.
  void _goHome() {
    tabRequestNotifier.value = 0;
    Navigator.of(context).popUntil((r) => r.isFirst);
  }

  // Compact balance chip for the tab header (same as the other tabs).
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
    final bottomInset = MediaQuery.of(context).padding.bottom;
    final isTab = widget.isTab;
    return Stack(children: [
      SubScaffold(
        title: isTab ? tr('Redeem') : tr('Member discounts'),
        showBack: !isTab,
        trailing: isTab
            ? _pointsChip()
            : IconButton(
                onPressed: _goHome,
                tooltip: tr('Home'),
                icon: const Icon(Icons.home_rounded, size: 22, color: AppColors.brandPrimary),
              ),
        bottomBar: isTab ? null : _MarketplaceNav(active: _nav, onTap: (i) => setState(() => _nav = i)),
        children: isTab
            ? _homeView()
            : switch (_nav) {
                1 => _favView(),
                2 => _pizzaView(),
                3 => _topPartnerView(),
                4 => _newPartnerView(),
                _ => _homeView(),
              },
      ),
      // The floating McDonald's badge hovers above this page's own nav (noon:
      // Pizza Hut in the bar + M floating over it). This is the ONLY place the M
      // appears. Gated on ad consent, and dismissible with a confirm.
      Positioned(
        right: 26, bottom: bottomInset + 104,
        child: AnimatedBuilder(
          animation: Listenable.merge([adsConsent, mcdonaldsAdVisible]),
          builder: (context, __) => (adsConsent.value && mcdonaldsAdVisible.value)
              ? McDonaldsAdBadge(
                  onTap: () => _claim("McDonald's", '20% off'),
                  onDismiss: () => confirmHideAd(context, mcdonaldsAdVisible),
                )
              : const SizedBox.shrink(),
        ),
      ),
    ]);
  }

  // A partner row + spacing, with the favourite heart wired in.
  List<Widget> _rows(List<_Partner> items) => [
        for (final p in items) ...[
          _PartnerRow(partner: p, onClaim: () => _claim(p.name, p.discount), isFav: _fav.contains(p.name), onFav: () => _toggleFav(p.name)),
          const SizedBox(height: 12),
        ],
      ];

  Widget _emptyState(IconData icon, String title, String sub) => Container(
        padding: const EdgeInsets.symmetric(vertical: 40, horizontal: 20),
        alignment: Alignment.center,
        child: Column(children: [
          Container(width: 64, height: 64, decoration: BoxDecoration(color: AppColors.surfaceMinimal, shape: BoxShape.circle), child: Icon(icon, size: 30, color: AppColors.textLight)),
          const SizedBox(height: 14),
          Text(tr(title), textAlign: TextAlign.center, style: AppText.body2.copyWith(color: AppColors.textDarker, fontWeight: FontWeight.w800)),
          const SizedBox(height: 4),
          Text(tr(sub), textAlign: TextAlign.center, style: AppText.body3Regular),
        ]),
      );

  Widget _footerNote() => Padding(
        padding: const EdgeInsets.only(top: 4),
        child: Row(children: [
          Icon(Icons.info_outline_rounded, size: 14, color: AppColors.textLight),
          const SizedBox(width: 6),
          Expanded(child: Text(tr('Discounts are a Fan+ perk — free to claim, as often as you like.'), style: AppText.caption1.copyWith(color: AppColors.textLight))),
        ]),
      );

  // Redemption entries shown at the top of the Redeem tab — the ways to turn
  // points into something: value (€) & discount (%) vouchers and the tombola.
  // A corner chevron makes clear each tile is tappable.
  Widget _redeemTile(IconData icon, Color color, String label, String sub, VoidCallback onTap) => Expanded(
        child: Tappable(
          scale: 0.97,
          onTap: onTap,
          child: Container(
            padding: const EdgeInsets.fromLTRB(12, 12, 10, 12),
            decoration: BoxDecoration(color: AppColors.surface, borderRadius: BorderRadius.circular(AppRadii.card), border: Border.all(color: AppColors.borderLightest)),
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Row(children: [
                Container(width: 40, height: 40, decoration: BoxDecoration(color: color.withValues(alpha: 0.14), borderRadius: BorderRadius.circular(12)), child: Icon(icon, color: color, size: 22)),
                const Spacer(),
                Icon(Icons.chevron_right_rounded, size: 18, color: AppColors.textLight),
              ]),
              const SizedBox(height: 10),
              Text(label, maxLines: 1, overflow: TextOverflow.ellipsis, style: AppText.body3.copyWith(color: AppColors.textDarker, fontWeight: FontWeight.w800, fontSize: 12.5)),
              Text(sub, maxLines: 1, overflow: TextOverflow.ellipsis, style: AppText.caption1.copyWith(color: AppColors.textLight)),
            ]),
          ),
        ),
      );

  Widget _redeemTilesRow() => Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
        _redeemTile(Icons.euro_rounded, AppColors.gold, tr('Value vouchers'), tr('€ off'), () => openValueVouchers(context)),
        const SizedBox(width: 10),
        _redeemTile(Icons.percent_rounded, AppColors.brandPrimary, tr('% vouchers'), tr('% off'), () => openDiscountVouchers(context)),
        const SizedBox(width: 10),
        _redeemTile(Icons.local_activity_rounded, const Color(0xFFC62828), tr('Tombola'), tr('Win prizes'), () => Navigator.of(context).push(MaterialPageRoute(builder: (_) => const RafflesScreen()))),
      ]);

  // ── View: Home — the full marketplace ──
  List<Widget> _homeView() {
    final list = _filtered;
    final isTab = widget.isTab;
    return [
      // Search is always the first thing on the page.
      HubSearchField(hint: 'Search partners & offers'),
      const SizedBox(height: 16),
      if (isTab) ...[
        // Redemption entries (no redundant heading — the tab is already
        // titled "Einlösen"). Each tile shows a chevron so it reads tappable.
        _redeemTilesRow(),
        const SizedBox(height: 24),
        Text(tr('Partner deals'), style: AppText.label1),
        const SizedBox(height: 12),
      ] else ...[
        // Concept intro (kept on the standalone marketplace, not the tab).
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
      ],
      _topPartnerCarousel(),
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
      Row(children: [
        Expanded(child: Text(_cat == 'All' ? tr('All partners') : tr(_cat), style: AppText.label1)),
        Text('${list.length} ${tr('partners')}', style: AppText.body3.copyWith(color: AppColors.textLight)),
      ]),
      const SizedBox(height: 12),
      ..._rows(list),
      _footerNote(),
    ];
  }

  // Shared horizontal "Top partners" carousel (Anzeige).
  Widget _topPartnerCarousel() => Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
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
      ]);

  // ── View: Favorites ──
  List<Widget> _favView() {
    final favs = _favPartners;
    return [
      Text(tr('Favorites'), style: AppText.label1),
      const SizedBox(height: 4),
      Text(tr('Your saved partners.'), style: AppText.body3Regular),
      const SizedBox(height: 14),
      if (favs.isEmpty)
        _emptyState(Icons.favorite_border_rounded, 'No favourites yet', 'Tap the heart on a partner to save it here.')
      else ...[
        ..._rows(favs),
        _footerNote(),
      ],
    ];
  }

  // ── View: Pizza Hut (sponsored focus) ──
  List<Widget> _pizzaView() {
    final ph = _partners.firstWhere((p) => p.name == 'Pizza Hut');
    return [
      Row(children: [
        Text(tr('Sponsored'), style: AppText.label1),
        const SizedBox(width: 8),
        Pill(color: AppColors.surfaceMinimal, child: Text(tr('Ad'), style: AppText.caption1.copyWith(color: AppColors.textLight, fontWeight: FontWeight.w800, fontSize: 10))),
      ]),
      const SizedBox(height: 12),
      SizedBox(height: 184, child: _FeaturedCard(partner: ph, wide: true, onTap: () => _claim(ph.name, ph.discount))),
      const SizedBox(height: 22),
      Text(tr('More fast-food offers'), style: AppText.label1),
      const SizedBox(height: 12),
      ..._rows(_fastFood),
      _footerNote(),
    ];
  }

  // ── View: Top partners ──
  List<Widget> _topPartnerView() => [
        _topPartnerCarousel(),
        const SizedBox(height: 22),
        Text(tr('All top partners'), style: AppText.label1),
        const SizedBox(height: 12),
        ..._rows(_sponsored),
        _footerNote(),
      ];

  // ── View: New partners ──
  List<Widget> _newPartnerView() {
    final news = _newPartners;
    return [
      Text(tr('New partners'), style: AppText.label1),
      const SizedBox(height: 4),
      Text(tr('Just joined the Fan+ programme.'), style: AppText.body3Regular),
      const SizedBox(height: 14),
      if (news.isEmpty)
        _emptyState(Icons.fiber_new_rounded, 'Nothing new right now', 'Check back soon for new partners.')
      else ...[
        ..._rows(news),
        _footerNote(),
      ],
    ];
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
  final bool wide;
  const _FeaturedCard({required this.partner, required this.onTap, this.wide = false});

  @override
  Widget build(BuildContext context) {
    final p = partner;
    return Tappable(
      scale: 0.98,
      onTap: onTap,
      child: Container(
        width: wide ? double.infinity : 260,
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
  final bool isFav;
  final VoidCallback? onFav;
  const _PartnerRow({required this.partner, required this.onClaim, this.isFav = false, this.onFav});

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
            if (onFav != null) ...[
              const SizedBox(width: 4),
              GestureDetector(
                onTap: onFav,
                behavior: HitTestBehavior.opaque,
                child: Icon(isFav ? Icons.favorite_rounded : Icons.favorite_border_rounded, size: 20, color: isFav ? AppColors.danger : AppColors.textLight),
              ),
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

/// Page-specific bottom navigation for the marketplace (noon style): the centre
/// slot is a paid, branded Pizza Hut placement; the others switch the view.
/// This replaces the app's normal nav on the discounts page only.
class _MarketplaceNav extends StatelessWidget {
  final int active;
  final ValueChanged<int> onTap;
  const _MarketplaceNav({required this.active, required this.onTap});

  static const _items = <(IconData, String)>[
    (Icons.grid_view_rounded, 'Overview'),
    (Icons.favorite_rounded, 'Favorites'),
    (Icons.local_pizza_rounded, 'Pizza Hut'), // centre — sponsored
    (Icons.workspace_premium_rounded, 'Top partners'),
    (Icons.fiber_new_rounded, 'New partners'),
  ];

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 8),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppRadii.nav),
        border: Border.all(color: AppColors.borderLightest),
        boxShadow: const [BoxShadow(color: Color(0x1F000000), blurRadius: 16, offset: Offset(0, 2))],
      ),
      child: Row(children: [
        for (var i = 0; i < _items.length; i++)
          Expanded(
            child: i == 2
                ? _PizzaNavItem(selected: i == active, onTap: () => onTap(i))
                : _NavItem(icon: _items[i].$1, label: _items[i].$2, selected: i == active, onTap: () => onTap(i)),
          ),
      ]),
    );
  }
}

class _NavItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final bool selected;
  final VoidCallback onTap;
  const _NavItem({required this.icon, required this.label, required this.selected, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final color = selected ? AppColors.brandPrimary : AppColors.textLight;
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 4, horizontal: 2),
        child: Column(mainAxisSize: MainAxisSize.min, children: [
          Icon(icon, size: 22, color: color),
          const SizedBox(height: 3),
          Text(tr(label), maxLines: 1, overflow: TextOverflow.ellipsis, textAlign: TextAlign.center,
              style: AppText.caption1.copyWith(color: color, fontWeight: selected ? FontWeight.w800 : FontWeight.w600, fontSize: 11)),
        ]),
      ),
    );
  }
}

/// The centre Pizza Hut slot — a raised, branded red button with a tiny
/// "Anzeige" tag, so it reads as the paid placement it is.
class _PizzaNavItem extends StatelessWidget {
  final bool selected;
  final VoidCallback onTap;
  const _PizzaNavItem({required this.selected, required this.onTap});
  static const _red = Color(0xFFE3000B);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: onTap,
      child: Column(mainAxisSize: MainAxisSize.min, children: [
        Container(
          width: 40, height: 40,
          decoration: BoxDecoration(
            color: _red, shape: BoxShape.circle,
            border: selected ? Border.all(color: AppColors.brandDarkest, width: 2) : null,
            boxShadow: [BoxShadow(color: _red.withValues(alpha: 0.4), blurRadius: 10, offset: const Offset(0, 3))],
          ),
          child: const Icon(Icons.local_pizza_rounded, color: Colors.white, size: 22),
        ),
        const SizedBox(height: 3),
        Row(mainAxisSize: MainAxisSize.min, children: [
          Text('Pizza Hut', maxLines: 1, overflow: TextOverflow.ellipsis, style: AppText.caption1.copyWith(color: _red, fontWeight: FontWeight.w800, fontSize: 10)),
          const SizedBox(width: 3),
          Container(padding: const EdgeInsets.symmetric(horizontal: 3, vertical: 1), decoration: BoxDecoration(color: AppColors.surfaceMinimal, borderRadius: BorderRadius.circular(3)), child: Text(tr('Ad'), style: AppText.caption1.copyWith(color: AppColors.textLight, fontWeight: FontWeight.w800, fontSize: 7))),
        ]),
      ]),
    );
  }
}
