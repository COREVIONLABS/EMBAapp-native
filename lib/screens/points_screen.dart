import 'package:flutter/material.dart';
import '../theme/app_theme.dart';
import '../widgets/app_widgets.dart';
import '../widgets/tab_scaffold.dart';
import '../widgets/hub_widgets.dart';
import '../model/fan_model.dart';
import 'redeem_screen.dart';
import 'earn_points_screen.dart';
import 'buy_points_screen.dart';
import 'leaderboard_screen.dart';
import 'fomo_drop_screen.dart';
import 'collection_screen.dart';
import 'subscription_screen.dart';
import 'points_history_screen.dart';
import 'fanshop_screen.dart';
import 'tickets_screen.dart';
import 'experiences_screen.dart';
import 'voucher_screen.dart';
import 'search_screen.dart';
import '../l10n/strings.dart';

/// Points tab — RevPoints-style Fan Points hub. Structure follows Revolut's
/// RevPoints (hero balance → 4 actions → sponsor promo → sponsors → redeem
/// grid → challenges → transactions), skinned in Schalke blue and filled with
/// EMBA/S04 content (real club sponsors, fan rewards).
class PointsScreen extends StatelessWidget {
  const PointsScreen({super.key});

  void _push(BuildContext context, Widget s) =>
      Navigator.of(context).push(MaterialPageRoute(builder: (_) => s));

