import 'package:flutter/material.dart';
import '../theme/app_theme.dart';
import '../widgets/app_widgets.dart';
import '../widgets/sub_scaffold.dart';
import '../model/fan_model.dart';
import '../model/daily_games.dart';
import 'raffles_screen.dart';
import 'subscription_screen.dart';
import 'buy_points_screen.dart';
import 'daily_spin_screen.dart';
import 'scratch_card_screen.dart';
import '../l10n/strings.dart';

/// "Gewinnen" tab — the play-&-win hub: daily games (spin / scratch, once a day,
/// with a streak to pull fans back), then the monthly Tombola where membership
/// grants free lots, with prizes from sponsors, the club and money-can't-buy
/// experiences. A top-level tab (no back button).
class GewinnenScreen extends StatelessWidget {
  const GewinnenScreen({super.key});

  void _push(BuildContext context, Widget s) =>
      Navigator.of(context).push(MaterialPageRoute(builder: (_) => s));

  // Prize categories in the monthly Tombola (icon, title, sub, colour).
  static const _draws = <(IconData, String, String, Color)>[
    (Icons.sports_bar_rounded, 'Sponsor prizes', 'Veltins crates, adidas gear & more', Color(0xFF00623A)),
    (Icons.verified_rounded, 'Club prizes', 'Signed shirts, matchballs, memorabilia', Color(0xFF0A2A5E)),
    (Icons.stadium_rounded, 'Money-can\'t-buy', 'Play on the pitch, meet the squad', Color(0xFF6A1B9A)),
    (Icons.confirmation_number_rounded, 'VIP tickets', 'Derby & top-match VIP seats', Color(0xFFC62828)),
  ];

