import 'package:flutter/material.dart';
import '../theme/app_theme.dart';
import '../widgets/app_widgets.dart';
import '../widgets/tab_scaffold.dart';
import '../widgets/skeleton.dart';
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
import 'experiences_screen.dart';
import 'raffles_screen.dart';
import 'sponsor_offer_screen.dart';
import 'my_vouchers_screen.dart';
import 'search_screen.dart';
import '../l10n/strings.dart';

/// Points tab — the Fan Points hub: hero balance → quick-access grid → sponsor
/// promos → reward deals → sponsors → redeem grid → challenges → transactions,
/// in Schalke blue with EMBA/S04 content (real club sponsors, fan rewards).
class PointsScreen extends StatelessWidget {
  const PointsScreen({super.key});

  // Real offerings from our own catalogue: (title, category, old pts, new pts,
  // badge, glyph, colour). Fanshop = real products, Tombola = a live draw,
  // Sponsor = a real partner voucher.
  static const _deals = <(String, String, int, int, String, IconData, Color, String)>[
    ('Home Jersey 25/26', 'Fanshop', 4500, 3800, '-15%', Icons.checkroom_rounded, Color(0xFF0A2A5E), 'img_fanshop'),
    ('VELTINS matchday crate', 'Sponsor', 1500, 1050, '-30%', Icons.sports_bar_rounded, Color(0xFF00897B), 'img_partner'),
    ('Derby VIP Tombola', 'Tombola', 500, 350, 'Limited', Icons.local_activity_rounded, Color(0xFFC62828), 'img_rewards'),
    ('Home Scarf 25/26', 'Fanshop', 900, 720, '-20%', Icons.style_rounded, Color(0xFF1565C0), 'img_fanshop'),
  ];

  void _push(BuildContext context, Widget s) =>
      Navigator.of(context).push(MaterialPageRoute(builder: (_) => s));

  @override
  Widget build(BuildContext context) {
    return TabScaffold(
      onRefresh: () => Future<void>.delayed(const Duration(milliseconds: 900)),
      skeleton: const HubSkeleton(),
      extendTopUnderStatusBar: true,
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
          padding: EdgeInsets.fromLTRB(20, MediaQuery.of(context).padding.top + 8, 20, 4),
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
            const SizedBox(height: 20),
            // Primary quick-access — every key hub function on one visible tap
            // (replaces the old 4 circles + hidden "More" sheet).
            Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Expanded(child: _Cat(icon: Icons.add_rounded, label: tr('Earn'), color: AppColors.brandPrimary, onTap: () => _push(context, const EarnPointsScreen()))),
              Expanded(child: _Cat(icon: Icons.savings_rounded, label: tr('Redeem'), color: const Color(0xFF00897B), onTap: () => _push(context, const RedeemScreen()))),
              Expanded(child: _Cat(icon: Icons.account_balance_wallet_rounded, label: tr('Top up'), color: const Color(0xFF1565C0), onTap: () => _push(context, const BuyPointsScreen()))),
              Expanded(child: _Cat(icon: Icons.leaderboard_rounded, label: tr('Ranking'), color: const Color(0xFFEF6C00), onTap: () => _push(context, const LeaderboardScreen()))),
            ]),
          ]),
        ),
        const SizedBox(height: 4),
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
                onTap: () => _push(context, SponsorOfferScreen(sponsor: s)),
              );
            },
          ),
        ),
        const SizedBox(height: 20),
        // ── Reward deals (strikethrough pricing) ──
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: SectionHeader('Reward deals', onAction: () => _push(context, const RedeemScreen())),
        ),
        const SizedBox(height: 12),
        SizedBox(
          height: 194,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 20),
            itemCount: _deals.length,
            separatorBuilder: (_, __) => const SizedBox(width: 12),
            itemBuilder: (_, i) {
              final d = _deals[i];
              return DealCard(
                title: d.$1, category: d.$2, oldPts: d.$3, newPts: d.$4, badge: d.$5, glyph: d.$6, color: d.$7, image: d.$8,
                onTap: () => _push(context, switch (d.$2) {
                  'Fanshop' => const FanshopScreen(),
                  'Tombola' => const RafflesScreen(),
                  _ => const RedeemScreen(),
                }),
              );
            },
          ),
        ),
        const SizedBox(height: 18),
        // ── FOMO drop hero ──
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: HeroBanner(
            eyebrow: 'Only today',
            title: 'Reward drop: prices cut for 24h',
            cta: 'See all deals',
            glyph: Icons.local_fire_department_rounded,
            gradient: const [Color(0xFFC62828), Color(0xFF7F1414)],
            onTap: () => _push(context, const FomoDropScreen()),
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
                _SponsorAvatar(name: s.name, perk: s.perk, color: s.color, symbol: s.icon, onTap: () => _push(context, SponsorOfferScreen(sponsor: s))),
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
          child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Expanded(child: _Cat(icon: Icons.confirmation_number_rounded, label: tr('Vouchers'), color: const Color(0xFF6A1B9A), onTap: () => _push(context, const MyVouchersScreen()))),
            Expanded(child: _Cat(icon: Icons.local_activity_rounded, label: tr('Tombola'), color: const Color(0xFFC62828), onTap: () => _push(context, const RafflesScreen()))),
            Expanded(child: _Cat(icon: Icons.stadium_rounded, label: tr('Experiences'), color: const Color(0xFF1565C0), onTap: () => _push(context, const ExperiencesScreen()))),
            Expanded(child: _Cat(icon: Icons.grid_view_rounded, label: tr('Collection'), color: const Color(0xFF00897B), onTap: () => _push(context, const CollectionScreen()))),
          ]),
        ),
        const SizedBox(height: 16),
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
        const SizedBox(height: 10),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: SurfaceCard(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
            child: Column(children: [
              for (final (i, r) in const [
                ('adidas Store Purchase', 'Today · 14:30', '+252 pts', true),
                ('Daily Spin Win', 'Today · 09:12', '+50 pts', true),
                ('Voucher: Home Scarf 25/26', 'Yesterday', '-900 pts', false),
              ].indexed) ...[
                if (i > 0) Divider(height: 1, color: AppColors.borderLightest),
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  child: _TxnRow(title: r.$1, date: r.$2, pts: r.$3, credit: r.$4),
                ),
              ],
            ]),
          ),
        ),
      ],
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
        decoration: BoxDecoration(color: credit ? AppColors.successBg : AppColors.dangerBg, borderRadius: BorderRadius.circular(11)),
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