  @override
  Widget build(BuildContext context) {
    return TabScaffold(
      children: [
        // ── Top zone: header + search + hero + actions on a soft gradient ──
        Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [AppColors.brandLightest, AppColors.surface],
            ),
          ),
          padding: const EdgeInsets.fromLTRB(20, 0, 20, 8),
          child: Column(children: [
            // Header
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Svg('logo_s04', size: 36),
                Container(
                  width: 36,
                  height: 36,
                  decoration: BoxDecoration(color: AppColors.surface, borderRadius: BorderRadius.circular(36)),
                  child: const Center(child: Svg('bell_dot', size: 20)),
                ),
              ],
            ),
            const SizedBox(height: 14),
            // Store search
            Tappable(
              scale: 0.98,
              onTap: () => _push(context, const SearchScreen()),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 13),
                decoration: BoxDecoration(color: AppColors.surface, borderRadius: BorderRadius.circular(AppRadii.pill)),
                child: Row(children: [
                  Icon(Icons.search_rounded, size: 20, color: AppColors.textLight),
                  const SizedBox(width: 10),
                  Text(tr('Search rewards & sponsors'), style: AppText.body2.copyWith(color: AppColors.textLight)),
                ]),
              ),
            ),
            const SizedBox(height: 22),
            // Hero balance
            GestureDetector(
              onTap: () => _push(context, const SubscriptionScreen()),
              child: Row(mainAxisAlignment: MainAxisAlignment.center, children: [
                Text(tr(FanModel.membershipTier), style: AppText.label2.copyWith(color: AppColors.textDarker)),
                const SizedBox(width: 4),
                Icon(Icons.chevron_right_rounded, size: 18, color: AppColors.textLight),
              ]),
            ),
            const SizedBox(height: 8),
            Row(mainAxisAlignment: MainAxisAlignment.center, crossAxisAlignment: CrossAxisAlignment.center, children: [
              Container(
                width: 40, height: 40,
                decoration: BoxDecoration(gradient: const LinearGradient(colors: AppColors.pointsGradient), borderRadius: BorderRadius.circular(12)),
                child: const Icon(Icons.hexagon_rounded, color: AppColors.gold, size: 22),
              ),
              const SizedBox(width: 12),
              Text(FanModel.pointsFormatted, style: AppText.h1.copyWith(color: AppColors.textDarker, fontSize: 46, fontWeight: FontWeight.w800)),
            ]),
            const SizedBox(height: 6),
            Row(mainAxisAlignment: MainAxisAlignment.center, children: [
              Text('≈ ${FanModel.balanceEuro} · ${tr('1 pt per €1 spent')}', style: AppText.body3.copyWith(color: AppColors.textLight)),
              const SizedBox(width: 4),
              Icon(Icons.info_outline_rounded, size: 14, color: AppColors.textLight),
            ]),
            const SizedBox(height: 22),
            // 4 circle actions
            Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
              _Action(icon: Icons.add_rounded, label: tr('Earn'), onTap: () => _push(context, const EarnPointsScreen())),
              _Action(icon: Icons.savings_rounded, label: tr('Redeem'), onTap: () => _push(context, const RedeemScreen())),
              _Action(icon: Icons.workspace_premium_rounded, label: tr('Membership'), onTap: () => _push(context, const SubscriptionScreen())),
              _Action(icon: Icons.more_horiz_rounded, label: tr('More'), onTap: () => _showMore(context)),
            ]),
          ]),
        ),
        const SizedBox(height: 8),
        // ── Featured sponsor promos (big-card carousel) ──
        SizedBox(
          height: 176,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 20),
            itemCount: kSponsors.length,
            separatorBuilder: (_, __) => const SizedBox(width: 12),
            itemBuilder: (_, i) {
              final s = kSponsors[i];
              return BigPromoCard(
                sponsor: s.name,
                category: 'Partner offer',
                headline: s.perk,
                color: s.color,
                onTap: () => _push(context, const RedeemScreen()),
              );
            },
          ),
        ),
        const SizedBox(height: 20),
        // ── Top Sponsors ──
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: SectionHeader('Top Sponsors', onAction: () => _push(context, const RedeemScreen())),
        ),
        const SizedBox(height: 12),
        SizedBox(
          height: 92,
          child: ListView(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 20),
            children: [
              for (final s in kSponsors)
                _SponsorAvatar(name: s.name, perk: s.perk, color: s.color, symbol: s.icon, onTap: () => _push(context, const VoucherScreen())),
            ],
          ),
        ),
        const SizedBox(height: 20),
        // ── Redeem categories (quick grid) ──
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: SectionHeader('Redeem your points', onAction: () => _push(context, const RedeemScreen())),
        ),
        const SizedBox(height: 12),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: GridView.count(
            crossAxisCount: 4,
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            mainAxisSpacing: 14,
            crossAxisSpacing: 12,
            childAspectRatio: 0.82,
            children: [
              _Cat(icon: Icons.checkroom_rounded, label: tr('Fanshop'), color: const Color(0xFF0A2A5E), onTap: () => _push(context, const FanshopScreen())),
              _Cat(icon: Icons.confirmation_number_rounded, label: tr('Tickets'), color: const Color(0xFF1565C0), onTap: () => _push(context, const TicketsScreen())),
              _Cat(icon: Icons.storefront_rounded, label: tr('Sponsors'), color: const Color(0xFF00897B), onTap: () => _push(context, const VoucherScreen())),
              _Cat(icon: Icons.stadium_rounded, label: tr('Experiences'), color: const Color(0xFF6A1B9A), onTap: () => _push(context, const ExperiencesScreen())),
            ],
          ),
        ),
        const SizedBox(height: 20),
        // ── Challenges ──
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: SurfaceCard(
            onTap: () => _push(context, const EarnPointsScreen()),
            child: Row(children: [
              Container(
                width: 44, height: 44,
                decoration: BoxDecoration(color: AppColors.brandLightest, borderRadius: BorderRadius.circular(12)),
                child: const Icon(Icons.emoji_events_outlined, color: AppColors.brandPrimary, size: 22),
              ),
              const SizedBox(width: 14),
              Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Text(tr('Challenges'), style: AppText.body2.copyWith(color: AppColors.textDarker)),
                Text(tr('2 active · earn up to +800 pts'), style: AppText.body3Regular),
              ])),
              Icon(Icons.chevron_right_rounded, color: AppColors.textLight),
            ]),
          ),
        ),
        const SizedBox(height: 20),
        // ── Transactions ──
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: SectionHeader('Transactions', onAction: () => _push(context, const PointsHistoryScreen())),
        ),
        const SizedBox(height: 8),
        for (final r in const [
          ('adidas Store Purchase', 'Today · 14:30', '+252 pts', true),
          ('Daily Spin Win', 'Today · 09:12', '+50 pts', true),
          ('Redeemed: Home Jersey', 'Yesterday', '-1,500 pts', false),
        ])
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 0, 20, 10),
            child: _TxnRow(title: r.$1, date: r.$2, pts: r.$3, credit: r.$4),
          ),
      ],
    );
  }

  void _showMore(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (_) => _MoreSheet(onPick: (w) {
        Navigator.of(context).pop();
        _push(context, w);
      }),
    );
  }
}

class _Action extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;
  const _Action({required this.icon, required this.label, required this.onTap});
  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Tappable(
        scale: 0.94,
        onTap: onTap,
        child: Column(children: [
          Container(
            width: 56, height: 56,
            decoration: BoxDecoration(color: AppColors.surface, shape: BoxShape.circle, border: Border.all(color: AppColors.borderLightest)),
            child: Icon(icon, color: AppColors.brandPrimary, size: 24),
          ),
          const SizedBox(height: 8),
          Text(label, textAlign: TextAlign.center, style: AppText.body3.copyWith(fontSize: 12.5), maxLines: 1, overflow: TextOverflow.ellipsis),
        ]),
      ),
    );
  }
}

