import 'package:flutter/material.dart';
import '../theme/app_theme.dart';
import '../widgets/app_widgets.dart';
import 'daily_spin_screen.dart';
import 'scratch_card_screen.dart';
import 'predictions_screen.dart';
import 'redeem_screen.dart';
import 'earn_points_screen.dart';
import 'fanshop_screen.dart';
import 'notifications_screen.dart';
import 'tickets_screen.dart';
import 'experiences_screen.dart';
import 'club_news_screen.dart';
import 'deals_hub_screen.dart';
import 'achievements_screen.dart';
import 'matchday_specials_screen.dart';
import 'matchday_live_screen.dart';
import 'search_screen.dart';
import 'exclusive_content_screen.dart';
import 'leaderboard_screen.dart';
import 'subscription_screen.dart';
import 'streak_screen.dart';
import 'fanplus_screen.dart';
import '../model/fan_model.dart';
import '../widgets/hub_widgets.dart';
import '../widgets/skeleton.dart';
import '../l10n/strings.dart';

void _push(BuildContext context, Widget screen) {
  Navigator.of(context).push(MaterialPageRoute(builder: (_) => screen));
}

/// Home tab (Figma 2145:7192 Matchday / 2145:7546 Non-Matchday).
class HomeMatchdayScreen extends StatefulWidget {
  const HomeMatchdayScreen({super.key});
  @override
  State<HomeMatchdayScreen> createState() => _HomeMatchdayScreenState();
}

class _HomeMatchdayScreenState extends State<HomeMatchdayScreen> {
  bool _matchday = true;
  bool _loading = true;
  bool _statusDismissed = false;
  bool _exploreExpanded = false;

  @override
  void initState() {
    super.initState();
    Future<void>.delayed(const Duration(milliseconds: 750), () {
      if (mounted) setState(() => _loading = false);
    });
  }

