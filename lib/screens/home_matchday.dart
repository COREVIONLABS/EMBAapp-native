import 'package:flutter/material.dart';
import '../theme/app_theme.dart';
import '../widgets/app_widgets.dart';
import 'predictions_screen.dart';
import 'redeem_screen.dart';
import 'earn_points_screen.dart';
import 'fanshop_screen.dart';
import 'notifications_screen.dart';
import 'tickets_screen.dart';
import 'club_news_screen.dart';
import 'experiences_screen.dart';
import 'leaderboard_screen.dart';
import 'collection_screen.dart';
import 'deals_hub_screen.dart';
import 'search_screen.dart';
import 'exclusive_content_screen.dart';
import 'subscription_screen.dart';
import '../widgets/sub_scaffold.dart';
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

/// Home tab — a focused dashboard around one story: **Collect → Redeem → Win**.
/// Above the fold: your points and the two things you do with them (Redeem +
/// Tombola). Everything else (all the games) sits one tap away under "Collect".
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
                child: Text('${tr('Moin')}, Max 👋', style: AppText.h4.copyWith(color: AppColors.textDarker)),
              ),
              const SizedBox(height: 16),
              // 1) Your points — always first.
              const Padding(padding: EdgeInsets.symmetric(horizontal: 20), child: _PointsCard()),
              const SizedBox(height: 12),
              // Fan+ Pay card promo — Phase-2 only (Demo toggle).
              ValueListenableBuilder<bool>(
                valueListenable: cardActiveNotifier,
                builder: (context, active, __) => active
                    ? Padding(
                        padding: const EdgeInsets.fromLTRB(20, 0, 20, 12),
                        child: SurfaceCard(
                          onTap: () => _push(context, const FanPlusPayScreen()),
                          child: Row(children: [
                            Container(width: 44, height: 44, decoration: BoxDecoration(color: AppColors.successBg, borderRadius: BorderRadius.circular(12)), child: const Icon(Icons.euro_rounded, color: AppColors.success, size: 22)),
                            const SizedBox(width: 14),
                            Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                              Text(tr('Fan+ Pay'), style: AppText.body2.copyWith(color: AppColors.textDarker, fontWeight: FontWeight.w700)),
                              Text(tr('Real cashback at S04 partners'), style: AppText.body3Regular),
                            ])),
                            Pill(color: AppColors.successBg, child: Text(tr('Active'), style: AppText.caption1.copyWith(color: AppColors.success, fontWeight: FontWeight.w800))),
                          ]),
                        ),
                      )
                    : const SizedBox.shrink(),
              ),
              // First-run activation: guide the new fan into the loop. Hidden
              // once switched off (returning fan / presenter).
              ValueListenableBuilder<bool>(
                valueListenable: starterNotifier,
                builder: (context, show, __) => show
                    ? const Padding(padding: EdgeInsets.fromLTRB(20, 0, 20, 14), child: _StarterCard())
                    : const SizedBox.shrink(),
              ),
              // 2) The four core actions — the whole app in one clear row:
              //    Collect · Redeem · Win · Benefits. Simple and self-explanatory.
              _shortcuts(),
              const SizedBox(height: 10),
              // Quiet link to everything else — keeps Home at four icons.
              Center(
                child: GestureDetector(
                  onTap: () => _push(context, const _MoreScreen()),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(vertical: 4, horizontal: 12),
                    child: Row(mainAxisSize: MainAxisSize.min, children: [
                      Text(tr('More in the app'), style: AppText.body3.copyWith(color: AppColors.brandPrimary, fontWeight: FontWeight.w700)),
                      Icon(Icons.chevron_right_rounded, size: 16, color: AppColors.brandPrimary),
                    ]),
                  ),
                ),
              ),
              const SizedBox(height: 18),
              // 3) Matchday context — the one contextual zone (matchday only).
              ValueListenableBuilder<bool>(
                valueListenable: matchdayNotifier,
                builder: (context, md, __) => md ? _matchdayZone(context) : const SizedBox.shrink(),
              ),
              // 5) Membership — value tied to the loop (lots + monthly points).
              Padding(padding: const EdgeInsets.symmetric(horizontal: 20), child: _MembershipCard(onTap: () => _push(context, const FanPlusScreen()))),
              const SizedBox(height: 22),
            ],
          ],
        ),
      ),
    );
  }

  // Matchday zone: next fixture + the live quiz. Only shown on matchday.
  Widget _matchdayZone(BuildContext context) {
    return Column(children: [
      Padding(padding: const EdgeInsets.symmetric(horizontal: 20), child: _NextMatchCard(onTicket: () => _push(context, const TicketsScreen()), onPredict: () => _push(context, const PredictionsScreen()))),
      const SizedBox(height: 12),
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
      const SizedBox(height: 20),
    ]);
  }

  // The four core actions, in the fan's own mental order:
  // Collect points → Redeem them → Win (Tombola) → Benefits (sponsor % + codes).
  Widget _shortcuts() {
    final items = <(String, String, IconData, Color, Widget)>[
      ('Collect', 'img_challenges', Icons.bolt_rounded, const Color(0xFF1B7A3D), const EarnPointsScreen()),
      ('Redeem', 'img_rewards', Icons.card_giftcard_rounded, const Color(0xFF0A2A5E), const RedeemScreen()),
      ('Prizes', 'img_raffles', Icons.emoji_events_rounded, const Color(0xFF6A1B9A), const RafflesScreen()),
      ('Deals %', 'img_partner', Icons.percent_rounded, const Color(0xFFEF6C00), const DealsHubScreen()),
    ];
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
        for (var i = 0; i < items.length; i++) ...[
          if (i > 0) const SizedBox(width: 12),
          Expanded(child: HomeImageTile(label: items[i].$1, image: items[i].$2, icon: items[i].$3, color: items[i].$4, height: 88, onTap: () => _push(context, items[i].$5))),
        ],
      ]),
    );
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
                  decoration: BoxDecoration(color: AppColors.surfaceMinimal, borderRadius: BorderRadius.circular(36)),
                  child: const Center(child: Svg('bell_dot', size: 20)),
                ),
              ),
            ]),
          ),
        ],
      ),
    );
  }
}

