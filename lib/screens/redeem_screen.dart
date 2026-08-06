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

/// Reward item: internal English category key + German-facing content.
/// (category, title, subtitle, points, image, sponsor)
typedef _Reward = (String, String, String, int, String, String);

/// Redeem Points — Socios-style: a search bar and live filter chips on top,
/// a curated view (exclusive experiences hero, category tiles, hot deals) when
/// nothing is filtered, and a clean 2-column reward grid the moment a fan
/// searches or picks a category. EMBA/S04 content with real club sponsors.
class RedeemScreen extends StatefulWidget {
  final bool isTab;
  const RedeemScreen({super.key, this.isTab = false});

  @override
  State<RedeemScreen> createState() => _RedeemScreenState();
}

class _RedeemScreenState extends State<RedeemScreen> {
  String _filter = 'All';
  String _query = '';
  final _searchCtrl = TextEditingController();

  // Filter categories (English keys → localized labels via tr()).
  static const _filters = ['All', 'Tickets', 'Fanshop', 'Experiences', 'Sponsors', 'Tombola'];

  // The full redeemable catalogue. Category is an English key (matches _filters).
  static const _rewards = <_Reward>[
    // Experiences — money-can't-buy (also feed the hero carousel).
    ('Experiences', 'Auf dem Rasen spielen', 'Spiele in der VELTINS-Arena', 12000, 'img_experiences', 'FC Schalke 04'),
    ('Experiences', 'VIP-Loge am Spieltag', 'Logenplatz inkl. Catering', 8000, 'img_tickets', 'FC Schalke 04'),
    ('Experiences', 'Triff die Mannschaft', 'Meet & Greet vor dem Spiel', 5000, 'img_rewards', 'FC Schalke 04'),
    ('Experiences', 'Stadiontour hinter den Kulissen', 'Kabine, Tunnel & Rasen', 2500, 'img_experiences', 'FC Schalke 04'),
    // Tickets
    ('Tickets', 'VIP-Ticket vs Dortmund', 'Business-Seat inkl. Catering', 8000, 'img_tickets', 'FC Schalke 04'),
    ('Tickets', 'Grandstand — Heimspiel', 'Nordkurve, Oberrang', 3000, 'img_tickets', 'FC Schalke 04'),
    ('Tickets', 'Standard-Ticket Heimspiel', 'Kategorie 3, freie Wahl', 1800, 'img_tickets', 'FC Schalke 04'),
    ('Tickets', 'Presale-Zugang Derby', '24 h früher Tickets sichern', 600, 'img_tickets', 'FC Schalke 04'),
    // Fanshop
    ('Fanshop', 'Home Jersey 25/26', 'adidas · Heimtrikot', 3800, 'img_fanshop', 'adidas'),
    ('Fanshop', 'Trainingsjacke', 'adidas · Anthrazit', 2400, 'img_fanshop', 'adidas'),
    ('Fanshop', 'Home Scarf 25/26', 'Offizieller Fanschal', 720, 'img_fanshop', 'adidas'),
    // Sponsors
    ('Sponsors', 'VELTINS Matchday-Kiste', 'Bierkiste zum Spieltag', 1050, 'img_partner', 'Veltins'),
    ('Sponsors', "Ernsting's family Gutschein", 'Mode für die Familie', 600, 'img_partner', "Ernsting's"),
    ('Sponsors', 'REWE Gutschein 10 €', 'In allen REWE-Märkten', 400, 'img_partner', 'REWE'),
    // Tombola
    ('Tombola', 'Derby-VIP Tombola', 'Los für die Monatsverlosung', 500, 'img_rewards', 'FC Schalke 04'),
    ('Tombola', 'Signiertes Trikot — Los', 'Money-can\'t-buy Verlosung', 350, 'img_rewards', 'FC Schalke 04'),
  ];

  // Hot reward deals with strikethrough pricing (curated view only).
  static const _deals = <(String, String, int, int, String, IconData, Color, String)>[
    ('Home Jersey 25/26', 'Fanshop', 4500, 3800, '-15%', Icons.checkroom_rounded, Color(0xFF0A2A5E), 'img_fanshop'),
    ('VELTINS matchday crate', 'Sponsor', 1500, 1050, '-30%', Icons.sports_bar_rounded, Color(0xFF00897B), 'img_partner'),
    ('Derby VIP Tombola', 'Tombola', 500, 350, 'Limited', Icons.local_activity_rounded, Color(0xFFC62828), 'img_rewards'),
    ('Home Scarf 25/26', 'Fanshop', 900, 720, '-20%', Icons.style_rounded, Color(0xFF1565C0), 'img_fanshop'),
  ];

  @override
  void dispose() {
    _searchCtrl.dispose();
    super.dispose();
  }

  void _push(Widget s) =>
      Navigator.of(context).push(MaterialPageRoute(builder: (_) => s));

  Widget? _screenFor(String category) => switch (category) {
        'Fanshop' => const FanshopScreen(),
        'Tickets' => const TicketsScreen(),
        'Experiences' => const ExperiencesScreen(),
        'Tombola' => const RafflesScreen(),
        'Sponsors' => const DealsHubScreen(),
        _ => null,
      };