  @override
  Widget build(BuildContext context) {
    return SubScaffold(
      title: tr('Prizes'),
      showBack: false,
      children: [
        // ── 1) Your daily chance (retention hook) ──
        AnimatedBuilder(
          animation: dailyGames,
          builder: (context, _) => Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Row(children: [
              Text(tr('Your daily chance'), style: AppText.label1),
              const Spacer(),
              Pill(color: const Color(0x1AEF6C00), child: Row(mainAxisSize: MainAxisSize.min, children: [
                const Icon(Icons.local_fire_department_rounded, size: 13, color: Color(0xFFEF6C00)),
                const SizedBox(width: 3),
                Text('${dailyGames.streakDays} ${tr('day streak')}', style: AppText.caption1.copyWith(color: const Color(0xFFEF6C00), fontWeight: FontWeight.w800)),
              ])),
            ]),
            const SizedBox(height: 12),
            Row(children: [
              Expanded(child: _DailyGameCard(
                icon: Icons.casino_rounded, label: tr('Daily Spin'), gradient: const [Color(0xFF6A1B9A), Color(0xFF311B92)],
                done: dailyGames.spinDone,
                onPlay: () { dailyGames.playSpin(); showDailySpin(context); },
              )),
              const SizedBox(width: 12),
              Expanded(child: _DailyGameCard(
                icon: Icons.style_rounded, label: tr('Scratch Card'), gradient: const [Color(0xFFB8860B), Color(0xFF7A5901)],
                done: dailyGames.scratchDone,
                onPlay: () { dailyGames.playScratch(); showScratchCard(context); },
              )),
            ]),
          ]),
        ),
        const SizedBox(height: 22),

        // ── 2) Your free lots this month (membership) ──
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(color: AppColors.brandLightest, borderRadius: BorderRadius.circular(AppRadii.card)),
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Row(children: [
              const Icon(Icons.local_activity_rounded, color: AppColors.brandPrimary),
              const SizedBox(width: 12),
              Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Text('${FanModel.perks.freeLots} ${tr('free lots this month')}', style: AppText.body2.copyWith(color: AppColors.onAccent, fontWeight: FontWeight.w800)),
                Text('${tr(FanModel.membershipTier)} · ${tr('use them in any draw')}', style: AppText.body3.copyWith(color: AppColors.onAccent)),
              ])),
              Tappable(
                onTap: () => _push(context, const BuyPointsScreen()),
                child: Pill(color: AppColors.surface, child: Text(tr('Buy lots'), style: AppText.caption1.copyWith(color: AppColors.brandPrimary, fontWeight: FontWeight.w800))),
              ),
            ]),
            const SizedBox(height: 10),
            Tappable(
              scale: 0.99,
              onTap: () => _push(context, const SubscriptionScreen()),
              child: Row(children: [
                Icon(Icons.arrow_circle_up_rounded, size: 16, color: AppColors.brandPrimary),
                const SizedBox(width: 6),
                Expanded(child: Text(tr('Higher membership = more free lots every month'), style: AppText.body3.copyWith(color: AppColors.brandPrimary, fontWeight: FontWeight.w700))),
                Icon(Icons.chevron_right_rounded, size: 18, color: AppColors.brandPrimary),
              ]),
            ),
          ]),
        ),
        const SizedBox(height: 22),

        // ── 3) Tombola of the month (featured) ──
        SectionHeader('Tombola of the month', action: 'See all', onAction: () => _push(context, const RafflesScreen())),
        const SizedBox(height: 12),
        Tappable(
          scale: 0.98,
          onTap: () => _push(context, const RafflesScreen()),
          child: Container(
            width: double.infinity,
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(gradient: const LinearGradient(begin: Alignment.topLeft, end: Alignment.bottomRight, colors: [Color(0xFF0A2A5E), Color(0xFF000D22)]), borderRadius: BorderRadius.circular(AppRadii.card)),
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Row(children: [
                Pill(gradient: const LinearGradient(colors: AppColors.goldGradient), child: Text(tr('Draw of the month'), style: AppText.caption1.copyWith(color: AppColors.brandDarkest, fontWeight: FontWeight.w800))),
                const Spacer(),
                Pill(color: Colors.white24, child: Text(tr('Ends in 3d 6h'), style: AppText.caption1.copyWith(color: Colors.white))),
              ]),
              const SizedBox(height: 14),
              const Icon(Icons.emoji_events_rounded, color: AppColors.gold, size: 36),
              const SizedBox(height: 10),
              Text(tr('2× VIP tickets — vs Dortmund'), style: AppText.h4.copyWith(color: Colors.white)),
              const SizedBox(height: 4),
              Text(tr('Enter with a free lot or points.'), style: AppText.body3.copyWith(color: Colors.white70)),
              const SizedBox(height: 14),
              Row(children: [
                Text(tr('Open Tombola'), style: AppText.body2.copyWith(color: Colors.white, fontWeight: FontWeight.w800)),
                const Icon(Icons.chevron_right_rounded, color: Colors.white, size: 18),
              ]),
            ]),
          ),
        ),
        const SizedBox(height: 22),

        // ── 4) All draws by prize source ──
        const SectionHeader('What you can win', action: null),
        const SizedBox(height: 12),
        for (final d in _draws) ...[
          SurfaceCard(
            onTap: () => _push(context, const RafflesScreen()),
            child: Row(children: [
              Container(width: 44, height: 44, decoration: BoxDecoration(color: d.$4.withValues(alpha: 0.12), borderRadius: BorderRadius.circular(12)), child: Icon(d.$1, color: d.$4, size: 22)),
              const SizedBox(width: 14),
              Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Text(tr(d.$2), style: AppText.body2.copyWith(color: AppColors.textDarker, fontWeight: FontWeight.w700)),
                Text(tr(d.$3), maxLines: 1, overflow: TextOverflow.ellipsis, style: AppText.body3Regular),
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

/// A daily game card that flips to a "done today, come back tomorrow" state.
class _DailyGameCard extends StatelessWidget {
  final IconData icon;
  final String label;
  final List<Color> gradient;
  final bool done;
  final VoidCallback onPlay;
  const _DailyGameCard({required this.icon, required this.label, required this.gradient, required this.done, required this.onPlay});

  @override
  Widget build(BuildContext context) {
    if (done) {
      return Container(
        height: 128,
        padding: const EdgeInsets.all(15),
        decoration: BoxDecoration(color: AppColors.surfaceMinimal, borderRadius: BorderRadius.circular(AppRadii.card), border: Border.all(color: AppColors.borderLightest)),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
          Container(width: 40, height: 40, decoration: BoxDecoration(color: AppColors.successBg, borderRadius: BorderRadius.circular(12)), child: const Icon(Icons.check_rounded, color: AppColors.success, size: 22)),
          Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text(tr(label), style: AppText.body2.copyWith(color: AppColors.textDarker, fontWeight: FontWeight.w800)),
            Text(tr('Done today · come back tomorrow'), maxLines: 2, style: AppText.body3Regular),
          ]),
        ]),
      );
    }
    return Tappable(
      scale: 0.97,
      onTap: onPlay,
      child: Container(
        height: 128,
        padding: const EdgeInsets.all(15),
        decoration: BoxDecoration(gradient: LinearGradient(begin: Alignment.topLeft, end: Alignment.bottomRight, colors: gradient), borderRadius: BorderRadius.circular(AppRadii.card)),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
          Container(width: 40, height: 40, decoration: BoxDecoration(color: Colors.white.withValues(alpha: 0.16), borderRadius: BorderRadius.circular(12)), child: Icon(icon, color: AppColors.gold, size: 22)),
          Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text(tr(label), style: AppText.body2.copyWith(color: Colors.white, fontWeight: FontWeight.w800)),
            Text(tr('Free once a day'), style: AppText.body3.copyWith(color: Colors.white70)),
          ]),
        ]),
      ),
    );
  }
}