/// First-run activation checklist — three quick tasks that pull a new fan into
/// the core loop and unlock a welcome bonus. Auto-dismisses when all are done.
class _StarterCard extends StatefulWidget {
  const _StarterCard();
  @override
  State<_StarterCard> createState() => _StarterCardState();
}

class _StarterCardState extends State<_StarterCard> {
  // (icon, title, reward, destination-or-null)
  static const _tasks = <(IconData, String, String)>[
    (Icons.person_outline_rounded, 'Complete your profile', '+50'),
    (Icons.sports_soccer_rounded, 'Make your first prediction', '+50'),
    (Icons.event_available_rounded, 'Check in today', '+10'),
  ];
  final Set<int> _done = {};

  @override
  Widget build(BuildContext context) {
    final allDone = _done.length == _tasks.length;
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.brandLightest,
        borderRadius: BorderRadius.circular(AppRadii.card),
        border: Border.all(color: AppColors.brandPrimary.withValues(alpha: 0.25)),
      ),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Row(children: [
          const Icon(Icons.rocket_launch_rounded, color: AppColors.brandPrimary, size: 20),
          const SizedBox(width: 8),
          Expanded(child: Text(tr('Get your first 500 points'), style: AppText.label2.copyWith(color: AppColors.textDarker))),
          if (allDone)
            GestureDetector(
              onTap: () => starterNotifier.value = false,
              child: Text(tr('Dismiss'), style: AppText.body3.copyWith(color: AppColors.brandPrimary, fontWeight: FontWeight.w700)),
            )
          else
            Text('${_done.length}/${_tasks.length}', style: AppText.body3.copyWith(color: AppColors.brandPrimary, fontWeight: FontWeight.w800)),
        ]),
        const SizedBox(height: 4),
        Text(tr('Finish these 3 steps to unlock a +500 welcome bonus.'), style: AppText.body3Regular),
        const SizedBox(height: 12),
        for (var i = 0; i < _tasks.length; i++) ...[
          if (i > 0) const SizedBox(height: 8),
          GestureDetector(
            behavior: HitTestBehavior.opaque,
            onTap: () => setState(() => _done.contains(i) ? _done.remove(i) : _done.add(i)),
            child: Row(children: [
              Icon(_done.contains(i) ? Icons.check_circle_rounded : Icons.radio_button_unchecked_rounded,
                  color: _done.contains(i) ? AppColors.success : AppColors.textLight, size: 22),
              const SizedBox(width: 12),
              Expanded(child: Text(tr(_tasks[i].$2),
                  style: AppText.body2.copyWith(
                      color: _done.contains(i) ? AppColors.textLight : AppColors.textDarker,
                      decoration: _done.contains(i) ? TextDecoration.lineThrough : null))),
              Pill(color: AppColors.successBg, child: Text(_tasks[i].$3, style: AppText.caption1.copyWith(color: AppColors.success, fontWeight: FontWeight.w800))),
            ]),
          ),
        ],
        if (allDone) ...[
          const SizedBox(height: 12),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(vertical: 10),
            alignment: Alignment.center,
            decoration: BoxDecoration(color: AppColors.successBg, borderRadius: BorderRadius.circular(AppRadii.pill)),
            child: Text(tr('+500 welcome bonus unlocked! 🎉'), style: AppText.body3.copyWith(color: AppColors.success, fontWeight: FontWeight.w800)),
          ),
        ],
      ]),
    );
  }
}