  List<_Reward> get _filtered {
    final q = _query.trim().toLowerCase();
    return _rewards.where((r) {
      final matchesCat = _filter == 'All' || r.$1 == _filter;
      final matchesQuery = q.isEmpty ||
          r.$2.toLowerCase().contains(q) ||
          r.$6.toLowerCase().contains(q) ||
          tr(r.$1).toLowerCase().contains(q);
      return matchesCat && matchesQuery;
    }).toList();
  }

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
    final searching = _query.trim().isNotEmpty || _filter != 'All';
    return SubScaffold(
      title: tr('Redeem'),
      showBack: !widget.isTab,
      trailing: widget.isTab ? _pointsChip() : null,
      children: [
        // ── Search ──
        _SearchField(
          controller: _searchCtrl,
          hint: tr('Search reward, team, category'),
          onChanged: (v) => setState(() => _query = v),
          onClear: () => setState(() {
            _query = '';
            _searchCtrl.clear();
          }),
        ),
        const SizedBox(height: 14),
        // ── Filter chips ──
        SizedBox(
          height: 34,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            itemCount: _filters.length,
            separatorBuilder: (_, __) => const SizedBox(width: 8),
            itemBuilder: (_, i) {
              final f = _filters[i];
              return _FilterChip(
                label: tr(f),
                selected: _filter == f,
                onTap: () => setState(() => _filter = f),
              );
            },
          ),
        ),
        const SizedBox(height: 20),
        // ── Body: filtered grid or curated view ──
        if (searching) ..._resultsView() else ..._curatedView(),
        const SizedBox(height: 4),
        // ── Always available: My Vouchers + Top up ──
        AnimatedBuilder(
          animation: voucherStore,
          builder: (context, _) {
            final open = voucherStore.openCount;
            return SurfaceCard(
              onTap: () => _push(const MyVouchersScreen()),
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
          onTap: () => _push(const BuyPointsScreen()),
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

  // ── Curated view (filter = All, no query) ──
  List<Widget> _curatedView() {
    final exclusive = _rewards.where((r) => r.$1 == 'Experiences').toList();
    return [
      // Exclusive, money-can't-buy hero.
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
          itemCount: exclusive.length,
          separatorBuilder: (_, __) => const SizedBox(width: 12),
          itemBuilder: (_, i) {
            final e = exclusive[i];
            return _ExclusiveCard(
              title: e.$2, sub: e.$3, image: e.$5, points: e.$4,
              onTap: () => redeemForVoucher(context, title: e.$2, category: 'Experience', points: e.$4, sponsor: e.$6),
            );
          },
        ),
      ),
      const SizedBox(height: 24),
      // Hot deals.
      const SectionHeader('Reward deals', action: null),
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
                    _push(const FanshopScreen());
                  case 'Tombola':
                    _push(const RafflesScreen());
                  default:
                    redeemForVoucher(context, title: d.$1, category: d.$2, points: d.$4, sponsor: 'Veltins');
                }
              },
            );
          },
        ),
      ),
      const SizedBox(height: 24),
    ];
  }

  // ── Results view (a filter or search is active) ──
  List<Widget> _resultsView() {
    final items = _filtered;
    final title = _filter == 'All' ? tr('Results') : tr(_filter);
    final dest = _screenFor(_filter);
    return [
      Row(children: [
        Expanded(child: Text('$title · ${items.length} ${tr('rewards')}', style: AppText.label1)),
        if (dest != null && _query.trim().isEmpty)
          Tappable(
            onTap: () => _push(dest),
            child: Row(mainAxisSize: MainAxisSize.min, children: [
              Text(tr('See all'), style: AppText.body3.copyWith(color: AppColors.brandPrimary, fontWeight: FontWeight.w700)),
              Icon(Icons.chevron_right_rounded, size: 18, color: AppColors.brandPrimary),
            ]),
          ),
      ]),
      const SizedBox(height: 14),
      if (items.isEmpty)
        _EmptyState(onReset: () => setState(() {
          _filter = 'All';
          _query = '';
          _searchCtrl.clear();
        }))
      else
        _grid(items),
      const SizedBox(height: 20),
    ];
  }

  // 2-column reward grid.
  Widget _grid(List<_Reward> items) {
    final rows = <Widget>[];
    for (var i = 0; i < items.length; i += 2) {
      rows.add(Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Expanded(child: _RewardCard(reward: items[i], onTap: () => _redeem(items[i]))),
        const SizedBox(width: 12),
        Expanded(
          child: i + 1 < items.length
              ? _RewardCard(reward: items[i + 1], onTap: () => _redeem(items[i + 1]))
              : const SizedBox(),
        ),
      ]));
      if (i + 2 < items.length) rows.add(const SizedBox(height: 12));
    }
    return Column(children: rows);
  }

  void _redeem(_Reward r) {
    // Tickets / Fanshop route to their rich flows; the rest issue a voucher.
    switch (r.$1) {
      case 'Fanshop':
        _push(const FanshopScreen());
      case 'Tickets':
        _push(const TicketsScreen());
      case 'Tombola':
        _push(const RafflesScreen());
      default:
        redeemForVoucher(context, title: r.$2, category: r.$1, points: r.$4, sponsor: r.$6);
    }
  }
}