  Future<void> _refresh() async {
    await Future<void>.delayed(const Duration(milliseconds: 900));
    if (mounted) setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      color: AppColors.surface,
      child: RefreshIndicator(
        onRefresh: _refresh,
        color: AppColors.brandPrimary,
        child: ListView(
          padding: EdgeInsets.only(top: MediaQuery.of(context).padding.top + 6, bottom: 120 + MediaQuery.of(context).padding.bottom),
          children: [
            if (_loading) const _HomeSkeleton() else ...[
            _header(),
            const SizedBox(height: 14),
            // Personal greeting
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Row(children: [
                Expanded(child: Text('${tr('Moin')}, Max 👋', style: AppText.h4.copyWith(color: AppColors.textDarker))),
              ]),
            ),
            const SizedBox(height: 16),
            // Fan Points wallet is always the first thing on Home.
            const Padding(padding: EdgeInsets.symmetric(horizontal: 20), child: _PointsCard()),
            const SizedBox(height: 14),
            _infoChips(),
            const SizedBox(height: 16),
            // Sponsor campaign + the open daily-spin nudge sit below the wallet.
            Padding(padding: const EdgeInsets.symmetric(horizontal: 20), child: _heroBanner()),
            const SizedBox(height: 14),
            if (!_statusDismissed) ...[
              Padding(padding: const EdgeInsets.symmetric(horizontal: 20), child: _statusCard()),
              const SizedBox(height: 14),
            ],
            const Padding(padding: EdgeInsets.symmetric(horizontal: 20), child: _StreakStrip()),
            const SizedBox(height: 20),
            if (_matchday)
              Padding(padding: const EdgeInsets.symmetric(horizontal: 20), child: _NextMatchCard(onTicket: () => _push(context, const TicketsScreen()), onPredict: () => _push(context, const PredictionsScreen())))
            else
              const _NonMatchdayCards(),
            const SizedBox(height: 20),
            const _QuickActions(),
            const SizedBox(height: 24),
            _explore(),
            const SizedBox(height: 24),
            _forYou(),
            const SizedBox(height: 24),
            _missions(),
            const SizedBox(height: 20),
            Padding(padding: const EdgeInsets.symmetric(horizontal: 20), child: _FanPlusCta(onTap: () => _push(context, const FanPlusScreen()))),
            ],
          ],
          ),
        ),
    );
  }

  Widget _explore() {
    // Eight primary shortcuts (label, image asset, motif icon, colour, target).
    // Row 1 = emotional/interactive, row 2 = content/commercial.
    final items = <(String, String, IconData, Color, Widget)>[
      ('Tickets', 'img_tickets', Icons.confirmation_number_rounded, const Color(0xFF1565C0), const TicketsScreen()),
      ('Experiences', 'img_experiences', Icons.stadium_rounded, const Color(0xFF6A1B9A), const ExperiencesScreen()),
      ('Community', 'img_community', Icons.groups_rounded, const Color(0xFF00897B), const LeaderboardScreen()),
      ('Challenges', 'img_challenges', Icons.flag_rounded, const Color(0xFFEF6C00), const EarnPointsScreen()),
      ('Content', 'img_content', Icons.play_circle_outline_rounded, const Color(0xFFC62828), const ExclusiveContentScreen()),
      ('News', 'img_news', Icons.newspaper_rounded, const Color(0xFF3949AB), const ClubNewsScreen()),
      ('Benefits', 'img_benefits', Icons.redeem_rounded, const Color(0xFFF9A825), const DealsHubScreen()),
      ('Fanshop', 'img_fanshop', Icons.storefront_rounded, const Color(0xFF0A2A5E), const FanshopScreen()),
    ];
    // Extra modules revealed by "Show more" (Revolut-style inline expand).
    // Partner has a real photo; Raffles/Live/Specials still fall back to a motif
    // until their photos are added.
    final more = <(String, String, IconData, Color, Widget)>[
      ('Partner', 'img_partner', Icons.handshake_rounded, const Color(0xFF00897B), const DealsHubScreen()),
      ('Raffles', 'img_raffles', Icons.local_activity_rounded, const Color(0xFF8E24AA), const ExperiencesScreen()),
      ('Live', 'img_live', Icons.sensors_rounded, const Color(0xFFD32F2F), const MatchdayLiveScreen()),
      ('Specials', 'img_specials', Icons.bolt_rounded, const Color(0xFFF9A825), const MatchdaySpecialsScreen()),
    ];
    final shown = [...items, if (_exploreExpanded) ...more];
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Padding(padding: EdgeInsets.symmetric(horizontal: 20), child: SectionHeader('Explore', action: null)),
        const SizedBox(height: 12),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: AnimatedSize(
            duration: const Duration(milliseconds: 220),
            curve: Curves.easeOut,
            alignment: Alignment.topCenter,
            child: GridView.count(
              crossAxisCount: 4,
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              mainAxisSpacing: 14,
              crossAxisSpacing: 12,
              childAspectRatio: 0.70,
              children: [
                for (final it in shown)
                  HomeImageTile(label: it.$1, image: it.$2, icon: it.$3, color: it.$4, height: 80, onTap: () => _push(context, it.$5)),
              ],
            ),
          ),
        ),
        const SizedBox(height: 6),
        GestureDetector(
          behavior: HitTestBehavior.opaque,
          onTap: () => setState(() => _exploreExpanded = !_exploreExpanded),
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 10),
            child: Center(
              child: Row(mainAxisSize: MainAxisSize.min, children: [
                Text(_exploreExpanded ? tr('Show less') : tr('Show more'), style: AppText.body2.copyWith(color: AppColors.textDarker, fontWeight: FontWeight.w800)),
                const SizedBox(width: 4),
                Icon(_exploreExpanded ? Icons.keyboard_arrow_up_rounded : Icons.keyboard_arrow_down_rounded, size: 22, color: AppColors.textDarker),
              ]),
            ),
          ),
        ),
      ],
    );
  }

  // Editorial sponsor/campaign hero (Careem "Restaurant Week" style) — kept
  // deliberately off the fixture so it never duplicates the next-match card.
  Widget _heroBanner() => HeroBanner(
        eyebrow: 'Presented by VELTINS',
        title: 'Win matchday jerseys & VIP seats',
        cta: 'Enter now',
        glyph: Icons.emoji_events_rounded,
        gradient: const [Color(0xFF1B5E20), Color(0xFF0B3D14)],
        image: 'img_hero_sponsor',
        onTap: () => _push(context, const DealsHubScreen()),
      );

  // Dismissible status card (Careem "That was fast!" style) — always a
  // non-fixture nudge so it doesn't repeat the match card on matchdays.
  Widget _statusCard() {
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 14, 10, 14),
      decoration: BoxDecoration(color: AppColors.brandDarkest, borderRadius: BorderRadius.circular(AppRadii.card)),
      child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Container(
          width: 46, height: 46,
          decoration: BoxDecoration(color: Colors.white.withValues(alpha: 0.12), borderRadius: BorderRadius.circular(12)),
          child: const Icon(Icons.casino_rounded, color: AppColors.gold),
        ),
        const SizedBox(width: 12),
        Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text(tr('Your daily spin is still open'), style: AppText.body2.copyWith(color: Colors.white, fontWeight: FontWeight.w700)),
          const SizedBox(height: 2),
          Text(tr('Spin now for bonus points'), maxLines: 1, overflow: TextOverflow.ellipsis, style: AppText.body3.copyWith(color: Colors.white70)),
          const SizedBox(height: 10),
          Tappable(
            onTap: () => showDailySpin(context),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
              decoration: BoxDecoration(gradient: const LinearGradient(colors: AppColors.goldGradient), borderRadius: BorderRadius.circular(999)),
              child: Text(tr('Spin now'), style: AppText.body3.copyWith(color: AppColors.brandDarkest, fontWeight: FontWeight.w800)),
            ),
          ),
        ])),
        GestureDetector(
          onTap: () => setState(() => _statusDismissed = true),
          behavior: HitTestBehavior.opaque,
          child: const Padding(padding: EdgeInsets.all(4), child: Icon(Icons.close_rounded, color: Colors.white54, size: 20)),
        ),
      ]),
    );
  }

  // At-a-glance quick-stat chips (Careem "Balance / SRW / Salik" row).
  Widget _infoChips() {
    return ValueListenableBuilder<String>(
      valueListenable: tierNotifier,
      builder: (context, tier, __) {
        final chips = <(IconData, String, String, Color, VoidCallback)>[
          (Icons.workspace_premium_rounded, 'Membership', tier, AppColors.gold, () => _push(context, const FanPlusScreen())),
          (Icons.local_fire_department_rounded, 'Streak', '5 days', const Color(0xFFEF6C00), () => _push(context, const AchievementsScreen())),
          (Icons.leaderboard_rounded, 'Rank', '#12', const Color(0xFF1565C0), () => _push(context, const LeaderboardScreen())),
          (Icons.card_giftcard_rounded, 'Next reward', '900 pts', const Color(0xFF00897B), () => _push(context, const RedeemScreen())),
        ];
        return SizedBox(
          height: 58,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 20),
            itemCount: chips.length,
            separatorBuilder: (_, __) => const SizedBox(width: 10),
            itemBuilder: (_, i) => InfoChip(icon: chips[i].$1, label: chips[i].$2, value: chips[i].$3, color: chips[i].$4, onTap: chips[i].$5),
          ),
        );
      },
    );
  }

  // Personalised recommendations (Careem "For you, Günter" row).
  Widget _forYou() {
    final recs = <(String, String, String, IconData, Color, VoidCallback)>[
      ('VIP stadium tour', 'Experience · 2,500 pts', 'Recommended', Icons.stadium_rounded, const Color(0xFF6A1B9A), () => _push(context, const ExperiencesScreen())),
      ('adidas home shirt 24/25', 'Fanshop · 20% with points', 'Popular', Icons.checkroom_rounded, const Color(0xFF0A2A5E), () => _push(context, const RedeemScreen())),
      ('Players meet & greet', 'Experience · raffle', 'New', Icons.emoji_events_rounded, const Color(0xFFC62828), () => _push(context, const ExperiencesScreen())),
      ('VELTINS 6-pack', 'Sponsor · -15%', 'Sponsor deal', Icons.local_offer_rounded, const Color(0xFF00897B), () => _push(context, const DealsHubScreen())),
    ];
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text('${tr('For you')}, Max', style: AppText.label1),
          const SizedBox(height: 2),
          Text(tr('Based on your activity'), style: AppText.body3Regular),
        ]),
      ),
      const SizedBox(height: 12),
      SizedBox(
        height: 192,
        child: ListView.separated(
          scrollDirection: Axis.horizontal,
          padding: const EdgeInsets.symmetric(horizontal: 20),
          itemCount: recs.length,
          separatorBuilder: (_, __) => const SizedBox(width: 12),
          itemBuilder: (_, i) => ForYouCard(title: recs[i].$1, meta: recs[i].$2, badge: recs[i].$3, glyph: recs[i].$4, color: recs[i].$5, onTap: recs[i].$6),
        ),
      ),
    ]);
  }

  Widget _header() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          const Svg('logo_s04', size: 36),
          GestureDetector(
            onTap: () => setState(() => _matchday = !_matchday),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
              decoration: BoxDecoration(
                color: _matchday ? AppColors.brandLightest : AppColors.surfaceMinimal,
                borderRadius: BorderRadius.circular(AppRadii.pill),
              ),
              child: Row(mainAxisSize: MainAxisSize.min, children: [
                Icon(_matchday ? Icons.sports_soccer_rounded : Icons.calendar_today_rounded,
                    size: 14, color: _matchday ? AppColors.brandPrimary : AppColors.textLight),
                const SizedBox(width: 6),
                Text(_matchday ? tr('Matchday') : tr('Non-Matchday'),
                    style: AppText.caption1.copyWith(
                        color: _matchday ? AppColors.brandPrimary : AppColors.textLight, fontWeight: FontWeight.w700)),
              ]),
            ),
          ),
          Builder(
            builder: (context) => Row(children: [
              GestureDetector(
                onTap: () => _push(context, const SearchScreen()),
                child: Container(
                  width: 36,
                  height: 36,
                  decoration: BoxDecoration(color: AppColors.surfaceMinimal, borderRadius: BorderRadius.circular(36)),
                  child: Icon(Icons.search_rounded, size: 20, color: AppColors.textNormal),
                ),
              ),
              const SizedBox(width: 10),
              GestureDetector(
                onTap: () => _push(context, const NotificationsScreen()),
                child: Container(
                  width: 36,
                  height: 36,
                  decoration:
                      BoxDecoration(color: AppColors.surfaceMinimal, borderRadius: BorderRadius.circular(36)),
                  child: const Center(child: Svg('bell_dot', size: 20)),
                ),
              ),
            ]),
          ),
        ],
      ),
    );
  }

  Widget _missions() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Padding(
          padding: EdgeInsets.symmetric(horizontal: 20),
          child: SectionHeader('Active Missions', action: null),
        ),
        const SizedBox(height: 14),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: const [
            Expanded(child: FeaturedGoalCard(
                icon: Icons.sports_soccer_rounded,
                title: 'Predict 2 matches',
                sub: '1 / 2 complete',
                progress: 0.5,
                reward: '+75')),
            SizedBox(width: 12),
            Expanded(child: FeaturedGoalCard(
                icon: Icons.local_fire_department_rounded,
                title: '5-day streak',
                sub: 'Keep it going for +10 pts',
                progress: 0.71,
                reward: '+10')),
          ]),
        ),
      ],
    );
  }
}