/// "More" — everything that isn't a Home headline, in one tidy list so Home can
/// stay at four icons without hiding features.
class _MoreScreen extends StatelessWidget {
  const _MoreScreen();
  @override
  Widget build(BuildContext context) {
    final items = <(IconData, String, String, Color, Widget)>[
      (Icons.confirmation_number_rounded, 'Tickets', 'Matchday & presale access', const Color(0xFF1565C0), const TicketsScreen()),
      (Icons.storefront_rounded, 'Fanshop', 'Jerseys, scarves & more', const Color(0xFF0A2A5E), const FanshopScreen()),
      (Icons.stadium_rounded, 'Experiences', 'Stadium tours, VIP & players', const Color(0xFF6A1B9A), const ExperiencesScreen()),
      (Icons.newspaper_rounded, 'Club News', 'Latest from S04', const Color(0xFF3949AB), const ClubNewsScreen()),
      (Icons.play_circle_outline_rounded, 'Exclusive Content', 'Members-only clips', const Color(0xFFC62828), const ExclusiveContentScreen()),
      (Icons.leaderboard_rounded, 'Leaderboard', 'Your rank this season', const Color(0xFF1565C0), const LeaderboardScreen()),
      (Icons.grid_view_rounded, 'Collection', 'Player stickers & badges', const Color(0xFF00897B), const CollectionScreen()),
    ];
    return SubScaffold(
      title: tr('More'),
      children: [
        for (final it in items) ...[
          SurfaceCard(
            onTap: () => _push(context, it.$5),
            child: Row(children: [
              Container(width: 44, height: 44, decoration: BoxDecoration(color: it.$4.withValues(alpha: 0.12), borderRadius: BorderRadius.circular(12)), child: Icon(it.$1, color: it.$4, size: 22)),
              const SizedBox(width: 14),
              Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Text(tr(it.$2), style: AppText.body2.copyWith(color: AppColors.textDarker, fontWeight: FontWeight.w700)),
                Text(tr(it.$3), style: AppText.body3Regular),
              ])),
              Icon(Icons.chevron_right_rounded, color: AppColors.textLight),
            ]),
          ),
          const SizedBox(height: 10),
        ],
      ],
    );
  }
}

/// Membership value stated in the loop's own terms: free tombola lots + monthly
/// bonus points, scaled by the current tier.
class _MembershipCard extends StatelessWidget {
  final VoidCallback onTap;
  const _MembershipCard({required this.onTap});
  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<String>(
      valueListenable: tierNotifier,
      builder: (context, tier, __) {
        final p = perksFor(tier);
        final isMember = p.monthlyPoints > 0;
        return Tappable(
          scale: 0.98,
          onTap: onTap,
          child: Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(gradient: const LinearGradient(colors: AppColors.pointsGradient), borderRadius: BorderRadius.circular(AppRadii.card)),
            child: Row(children: [
              const Icon(Icons.workspace_premium_rounded, color: AppColors.gold, size: 26),
              const SizedBox(width: 12),
              Expanded(
                child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  Text(isMember ? '${tr(tier)} · ${tr('your membership')}' : tr('Become a member'), style: AppText.body2.copyWith(color: Colors.white, fontWeight: FontWeight.w700)),
                  const SizedBox(height: 2),
                  Text(
                    isMember
                        ? '${p.freeLots} ${tr('free lots')} + ${FanModel.fmtPublic(p.monthlyPoints)} ${tr('pts / month')}'
                        : tr('Get free tombola lots + monthly bonus points'),
                    maxLines: 1, overflow: TextOverflow.ellipsis,
                    style: AppText.body3.copyWith(color: Colors.white70),
                  ),
                ]),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                decoration: BoxDecoration(gradient: const LinearGradient(colors: AppColors.goldGradient), borderRadius: BorderRadius.circular(999)),
                child: Text(isMember ? tr('Manage') : tr('Upgrade'), style: AppText.body3.copyWith(color: AppColors.brandDarkest, fontWeight: FontWeight.w700)),
              ),
            ]),
          ),
        );
      },
    );
  }
}

/// Loading placeholder for the Home tab.
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
            SkeletonBox(width: 82, height: 36, radius: 18),
          ]),
          const SizedBox(height: 22),
          const SkeletonBox(width: 150, height: 22),
          const SizedBox(height: 18),
          const SkeletonBox(height: 128, radius: 22),
          const SizedBox(height: 16),
          Row(children: const [
            Expanded(child: SkeletonBox(height: 128, radius: 20)),
            SizedBox(width: 12),
            Expanded(child: SkeletonBox(height: 128, radius: 20)),
          ]),
          const SizedBox(height: 18),
          const SkeletonBox(height: 72, radius: 16),
          const SizedBox(height: 12),
          const SkeletonBox(height: 72, radius: 16),
        ]),
      ),
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
              const SizedBox(height: 4),
              Text('≈ ${FanModel.balanceEuro} ${tr('in vouchers')}', style: AppText.body3.copyWith(color: Colors.white70)),
              const SizedBox(height: 10),
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

/// Next-match fixture card — matchday centrepiece: crests, kickoff, quick actions.
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
