import 'package:flutter/material.dart';
import '../theme/app_theme.dart';
import '../widgets/app_widgets.dart';
import '../widgets/sub_scaffold.dart';
import '../widgets/hub_widgets.dart';
import '../widgets/action_sheets.dart';
import 'buy_points_screen.dart';
import 'search_screen.dart';
import 'daily_spin_screen.dart';
import 'scratch_card_screen.dart';
import 'predictions_screen.dart';
import 'leaderboard_screen.dart';
import 'fan_polls_screen.dart';
import 'referral_screen.dart';
import 'sponsor_missions_screen.dart';
import '../model/sponsor_missions.dart';
import '../l10n/strings.dart';

/// Earn Points — a motivating fan hub (not a flat list): a weekly points goal
/// with a streak, one-tap daily actions, active challenges with progress, ways
/// to earn shown with their reward, a referral promo and a leaderboard nudge.
class EarnPointsScreen extends StatelessWidget {
  const EarnPointsScreen({super.key});

  // Ways to earn: (icon, title, subtitle, reward pill, colour)
  static const _ways = <(IconData, String, String, String, Color)>[
    (Icons.confirmation_number_outlined, 'Attend a Match', 'Check in at the stadium', '+100', AppColors.brandPrimary),
    (Icons.sports_soccer_outlined, 'Visit training', 'Check in at Berger Feld', '+40', AppColors.brandPrimary),
    (Icons.shopping_bag_outlined, 'Fanshop Purchase', 'Earn on every order', '1 / €1', Color(0xFF0A2A5E)),
    (Icons.play_circle_outline_rounded, 'Watch a Short Ad', 'A quick sponsor clip', '+15', Color(0xFFE65100)),
    (Icons.share_outlined, 'Share on Social', 'Spread the blue & white', '+25', AppColors.brandPrimary),
    (Icons.person_outline_rounded, 'Complete Profile', 'One-off — takes a minute', '+50', AppColors.brandPrimary),
  ];

  // Active challenges: (icon, title, sub, progress, reward)
  static const _challenges = <(IconData, String, String, double, String)>[
    (Icons.euro_rounded, 'Spend €50 this week', '€32.50 of €50', 0.65, '+50'),
    (Icons.sports_soccer_rounded, 'Predict 3 matches', '1 of 3 done', 0.33, '+120'),
    (Icons.local_fire_department_rounded, 'Attend the derby', 'Check in vs Dortmund', 0.0, '+150'),
  ];

  void _push(BuildContext context, Widget s) =>
      Navigator.of(context).push(MaterialPageRoute(builder: (_) => s));

  @override
  Widget build(BuildContext context) {
    return SubScaffold(
      title: tr('Earn Points'),
      children: [
        HubSearchField(hint: 'Search rewards & sponsors', onTap: () => _push(context, const SearchScreen())),
        const SizedBox(height: 16),

        // ── Weekly goal hero (gamified progress + streak) ──
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(color: AppColors.surface, borderRadius: BorderRadius.circular(AppRadii.card), border: Border.all(color: AppColors.borderLightest)),
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Row(children: [
              Text(tr('This week'), style: AppText.body2.copyWith(color: AppColors.textLight)),
              const Spacer(),
              Pill(color: AppColors.brandLightest, child: Row(mainAxisSize: MainAxisSize.min, children: [
                const Icon(Icons.local_fire_department_rounded, size: 13, color: AppColors.brandPrimary),
                const SizedBox(width: 3),
                Text(tr('5-day streak'), style: AppText.caption1.copyWith(color: AppColors.brandPrimary, fontWeight: FontWeight.w800)),
              ])),
            ]),
            const SizedBox(height: 12),
            Row(crossAxisAlignment: CrossAxisAlignment.baseline, textBaseline: TextBaseline.alphabetic, children: [
              Text('320', style: AppText.h1.copyWith(color: AppColors.textDarker, fontWeight: FontWeight.w800)),
              const SizedBox(width: 6),
              Text('/ 500 ${tr('pts')}', style: AppText.body2.copyWith(color: AppColors.textLight)),
            ]),
            const SizedBox(height: 12),
            ClipRRect(
              borderRadius: BorderRadius.circular(4),
              child: LinearProgressIndicator(value: 0.64, minHeight: 8, backgroundColor: AppColors.surfaceLowContrast, valueColor: const AlwaysStoppedAnimation(AppColors.brandPrimary)),
            ),
            const SizedBox(height: 12),
            Row(children: [
              Icon(Icons.card_giftcard_rounded, size: 16, color: AppColors.brandPrimary),
              const SizedBox(width: 8),
              Expanded(child: Text(tr('Reach 500 this week to unlock a +100 bonus.'), style: AppText.body3.copyWith(color: AppColors.textNormal))),
            ]),
          ]),
        ),
        const SizedBox(height: 16),

