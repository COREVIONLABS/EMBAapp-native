import 'package:flutter/material.dart';
import '../theme/app_theme.dart';
import '../widgets/app_widgets.dart';
import '../widgets/asset_img.dart';
import '../widgets/tab_scaffold.dart';
import '../widgets/skeleton.dart';
import '../widgets/hub_widgets.dart';
import 'subscription_screen.dart';
import 'fomo_drop_screen.dart';
import 'exclusive_content_screen.dart';
import 'fanshop_screen.dart';
import 'raffles_screen.dart';
import '../model/fan_model.dart';
import '../l10n/strings.dart';

/// Fan+ (Figma 2145:8198 Non-Subscriber / 2145:8275 Subscriber).
class FanPlusScreen extends StatefulWidget {
  final bool subscribed;
  const FanPlusScreen({super.key, this.subscribed = false});
  @override
  State<FanPlusScreen> createState() => _FanPlusScreenState();
}

class _FanPlusScreenState extends State<FanPlusScreen> {
  @override
  void initState() {
    super.initState();
    // Becoming a member (via the upgrade flow) flips the preview to the lounge.
    if (widget.subscribed) memberPreviewNotifier.value = true;
  }

  void _push(BuildContext context, Widget s) => Navigator.of(context).push(MaterialPageRoute(builder: (_) => s));

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

