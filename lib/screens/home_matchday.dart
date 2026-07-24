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
import '../model/fan_model.dart';

void _push(BuildContext context, Widget screen) {
  Navigator.of(context).push(MaterialPageRoute(builder: (_) => screen));
}

/// Home — Matchday (Figma node 350:1354), built 1:1.
class HomeMatchdayScreen extends StatelessWidget {
  const HomeMatchdayScreen({super.key});

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
            const SizedBox(height: 20),
            const Padding(padding: EdgeInsets.symmetric(horizontal: 20), child: _PointsCard()),
            const SizedBox(height: 20),
            const Padding(padding: EdgeInsets.symmetric(horizontal: 20), child: _PromoBanner()),
            const SizedBox(height: 20),
            const _QuickActions(),
            const SizedBox(height: 20),
            _missions(),
            const SizedBox(height: 20),
            const Padding(padding: EdgeInsets.symmetric(horizontal: 20), child: _RewardCard()),
            const SizedBox(height: 24),
            _explore(),
            const SizedBox(height: 24),
            _experiencesTeaser(),
            const SizedBox(height: 24),
            _newsTeaser(),
          ],
        ),
      ),
    );
  }

  Widget _explore() {
    const items = [
      ('Tickets', Icons.confirmation_number_rounded),
      ('Experiences', Icons.stadium_rounded),
      ('Deals', Icons.local_offer_rounded),
      ('News', Icons.newspaper_rounded),
      ('Awards', Icons.emoji_events_rounded),
    ];
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Padding(padding: EdgeInsets.symmetric(horizontal: 20), child: SectionHeader('Explore', action: null)),
        const SizedBox(height: 12),
        SizedBox(
          height: 96,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 20),
            itemCount: items.length,
            separatorBuilder: (_, __) => const SizedBox(width: 12),
            itemBuilder: (context, i) => GestureDetector(
              onTap: () => _push(context, switch (items[i].$1) {
                'Tickets' => const TicketsScreen(),
                'Experiences' => const ExperiencesScreen(),
                'Deals' => const DealsHubScreen(),
                'News' => const ClubNewsScreen(),
                _ => const AchievementsScreen(),
              }),
              child: SizedBox(
                width: 76,
                child: Column(children: [
                  Container(
                    width: 64, height: 64,
                    decoration: BoxDecoration(color: AppColors.brandLightest, borderRadius: BorderRadius.circular(AppRadii.tile)),
                    child: Icon(items[i].$2, color: AppColors.brandPrimary, size: 28),
                  ),
                  const SizedBox(height: 6),
                  Text(items[i].$1, style: AppText.body3, textAlign: TextAlign.center, maxLines: 1, overflow: TextOverflow.ellipsis),
                ]),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _experiencesTeaser() {
    final items = kExperiences.where((e) => !e.featured).take(2).toList();
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Builder(builder: (context) => SectionHeader('Upcoming Experiences', onAction: () => _push(context, const ExperiencesScreen()))),
        ),
        const SizedBox(height: 12),
        for (final e in items)
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 0, 20, 8),
            child: Builder(builder: (context) => GestureDetector(
              onTap: () => _push(context, const ExperiencesScreen()),
              child: SurfaceCard(
                padding: const EdgeInsets.all(12),
                child: Row(children: [
                  Container(width: 48, height: 48, decoration: BoxDecoration(gradient: const LinearGradient(colors: AppColors.pointsGradient), borderRadius: BorderRadius.circular(12)), child: const Icon(Icons.event_rounded, color: Colors.white70)),
                  const SizedBox(width: 12),
                  Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                    Text(e.title, style: AppText.body2.copyWith(color: AppColors.textDarker)),
                    const SizedBox(height: 2),
                    Text('${e.date} · ${e.venue}', style: AppText.body3Regular),
                  ])),
                  Text(e.pointsLabel, style: AppText.body2.copyWith(color: AppColors.brandPrimary, fontWeight: FontWeight.w700)),
                ]),
              ),
            )),
          ),
      ],
    );
  }

  Widget _newsTeaser() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Builder(builder: (context) => SectionHeader('Club News', onAction: () => _push(context, const ClubNewsScreen()))),
        ),
        const SizedBox(height: 12),
        Builder(builder: (context) => GestureDetector(
          onTap: () => _push(context, const ClubNewsScreen()),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: SurfaceCard(
              padding: EdgeInsets.zero,
              child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Container(height: 130, width: double.infinity, decoration: const BoxDecoration(gradient: LinearGradient(colors: AppColors.pointsGradient), borderRadius: BorderRadius.vertical(top: Radius.circular(AppRadii.tile))), child: const Center(child: Icon(Icons.image_rounded, color: Colors.white24, size: 44))),
                Padding(padding: const EdgeInsets.all(14), child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  Row(children: [
                    Pill(color: AppColors.brandLightest, child: Text('Matchday', style: AppText.caption1.copyWith(color: AppColors.brandPrimary))),
                    const Spacer(),
                    Text('2h ago', style: AppText.body3Regular),
                  ]),
                  const SizedBox(height: 8),
                  Text('Königsblau secures vital home win against Bayern', style: AppText.label2.copyWith(color: AppColors.textDarker)),
                ])),
              ]),
            ),
          ),
        )),
        const SizedBox(height: 8),
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
            builder: (context) => GestureDetector(
              onTap: () => _push(context, const NotificationsScreen()),
              child: Container(
                width: 36,
                height: 36,
                decoration:
                    BoxDecoration(color: AppColors.surfaceMinimal, borderRadius: BorderRadius.circular(36)),
                child: const Center(child: Svg('bell_dot', size: 20)),
              ),
            ),
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
          child: SectionHeader('Active Missions'),
        ),
        const SizedBox(height: 14),
        const Padding(
          padding: EdgeInsets.symmetric(horizontal: 20),
          child: Column(
            children: [
              _MissionCard(title: 'Spend €200 this week', reward: '+50 pts', progress: 0.4, sub: '€80 / €200 · 40%'),
              SizedBox(height: 8),
              _MissionCard(title: 'Invite a friend', reward: '+100 pts', progress: 0, sub: 'Not started'),
              SizedBox(height: 8),
              _MissionCard(
                  title: 'Predict 2 matches',
                  reward: '+1 Ticket',
                  rewardColor: AppColors.brandPrimary,
                  rewardBg: AppColors.infoBg,
                  progress: 0.75,
                  sub: '1 / 2 complete'),
            ],
          ),
        ),
      ],
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
                  Text('S04 Fan Points', style: AppText.body2.copyWith(color: Colors.white)),
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
                        Text('Schalker',
                            style: AppText.caption1.copyWith(color: Colors.white, fontWeight: FontWeight.w600, fontSize: 11)),
                        const SizedBox(width: 4),
                        const Icon(Icons.chevron_right_rounded, size: 14, color: Colors.white),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 6),
              Text('12,450',
                  style: AppText.h1.copyWith(color: Colors.white, fontWeight: FontWeight.w700)),
              const SizedBox(height: 8),
              Row(
                children: [
                  Pill(
                    color: AppColors.brandDark,
                    child: Text('12 Raffle Tickets',
                        style: AppText.caption1.copyWith(color: AppColors.textLightest)),
                  ),
                  const SizedBox(width: 8),
                  Pill(
                    gradient: const LinearGradient(colors: AppColors.goldGradient),
                    child: Text('3x Stadium Boost', style: AppText.caption1.copyWith(color: AppColors.textDarker)),
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

class _PromoBanner extends StatelessWidget {
  const _PromoBanner();
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: const LinearGradient(colors: AppColors.goldGradient),
        borderRadius: BorderRadius.circular(AppRadii.card),
      ),
      child: Row(
        children: [
          const AssetImg('home_trophy', width: 43, height: 50, fallbackIcon: Icons.emoji_events_rounded),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('02:14:35', style: AppText.h4.copyWith(color: AppColors.brandDarkest)),
                Text('Until Kickoff', style: AppText.body3.copyWith(color: AppColors.textDark)),
              ],
            ),
          ),
          Builder(
            builder: (context) => GestureDetector(
              onTap: () => _push(context, const PredictionsScreen()),
              child: Container(
                padding: const EdgeInsets.fromLTRB(12, 8, 8, 8),
                decoration: BoxDecoration(
                  color: AppColors.brandDarkest.withValues(alpha: 0.6),
                  borderRadius: BorderRadius.circular(999),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text('Predict Score', style: AppText.body3.copyWith(color: AppColors.textLightest)),
                    const SizedBox(width: 4),
                    const Svg('arrow_left', size: 16), // white right-arrow variant
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
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
                    Text(it.$2, textAlign: TextAlign.center, style: AppText.body3),
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }
}

class _MissionCard extends StatelessWidget {
  final String title;
  final String reward;
  final Color rewardColor;
  final Color rewardBg;
  final double progress;
  final String sub;
  const _MissionCard({
    required this.title,
    required this.reward,
    required this.progress,
    required this.sub,
    this.rewardColor = AppColors.success,
    this.rewardBg = AppColors.successBg,
  });

  @override
  Widget build(BuildContext context) {
    return SurfaceCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(title, style: AppText.body2.copyWith(color: AppColors.textDarker)),
              Pill(
                color: rewardBg,
                child: Text(reward,
                    style: AppText.caption1.copyWith(color: rewardColor, fontWeight: FontWeight.w600, fontSize: 11)),
              ),
            ],
          ),
          const SizedBox(height: 8),
          ClipRRect(
            borderRadius: BorderRadius.circular(3),
            child: LinearProgressIndicator(
              value: progress,
              minHeight: 6,
              backgroundColor: AppColors.surfaceLowContrast,
              valueColor: const AlwaysStoppedAnimation(AppColors.brandPrimary),
            ),
          ),
          const SizedBox(height: 8),
          Text(sub, style: AppText.body3Regular),
        ],
      ),
    );
  }
}

