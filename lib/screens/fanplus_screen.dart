import 'package:flutter/material.dart';
import '../theme/app_theme.dart';
import '../widgets/app_widgets.dart';
import '../widgets/asset_img.dart';
import '../widgets/tab_scaffold.dart';
import '../widgets/skeleton.dart';
import '../widgets/hub_widgets.dart';
import 'subscription_screen.dart';
import 'upgrade_plan_screen.dart';
import 'manage_subscription_screen.dart';
import 'fomo_drop_screen.dart';
import 'exclusive_content_screen.dart';
import 'member_discounts_screen.dart';
import 'raffles_screen.dart';
import '../model/fan_model.dart';
import '../l10n/strings.dart';

/// A forward-dated renewal label (~30 days out) so the "Renews …" line is never
/// stale in a demo.
String _renewLabel() {
  final d = DateTime.now().add(const Duration(days: 30));
  const en = ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'];
  const de = ['Jan', 'Feb', 'Mär', 'Apr', 'Mai', 'Jun', 'Jul', 'Aug', 'Sep', 'Okt', 'Nov', 'Dez'];
  final m = localeNotifier.value == AppLocale.de ? de : en;
  return '${d.day} ${m[d.month - 1]} ${d.year}';
}

/// Fan+ (Figma 2145:8198 Non-Subscriber / 2145:8275 Subscriber).
class FanPlusScreen extends StatefulWidget {
  final bool subscribed;
  const FanPlusScreen({super.key, this.subscribed = false});
  @override
  State<FanPlusScreen> createState() => _FanPlusScreenState();
}

class _FanPlusScreenState extends State<FanPlusScreen> {
  // Member lounge: 0 = Vorteile (perks), 1 = Inhalte (content).
  int _loungeTab = 0;
  // Pitch: selected tier (0 Fan Member, 1 Super Fan) and billing period.
  int _pitchTier = 1;
  bool _annual = false;

  @override
  void initState() {
    super.initState();
    // Becoming a member (via the upgrade flow) flips the preview to the lounge.
    if (widget.subscribed) memberPreviewNotifier.value = true;
  }

  void _push(BuildContext context, Widget s) => Navigator.of(context).push(MaterialPageRoute(builder: (_) => s));

  // Pitch pricing helpers (Fan Member €4.99 · Super Fan €9.99 · annual = 10×).
  String get _pitchTierName => _pitchTier == 0 ? 'Fan Member' : 'Super Fan';
  double get _monthly => _pitchTier == 0 ? 4.99 : 9.99;
  String get _priceLabel => _annual ? '€${(_monthly * 10).toStringAsFixed(2)}' : '€${_monthly.toStringAsFixed(2)}';
  String _period() => _annual ? tr('/ year') : tr('/ month');
  List<String> get _pitchBenefits => _pitchTier == 0
      ? const [
          'Priority ticket access to top matches (48–72h)',
          'Monthly exclusive FOMO drop',
          'Exclusive content & locker-room clips',
        ]
      : const [
          'Priority ticket access to top matches (48–72h)',
          'Best seats first + matchday upgrades',
          'Monthly exclusive FOMO drop',
          'Exclusive content & locker-room clips',
          'Branded Fan+ Pay card (from Season 2)',
        ];

