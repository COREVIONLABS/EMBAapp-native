import 'package:flutter/material.dart';
import '../theme/app_theme.dart';
import '../widgets/app_widgets.dart';
import '../widgets/action_sheets.dart';
import 'predictions_screen.dart';
import 'fan_polls_screen.dart';
import 'season_journey_screen.dart';
import 'earn_points_screen.dart';
import 'fanshop_screen.dart';
import 'notifications_screen.dart';
import 'tickets_screen.dart';
import 'my_vouchers_screen.dart';
import 'raffles_screen.dart';
import 'club_news_screen.dart';
import 'experiences_screen.dart';
import 'leaderboard_screen.dart';
import 'collection_screen.dart';
import 'deals_hub_screen.dart';
import 'search_screen.dart';
import 'assistant_screen.dart';
import 'exclusive_content_screen.dart';
import 'subscription_screen.dart';
import '../widgets/sub_scaffold.dart';
import 'fanplus_screen.dart';
import 'fanplus_pay_screen.dart';
import 'matchday_quiz_screen.dart';
import 'sponsor_missions_screen.dart';
import 'auctions_screen.dart';
import '../model/sponsor_missions.dart';
import '../model/auctions.dart';
import '../model/fan_model.dart';
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
              const SizedBox(height: 22),
              // 1) Clean, centred points balance (Socios-style) — right under greeting.
              const _PointsHeader(),
              const SizedBox(height: 22),
              // 2) Round core actions under the balance.
              _roundActions(),
              const SizedBox(height: 20),
              // First-run activation — new fans only (below the balance).
              ValueListenableBuilder<bool>(
                valueListenable: starterNotifier,
                builder: (context, show, __) => show
                    ? const Padding(padding: EdgeInsets.fromLTRB(20, 0, 20, 8), child: _StarterCard())
                    : const SizedBox.shrink(),
              ),
              // Fan+ Pay card promo — Phase-2 only (Demo toggle).
              ValueListenableBuilder<bool>(
                valueListenable: cardActiveNotifier,
                builder: (context, active, __) => active
                    ? Padding(
                        padding: const EdgeInsets.fromLTRB(20, 8, 20, 0),
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
              const SizedBox(height: 20),
              // 3) How Fan+ works — dismissible (with a confirm so it's not lost).
              ValueListenableBuilder<bool>(
                valueListenable: howToNotifier,
                builder: (context, show, __) => show
                    ? Padding(padding: const EdgeInsets.fromLTRB(20, 0, 20, 20), child: _HowItWorksCard(onDismiss: () => _dismissHowTo(context)))
                    : const SizedBox.shrink(),
              ),
              // 4) Engagement — fan votes + the season journey.
              _engagement(context),
              const SizedBox(height: 12),
              // 4b) Partner value — sponsor missions + points auctions.
              _partnerRow(context),
              const SizedBox(height: 20),
              // 5) Matchday context — the one contextual zone (matchday only).
              ValueListenableBuilder<bool>(
                valueListenable: matchdayNotifier,
                builder: (context, md, __) => md ? _matchdayZone(context) : const SizedBox.shrink(),
              ),
              // 6) Membership — value tied to the loop (lots + monthly points).
              Padding(padding: const EdgeInsets.symmetric(horizontal: 20), child: _MembershipCard(onTap: () => _push(context, const FanPlusScreen()))),
              const SizedBox(height: 18),
              // Quiet link to everything else.
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
              const SizedBox(height: 8),
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
        child: SurfaceCard(
          onTap: () => _push(context, const MatchdayQuizScreen()),
          child: Row(children: [
            Container(width: 46, height: 46, decoration: BoxDecoration(color: AppColors.brandLightest, borderRadius: BorderRadius.circular(13)), child: const Icon(Icons.quiz_rounded, color: AppColors.brandPrimary, size: 24)),
            const SizedBox(width: 14),
            Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Row(children: [
                Container(width: 7, height: 7, decoration: const BoxDecoration(color: AppColors.danger, shape: BoxShape.circle)),
                const SizedBox(width: 6),
                Text(tr('LIVE · Matchday Quiz'), style: AppText.body2.copyWith(color: AppColors.textDarker, fontWeight: FontWeight.w800)),
              ]),
              const SizedBox(height: 3),
              Text(tr('Answer live for up to +250 points'), style: AppText.body3Regular),
            ])),
            Icon(Icons.chevron_right_rounded, color: AppColors.textLight),
          ]),
        ),
      ),
      const SizedBox(height: 20),
    ]);
  }

  // Four round shortcuts under the balance (Socios-style). These mirror the
  // universal voucher/points loop — the SAME for every club, no club-specific
  // retail (Tickets/Fanshop): Earn points → Vouchers → Discounts → Tombola.
  // One calm brand colour across all four — the glyph does the distinguishing.
  Widget _roundActions() {
    const c = AppColors.brandPrimary;
    final items = <(String, IconData, Color, VoidCallback)>[
      ('Earn', Icons.bolt_rounded, c, () => _push(context, const EarnPointsScreen())),
      ('Vouchers', Icons.confirmation_number_rounded, c, () => _push(context, const MyVouchersScreen())),
      ('Deals %', Icons.percent_rounded, c, () => _push(context, const DealsHubScreen())),
      ('Tombola', Icons.local_activity_rounded, c, () => _push(context, const RafflesScreen())),
    ];
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
        for (var i = 0; i < items.length; i++)
          Expanded(child: _RoundNav(label: tr(items[i].$1), icon: items[i].$2, color: items[i].$3, onTap: items[i].$4)),
      ]),
    );
  }

  // Engagement section — fan votes + Road to Gold (moved here from the tabs).
  // Engagement — two brand-tinted tiles in the same clean style as the
  // "Vouchers / Tombola lots" pathway tiles on the Redeem screen.
  Widget _engagement(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: IntrinsicHeight(
        child: Row(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
          Expanded(child: _EngageTile(
            icon: Icons.how_to_vote_rounded,
            iconColor: AppColors.brandPrimary,
            title: tr('Fan votes'),
            sub: tr('Captain, kit & more'),
            onTap: () => _push(context, const FanPollsScreen()),
          )),
          const SizedBox(width: 12),
          Expanded(child: _EngageTile(
            icon: Icons.route_rounded,
            iconColor: AppColors.gold,
            title: tr('Road to Gold'),
            sub: '${FanModel.seasonPercent}% · ${tr('season journey')}',
            onTap: () => _push(context, const SeasonJourneyScreen()),
          )),
        ]),
      ),
    );
  }

  // Partner value row — the sponsor-funded stream + points auctions, in the
  // same clean pathway-tile style as the engagement row above.
  Widget _partnerRow(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: AnimatedBuilder(
        animation: Listenable.merge([sponsorMissionStore, auctionStore, pointsNotifier]),
        builder: (context, _) => IntrinsicHeight(
          child: Row(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
            Expanded(child: _EngageTile(
              icon: Icons.handshake_rounded,
              iconColor: AppColors.brandPrimary,
              title: tr('Sponsor missions'),
              sub: '+${sponsorMissionStore.availablePoints} ${tr('pts to earn')}',
              onTap: () => _push(context, const SponsorMissionsScreen()),
            )),
            const SizedBox(width: 12),
            Expanded(child: _EngageTile(
              icon: Icons.gavel_rounded,
              iconColor: AppColors.gold,
              title: tr('Points auctions'),
              sub: auctionStore.leadingCount > 0 ? tr('You’re winning a lot') : tr('Bid to win prizes'),
              onTap: () => _push(context, const AuctionsScreen()),
            )),
          ]),
        ),
      ),
    );
  }

  void _dismissHowTo(BuildContext context) async {
    final ok = await showConfirmDialog(
      context,
      title: 'Hide this?',
      message: 'You can re-open “How Fan+ works” anytime under “More in the app”.',
      confirmLabel: 'Hide',
    );
    if (ok) howToNotifier.value = false;
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
                onTap: () => _push(context, const AssistantScreen()),
                child: Container(
                  width: 36,
                  height: 36,
                  decoration: BoxDecoration(color: AppColors.brandLightest, borderRadius: BorderRadius.circular(36)),
                  child: Icon(Icons.auto_awesome_rounded, size: 19, color: AppColors.brandPrimary),
                ),
              ),
              const SizedBox(width: 10),
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
    (Icons.person_outline_rounded, 'Complete your profile', '+150'),
    (Icons.sports_soccer_rounded, 'Make your first prediction', '+150'),
    (Icons.event_available_rounded, 'Check in today', '+200'),
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
    // One calm brand tint across the whole list (was a rainbow of 7 colours).
    const c = AppColors.brandPrimary;
    final items = <(IconData, String, String, Color, Widget)>[
      (Icons.confirmation_number_rounded, 'Tickets', 'Matchday & presale access', c, const TicketsScreen()),
      (Icons.storefront_rounded, 'Fanshop', 'Jerseys, scarves & more', c, const FanshopScreen()),
      (Icons.stadium_rounded, 'Experiences', 'Money-can\'t-buy — win in the tombola', c, const ExperiencesScreen()),
      (Icons.newspaper_rounded, 'Club News', 'Latest from S04', c, const ClubNewsScreen()),
      (Icons.play_circle_outline_rounded, 'Exclusive Content', 'Members-only clips', c, const ExclusiveContentScreen()),
      (Icons.leaderboard_rounded, 'Leaderboard', 'Your rank this season', c, const LeaderboardScreen()),
      (Icons.grid_view_rounded, 'Collection', 'Player stickers & badges', c, const CollectionScreen()),
    ];
    return SubScaffold(
      title: tr('More'),
      children: [
        // Re-open the "How Fan+ works" explainer on Home.
        SurfaceCard(
          onTap: () { howToNotifier.value = true; Navigator.of(context).pop(); },
          child: Row(children: [
            Container(width: 44, height: 44, decoration: BoxDecoration(color: AppColors.brandLightest, borderRadius: BorderRadius.circular(12)), child: const Icon(Icons.help_outline_rounded, color: AppColors.brandPrimary, size: 22)),
            const SizedBox(width: 14),
            Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text(tr('How Fan+ works'), style: AppText.body2.copyWith(color: AppColors.textDarker, fontWeight: FontWeight.w700)),
              Text(tr('The basics in 3 steps'), style: AppText.body3Regular),
            ])),
            Icon(Icons.chevron_right_rounded, color: AppColors.textLight),
          ]),
        ),
        const SizedBox(height: 10),
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
        return SurfaceCard(
          color: AppColors.brandLightest,
          onTap: onTap,
          child: Row(children: [
            Container(width: 44, height: 44, decoration: BoxDecoration(color: AppColors.gold.withValues(alpha: 0.16), borderRadius: BorderRadius.circular(12)), child: const Icon(Icons.workspace_premium_rounded, color: AppColors.gold, size: 24)),
            const SizedBox(width: 12),
            Expanded(
              child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Text(isMember ? '${tr(tier)} · ${tr('your membership')}' : tr('Become a member'), style: AppText.body2.copyWith(color: AppColors.textDarker, fontWeight: FontWeight.w700)),
                const SizedBox(height: 2),
                Text(
                  isMember
                      ? '${p.freeLots} ${tr('free lots')} + ${FanModel.fmtPublic(p.monthlyPoints)} ${tr('pts / month')}'
                      : tr('Get free tombola lots + monthly bonus points'),
                  maxLines: 1, overflow: TextOverflow.ellipsis,
                  style: AppText.body3.copyWith(color: AppColors.onAccent),
                ),
              ]),
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              decoration: BoxDecoration(color: AppColors.brandPrimary, borderRadius: BorderRadius.circular(999)),
              child: Text(isMember ? tr('Manage') : tr('Upgrade'), style: AppText.body3.copyWith(color: Colors.white, fontWeight: FontWeight.w700)),
            ),
          ]),
        );
      },
    );
  }
}