class _SponsorAvatar extends StatelessWidget {
  final String name;
  final String perk;
  final Color color;
  final IconData? symbol;
  final VoidCallback onTap;
  const _SponsorAvatar({required this.name, required this.perk, required this.color, this.symbol, required this.onTap});
  @override
  Widget build(BuildContext context) {
    return Tappable(
      scale: 0.94,
      onTap: onTap,
      child: Container(
        width: 78,
        margin: const EdgeInsets.only(right: 12),
        child: Column(children: [
          SponsorLogo(name: name, size: 52, bg: color, symbol: symbol),
          const SizedBox(height: 6),
          Text(name, maxLines: 1, overflow: TextOverflow.ellipsis, style: AppText.caption1.copyWith(color: AppColors.textDarker, fontWeight: FontWeight.w700, fontSize: 11)),
          Text(perk, maxLines: 1, overflow: TextOverflow.ellipsis, style: AppText.caption1.copyWith(color: AppColors.brandPrimary, fontSize: 10)),
        ]),
      ),
    );
  }
}

class _Cat extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;
  final VoidCallback onTap;
  const _Cat({required this.icon, required this.label, required this.color, required this.onTap});
  @override
  Widget build(BuildContext context) {
    return Tappable(
      scale: 0.94,
      onTap: onTap,
      child: Column(children: [
        Container(
          width: 56, height: 56,
          decoration: BoxDecoration(color: color.withValues(alpha: 0.12), borderRadius: BorderRadius.circular(AppRadii.tile)),
          child: Icon(icon, color: color, size: 26),
        ),
        const SizedBox(height: 6),
        Text(label, style: AppText.body3.copyWith(fontSize: 12), textAlign: TextAlign.center, maxLines: 1, overflow: TextOverflow.ellipsis),
      ]),
    );
  }
}

class _TxnRow extends StatelessWidget {
  final String title;
  final String date;
  final String pts;
  final bool credit;
  const _TxnRow({required this.title, required this.date, required this.pts, required this.credit});
  @override
  Widget build(BuildContext context) {
    return Row(children: [
      Container(
        width: 40, height: 40,
        decoration: BoxDecoration(color: credit ? AppColors.successBg : const Color(0xFFFDE7E7), borderRadius: BorderRadius.circular(11)),
        child: Icon(credit ? Icons.arrow_upward_rounded : Icons.arrow_downward_rounded, color: credit ? AppColors.success : AppColors.danger, size: 18),
      ),
      const SizedBox(width: 12),
      Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text(tr(title), style: AppText.body2.copyWith(color: AppColors.textDarker)),
        const SizedBox(height: 2),
        Text(tr(date), style: AppText.body3Regular),
      ])),
      Text(pts, style: AppText.body2.copyWith(color: credit ? AppColors.success : AppColors.danger, fontWeight: FontWeight.w700)),
    ]);
  }
}

class _MoreSheet extends StatelessWidget {
  final void Function(Widget) onPick;
  const _MoreSheet({required this.onPick});
  @override
  Widget build(BuildContext context) {
    final items = <(IconData, String, String, Widget)>[
      (Icons.add_circle_outline_rounded, 'Top up points', 'Buy a package · 100 pts = €1', const BuyPointsScreen()),
      (Icons.leaderboard_rounded, 'Top Supporters', 'Season ranking — earned points only', const LeaderboardScreen()),
      (Icons.local_fire_department_rounded, "This Month's Drop", 'Super Fan exclusive', const FomoDropScreen(subscribed: true)),
      (Icons.grid_view_rounded, 'Season Collection', 'Collect player stickers', const CollectionScreen()),
      (Icons.history_rounded, 'Points History', 'All your transactions', const PointsHistoryScreen()),
    ];
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 28),
      decoration: BoxDecoration(color: AppColors.surface, borderRadius: BorderRadius.vertical(top: Radius.circular(28))),
      child: Column(mainAxisSize: MainAxisSize.min, children: [
        Container(width: 40, height: 4, decoration: BoxDecoration(color: AppColors.borderLightest, borderRadius: BorderRadius.circular(2))),
        const SizedBox(height: 12),
        Align(alignment: Alignment.centerLeft, child: Padding(padding: const EdgeInsets.symmetric(horizontal: 4), child: Text(tr('More'), style: AppText.label1))),
        const SizedBox(height: 8),
        for (final it in items)
          InkWell(
            onTap: () => onPick(it.$4),
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 4),
              child: Row(children: [
                Container(
                  width: 42, height: 42,
                  decoration: BoxDecoration(color: AppColors.brandLightest, borderRadius: BorderRadius.circular(12)),
                  child: Icon(it.$1, color: AppColors.brandPrimary, size: 22),
                ),
                const SizedBox(width: 14),
                Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  Text(tr(it.$2), style: AppText.body2.copyWith(color: AppColors.textDarker)),
                  Text(tr(it.$3), style: AppText.body3Regular),
                ])),
                Icon(Icons.chevron_right_rounded, color: AppColors.textLight),
              ]),
            ),
          ),
      ]),
    );
  }
}
