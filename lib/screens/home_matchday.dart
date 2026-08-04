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
import 'search_screen.dart';
import 'exclusive_content_screen.dart';
import 'leaderboard_screen.dart';
import 'subscription_screen.dart';
import 'streak_screen.dart';
import 'fanplus_screen.dart';
import 'fanplus_pay_screen.dart';
import 'matchday_quiz_screen.dart';
import 'raffles_screen.dart';
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
  bool _loading = true;

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
            // Fan+ Pay card promo — Phase-2 only (Demo toggle). Sits right under
            // the wallet so the "with card" state reads instantly when presenting.
            ValueListenableBuilder<bool>(
              valueListenable: cardActiveNotifier,
              builder: (context, active, __) => active
                  ? Padding(
                      padding: const EdgeInsets.fromLTRB(20, 0, 20, 14),
                      child: Tappable(
                        scale: 0.98,
                        onTap: () => _push(context, const FanPlusPayScreen()),
                        child: Container(
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(gradient: const LinearGradient(colors: [Color(0xFF0055AA), Color(0xFF000D22)]), borderRadius: BorderRadius.circular(AppRadii.card)),
                          child: Row(children: [
                            Container(width: 46, height: 46, decoration: BoxDecoration(color: Colors.white.withValues(alpha: 0.14), borderRadius: BorderRadius.circular(13)), child: const Icon(Icons.credit_card_rounded, color: AppColors.gold, size: 24)),
                            const SizedBox(width: 14),
                            Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                              Text(tr('Fan+ Pay'), style: AppText.label2.copyWith(color: Colors.white)),
                              const SizedBox(height: 2),
                              Text(tr('Real cashback at S04 partners'), style: AppText.body3.copyWith(color: Colors.white70)),
                            ])),
                            const Icon(Icons.chevron_right_rounded, color: Colors.white54),
                          ]),
                        ),
                      ),
                    )
                  : const SizedBox.shrink(),
            ),
            _infoChips(),
            const SizedBox(height: 16),
            // Sponsor campaign below the wallet (the daily-spin nudge and the
            // separate streak strip were dropped — both already live one tap
            // away in Quick Actions and the Streak chip).
            Padding(padding: const EdgeInsets.symmetric(horizontal: 20), child: _heroBanner()),
            const SizedBox(height: 20),
            ValueListenableBuilder<bool>(
              valueListenable: matchdayNotifier,
              builder: (context, md, __) => md
                  ? Column(children: [
                      Padding(padding: const EdgeInsets.symmetric(horizontal: 20), child: _NextMatchCard(onTicket: () => _push(context, const TicketsScreen()), onPredict: () => _push(context, const PredictionsScreen()))),
                      const SizedBox(height: 12),
                      // Live matchday quiz (AFL fan-zone style) — only on matchday.
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 20),
                        child: Tappable(
                          scale: 0.98,
                          onTap: () => _push(context, const MatchdayQuizScreen()),
                          child: Container(
                            padding: const EdgeInsets.all(16),
                            decoration: BoxDecoration(gradient: const LinearGradient(colors: [Color(0xFFC62828), Color(0xFF7F1414)]), borderRadius: BorderRadius.circular(AppRadii.card)),
                            child: Row(children: [
                              Container(width: 46, height: 46, decoration: BoxDecoration(color: Colors.white.withValues(alpha: 0.16), borderRadius: BorderRadius.circular(13)), child: const Icon(Icons.quiz_rounded, color: Colors.white, size: 24)),
                              const SizedBox(width: 14),
                              Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                                Row(children: [
                                  Container(width: 7, height: 7, decoration: const BoxDecoration(color: Colors.white, shape: BoxShape.circle)),
                                  const SizedBox(width: 6),
                                  Text(tr('LIVE · Matchday Quiz'), style: AppText.caption1.copyWith(color: Colors.white, fontWeight: FontWeight.w800)),
                                ]),
                                const SizedBox(height: 4),
                                Text(tr('Answer live for up to +250 points'), style: AppText.body3.copyWith(color: Colors.white70)),
                              ])),
                              const Icon(Icons.chevron_right_rounded, color: Colors.white54),
                            ]),
                          ),
                        ),
                      ),
                    ])
                  : const _NonMatchdayCards(),
            ),
            const SizedBox(height: 20),
            const _QuickActions(),
            const SizedBox(height: 20),
            _explore(),
            const SizedBox(height: 16),
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
    // One clean 4×2 grid — the eight things a fan actually comes here for.
    // (Partner folded into Vorteile; live-score/specials dropped.)
    final items = <(String, String, IconData, Color, Widget)>[
      ('Tickets', 'img_tickets', Icons.confirmation_number_rounded, const Color(0xFF1565C0), const TicketsScreen()),
      ('Fanshop', 'img_fanshop', Icons.storefront_rounded, const Color(0xFF0A2A5E), const FanshopScreen()),
      ('Experiences', 'img_experiences', Icons.stadium_rounded, const Color(0xFF6A1B9A), const ExperiencesScreen()),
      ('Tombola', 'img_raffles', Icons.local_activity_rounded, const Color(0xFF8E24AA), const RafflesScreen()),
      ('Challenges', 'img_challenges', Icons.flag_rounded, const Color(0xFFEF6C00), const EarnPointsScreen()),
      ('Content', 'img_content', Icons.play_circle_outline_rounded, const Color(0xFFC62828), const ExclusiveContentScreen()),
      ('News', 'img_news', Icons.newspaper_rounded, const Color(0xFF3949AB), const ClubNewsScreen()),
      ('Benefits', 'img_benefits', Icons.redeem_rounded, const Color(0xFFF9A825), const DealsHubScreen()),
    ];
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Padding(padding: EdgeInsets.symmetric(horizontal: 20), child: SectionHeader('Explore', action: null)),
        const SizedBox(height: 12),
        // Two explicit rows (not a GridView) so the height is exactly the tiles —
        // no square-cell slack, no dead space above/below the grid.
        Padding(padding: const EdgeInsets.symmetric(horizontal: 20), child: _tileRow(items.sublist(0, 4))),
        const SizedBox(height: 14),
        Padding(padding: const EdgeInsets.symmetric(horizontal: 20), child: _tileRow(items.sublist(4, 8))),
      ],
    );
  }

  Widget _tileRow(List<(String, String, IconData, Color, Widget)> row) {
    return Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
      for (var i = 0; i < row.length; i++) ...[
        if (i > 0) const SizedBox(width: 12),
        Expanded(child: HomeImageTile(label: row[i].$1, image: row[i].$2, icon: row[i].$3, color: row[i].$4, height: 80, onTap: () => _push(context, row[i].$5))),
      ],
    ]);
  }

  // Editorial sponsor/campaign hero — kept deliberately off the fixture so it
  // never duplicates the next-match card.
  Widget _heroBanner() => HeroBanner(
        eyebrow: 'Presented by VELTINS',
        title: 'Win matchday jerseys & VIP seats',
        cta: 'Enter now',
        glyph: Icons.emoji_events_rounded,
        gradient: const [Color(0xFF1B5E20), Color(0xFF0B3D14)],
        image: 'img_hero_sponsor',
        onTap: () => _push(context, const DealsHubScreen()),
      );


  // At-a-glance quick-stat chips (Membership / Streak / Rank / Next reward).
  Widget _infoChips() {
    return ValueListenableBuilder<String>(
      valueListenable: tierNotifier,
      builder: (context, tier, __) {
        final chips = <(IconData, String, String, Color, VoidCallback)>[
          (Icons.workspace_premium_rounded, 'Membership', tier, AppColors.gold, () => _push(context, const FanPlusScreen())),
          (Icons.local_fire_department_rounded, 'Streak', '5 days', const Color(0xFFEF6C00), () => _push(context, const StreakScreen())),
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

  // Personalised recommendations ("For you" row).
  Widget _forYou() {
    final recs = <(String, String, String, IconData, Color, String, VoidCallback)>[
      ('Home Jersey 25/26', 'Fanshop · -15% today', 'For you', Icons.checkroom_rounded, const Color(0xFF0A2A5E), 'img_fanshop', () => _push(context, const FanshopScreen())),
      ('Free tombola ticket', 'Tombola · Super Fan perk', 'Free', Icons.local_activity_rounded, const Color(0xFFC62828), 'img_rewards', () => _push(context, const RafflesScreen())),
      ('Double points at REWE', 'Sponsor · 2× points', 'Sponsor', Icons.shopping_cart_rounded, const Color(0xFFC8102E), 'img_partner', () => _push(context, const DealsHubScreen())),
      ('Stadium Tour VIP', 'Experience · -500 pts', 'Saving', Icons.stadium_rounded, const Color(0xFF6A1B9A), 'img_experiences', () => _push(context, const ExperiencesScreen())),
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
          itemBuilder: (_, i) => ForYouCard(title: recs[i].$1, meta: recs[i].$2, badge: recs[i].$3, glyph: recs[i].$4, color: recs[i].$5, image: recs[i].$6, onTap: recs[i].$7),
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

/// Non-matchday state (Figma 2145:7546): weekly challenge + community goal.
class _NonMatchdayCards extends StatelessWidget {
  const _NonMatchdayCards();
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(children: [
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
              Text(FanModel.pointsFormatted,
                  style: AppText.h1.copyWith(color: Colors.white, fontWeight: FontWeight.w700)),
              const SizedBox(height: 8),
              Row(
                children: [
                  Pill(
                    color: AppColors.brandDark,
                    child: Text('${FanModel.raffleTickets} ${tr('Raffle Tickets')}',
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
          Text('${tr('Next match')} · Sat 15:30', style: AppText.caption1.copyWith(color: Colors.white70)),
          Pill(color: Colors.white24, child: Text(tr('Home Match'), style: AppText.caption1.copyWith(color: Colors.white, fontWeight: FontWeight.w700))),
        ]),
        const SizedBox(height: 16),
        Row(children: [
          Expanded(child: _team(const Svg('logo_s04', size: 46), tr('Schalke'))),
          Column(children: [
            const SizedBox(height: 6),
            Text(tr('VS'), style: AppText.h4.copyWith(color: AppColors.gold)),
          ]),
          Expanded(child: _team(
            Container(width: 46, height: 46, decoration: const BoxDecoration(color: Colors.white24, shape: BoxShape.circle), alignment: Alignment.center, child: const Icon(Icons.shield_rounded, color: Colors.white, size: 26)),
            tr('Dortmund'),
          )),
        ]),
        const SizedBox(height: 14),
        // Gamification hook (not a live scoreboard) — predict for points.
        Container(
          padding: const EdgeInsets.symmetric(vertical: 9, horizontal: 12),
          decoration: BoxDecoration(color: AppColors.brandDarkest.withValues(alpha: 0.35), borderRadius: BorderRadius.circular(999)),
          child: Row(mainAxisSize: MainAxisSize.min, children: [
            const Icon(Icons.sports_soccer_rounded, size: 14, color: AppColors.gold),
            const SizedBox(width: 6),
            Flexible(child: Text(tr('Predict the score for +50 points'), maxLines: 1, overflow: TextOverflow.ellipsis, style: AppText.body3.copyWith(color: Colors.white, fontWeight: FontWeight.w700))),
          ]),
        ),
        const SizedBox(height: 14),
        Row(children: [
          Expanded(child: _cta(tr('Predict Score'), AppColors.gold, AppColors.brandDarkest, onPredict)),
          const SizedBox(width: 10),
          Expanded(child: _cta(tr('Ticket voucher'), Colors.white24, Colors.white, onTicket)),
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