  // 2-column grid of member-content photo tiles.
  Widget _contentGrid(BuildContext context) {
    final rows = <Widget>[];
    for (var i = 0; i < _content.length; i += 2) {
      rows.add(Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Expanded(child: _ContentCard(item: _content[i], onTap: () => _push(context, const ExclusiveContentScreen()))),
        const SizedBox(width: 12),
        Expanded(
          child: i + 1 < _content.length
              ? _ContentCard(item: _content[i + 1], onTap: () => _push(context, const ExclusiveContentScreen()))
              : const SizedBox(),
        ),
      ]));
      if (i + 2 < _content.length) rows.add(const SizedBox(height: 12));
    }
    return Column(children: rows);
  }

  // Member discounts — fixed % off at club partners & sponsors (a membership
  // perk). (partner, category, discount, icon, color)
  static const _discounts = <(String, String, String, IconData, Color)>[
    ('Official Fanshop', 'Club', '15% off', Icons.storefront_rounded, Color(0xFF004B9C)),
    ('adidas', 'Sportswear', '20% off', Icons.sports_soccer_rounded, Color(0xFF111111)),
    ('Veltins', 'Beverages', '10% off', Icons.sports_bar_rounded, Color(0xFF00623A)),
    ('Vivawest', 'Housing', '10% off', Icons.apartment_rounded, Color(0xFF6A1B9A)),
  ];

  // Member content (title, subtitle, image)
  static const _content = <(String, String, String)>[
    ('Locker-room after the derby', 'Exclusive clip · 6:20', 'img_experiences'),
    ('Training-ground access', 'Behind the scenes', 'img_rewards'),
    ('Captain’s matchday vlog', 'Members only · 4:12', 'img_tickets'),
  ];

  @override
  Widget build(BuildContext context) => ValueListenableBuilder<bool>(
        valueListenable: memberPreviewNotifier,
        builder: (context, member, __) => member ? _lounge(context) : _pitch(context),
      );

  // Tab-root header — left-aligned title + points chip, matching the other
  // tabs (Einlösen / Gewinne).
  Widget _header() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 0, 20, 4),
      child: Row(children: [
        Expanded(child: Text(tr('Fan+'), style: AppText.h4)),
        Container(
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
        ),
      ]),
    );
  }

  Widget _pitch(BuildContext context) {
    final tierName = _pitchTierName;
    final s = perksFor(tierName);
    void toPlans() => Navigator.of(context).push(MaterialPageRoute(builder: (_) => const SubscriptionScreen()));
    void toCheckout() => _push(context, UpgradePlanScreen(plan: tierName, price: _priceLabel, period: _period()));
    return TabScaffold(
      onRefresh: () => Future<void>.delayed(const Duration(milliseconds: 900)),
      skeleton: const HubSkeleton(),
      children: [
        _header(),
        const SizedBox(height: 16),
        // ── Hero with the price anchor front-and-centre (value first) ──
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Container(
            width: double.infinity,
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(gradient: const LinearGradient(colors: AppColors.pointsGradient), borderRadius: BorderRadius.circular(AppRadii.card)),
            child: Column(children: [
              const Icon(Icons.workspace_premium_rounded, color: AppColors.gold, size: 40),
              const SizedBox(height: 12),
              Text(tr('Become a Fan+ member'), textAlign: TextAlign.center, style: AppText.h4.copyWith(color: Colors.white)),
              const SizedBox(height: 6),
              Text(tr('More points, free tombola lots & priority access.'),
                  textAlign: TextAlign.center, style: AppText.body3.copyWith(color: Colors.white70)),
              const SizedBox(height: 18),
              // Big price anchor — reflects the selected tier & billing below.
              Row(mainAxisAlignment: MainAxisAlignment.center, crossAxisAlignment: CrossAxisAlignment.baseline, textBaseline: TextBaseline.alphabetic, children: [
                Text(_priceLabel, style: AppText.h2.copyWith(color: Colors.white, fontWeight: FontWeight.w800)),
                const SizedBox(width: 5),
                Text(_period(), style: AppText.body2.copyWith(color: Colors.white70)),
              ]),
              const SizedBox(height: 4),
              Text('${tr(tierName)} · ${tr('cancel anytime')}', style: AppText.caption1.copyWith(color: Colors.white60)),
              const SizedBox(height: 14),
              Pill(gradient: const LinearGradient(colors: AppColors.goldGradient), child: Row(mainAxisSize: MainAxisSize.min, children: [
                const Icon(Icons.check_circle_rounded, size: 13, color: AppColors.brandDarkest),
                const SizedBox(width: 5),
                Text(tr('7 days free'), style: AppText.caption1.copyWith(color: AppColors.brandDarkest, fontWeight: FontWeight.w800)),
              ])),
            ]),
          ),
        ),
        const SizedBox(height: 20),
        // ── Value first: the concrete 2×2 grid, before any toggles ──
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Align(alignment: Alignment.centerLeft, child: Text('${tr(tierName)} ${tr('includes')}:', style: AppText.label1)),
        ),
        const SizedBox(height: 10),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Column(children: [
            Row(children: [
              Expanded(child: _ValueTile(icon: Icons.savings_rounded, color: AppColors.brandPrimary, title: '+${FanModel.fmtPublic(s.monthlyPoints)} ${tr('pts')}', sub: tr('automatically, every month'))),
              const SizedBox(width: 12),
              Expanded(child: _ValueTile(icon: Icons.local_activity_rounded, color: AppColors.brandPrimary, title: '${s.freeLots} ${tr('free lots')}', sub: tr('every month'))),
            ]),
            const SizedBox(height: 12),
            Row(children: [
              Expanded(child: _ValueTile(icon: Icons.bolt_rounded, color: AppColors.brandPrimary, title: _pitchTier == 1 ? tr('Double points') : tr('1.5× points'), sub: tr('on every purchase'))),
              const SizedBox(width: 12),
              Expanded(child: _ValueTile(icon: Icons.workspace_premium_rounded, color: AppColors.gold, title: tr('Priority & drops'), sub: tr('first access, exclusives'))),
            ]),
          ]),
        ),
        const SizedBox(height: 16),
        // Pays for itself — shown as honest rewards value, not cash.
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: SurfaceCard(
            color: AppColors.successBg,
            child: Row(children: [
              const Icon(Icons.savings_rounded, color: AppColors.success),
              const SizedBox(width: 12),
              Expanded(child: Text('+${FanModel.fmtPublic(s.monthlyPoints)} ${tr('pts')} (${tr('≈')} ${FanModel.euroValue(s.monthlyPoints)} ${tr('in rewards')}) + ${s.freeLots} ${tr('free lots')} — ${tr('for')} $_priceLabel ${_period()}.',
                  style: AppText.body2.copyWith(color: AppColors.textDarker, fontWeight: FontWeight.w600))),
            ]),
          ),
        ),
        const SizedBox(height: 20),
        // ── Compact plan switch — AFTER the value is shown ──
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Align(alignment: Alignment.centerLeft, child: Text(tr('Choose your plan'), style: AppText.label2)),
        ),
        const SizedBox(height: 10),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: SegmentedToggle(labels: [tr('Fan Member'), tr('Super Fan')], selected: _pitchTier, onTap: (i) => setState(() => _pitchTier = i)),
        ),
        const SizedBox(height: 10),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Row(children: [
            Expanded(child: SegmentedToggle(labels: [tr('Monthly'), tr('Yearly')], selected: _annual ? 1 : 0, onTap: (i) => setState(() => _annual = i == 1))),
            const SizedBox(width: 10),
            _annual
                ? Pill(color: AppColors.successBg, child: Text(tr('2 months free'), style: AppText.caption1.copyWith(color: AppColors.success, fontWeight: FontWeight.w800)))
                : Pill(color: AppColors.surfaceMinimal, child: Text(tr('Save yearly'), style: AppText.caption1.copyWith(color: AppColors.textLight, fontWeight: FontWeight.w700))),
          ]),
        ),
        const SizedBox(height: 20),
        // Everything you get
        Padding(padding: const EdgeInsets.symmetric(horizontal: 20), child: Align(alignment: Alignment.centerLeft, child: Text(tr('Everything you get'), style: AppText.label1))),
        const SizedBox(height: 12),
        for (final t in _pitchBenefits)
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 0, 20, 12),
            child: Row(children: [
              const Icon(Icons.check_circle_rounded, color: AppColors.success, size: 20),
              const SizedBox(width: 12),
              Expanded(child: Text(tr(t), style: AppText.body1.copyWith(color: AppColors.textDarker, fontSize: 15))),
            ]),
          ),
        const SizedBox(height: 8),
        // Trial CTA
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: PrimaryButton(tr('Start 7-day free trial'), onTap: toCheckout),
        ),
        const SizedBox(height: 8),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Center(child: Text('${tr('7 days free, then')} $_priceLabel ${_period()} · ${tr('cancel anytime')}', style: AppText.caption1.copyWith(color: AppColors.textLight))),
        ),
        const SizedBox(height: 6),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Center(child: GestureDetector(onTap: toPlans, child: Text(tr('Compare all plans'), style: AppText.body3.copyWith(color: AppColors.brandPrimary, fontWeight: FontWeight.w700)))),
        ),
      ],
    );
  }

  Widget _lounge(BuildContext context) {
    return TabScaffold(
      onRefresh: () => Future<void>.delayed(const Duration(milliseconds: 900)),
      skeleton: const HubSkeleton(),
      children: [
        _header(),
        const SizedBox(height: 16),
        // Active membership — compact card (you already pay; no need for a big
        // hero). Tier + status inline, perks on one line, manage on the right.
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Container(
            width: double.infinity,
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              gradient: const LinearGradient(colors: AppColors.pointsGradient),
              borderRadius: BorderRadius.circular(AppRadii.card),
            ),
            child: ValueListenableBuilder<String>(
              valueListenable: tierNotifier,
              builder: (context, tier, __) {
                final p = perksFor(tier);
                return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  Row(children: [
                    Container(width: 42, height: 42, decoration: BoxDecoration(color: Colors.white.withValues(alpha: 0.14), borderRadius: BorderRadius.circular(12)), child: const Icon(Icons.workspace_premium_rounded, color: AppColors.gold, size: 24)),
                    const SizedBox(width: 12),
                    Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                      Row(children: [
                        Text(tr(tier), style: AppText.label1.copyWith(color: Colors.white)),
                        const SizedBox(width: 8),
                        Pill(gradient: const LinearGradient(colors: AppColors.goldGradient), padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3), child: Text(tr('Active'), style: AppText.caption1.copyWith(color: AppColors.brandDarkest, fontWeight: FontWeight.w700))),
                      ]),
                      const SizedBox(height: 3),
                      Text('${p.freeLots} ${tr('free lots')} · ${tr('Priority access')}', style: AppText.body3.copyWith(color: Colors.white70)),
                    ])),
                  ]),
                  const SizedBox(height: 12),
                  Row(children: [
                    Text('${tr('Renews')} ${_renewLabel()}', style: AppText.caption1.copyWith(color: Colors.white60)),
                    const Spacer(),
                    Tappable(
                      onTap: () => Navigator.of(context).push(MaterialPageRoute(builder: (_) => const ManageSubscriptionScreen())),
                      child: Row(mainAxisSize: MainAxisSize.min, children: [
                        Text(tr('Manage'), style: AppText.body3.copyWith(color: Colors.white, fontWeight: FontWeight.w700)),
                        const Icon(Icons.chevron_right_rounded, size: 16, color: Colors.white),
                      ]),
                    ),
                  ]),
                ]);
              },
            ),
          ),
        ),
        const SizedBox(height: 12),
        // ── Monthly points — the recurring benefit, stated clearly ──
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: ValueListenableBuilder<String>(
            valueListenable: tierNotifier,
            builder: (context, tier, __) => Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(color: AppColors.successBg, borderRadius: BorderRadius.circular(AppRadii.card)),
              child: Row(children: [
                Container(width: 46, height: 46, decoration: BoxDecoration(color: AppColors.success.withValues(alpha: 0.16), borderRadius: BorderRadius.circular(13)), child: const Icon(Icons.savings_rounded, color: AppColors.success, size: 24)),
                const SizedBox(width: 14),
                Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  Row(crossAxisAlignment: CrossAxisAlignment.baseline, textBaseline: TextBaseline.alphabetic, children: [
                    Text('+${FanModel.fmtPublic(perksFor(tier).monthlyPoints)}', style: AppText.h4.copyWith(color: AppColors.textDarker, fontWeight: FontWeight.w800)),
                    const SizedBox(width: 6),
                    Text('${tr('points')} ${tr('/ month')}', style: AppText.body2.copyWith(color: AppColors.textNormal, fontWeight: FontWeight.w700)),
                  ]),
                  const SizedBox(height: 2),
                  Text('${tr('Automatically credited — next on')} ${_renewLabel()}', style: AppText.body3Regular),
                ])),
              ]),
            ),
          ),
        ),
        const SizedBox(height: 16),
        // ── Vorteile / Inhalte toggle (same pattern as the voucher switch) ──
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: SegmentedToggle(labels: [tr('Perks'), tr('Content')], selected: _loungeTab, onTap: (i) => setState(() => _loungeTab = i)),
        ),
        const SizedBox(height: 20),
        if (_loungeTab == 0) ...[
        // Unlocked perks
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Row(children: [
            Expanded(child: _UnlockedCard(fallback: Icons.casino_rounded, label: tr('Extra Spin'))),
            const SizedBox(width: 12),
            Expanded(child: _UnlockedCard(fallback: Icons.style_rounded, label: tr('Extra Scratch Card'))),
          ]),
        ),
        const SizedBox(height: 24),
        ],
        if (_loungeTab == 1) ...[
        // The one real monthly drop (Super Fan exclusive)
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: SectionHeader('This month’s drop', onAction: () => _push(context, const FomoDropScreen(subscribed: true))),
        ),
        const SizedBox(height: 12),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Tappable(
            scale: 0.98,
            onTap: () => _push(context, const FomoDropScreen(subscribed: true)),
            child: Container(
              width: double.infinity,
              height: 230,
              clipBehavior: Clip.antiAlias,
              decoration: BoxDecoration(borderRadius: BorderRadius.circular(AppRadii.card)),
              child: Stack(fit: StackFit.expand, children: [
                const AssetImg('img_rewards', fit: BoxFit.cover, fallbackIcon: Icons.diamond_rounded),
                const DecoratedBox(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter, end: Alignment.bottomCenter,
                      colors: [Color(0x66000D22), Color(0x11000D22), Color(0xF2000D22)], stops: [0, 0.3, 1],
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(18),
                  child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                    Row(children: [
                      Pill(gradient: const LinearGradient(colors: AppColors.goldGradient), child: Text(tr('Members only'), style: AppText.caption1.copyWith(color: AppColors.brandDarkest, fontWeight: FontWeight.w800))),
                      const Spacer(),
                      Pill(color: Colors.black.withValues(alpha: 0.4), child: Row(mainAxisSize: MainAxisSize.min, children: [
                        const Icon(Icons.local_fire_department_rounded, size: 12, color: AppColors.gold),
                        const SizedBox(width: 4),
                        Text(tr('Only 50 made'), style: AppText.caption1.copyWith(color: Colors.white, fontWeight: FontWeight.w700)),
                      ])),
                    ]),
                    const Spacer(),
                    Text(tr('Signed Retro Shirt — this month’s drop'), style: AppText.h4.copyWith(color: Colors.white)),
                    const SizedBox(height: 4),
                    Text(tr('A limited signed 1997 UEFA Cup retro shirt — dropped once, never restocked.'), maxLines: 2, overflow: TextOverflow.ellipsis, style: AppText.body3.copyWith(color: Colors.white70)),
                    const SizedBox(height: 12),
                    Row(children: [
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 9),
                        decoration: BoxDecoration(gradient: const LinearGradient(colors: AppColors.goldGradient), borderRadius: BorderRadius.circular(999)),
                        child: Row(mainAxisSize: MainAxisSize.min, children: [
                          Text(tr('View drop'), style: AppText.caption1.copyWith(color: AppColors.brandDarkest, fontWeight: FontWeight.w800)),
                          const Icon(Icons.chevron_right_rounded, color: AppColors.brandDarkest, size: 16),
                        ]),
                      ),
                    ]),
                  ]),
                ),
              ]),
            ),
          ),
        ),
        const SizedBox(height: 24),
        ],
        if (_loungeTab == 0) ...[
        // Member discounts — fixed % vouchers at club partners & sponsors
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: SectionHeader('Member discounts', onAction: () => _push(context, const MemberDiscountsScreen())),
        ),
        const SizedBox(height: 4),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Align(alignment: Alignment.centerLeft, child: Text(tr('Fixed % off at the Fanshop, partners & sponsors.'), style: AppText.body3Regular)),
        ),
        const SizedBox(height: 12),
        SizedBox(
          height: 150,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 20),
            itemCount: _discounts.length,
            separatorBuilder: (_, __) => const SizedBox(width: 12),
            itemBuilder: (_, i) {
              final d = _discounts[i];
              return _DiscountCard(partner: d.$1, category: d.$2, discount: d.$3, icon: d.$4, color: d.$5, onTap: () => _push(context, const MemberDiscountsScreen()));
            },
          ),
        ),
        const SizedBox(height: 24),
        ],
        if (_loungeTab == 1) ...[
        // Member content — real photo tiles (matches Redeem / Prizes)
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: SectionHeader('Member content', onAction: () => _push(context, const ExclusiveContentScreen())),
        ),
        const SizedBox(height: 12),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: _contentGrid(context),
        ),
        const SizedBox(height: 24),
        ],
        if (_loungeTab == 0) ...[
        // Tombola perk — compact link (the numbers already live on the
        // membership card, so this stays a lean shortcut, not a repeat).
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: HubListRow(
            icon: Icons.local_activity_rounded,
            iconColor: AppColors.brandPrimary,
            title: 'Your Tombola perk',
            subtitle: '${FanModel.perks.freeLots} ${tr('free lots')} · ${tr('automatically entered')}',
            onTap: () => _push(context, const RafflesScreen()),
          ),
        ),
        ],
      ],
    );
  }
}