/// Rounded live search field with a clear button.
class _SearchField extends StatelessWidget {
  final TextEditingController controller;
  final String hint;
  final ValueChanged<String> onChanged;
  final VoidCallback onClear;
  const _SearchField({required this.controller, required this.hint, required this.onChanged, required this.onClear});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14),
      decoration: BoxDecoration(color: AppColors.surfaceMinimal, borderRadius: BorderRadius.circular(AppRadii.pill)),
      child: Row(children: [
        Icon(Icons.search_rounded, size: 20, color: AppColors.textLight),
        const SizedBox(width: 10),
        Expanded(
          child: TextField(
            controller: controller,
            onChanged: onChanged,
            style: AppText.body2.copyWith(color: AppColors.textDarker),
            cursorColor: AppColors.brandPrimary,
            decoration: InputDecoration(
              isDense: true,
              border: InputBorder.none,
              hintText: hint,
              hintStyle: AppText.body2.copyWith(color: AppColors.textLight),
              contentPadding: const EdgeInsets.symmetric(vertical: 13),
            ),
          ),
        ),
        ValueListenableBuilder<TextEditingValue>(
          valueListenable: controller,
          builder: (_, v, __) => v.text.isEmpty
              ? const SizedBox.shrink()
              : Tappable(
                  onTap: onClear,
                  child: Icon(Icons.close_rounded, size: 18, color: AppColors.textLight),
                ),
        ),
      ]),
    );
  }
}

/// Pill-style filter chip.
class _FilterChip extends StatelessWidget {
  final String label;
  final bool selected;
  final VoidCallback onTap;
  const _FilterChip({required this.label, required this.selected, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Tappable(
      scale: 0.96,
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        padding: const EdgeInsets.symmetric(horizontal: 16),
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: selected ? AppColors.brandPrimary : AppColors.surface,
          borderRadius: BorderRadius.circular(999),
          border: Border.all(color: selected ? AppColors.brandPrimary : AppColors.borderLightest),
        ),
        child: Text(label, style: AppText.caption1.copyWith(
          color: selected ? Colors.white : AppColors.textNormal,
          fontWeight: FontWeight.w700,
        )),
      ),
    );
  }
}

/// Reward grid card (Socios-style): full-bleed photo with a points badge and a
/// category band, then a white body with title, sub and a redeem chip.
class _RewardCard extends StatelessWidget {
  final _Reward reward;
  final VoidCallback onTap;
  const _RewardCard({required this.reward, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final (category, title, sub, points, image, _) = reward;
    return Tappable(
      scale: 0.97,
      onTap: onTap,
      child: Container(
        height: 244,
        clipBehavior: Clip.antiAlias,
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(AppRadii.card),
          border: Border.all(color: AppColors.borderLightest),
        ),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Stack(children: [
            SizedBox(
              height: 118, width: double.infinity,
              child: AssetImg(image, fit: BoxFit.cover, fallbackIcon: Icons.card_giftcard_rounded),
            ),
            Positioned(
              left: 10, top: 10,
              child: Pill(color: Colors.black.withValues(alpha: 0.55), child: Text(tr(category), style: AppText.caption1.copyWith(color: Colors.white, fontWeight: FontWeight.w700))),
            ),
          ]),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(12, 10, 12, 12),
              child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Text(tr(title), maxLines: 2, overflow: TextOverflow.ellipsis, style: AppText.body2.copyWith(color: AppColors.textDarker, fontWeight: FontWeight.w700, height: 1.15)),
                const SizedBox(height: 3),
                Text(tr(sub), maxLines: 1, overflow: TextOverflow.ellipsis, style: AppText.body3Regular),
                const Spacer(),
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
          ),
        ]),
      ),
    );
  }
}

/// Empty state when a search/filter yields nothing.
class _EmptyState extends StatelessWidget {
  final VoidCallback onReset;
  const _EmptyState({required this.onReset});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 40, horizontal: 20),
      decoration: BoxDecoration(color: AppColors.surfaceMinimal, borderRadius: BorderRadius.circular(AppRadii.card)),
      child: Column(children: [
        Icon(Icons.search_off_rounded, size: 40, color: AppColors.textLight),
        const SizedBox(height: 12),
        Text(tr('No rewards found'), style: AppText.body1.copyWith(color: AppColors.textDarker, fontWeight: FontWeight.w700)),
        const SizedBox(height: 4),
        Text(tr('Try another search or category.'), textAlign: TextAlign.center, style: AppText.body3Regular),
        const SizedBox(height: 16),
        Tappable(
          onTap: onReset,
          child: Pill(color: AppColors.brandLightest, child: Text(tr('Reset filters'), style: AppText.caption1.copyWith(color: AppColors.brandPrimary, fontWeight: FontWeight.w800))),
        ),
      ]),
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