/// Loading placeholder for the Home tab — mirrors the greeting, points card,
/// fixture card and quick-action row while content settles on first launch.
class _HomeSkeleton extends StatelessWidget {
  const _HomeSkeleton();
  @override
  Widget build(BuildContext context) {
    return Shimmer(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: const [
            SkeletonCircle(size: 36),
            SkeletonBox(width: 92, height: 32, radius: 16),
            SkeletonBox(width: 82, height: 36, radius: 18),
          ]),
          const SizedBox(height: 22),
          const SkeletonBox(width: 150, height: 22),
          const SizedBox(height: 18),
          const SkeletonBox(height: 128, radius: 22),
          const SizedBox(height: 12),
          const SkeletonBox(height: 72, radius: 16),
          const SizedBox(height: 18),
          const SkeletonBox(height: 176, radius: 22),
          const SizedBox(height: 22),
          Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: const [
            Column(children: [SkeletonBox(width: 72, height: 72, radius: 20), SizedBox(height: 8), SkeletonBox(width: 46, height: 10)]),
            Column(children: [SkeletonBox(width: 72, height: 72, radius: 20), SizedBox(height: 8), SkeletonBox(width: 46, height: 10)]),
            Column(children: [SkeletonBox(width: 72, height: 72, radius: 20), SizedBox(height: 8), SkeletonBox(width: 46, height: 10)]),
            Column(children: [SkeletonBox(width: 72, height: 72, radius: 20), SizedBox(height: 8), SkeletonBox(width: 46, height: 10)]),
          ]),
        ]),
      ),
    );
  }
}