/// Concrete membership-benefit tile for the pitch value grid.
class _ValueTile extends StatelessWidget {
  final IconData icon;
  final Color color;
  final String title;
  final String sub;
  const _ValueTile({required this.icon, required this.color, required this.title, required this.sub});
  @override
  Widget build(BuildContext context) {
    return Container(
      height: 108,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(color: AppColors.surface, borderRadius: BorderRadius.circular(AppRadii.card), border: Border.all(color: AppColors.borderLightest)),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
        Container(width: 38, height: 38, decoration: BoxDecoration(color: color.withValues(alpha: 0.12), borderRadius: BorderRadius.circular(11)), child: Icon(icon, color: color, size: 20)),
        Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text(title, maxLines: 1, overflow: TextOverflow.ellipsis, style: AppText.body2.copyWith(color: AppColors.textDarker, fontWeight: FontWeight.w800)),
          Text(sub, maxLines: 1, overflow: TextOverflow.ellipsis, style: AppText.body3Regular),
        ]),
      ]),
    );
  }
}

class _UnlockedCard extends StatelessWidget {
  final IconData fallback;
  final String label;
  const _UnlockedCard({required this.fallback, required this.label});
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(color: AppColors.brandLightest, borderRadius: BorderRadius.circular(AppRadii.tile)),
      child: Column(children: [
        Align(
          alignment: Alignment.topRight,
          child: Pill(
            gradient: const LinearGradient(colors: AppColors.goldGradient),
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
            child: Text(tr('1 Left'), style: AppText.caption1.copyWith(color: AppColors.brandDarkest, fontWeight: FontWeight.w700)),
          ),
        ),
        const SizedBox(height: 4),
        Container(
          width: 44, height: 44,
          decoration: BoxDecoration(color: AppColors.surface, borderRadius: BorderRadius.circular(12)),
          child: Icon(fallback, color: AppColors.brandPrimary, size: 24),
        ),
        const SizedBox(height: 8),
        Text(label, textAlign: TextAlign.center, maxLines: 1, overflow: TextOverflow.ellipsis, style: AppText.body3),
      ]),
    );
  }
}

