import 'package:flutter/material.dart';
import '../theme/app_theme.dart';
import '../widgets/app_widgets.dart';
import '../widgets/asset_img.dart';
import '../widgets/ios_chrome.dart';
import 'daily_spin_screen.dart';
import 'scratch_card_screen.dart';
import 'predictions_screen.dart';
import 'redeem_screen.dart';
import 'notifications_screen.dart';
import 'tickets_screen.dart';
import 'experiences_screen.dart';
import 'club_news_screen.dart';
import 'deals_hub_screen.dart';
import 'achievements_screen.dart';
import 'matchday_specials_screen.dart';
import 'search_screen.dart';
import 'exclusive_content_screen.dart';
import 'matchday_live_screen.dart';
import 'fanplus_screen.dart';
import '../widgets/hub_widgets.dart';
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

  @override
  Widget build(BuildContext context) {
    return Container(
      color: AppColors.surface,
      child: SafeArea(
        bottom: false,
        child: ListView(
          padding: const EdgeInsets.only(bottom: 120),
          children: [
            const IOSStatusBar(),
            const SizedBox(height: 16),
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
            const Padding(padding: EdgeInsets.symmetric(horizontal: 20), child: _PointsCard()),
            const SizedBox(height: 12),
            const Padding(padding: EdgeInsets.symmetric(horizontal: 20), child: _StreakStrip()),
            const SizedBox(height: 20),
            if (_matchday)
              Padding(padding: const EdgeInsets.symmetric(horizontal: 20), child: _NextMatchCard(onTicket: () => _push(context, const TicketsScreen()), onPredict: () => _push(context, const PredictionsScreen())))
            else
              const _NonMatchdayCards(),
            const SizedBox(height: 16),
            const Padding(padding: EdgeInsets.symmetric(horizontal: 20), child: _LeagueTableCard()),
            const SizedBox(height: 20),
            const _QuickActions(),
            const SizedBox(height: 24),
            _explore(),
            const SizedBox(height: 24),
            _missions(),
            const SizedBox(height: 20),
            Padding(padding: const EdgeInsets.symmetric(horizontal: 20), child: _FanPlusCta(onTap: () => _push(context, const FanPlusScreen()))),
          ],
        ),
      ),
    );
  }

  Widget _explore() {
    const items = [
      ('Tickets', Icons.confirmation_number_rounded),
      ('Experiences', Icons.stadium_rounded),
      ('Content', Icons.play_circle_outline_rounded),
      ('Live', Icons.sensors_rounded),
      ('Deals', Icons.local_offer_rounded),
      ('Specials', Icons.bolt_rounded),
      ('News', Icons.newspaper_rounded),
    ];
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Padding(padding: EdgeInsets.symmetric(horizontal: 20), child: SectionHeader('Explore', action: null)),
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
              for (final it in items)
                GestureDetector(
                  onTap: () => _push(context, switch (it.$1) {
                    'Tickets' => const TicketsScreen(),
                    'Experiences' => const ExperiencesScreen(),
                    'Content' => const ExclusiveContentScreen(),
                    'Live' => const MatchdayLiveScreen(),
                    'Deals' => const DealsHubScreen(),
                    'Specials' => const MatchdaySpecialsScreen(),
                    'News' => const ClubNewsScreen(),
                    _ => const AchievementsScreen(),
                  }),
                  child: Column(children: [
                    Container(
                      width: 56, height: 56,
                      decoration: BoxDecoration(color: AppColors.brandLightest, borderRadius: BorderRadius.circular(AppRadii.tile)),
                      child: Icon(it.$2, color: AppColors.brandPrimary, size: 26),
                    ),
                    const SizedBox(height: 6),
                    Text(tr(it.$1), style: AppText.body3.copyWith(fontSize: 12), textAlign: TextAlign.center, maxLines: 1, overflow: TextOverflow.ellipsis),
                  ]),
                ),
            ],
          ),
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