/// Compact Fan+ conversion banner — surfaces the paid membership on Home.
class _FanPlusCta extends StatelessWidget {
  final VoidCallback onTap;
  const _FanPlusCta({required this.onTap});
  @override
  Widget build(BuildContext context) {
    return Tappable(
      onTap: onTap,
      scale: 0.98,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          gradient: const LinearGradient(colors: AppColors.pointsGradient),
          borderRadius: BorderRadius.circular(AppRadii.card),
        ),
        child: Row(children: [
          const Icon(Icons.workspace_premium_rounded, color: AppColors.gold, size: 26),
          const SizedBox(width: 12),
          Expanded(
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text(tr('Become a member'), style: AppText.body2.copyWith(color: Colors.white, fontWeight: FontWeight.w700)),
              const SizedBox(height: 2),
              Text(tr('Get 100% of your fee back in points'), style: AppText.body3.copyWith(color: Colors.white70)),
            ]),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            decoration: BoxDecoration(gradient: const LinearGradient(colors: AppColors.goldGradient), borderRadius: BorderRadius.circular(999)),
            child: Text(tr('Upgrade'), style: AppText.body3.copyWith(color: AppColors.brandDarkest, fontWeight: FontWeight.w700)),
          ),
        ]),
      ),
    );
  }
}