        // ── Sponsor missions (the club's 3rd revenue stream — partners pay) ──
        AnimatedBuilder(
          animation: sponsorMissionStore,
          builder: (context, _) => Tappable(
            scale: 0.98,
            onTap: () => _push(context, const SponsorMissionsScreen()),
            child: Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                gradient: const LinearGradient(begin: Alignment.topLeft, end: Alignment.bottomRight, colors: AppColors.pointsGradient),
                borderRadius: BorderRadius.circular(AppRadii.card),
              ),
              child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Row(children: [
                  Container(width: 48, height: 48, decoration: BoxDecoration(color: Colors.white.withValues(alpha: 0.14), borderRadius: BorderRadius.circular(14)), child: const Icon(Icons.handshake_rounded, color: AppColors.gold, size: 26)),
                  const SizedBox(width: 14),
                  Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                    Text(tr('Sponsor missions'), style: AppText.label2.copyWith(color: Colors.white)),
                    const SizedBox(height: 2),
                    Text(tr('Our partners pay you in points'), style: AppText.body3.copyWith(color: Colors.white70)),
                  ])),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 9),
                    decoration: BoxDecoration(gradient: const LinearGradient(colors: AppColors.goldGradient), borderRadius: BorderRadius.circular(999)),
                    child: Text('+${sponsorMissionStore.availablePoints}', style: AppText.body3.copyWith(color: AppColors.brandDarkest, fontWeight: FontWeight.w800)),
                  ),
                ]),
                if (sponsorMissionStore.openCount > 0) ...[
                  const SizedBox(height: 12),
                  Text(trp('{n} open missions · watch, survey, scan & more', n: '${sponsorMissionStore.openCount}'), style: AppText.caption1.copyWith(color: Colors.white60)),
                ],
              ]),
            ),
          ),
        ),
        const SizedBox(height: 16),

        // ── Fan votes (club-emotional: captain, kit, MVP …) ──
        Tappable(
          scale: 0.98,
          onTap: () => _push(context, const FanPollsScreen()),
          child: Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(gradient: const LinearGradient(colors: [Color(0xFF0A2A5E), Color(0xFF000D22)]), borderRadius: BorderRadius.circular(AppRadii.card)),
            child: Row(children: [
              Container(width: 48, height: 48, decoration: BoxDecoration(color: Colors.white.withValues(alpha: 0.14), borderRadius: BorderRadius.circular(14)), child: const Icon(Icons.how_to_vote_rounded, color: AppColors.gold, size: 26)),
              const SizedBox(width: 14),
              Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Text(tr('Fan votes'), style: AppText.label2.copyWith(color: Colors.white)),
                const SizedBox(height: 2),
                Text(tr('Captain, kit, Player of the Month — you decide'), style: AppText.body3.copyWith(color: Colors.white70)),
              ])),
              const SizedBox(width: 10),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                decoration: BoxDecoration(gradient: const LinearGradient(colors: AppColors.goldGradient), borderRadius: BorderRadius.circular(999)),
                child: Text(tr('Vote'), style: AppText.body3.copyWith(color: AppColors.brandDarkest, fontWeight: FontWeight.w800)),
              ),
            ]),
          ),
        ),
        const SizedBox(height: 22),

        // ── Do it today (one-tap daily actions) ──
        Align(alignment: Alignment.centerLeft, child: Text(tr('Do it today'), style: AppText.label1)),
        const SizedBox(height: 12),
        Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Expanded(child: _DailyAction(icon: Icons.event_available_rounded, label: tr('Check-in'), reward: '+10', color: const Color(0xFF2E7D32),
              onTap: () => showSuccessSheet(context, title: 'Checked in!', message: '+10 points added — come back tomorrow to keep your streak.'))),
          const SizedBox(width: 10),
          Expanded(child: _DailyAction(icon: Icons.casino_rounded, label: tr('Spin'), reward: tr('Play'), color: AppColors.brandPrimary, onTap: () => showDailySpin(context))),
          const SizedBox(width: 10),
          Expanded(child: _DailyAction(icon: Icons.style_rounded, label: tr('Scratch'), reward: tr('Play'), color: AppColors.brandPrimary, onTap: () => showScratchCard(context))),
          const SizedBox(width: 10),
          Expanded(child: _DailyAction(icon: Icons.sports_soccer_rounded, label: tr('Predict'), reward: '+50', color: const Color(0xFF1B7A3D), onTap: () => _push(context, const PredictionsScreen()))),
        ]),
        const SizedBox(height: 24),

        // ── Active challenges (progress + reward) ──
        Align(alignment: Alignment.centerLeft, child: Text(tr('Active challenges'), style: AppText.label1)),
        const SizedBox(height: 12),
        SizedBox(
          height: 176,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            itemCount: _challenges.length,
            separatorBuilder: (_, __) => const SizedBox(width: 12),
            itemBuilder: (_, i) {
              final c = _challenges[i];
              // Only wire a tap where it leads somewhere real; otherwise pass
              // null so the card doesn't fake a tappable affordance.
              final onTap = c.$2 == 'Predict 3 matches' ? () => _push(context, const PredictionsScreen()) : null;
              return SizedBox(
                width: 210,
                child: FeaturedGoalCard(icon: c.$1, title: c.$2, sub: c.$3, progress: c.$4, reward: c.$5, onTap: onTap),
              );
            },
          ),
        ),
        const SizedBox(height: 24),

        // ── Ways to earn (reward shown as a pill) ──
        Align(alignment: Alignment.centerLeft, child: Text(tr('More ways to earn'), style: AppText.label1)),
        const SizedBox(height: 12),
        for (final w in _ways) ...[
          _EarnRow(icon: w.$1, title: w.$2, sub: w.$3, reward: w.$4, color: w.$5),
          const SizedBox(height: 10),
        ],
        const SizedBox(height: 8),

        // ── Referral promo (big incentive) ──
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(18),
          decoration: BoxDecoration(gradient: const LinearGradient(colors: [Color(0xFF0A2A5E), Color(0xFF000D22)]), borderRadius: BorderRadius.circular(AppRadii.card)),
          child: Row(children: [
            Container(width: 48, height: 48, decoration: BoxDecoration(color: Colors.white.withValues(alpha: 0.14), borderRadius: BorderRadius.circular(14)), child: const Icon(Icons.group_add_rounded, color: AppColors.gold, size: 26)),
            const SizedBox(width: 14),
            Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text(tr('Bring a friend'), style: AppText.label2.copyWith(color: Colors.white)),
              const SizedBox(height: 2),
              Text(tr('You both get +250 points'), style: AppText.body3.copyWith(color: Colors.white70)),
            ])),
            const SizedBox(width: 10),
            Tappable(
              onTap: () => _push(context, const ReferralScreen()),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                decoration: BoxDecoration(gradient: const LinearGradient(colors: AppColors.goldGradient), borderRadius: BorderRadius.circular(999)),
                child: Text(tr('Invite'), style: AppText.body3.copyWith(color: AppColors.brandDarkest, fontWeight: FontWeight.w800)),
              ),
            ),
          ]),
        ),
        const SizedBox(height: 16),

        // ── Leaderboard nudge (competition) ──
        SurfaceCard(
          onTap: () => _push(context, const LeaderboardScreen()),
          child: Row(children: [
            Container(width: 44, height: 44, decoration: BoxDecoration(color: AppColors.brandLightest, borderRadius: BorderRadius.circular(12)), child: const Icon(Icons.leaderboard_rounded, color: AppColors.brandPrimary, size: 22)),
            const SizedBox(width: 14),
            Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text(tr('You\'re #12 this season'), style: AppText.body2.copyWith(color: AppColors.textDarker, fontWeight: FontWeight.w700)),
              Text(tr('Earn 2,000 pts to break into the Top 10'), style: AppText.body3Regular),
            ])),
            Icon(Icons.chevron_right_rounded, color: AppColors.textLight),
          ]),
        ),
        const SizedBox(height: 16),

        // ── Sponsor promo + top up ──
        SponsorPromoCard(
          sponsor: 'adidas',
          category: 'Fanshop',
          offer: '5%',
          sub: 'points back on every Fanshop order',
          color: const Color(0xFF111111),
        ),
        const SizedBox(height: 12),
        _EarnRow(
          icon: Icons.add_rounded,
          title: 'Top up points',
          sub: 'Reach your next reward faster · optional',
          reward: 'Buy',
          color: AppColors.brandDarkest,
          onTap: () => _push(context, const BuyPointsScreen()),
        ),
        const SizedBox(height: 6),
        Row(children: [
          Icon(Icons.card_giftcard_rounded, size: 14, color: AppColors.textLight),
          const SizedBox(width: 6),
          Expanded(child: Text(tr('Welcome bonus: +500 points to start — annual members get +1,500.'), style: AppText.caption1.copyWith(color: AppColors.textLight))),
        ]),
      ],
    );
  }
}