/// Round core-action button under the balance (Socios-style): a coloured circle
/// with a white icon and a small label.
class _RoundNav extends StatelessWidget {
  final String label;
  final IconData icon;
  final Color color;
  final VoidCallback onTap;
  const _RoundNav({required this.label, required this.icon, required this.color, required this.onTap});
  @override
  Widget build(BuildContext context) {
    return Tappable(
      scale: 0.92,
      onTap: onTap,
      child: Column(children: [
        Container(
          width: 56, height: 56,
          decoration: BoxDecoration(color: color, shape: BoxShape.circle, boxShadow: [BoxShadow(color: color.withValues(alpha: 0.3), blurRadius: 10, offset: const Offset(0, 4))]),
          child: Icon(icon, color: Colors.white, size: 26),
        ),
        const SizedBox(height: 7),
        Text(label, maxLines: 1, overflow: TextOverflow.ellipsis, style: AppText.body3.copyWith(fontSize: 12, fontWeight: FontWeight.w700)),
      ]),
    );
  }
}

/// Engagement tile in the Redeem "pathway tile" style: a brand-tinted box with
/// a small surface icon chip, a title and a sub. Tappable.
class _EngageTile extends StatelessWidget {
  final IconData icon;
  final Color iconColor;
  final String title;
  final String sub;
  final VoidCallback onTap;
  const _EngageTile({required this.icon, required this.iconColor, required this.title, required this.sub, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Tappable(
      scale: 0.97,
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(color: AppColors.brandLightest, borderRadius: BorderRadius.circular(AppRadii.card)),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Row(children: [
            Container(width: 36, height: 36, decoration: BoxDecoration(color: AppColors.surface, borderRadius: BorderRadius.circular(11)), child: Icon(icon, color: iconColor, size: 19)),
            const Spacer(),
            Icon(Icons.chevron_right_rounded, size: 18, color: AppColors.brandPrimary),
          ]),
          const SizedBox(height: 12),
          Text(title, maxLines: 1, overflow: TextOverflow.ellipsis, style: AppText.body2.copyWith(color: AppColors.onAccent, fontWeight: FontWeight.w800)),
          const SizedBox(height: 1),
          Text(sub, maxLines: 1, overflow: TextOverflow.ellipsis, style: AppText.body3.copyWith(color: AppColors.onAccent)),
        ]),
      ),
    );
  }
}