/// Daily streak strip — season-long engagement mechanic from the Fan+ pitch.
class _StreakStrip extends StatelessWidget {
  const _StreakStrip();
  @override
  Widget build(BuildContext context) {
    const done = 5; // days completed this week
    const labels = ['M', 'T', 'W', 'T', 'F', 'S', 'S'];
    return SurfaceCard(
      onTap: () => _push(context, const StreakScreen()),
      padding: const EdgeInsets.all(14),
      child: Row(children: [
        Container(
          width: 40, height: 40,
          decoration: BoxDecoration(gradient: const LinearGradient(colors: AppColors.goldGradient), borderRadius: BorderRadius.circular(12)),
          alignment: Alignment.center,
          child: const Icon(Icons.local_fire_department_rounded, color: AppColors.brandDarkest, size: 24),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Row(children: [
              Expanded(child: Row(children: [
                Flexible(child: Text(tr('5-day streak'), overflow: TextOverflow.ellipsis, style: AppText.body2.copyWith(color: AppColors.textDarker, fontWeight: FontWeight.w700))),
                const SizedBox(width: 6),
                Flexible(child: Text(tr('· keep it going for +10 pts'), overflow: TextOverflow.ellipsis, style: AppText.body3Regular)),
              ])),
              // Streak protection — a Fan Member / Super Fan perk: one missed day
              // won't reset the streak.
              Pill(
                color: AppColors.successBg,
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                child: Row(mainAxisSize: MainAxisSize.min, children: [
                  const Icon(Icons.shield_rounded, size: 11, color: AppColors.success),
                  const SizedBox(width: 3),
                  Text(tr('Protected'), style: AppText.caption1.copyWith(color: AppColors.success, fontWeight: FontWeight.w700, fontSize: 10)),
                ]),
              ),
            ]),
            const SizedBox(height: 8),
            Row(children: [
              for (var i = 0; i < 7; i++) ...[
                Expanded(
                  child: Column(children: [
                    Container(
                      height: 22,
                      decoration: BoxDecoration(
                        color: i < done ? AppColors.brandPrimary : AppColors.surfaceMinimal,
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: i < done ? const Icon(Icons.check_rounded, size: 13, color: Colors.white) : null,
                    ),
                    const SizedBox(height: 3),
                    Text(labels[i], style: AppText.caption1.copyWith(color: AppColors.textLight, fontSize: 10)),
                  ]),
                ),
                if (i < 6) const SizedBox(width: 5),
              ],
            ]),
          ]),
        ),
      ]),
    );
  }
}