/// Compact Fan+ conversion banner — surfaces the paid membership on Home.
class _FanPlusCta extends StatelessWidget {
  final VoidCallback onTap;
  const _FanPlusCta({required this.onTap});
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
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
                  Container(
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

  Widget _cta(String label, Color bg, Color fg, VoidCallback onTap) => GestureDetector(
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

/// Compact league-table snippet — position, points and Schalke's recent form.
class _LeagueTableCard extends StatelessWidget {
  const _LeagueTableCard();

  // (pos, team, played, points, isS04)
  static const _rows = [
    (1, 'Bayern', 33, 71, false),
    (2, 'Leverkusen', 33, 66, false),
    (3, 'Dortmund', 33, 61, false),
    (4, 'Schalke 04', 33, 58, true),
    (5, 'Leipzig', 33, 55, false),
  ];
  // Last 5 results, newest last: W win / D draw / L loss
  static const _form = ['W', 'W', 'D', 'L', 'W'];

  @override
  Widget build(BuildContext context) {
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      const SectionHeader('League Table', action: null),
      const SizedBox(height: 12),
      SurfaceCard(
        padding: EdgeInsets.zero,
        child: Column(children: [
          for (var i = 0; i < _rows.length; i++) ...[
            Container(
              color: _rows[i].$5 ? AppColors.brandLightest : Colors.transparent,
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 11),
              child: Row(children: [
                SizedBox(width: 20, child: Text('${_rows[i].$1}', style: AppText.body3.copyWith(color: AppColors.textLight, fontWeight: FontWeight.w700))),
                const SizedBox(width: 8),
                _rows[i].$5
                    ? const Svg('logo_s04', size: 22)
                    : Container(width: 22, height: 22, decoration: BoxDecoration(color: AppColors.surfaceMinimal, shape: BoxShape.circle), alignment: Alignment.center, child: Icon(Icons.shield_rounded, size: 13, color: AppColors.textLight)),
                const SizedBox(width: 10),
                Expanded(child: Text(tr(_rows[i].$2), maxLines: 1, overflow: TextOverflow.ellipsis, style: AppText.body2.copyWith(color: AppColors.textDarker, fontWeight: _rows[i].$5 ? FontWeight.w800 : FontWeight.w600))),
                Text('${_rows[i].$3}', style: AppText.body3Regular),
                const SizedBox(width: 18),
                SizedBox(width: 28, child: Text('${_rows[i].$4}', textAlign: TextAlign.right, style: AppText.body2.copyWith(color: AppColors.textDarker, fontWeight: FontWeight.w800))),
              ]),
            ),
            if (i != _rows.length - 1) Divider(height: 1, color: AppColors.borderLightest),
          ],
        ]),
      ),
      const SizedBox(height: 10),
      Row(children: [
        Text('${tr('Form')} · ${tr('Schalke')}', style: AppText.body3Regular),
        const Spacer(),
        for (final f in _form) ...[
          Container(
            width: 20, height: 20,
            margin: const EdgeInsets.only(left: 5),
            decoration: BoxDecoration(shape: BoxShape.circle, color: f == 'W' ? AppColors.success : (f == 'D' ? AppColors.textLight : AppColors.danger)),
            alignment: Alignment.center,
            child: Text(tr(f), style: AppText.caption1.copyWith(color: Colors.white, fontWeight: FontWeight.w800, fontSize: 10)),
          ),
        ],
      ]),
    ]);
  }
}

class _QuickActions extends StatelessWidget {
  const _QuickActions();
  static const _items = [
    ('ic_daily_spin', 'Daily Spin', Icons.casino_rounded),
    ('ic_scratch', 'Scratch Card', Icons.style_rounded),
    ('ic_predictions', 'Predictions', Icons.sports_soccer_rounded),
    ('ic_rewards', 'Rewards', Icons.card_giftcard_rounded),
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
          for (final it in _items)
            Expanded(
              child: GestureDetector(
                behavior: HitTestBehavior.opaque,
                onTap: () {
                  if (it.$2 == 'Daily Spin') {
                    showDailySpin(context);
                  } else if (it.$2 == 'Scratch Card') {
                    showScratchCard(context);
                  } else {
                    _push(context, _routeFor(it.$2));
                  }
                },
                child: Column(
                  children: [
                    Container(
                      width: 72,
                      height: 72,
                      decoration: BoxDecoration(
                        color: AppColors.brandLightest,
                        borderRadius: BorderRadius.circular(AppRadii.tile),
                      ),
                      padding: const EdgeInsets.all(12),
                      child: AssetImg(it.$1, width: 48, height: 48, fallbackIcon: it.$3),
                    ),
                    const SizedBox(height: 8),
                    Text(tr(it.$2), textAlign: TextAlign.center, style: AppText.body3, maxLines: 1, overflow: TextOverflow.ellipsis),
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }
}