/// Compact member-discount card for the Fan+ carousel: a sponsor mark, the
/// partner name & category and the fixed % badge. Taps into the full list.
class _DiscountCard extends StatelessWidget {
  final String partner;
  final String category;
  final String discount;
  final IconData icon;
  final Color color;
  final VoidCallback onTap;
  const _DiscountCard({required this.partner, required this.category, required this.discount, required this.icon, required this.color, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Tappable(
      scale: 0.97,
      onTap: onTap,
      child: Container(
        width: 168,
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(color: AppColors.surface, borderRadius: BorderRadius.circular(AppRadii.card), border: Border.all(color: AppColors.borderLightest)),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          SponsorLogo(name: partner, size: 40, bg: color, fg: Colors.white, symbol: icon),
          const Spacer(),
          Text(partner, maxLines: 1, overflow: TextOverflow.ellipsis, style: AppText.body2.copyWith(color: AppColors.textDarker, fontWeight: FontWeight.w800)),
          Text(tr(category), maxLines: 1, overflow: TextOverflow.ellipsis, style: AppText.body3Regular),
          const SizedBox(height: 8),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 5),
            decoration: BoxDecoration(color: AppColors.brandLightest, borderRadius: BorderRadius.circular(AppRadii.chip)),
            child: Text(tr(discount), style: AppText.caption1.copyWith(color: AppColors.brandPrimary, fontWeight: FontWeight.w800, fontSize: 12)),
          ),
        ]),
      ),
    );
  }
}