/// Non-matchday state (Figma 2145:7546): weekly challenge + community goal.
class _NonMatchdayCards extends StatelessWidget {
  const _NonMatchdayCards();
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(children: [
        const _LastResultCard(),
        const SizedBox(height: 12),
        SurfaceCard(
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
              Text(tr('Weekly Challenge'), style: AppText.label2.copyWith(color: AppColors.textDarker)),
              Pill(color: AppColors.successBg, child: Text('+50 pts', style: AppText.caption1.copyWith(color: AppColors.success, fontWeight: FontWeight.w700, fontSize: 11))),
            ]),
            const SizedBox(height: 8),
            Text(tr('Spend €50 this week'), style: AppText.body2.copyWith(color: AppColors.textNormal)),
            const SizedBox(height: 10),
            ClipRRect(
              borderRadius: BorderRadius.circular(3),
              child: LinearProgressIndicator(
                  value: 0.65, minHeight: 6, backgroundColor: AppColors.surfaceLowContrast,
                  valueColor: AlwaysStoppedAnimation(AppColors.brandPrimary)),
            ),
            const SizedBox(height: 8),
            Text('€32.50 / €50 · 65%', style: AppText.body3Regular),
          ]),
        ),
        const SizedBox(height: 12),
        SurfaceCard(
          color: AppColors.brandLightest,
          border: Border.all(color: AppColors.brandPrimary.withValues(alpha: 0.2)),
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text(tr('Community Goal'), style: AppText.label2.copyWith(color: AppColors.textDarker)),
            const SizedBox(height: 6),
            Text(tr('€32,000 left to unlock Community Bonus'), style: AppText.body2.copyWith(color: AppColors.textNormal)),
            const SizedBox(height: 10),
            ClipRRect(
              borderRadius: BorderRadius.circular(3),
              child: const LinearProgressIndicator(
                  value: 0.36, minHeight: 6, backgroundColor: Colors.white,
                  valueColor: AlwaysStoppedAnimation(AppColors.success)),
            ),
            const SizedBox(height: 8),
            Text('€18,000 / €50,000 · ${tr('36% collective')}', style: AppText.body3Regular),
          ]),
        ),
      ]),
    );
  }
}