class _RewardCard extends StatelessWidget {
  const _RewardCard();
  @override
  Widget build(BuildContext context) {
    return Container(
      height: 104,
      clipBehavior: Clip.antiAlias,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: const LinearGradient(colors: AppColors.pointsGradient),
        borderRadius: BorderRadius.circular(AppRadii.card),
      ),
      child: Stack(
        children: [
          Positioned(
            right: 0,
            top: -20,
            bottom: -20,
            child: Opacity(
              opacity: 0.16,
              child: AssetImg('home_reward_players', width: 200, fit: BoxFit.cover, fallbackIcon: Icons.groups_rounded),
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Pill(
                    gradient: const LinearGradient(colors: AppColors.goldGradient),
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    child: Text('Exclusive Reward', style: AppText.caption1.copyWith(color: AppColors.textDarker)),
                  ),
                  Pill(
                    color: AppColors.brandLightest,
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    child: Text('Ends in 4:12:30', style: AppText.caption1.copyWith(color: AppColors.textDarker)),
                  ),
                ],
              ),
              const Spacer(),
              Text('Meet the Players', style: AppText.label1.copyWith(color: AppColors.textLightest)),
              const SizedBox(height: 4),
              Text('Exclusive post-match meet & greet with the team',
                  style: AppText.body3.copyWith(color: AppColors.textLightest.withValues(alpha: 0.7))),
            ],
          ),
        ],
      ),
    );
  }
}