/// Member-content photo card: full-bleed image, dark scrim, a play badge and a
/// "Members only" pill, with the title and duration overlaid.
class _ContentCard extends StatelessWidget {
  final (String, String, String) item;
  final VoidCallback onTap;
  const _ContentCard({required this.item, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final (title, sub, image) = item;
    return Tappable(
      scale: 0.97,
      onTap: onTap,
      child: Container(
        height: 172,
        clipBehavior: Clip.antiAlias,
        decoration: BoxDecoration(borderRadius: BorderRadius.circular(AppRadii.card)),
        child: Stack(fit: StackFit.expand, children: [
          AssetImg(image, fit: BoxFit.cover, fallbackIcon: Icons.play_circle_rounded),
          const DecoratedBox(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter, end: Alignment.bottomCenter,
                colors: [Color(0x22000000), Color(0x00000000), Color(0xE6000B18)],
                stops: [0, 0.4, 1],
              ),
            ),
          ),
          Positioned(
            top: 10, left: 10,
            child: Pill(color: Colors.black.withValues(alpha: 0.55), child: Text(tr('Members only'), style: AppText.caption1.copyWith(color: Colors.white, fontWeight: FontWeight.w700))),
          ),
          const Center(child: Icon(Icons.play_circle_fill_rounded, color: Colors.white, size: 42)),
          Positioned(
            left: 12, right: 12, bottom: 12,
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text(tr(title), maxLines: 2, overflow: TextOverflow.ellipsis, style: AppText.label2.copyWith(color: Colors.white)),
              const SizedBox(height: 2),
              Text(tr(sub), maxLines: 1, overflow: TextOverflow.ellipsis, style: AppText.body3.copyWith(color: Colors.white70)),
            ]),
          ),
        ]),
      ),
    );
  }
}