class _PointsCard extends StatelessWidget {
  const _PointsCard();
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      clipBehavior: Clip.antiAlias,
      decoration: BoxDecoration(
        gradient: const LinearGradient(colors: AppColors.pointsGradient),
        borderRadius: BorderRadius.circular(AppRadii.card),
      ),
      child: Stack(
        children: [
          Positioned(
            left: -23,
            top: -22,
            child: Container(
              width: 193,
              height: 193,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.white.withValues(alpha: 0.05),
              ),
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(tr('S04 Fan Points'), style: AppText.body2.copyWith(color: Colors.white)),
                  Tappable(
                    onTap: () => _push(context, const SubscriptionScreen()),
                    child: Container(
                    padding: const EdgeInsets.fromLTRB(6, 4, 4, 4),
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.24),
                      borderRadius: BorderRadius.circular(999),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(Icons.keyboard_double_arrow_down_rounded, size: 14, color: Colors.white),
                        const SizedBox(width: 4),
                        Text(tr('Schalker'),
                            style: AppText.caption1.copyWith(color: Colors.white, fontWeight: FontWeight.w600, fontSize: 11)),
                        const SizedBox(width: 4),
                        const Icon(Icons.chevron_right_rounded, size: 14, color: Colors.white),
                      ],
                    ),
                  ),
                  ),
                ],
              ),
              const SizedBox(height: 6),
              Text(tr('12,450'),
                  style: AppText.h1.copyWith(color: Colors.white, fontWeight: FontWeight.w700)),
              const SizedBox(height: 8),
              Row(
                children: [
                  Pill(
                    color: AppColors.brandDark,
                    child: Text(tr('12 Raffle Tickets'),
                        style: AppText.caption1.copyWith(color: AppColors.textLightest)),
                  ),
                  const SizedBox(width: 8),
                  Pill(
                    gradient: const LinearGradient(colors: AppColors.goldGradient),
                    child: Text(tr('3x Stadium Boost'), style: AppText.caption1.copyWith(color: AppColors.textDarker)),
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }
}

/// Next-match fixture card — the football-home centrepiece: competition, both
/// crests, kickoff countdown, venue and quick actions.
class _NextMatchCard extends StatelessWidget {
  final VoidCallback onTicket;
  final VoidCallback onPredict;
  const _NextMatchCard({required this.onTicket, required this.onPredict});

  @override
  Widget build(BuildContext context) {
    return Container(
      clipBehavior: Clip.antiAlias,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        gradient: const LinearGradient(begin: Alignment.topLeft, end: Alignment.bottomRight, colors: AppColors.pointsGradient),
        borderRadius: BorderRadius.circular(AppRadii.card),
      ),
      child: Column(children: [
        Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
          Text(tr('Bundesliga · Matchday 34'), style: AppText.caption1.copyWith(color: Colors.white70)),
          Pill(color: Colors.white24, child: Text(tr('Home Match'), style: AppText.caption1.copyWith(color: Colors.white, fontWeight: FontWeight.w700))),
        ]),
        const SizedBox(height: 16),
        Row(children: [
          Expanded(child: _team(const Svg('logo_s04', size: 46), tr('Schalke'))),
          Column(children: [
            Text(tr('Sat 15:30'), style: AppText.caption1.copyWith(color: Colors.white70)),
            const SizedBox(height: 2),
            Text(tr('VS'), style: AppText.h4.copyWith(color: AppColors.gold)),
          ]),
          Expanded(child: _team(
            Container(width: 46, height: 46, decoration: const BoxDecoration(color: Colors.white24, shape: BoxShape.circle), alignment: Alignment.center, child: const Icon(Icons.shield_rounded, color: Colors.white, size: 26)),
            tr('Dortmund'),
          )),
        ]),
        const SizedBox(height: 14),
        Container(
          padding: const EdgeInsets.symmetric(vertical: 8),
          alignment: Alignment.center,
          decoration: BoxDecoration(color: AppColors.brandDarkest.withValues(alpha: 0.35), borderRadius: BorderRadius.circular(999)),
          child: Row(mainAxisSize: MainAxisSize.min, children: [
            const Icon(Icons.schedule_rounded, size: 14, color: Colors.white70),
            const SizedBox(width: 6),
            Text('${tr('Kickoff in')} 02:14:35', style: AppText.body3.copyWith(color: Colors.white, fontWeight: FontWeight.w700)),
            const SizedBox(width: 8),
            Text('· VELTINS-Arena', style: AppText.body3.copyWith(color: Colors.white70)),
          ]),
        ),
        const SizedBox(height: 14),
        Row(children: [
          Expanded(child: _cta(tr('Buy Ticket'), AppColors.gold, AppColors.brandDarkest, onTicket)),
          const SizedBox(width: 10),
          Expanded(child: _cta(tr('Predict Score'), Colors.white24, Colors.white, onPredict)),
        ]),
      ]),
    );
  }

  Widget _team(Widget crest, String name) => Column(children: [
        crest,
        const SizedBox(height: 8),
        Text(name, maxLines: 1, overflow: TextOverflow.ellipsis, style: AppText.body2.copyWith(color: Colors.white, fontWeight: FontWeight.w700)),
      ]);

  Widget _cta(String label, Color bg, Color fg, VoidCallback onTap) => Tappable(
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 12),
          alignment: Alignment.center,
          decoration: BoxDecoration(color: bg, borderRadius: BorderRadius.circular(999)),
          child: Text(label, maxLines: 1, overflow: TextOverflow.ellipsis, style: AppText.body3.copyWith(color: fg, fontWeight: FontWeight.w800)),
        ),
      );
}