  // Member deals — real Fanshop products at a members-only price.
  static const _drops = <(String, String, int, int, String, IconData, Color)>[
    ('Home Jersey 25/26', 'Members', 4500, 3800, '-15%', Icons.checkroom_rounded, Color(0xFF0A2A5E)),
    ('Home Scarf 25/26', 'Members', 900, 720, '-20%', Icons.style_rounded, Color(0xFF1565C0)),
    ('Cap Royal Blue', 'Members', 1100, 950, '-15%', Icons.sports_baseball_rounded, Color(0xFF002F63)),
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
            Text(FanModel.pointsFormatted, style: AppText.caption1.copyWith(color: AppColors.brandPrimary, fontWeight: FontWeight.w800)),
          ]),
        ),
      ]),
    );
  }

  Widget _pitch(BuildContext context) {
    final s = perksFor('Super Fan'); // showcase the hero tier's numbers
    void toPlans() => Navigator.of(context).push(MaterialPageRoute(builder: (_) => const SubscriptionScreen()));
    return TabScaffold(
      onRefresh: () => Future<void>.delayed(const Duration(milliseconds: 900)),
      skeleton: const HubSkeleton(),
      children: [
        _header(),
        const SizedBox(height: 16),
        // Hero
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
              Text(tr('More points, free tombola lots & priority — from €4.99. It pays for itself.'),
                  textAlign: TextAlign.center, style: AppText.body3.copyWith(color: Colors.white70)),
            ]),
          ),
        ),
        const SizedBox(height: 16),
        // Concrete value grid (2×2)
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Column(children: [
            Row(children: [
              Expanded(child: _ValueTile(icon: Icons.bolt_rounded, color: const Color(0xFF1B7A3D), title: tr('Double points'), sub: tr('on every purchase'))),
              const SizedBox(width: 12),
              Expanded(child: _ValueTile(icon: Icons.local_activity_rounded, color: const Color(0xFFC62828), title: '${s.freeLots} ${tr('free lots')}', sub: tr('every month'))),
            ]),
            const SizedBox(height: 12),
            Row(children: [
              Expanded(child: _ValueTile(icon: Icons.savings_rounded, color: AppColors.brandPrimary, title: '+${FanModel.fmtPublic(s.monthlyPoints)} ${tr('pts')}', sub: tr('every month'))),
              const SizedBox(width: 12),
              Expanded(child: _ValueTile(icon: Icons.workspace_premium_rounded, color: const Color(0xFF6A1B9A), title: tr('Priority & drops'), sub: tr('first access, exclusives'))),
            ]),
          ]),
        ),
        const SizedBox(height: 16),
        // Pays for itself
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: SurfaceCard(
            color: AppColors.successBg,
            child: Row(children: [
              const Icon(Icons.savings_rounded, color: AppColors.success),
              const SizedBox(width: 12),
              Expanded(child: Text('${tr('Super Fan')}: +${FanModel.fmtPublic(s.monthlyPoints)} ${tr('pts')} / ${tr('month')} + ${s.freeLots} ${tr('free lots')} — ${tr('it pays for itself.')}',
                  style: AppText.body2.copyWith(color: AppColors.textDarker, fontWeight: FontWeight.w600))),
            ]),
          ),
        ),
        const SizedBox(height: 20),
        // Everything you get
        Padding(padding: const EdgeInsets.symmetric(horizontal: 20), child: Align(alignment: Alignment.centerLeft, child: Text(tr('Everything you get'), style: AppText.label1))),
        const SizedBox(height: 12),
        for (final t in const [
          'Priority ticket access to top matches (48–72h)',
          'Best seats first + matchday upgrades',
          'Monthly exclusive FOMO drop',
          'Exclusive content & locker-room clips',
          'Branded VISA fan card (from Season 2)',
        ])
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
          child: PrimaryButton(tr('Start 7-day free trial'), onTap: toPlans),
        ),
        const SizedBox(height: 8),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Center(child: Text(tr('Then from €4.99 / month · cancel anytime'), style: AppText.caption1.copyWith(color: AppColors.textLight))),
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
        // Active membership card
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Container(
            width: double.infinity,
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              gradient: const LinearGradient(colors: AppColors.pointsGradient),
              borderRadius: BorderRadius.circular(AppRadii.card),
            ),
            child: Column(children: [
              Align(
                alignment: Alignment.topRight,
                child: Pill(
                  gradient: const LinearGradient(colors: AppColors.goldGradient),
                  child: Text(tr('Active'), style: AppText.caption1.copyWith(color: AppColors.brandDarkest, fontWeight: FontWeight.w700)),
                ),
              ),
              const Icon(Icons.workspace_premium_rounded, color: AppColors.gold, size: 36),
              const SizedBox(height: 8),
              ValueListenableBuilder<String>(
                valueListenable: tierNotifier,
                builder: (context, tier, __) => Text(tr(tier), style: AppText.h4.copyWith(color: Colors.white)),
              ),
              const SizedBox(height: 12),
              Wrap(spacing: 8, runSpacing: 8, alignment: WrapAlignment.center, children: [
                for (final b in const ['Priority Access', 'Best Seats', '+3 VIP Draws'])
                  Pill(color: Colors.white24, child: Text(tr(b), style: AppText.caption1.copyWith(color: Colors.white))),
              ]),
              const SizedBox(height: 16),
              Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                Text(tr('Renews: 28 May 2026'), style: AppText.body3.copyWith(color: Colors.white70)),
                Tappable(
                  onTap: () => Navigator.of(context).push(MaterialPageRoute(builder: (_) => const SubscriptionScreen())),
                  child: Row(mainAxisSize: MainAxisSize.min, children: [
                    Text(tr('Manage Subscription'), style: AppText.body3.copyWith(color: Colors.white, fontWeight: FontWeight.w600)),
                    const Icon(Icons.chevron_right_rounded, size: 16, color: Colors.white),
                  ]),
                ),
              ]),
            ]),
          ),
        ),
        const SizedBox(height: 14),
        // Value-back — your membership already paid for itself
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: SurfaceCard(
            color: AppColors.brandLightest,
            child: Row(children: [
              const Icon(Icons.workspace_premium_rounded, color: AppColors.gold),
              const SizedBox(width: 12),
              Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Text(tr('Your membership is working for you'), style: AppText.body2.copyWith(color: AppColors.textDarker, fontWeight: FontWeight.w800)),
                Text('${FanModel.perks.freeLots} ${tr('free lots')} + ${FanModel.fmtPublic(FanModel.perks.monthlyPoints)} ${tr('pts / month')}', style: AppText.body3Regular),
              ])),
            ]),
          ),
        ),
        const SizedBox(height: 16),
        // Unlocked perks
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Row(children: [
            Expanded(child: _UnlockedCard(icon: 'ic_daily_spin', label: tr('Extra Spin'))),
            const SizedBox(width: 12),
            Expanded(child: _UnlockedCard(icon: 'ic_scratch', label: tr('Extra Scratch Card'))),
          ]),
        ),
        const SizedBox(height: 24),
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
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                gradient: const LinearGradient(begin: Alignment.topLeft, end: Alignment.bottomRight, colors: [Color(0xFF0A2A5E), Color(0xFF000D22)]),
                borderRadius: BorderRadius.circular(AppRadii.card),
                border: Border.all(color: AppColors.gold.withValues(alpha: 0.35)),
              ),
              child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Row(children: [
                  Pill(gradient: const LinearGradient(colors: AppColors.goldGradient), child: Text(tr('Super Fan only'), style: AppText.caption1.copyWith(color: AppColors.brandDarkest, fontWeight: FontWeight.w800))),
                  const Spacer(),
                  Pill(color: Colors.white24, child: Text(tr('Only 50 made'), style: AppText.caption1.copyWith(color: Colors.white))),
                ]),
                const SizedBox(height: 14),
                Container(
                  width: 48, height: 48,
                  decoration: BoxDecoration(color: AppColors.gold.withValues(alpha: 0.15), borderRadius: BorderRadius.circular(14)),
                  child: const Icon(Icons.diamond_rounded, color: AppColors.gold, size: 26),
                ),
                const SizedBox(height: 12),
                Text(tr('Signed Retro Shirt — April Drop'), style: AppText.h4.copyWith(color: Colors.white)),
                const SizedBox(height: 6),
                Text(tr('A limited signed 1997 UEFA Cup retro shirt — dropped once, never restocked.'), style: AppText.body3.copyWith(color: Colors.white70)),
                const SizedBox(height: 14),
                Row(children: [
                  Text(tr('View this month\'s drop'), style: AppText.body2.copyWith(color: AppColors.gold, fontWeight: FontWeight.w800)),
                  const Icon(Icons.chevron_right_rounded, color: AppColors.gold, size: 18),
                ]),
              ]),
            ),
          ),
        ),
        const SizedBox(height: 24),
        // Member deals — real Fanshop products at a members-only price
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: SectionHeader('Member deals', onAction: () => _push(context, const FanshopScreen())),
        ),
        const SizedBox(height: 12),
        SizedBox(
          height: 194,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 20),
            itemCount: _drops.length,
            separatorBuilder: (_, __) => const SizedBox(width: 12),
            itemBuilder: (_, i) {
              final d = _drops[i];
              return DealCard(title: d.$1, category: d.$2, oldPts: d.$3, newPts: d.$4, badge: d.$5, glyph: d.$6, color: d.$7, onTap: () => _push(context, const FanshopScreen()));
            },
          ),
        ),
        const SizedBox(height: 24),
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
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Align(alignment: Alignment.centerLeft, child: Text(tr('Your Tombola perk'), style: AppText.label1)),
        ),
        const SizedBox(height: 12),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Container(
            clipBehavior: Clip.antiAlias,
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(gradient: const LinearGradient(colors: [Color(0xFF6A1B9A), Color(0xFF311B92)]), borderRadius: BorderRadius.circular(AppRadii.card)),
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Row(children: [
                Pill(gradient: const LinearGradient(colors: AppColors.goldGradient), child: Text(tr('Super Fan perk'), style: AppText.caption1.copyWith(color: AppColors.brandDarkest, fontWeight: FontWeight.w700))),
                const Spacer(),
                const Icon(Icons.local_activity_rounded, color: AppColors.gold, size: 24),
              ]),
              const SizedBox(height: 14),
              Text('${FanModel.perks.freeLots} ${tr('free tombola lots every month')}', style: AppText.label1.copyWith(color: Colors.white)),
              const SizedBox(height: 4),
              Text(tr('Win VIP tickets, signed gear and more — winners drawn each month.'), style: AppText.body3.copyWith(color: Colors.white70)),
              const SizedBox(height: 14),
              SizedBox(
                width: double.infinity,
                child: Tappable(
                  onTap: () => _push(context, const RafflesScreen()),
                  child: Container(
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    alignment: Alignment.center,
                    decoration: BoxDecoration(color: AppColors.brandDarkest, borderRadius: BorderRadius.circular(999)),
                    child: Row(mainAxisSize: MainAxisSize.min, mainAxisAlignment: MainAxisAlignment.center, children: [
                      Text(tr('Open Tombola'), style: AppText.body2.copyWith(color: Colors.white, fontWeight: FontWeight.w600)),
                      const SizedBox(width: 4),
                      const Icon(Icons.chevron_right_rounded, size: 18, color: Colors.white),
                    ]),
                  ),
                ),
              ),
            ]),
          ),
        ),
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
  final String icon;
  final String label;
  const _UnlockedCard({required this.icon, required this.label});
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
        AssetImg(icon, width: 44, height: 44, fallbackIcon: Icons.card_giftcard_rounded),
        const SizedBox(height: 8),
        Text(label, textAlign: TextAlign.center, maxLines: 1, overflow: TextOverflow.ellipsis, style: AppText.body3),
      ]),
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

