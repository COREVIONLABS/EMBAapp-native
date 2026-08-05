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
import 'search_screen.dart';
import 'exclusive_content_screen.dart';
import 'subscription_screen.dart';
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
              // 2) The two things you do with points — the stars.
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Row(children: [
                  Expanded(child: _StarCard(
                    title: tr('Redeem'),
                    sub: tr('Vouchers & sponsors'),
                    icon: Icons.card_giftcard_rounded,
                    gradient: const [Color(0xFF0055AA), Color(0xFF001B44)],
                    onTap: () => _push(context, const RedeemScreen()),
                  )),
                  const SizedBox(width: 12),
                  Expanded(child: _StarCard(
                    title: tr('Tombola'),
                    sub: tr('Play lots & win big'),
                    icon: Icons.local_activity_rounded,
                    gradient: const [Color(0xFF6A1B9A), Color(0xFF311B92)],
                    onTap: () => _push(context, const RafflesScreen()),
                  )),
                ]),
              ),
              const SizedBox(height: 20),
              // 3) Matchday context — the one contextual zone (matchday only).
              ValueListenableBuilder<bool>(
                valueListenable: matchdayNotifier,
                builder: (context, md, __) => md ? _matchdayZone(context) : const SizedBox.shrink(),
              ),
              // 4) The engagement motor — one entry to all games/tasks.
              Padding(padding: const EdgeInsets.symmetric(horizontal: 20), child: _CollectCard(onTap: () => _push(context, const EarnPointsScreen()))),
              const SizedBox(height: 16),
              // 5) Membership — value tied to the loop (lots + monthly points).
              Padding(padding: const EdgeInsets.symmetric(horizontal: 20), child: _MembershipCard(onTap: () => _push(context, const FanPlusScreen()))),
              const SizedBox(height: 22),
              // 6) Discover — secondary, kept small and last.
              _discover(),
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

  Widget _discover() {
    final items = <(String, String, IconData, Color, Widget)>[
      ('Tickets', 'img_tickets', Icons.confirmation_number_rounded, const Color(0xFF1565C0), const TicketsScreen()),
      ('Fanshop', 'img_fanshop', Icons.storefront_rounded, const Color(0xFF0A2A5E), const FanshopScreen()),
      ('News', 'img_news', Icons.newspaper_rounded, const Color(0xFF3949AB), const ClubNewsScreen()),
      ('Content', 'img_content', Icons.play_circle_outline_rounded, const Color(0xFFC62828), const ExclusiveContentScreen()),
    ];
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Padding(padding: EdgeInsets.symmetric(horizontal: 20), child: SectionHeader('Discover', action: null)),
        const SizedBox(height: 12),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
            for (var i = 0; i < items.length; i++) ...[
              if (i > 0) const SizedBox(width: 12),
              Expanded(child: HomeImageTile(label: items[i].$1, image: items[i].$2, icon: items[i].$3, color: items[i].$4, height: 80, onTap: () => _push(context, items[i].$5))),
            ],
          ]),
        ),
      ],
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

/// One of the two big "stars" on Home — the actions points exist for.
class _StarCard extends StatelessWidget {
  final String title;
  final String sub;
  final IconData icon;
  final List<Color> gradient;
  final VoidCallback onTap;
  const _StarCard({required this.title, required this.sub, required this.icon, required this.gradient, required this.onTap});
  @override
  Widget build(BuildContext context) {
    return Tappable(
      scale: 0.97,
      onTap: onTap,
      child: Container(
        height: 128,
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(gradient: LinearGradient(begin: Alignment.topLeft, end: Alignment.bottomRight, colors: gradient), borderRadius: BorderRadius.circular(AppRadii.card)),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
          Container(width: 44, height: 44, decoration: BoxDecoration(color: Colors.white.withValues(alpha: 0.16), borderRadius: BorderRadius.circular(13)), child: Icon(icon, color: AppColors.gold, size: 24)),
          Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text(title, style: AppText.label1.copyWith(color: Colors.white)),
            const SizedBox(height: 2),
            Text(sub, maxLines: 1, overflow: TextOverflow.ellipsis, style: AppText.body3.copyWith(color: Colors.white70)),
          ]),
        ]),
      ),
    );
  }
}

/// The engagement motor — one entry to every way to earn points.
class _CollectCard extends StatelessWidget {
  final VoidCallback onTap;
  const _CollectCard({required this.onTap});
  @override
  Widget build(BuildContext context) {
    return SurfaceCard(
      onTap: onTap,
      child: Row(children: [
        Container(width: 46, height: 46, decoration: BoxDecoration(color: AppColors.brandLightest, borderRadius: BorderRadius.circular(13)), child: const Icon(Icons.bolt_rounded, color: AppColors.brandPrimary, size: 24)),
        const SizedBox(width: 14),
        Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text(tr('Collect points'), style: AppText.body2.copyWith(color: AppColors.textDarker, fontWeight: FontWeight.w700)),
          Text(tr('Games, predictions, check-ins & challenges'), maxLines: 1, overflow: TextOverflow.ellipsis, style: AppText.body3Regular),
        ])),
        Pill(color: AppColors.successBg, child: Text('+250 ${tr('today')}', style: AppText.caption1.copyWith(color: AppColors.success, fontWeight: FontWeight.w800))),
      ]),
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