/// Last-result hero shown on non-matchdays + a teaser for the next fixture.
class _LastResultCard extends StatelessWidget {
  const _LastResultCard();
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(color: AppColors.surface, borderRadius: BorderRadius.circular(AppRadii.card), border: Border.all(color: AppColors.borderLightest)),
      child: Column(children: [
        Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
          Text(tr('Last result'), style: AppText.caption1.copyWith(color: AppColors.textLight)),
          Text(tr('Bundesliga · Matchday 33'), style: AppText.caption1.copyWith(color: AppColors.textLight)),
        ]),
        const SizedBox(height: 12),
        Row(children: [
          Expanded(child: Column(children: [
            const Svg('logo_s04', size: 40),
            const SizedBox(height: 6),
            Text(tr('Schalke'), style: AppText.body3.copyWith(color: AppColors.textDarker, fontWeight: FontWeight.w700)),
          ])),
          Column(children: [
            Text('3 : 1', style: AppText.h2.copyWith(color: AppColors.textDarker)),
            Pill(color: AppColors.successBg, padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2), child: Text(tr('Win'), style: AppText.caption1.copyWith(color: AppColors.success, fontWeight: FontWeight.w700, fontSize: 10))),
          ]),
          Expanded(child: Column(children: [
            Container(width: 40, height: 40, decoration: BoxDecoration(color: AppColors.surfaceMinimal, shape: BoxShape.circle), alignment: Alignment.center, child: Icon(Icons.shield_rounded, color: AppColors.textLight, size: 24)),
            const SizedBox(height: 6),
            Text(tr('Bremen'), style: AppText.body3.copyWith(color: AppColors.textDarker, fontWeight: FontWeight.w700)),
          ])),
        ]),
        const SizedBox(height: 14),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
          decoration: BoxDecoration(color: AppColors.brandLightest, borderRadius: BorderRadius.circular(AppRadii.tile)),
          child: Row(children: [
            const Icon(Icons.event_rounded, size: 16, color: AppColors.brandPrimary),
            const SizedBox(width: 8),
            Expanded(child: Text('${tr('Next')}: vs Bayern · ${tr('in 5 days')}', style: AppText.body3.copyWith(color: AppColors.onAccent, fontWeight: FontWeight.w700))),
            Icon(Icons.chevron_right_rounded, size: 18, color: AppColors.brandPrimary),
          ]),
        ),
      ]),
    );
  }
}

class _QuickActions extends StatelessWidget {
  const _QuickActions();
  // (image asset, label, motif icon, motif colour)
  static const _items = [
    ('img_spin', 'Daily Spin', Icons.casino_rounded, Color(0xFF6A1B9A)),
    ('img_scratch', 'Scratch Card', Icons.style_rounded, Color(0xFFB8860B)),
    ('img_predict', 'Predictions', Icons.sports_soccer_rounded, Color(0xFF1B7A3D)),
    ('img_rewards', 'Rewards', Icons.card_giftcard_rounded, Color(0xFFC2185B)),
  ];

  Widget _routeFor(String label) {
    switch (label) {
      case 'Predictions':
        return const PredictionsScreen();
      default:
        return const RedeemScreen();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          for (var i = 0; i < _items.length; i++) ...[
            if (i > 0) const SizedBox(width: 12),
            Expanded(
              child: HomeImageTile(
                image: _items[i].$1,
                label: _items[i].$2,
                icon: _items[i].$3,
                color: _items[i].$4,
                height: 84,
                onTap: () {
                  final label = _items[i].$2;
                  if (label == 'Daily Spin') {
                    showDailySpin(context);
                  } else if (label == 'Scratch Card') {
                    showScratchCard(context);
                  } else {
                    _push(context, _routeFor(label));
                  }
                },
              ),
            ),
          ],
        ],
      ),
    );
  }
}