/// Dismissible "How Fan+ works" explainer for Home (three steps). The X asks for
/// confirmation so a fan can't lose it by accident.
class _HowItWorksCard extends StatelessWidget {
  final VoidCallback onDismiss;
  const _HowItWorksCard({required this.onDismiss});
  @override
  Widget build(BuildContext context) {
    final steps = <(IconData, Color, String, String)>[
      (Icons.add_circle_outline_rounded, AppColors.brandPrimary, 'Earn points', 'On tickets, shop, games & check-ins'),
      (Icons.card_giftcard_rounded, const Color(0xFF6A1B9A), 'Redeem for vouchers', 'Swap points for real club & sponsor vouchers'),
      (Icons.emoji_events_rounded, const Color(0xFFC62828), 'Win experiences', 'Enter tombolas & unlock VIP moments'),
    ];
    return SurfaceCard(
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Row(children: [
          Expanded(child: Text(tr('How Fan+ works'), style: AppText.label2.copyWith(color: AppColors.textDarker))),
          GestureDetector(
            onTap: onDismiss,
            behavior: HitTestBehavior.opaque,
            child: Padding(padding: const EdgeInsets.only(left: 8), child: Icon(Icons.close_rounded, size: 20, color: AppColors.textLight)),
          ),
        ]),
        const SizedBox(height: 12),
        for (var i = 0; i < steps.length; i++) ...[
          if (i > 0) const SizedBox(height: 14),
          Row(children: [
            Container(width: 34, height: 34, decoration: BoxDecoration(color: steps[i].$2.withValues(alpha: 0.12), borderRadius: BorderRadius.circular(10)), child: Icon(steps[i].$1, color: steps[i].$2, size: 18)),
            const SizedBox(width: 12),
            Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text(tr(steps[i].$3), style: AppText.body2.copyWith(color: AppColors.textDarker, fontWeight: FontWeight.w700)),
              Text(tr(steps[i].$4), style: AppText.body3Regular),
            ])),
          ]),
        ],
      ]),
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