/// One-tap daily action card (icon, label, a reward/CTA pill).
class _DailyAction extends StatelessWidget {
  final IconData icon;
  final String label;
  final String reward;
  final Color color;
  final VoidCallback onTap;
  const _DailyAction({required this.icon, required this.label, required this.reward, required this.color, required this.onTap});
  @override
  Widget build(BuildContext context) {
    return Tappable(
      scale: 0.96,
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 8),
        decoration: BoxDecoration(color: AppColors.surface, borderRadius: BorderRadius.circular(AppRadii.tile), border: Border.all(color: AppColors.borderLightest)),
        child: Column(children: [
          Container(width: 44, height: 44, decoration: BoxDecoration(color: color.withValues(alpha: 0.12), borderRadius: BorderRadius.circular(12)), child: Icon(icon, color: color, size: 22)),
          const SizedBox(height: 8),
          Text(label, maxLines: 1, overflow: TextOverflow.ellipsis, style: AppText.body3.copyWith(fontSize: 11.5)),
          const SizedBox(height: 6),
          Pill(color: AppColors.successBg, padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2), child: Text(reward, style: AppText.caption1.copyWith(color: AppColors.success, fontWeight: FontWeight.w800, fontSize: 10))),
        ]),
      ),
    );
  }
}

/// Way-to-earn row with the reward shown as a gold pill on the right.
class _EarnRow extends StatelessWidget {
  final IconData icon;
  final String title;
  final String sub;
  final String reward;
  final Color color;
  final VoidCallback? onTap;
  const _EarnRow({required this.icon, required this.title, required this.sub, required this.reward, required this.color, this.onTap});
  @override
  Widget build(BuildContext context) {
    return Tappable(
      scale: 0.99,
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(color: AppColors.surface, borderRadius: BorderRadius.circular(AppRadii.tile), border: Border.all(color: AppColors.borderLightest)),
        child: Row(children: [
          Container(width: 44, height: 44, decoration: BoxDecoration(color: color.withValues(alpha: 0.12), borderRadius: BorderRadius.circular(12)), child: Icon(icon, color: color, size: 22)),
          const SizedBox(width: 14),
          Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text(tr(title), style: AppText.body2.copyWith(color: AppColors.textDarker, fontWeight: FontWeight.w700)),
            const SizedBox(height: 2),
            Text(tr(sub), style: AppText.body3Regular),
          ])),
          const SizedBox(width: 10),
          Pill(
            color: AppColors.brandLightest,
            child: Text(tr(reward), style: AppText.caption1.copyWith(color: AppColors.brandPrimary, fontWeight: FontWeight.w800)),
          ),
        ]),
      ),
    );
  }
}