/// Clean, centred points balance (Socios-style) — the tier chip, the big number
/// and its voucher value, on a plain background. No card, no gradient.
class _PointsHeader extends StatelessWidget {
  const _PointsHeader();
  @override
  Widget build(BuildContext context) {
    return Column(children: [
      // Tier chip → membership plans.
      ValueListenableBuilder<String>(
        valueListenable: tierNotifier,
        builder: (context, tier, __) => Tappable(
          scale: 0.97,
          onTap: () => _push(context, const SubscriptionScreen()),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(color: AppColors.brandLightest, borderRadius: BorderRadius.circular(999)),
            child: Row(mainAxisSize: MainAxisSize.min, children: [
              const Icon(Icons.workspace_premium_rounded, size: 14, color: AppColors.gold),
              const SizedBox(width: 5),
              Text(tr(tier), style: AppText.caption1.copyWith(color: AppColors.brandPrimary, fontWeight: FontWeight.w800)),
              Icon(Icons.chevron_right_rounded, size: 15, color: AppColors.brandPrimary),
            ]),
          ),
        ),
      ),
      const SizedBox(height: 14),
      // Big, clean, centred balance — live, with its €-reward value.
      ValueListenableBuilder<int>(
        valueListenable: pointsNotifier,
        builder: (context, _, __) => Column(children: [
          Text(FanModel.pointsFormatted, textAlign: TextAlign.center, style: AppText.h1.copyWith(color: AppColors.textDarker, fontSize: 54, fontWeight: FontWeight.w600, letterSpacing: -1)),
          const SizedBox(height: 6),
          Text('${tr('S04 Fan Points')} · ${tr('≈')} ${FanModel.balanceEuro} ${tr('in rewards')}', style: AppText.body3.copyWith(color: AppColors.textLight)),
        ]),
      ),
    ]);
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
