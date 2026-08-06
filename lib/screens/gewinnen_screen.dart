import 'package:flutter/material.dart';
import '../theme/app_theme.dart';
import '../widgets/app_widgets.dart';
import '../widgets/hub_widgets.dart';
import '../widgets/sub_scaffold.dart';
import '../widgets/asset_img.dart';
import '../model/fan_model.dart';
import '../model/daily_games.dart';
import 'raffles_screen.dart';
import 'collection_screen.dart';
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

        // ── 3) Tombola of the month (featured, photo hero) ──
        SectionHeader('Tombola of the month', action: 'See all', onAction: () => _push(context, const RafflesScreen())),
        const SizedBox(height: 12),
        Tappable(
          scale: 0.98,
          onTap: () => _push(context, const RafflesScreen()),
          child: Container(
            width: double.infinity,
            height: 216,
            clipBehavior: Clip.antiAlias,
            decoration: BoxDecoration(borderRadius: BorderRadius.circular(AppRadii.card)),
            child: Stack(fit: StackFit.expand, children: [
              const AssetImg('img_tickets', fit: BoxFit.cover, fallbackIcon: Icons.emoji_events_rounded),
              const DecoratedBox(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter, end: Alignment.bottomCenter,
                    colors: [Color(0x99000D22), Color(0x22000D22), Color(0xF2000D22)], stops: [0, 0.35, 1],
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(20),
                child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  Row(children: [
                    Pill(gradient: const LinearGradient(colors: AppColors.goldGradient), child: Text(tr('Draw of the month'), style: AppText.caption1.copyWith(color: AppColors.brandDarkest, fontWeight: FontWeight.w800))),
                    const Spacer(),
                    Pill(color: Colors.black.withValues(alpha: 0.5), child: Row(mainAxisSize: MainAxisSize.min, children: [
                      const Icon(Icons.schedule_rounded, size: 12, color: Colors.white),
                      const SizedBox(width: 4),
                      Text(tr('Ends in 3d 6h'), style: AppText.caption1.copyWith(color: Colors.white, fontWeight: FontWeight.w700)),
                    ])),
                  ]),
                  const Spacer(),
                  Text(tr('2× VIP tickets — vs Dortmund'), style: AppText.h4.copyWith(color: Colors.white)),
                  const SizedBox(height: 4),
                  Text(tr('You\'re automatically entered every month.'), style: AppText.body3.copyWith(color: Colors.white70)),
                  const SizedBox(height: 12),
                  Row(children: [
                    Text(tr('See all prizes'), style: AppText.body2.copyWith(color: Colors.white, fontWeight: FontWeight.w800)),
                    const Icon(Icons.chevron_right_rounded, color: Colors.white, size: 18),
                  ]),
                ]),
              ),
            ]),
          ),
        ),
        const SizedBox(height: 22),

        // ── 4) Your tombola overview (wins & past draws) ──
        const SectionHeader('Your tombola', action: null),
        const SizedBox(height: 10),
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(color: AppColors.successBg, borderRadius: BorderRadius.circular(AppRadii.tile)),
          child: Row(children: [
            const Icon(Icons.verified_rounded, color: AppColors.success, size: 20),
            const SizedBox(width: 10),
            Expanded(child: Text(tr('As a member you\'re automatically in every monthly draw.'), style: AppText.body3.copyWith(color: AppColors.textDarker, fontWeight: FontWeight.w600))),
          ]),
        ),
        const SizedBox(height: 12),
        HubListRow(
          icon: Icons.emoji_events_rounded, iconColor: AppColors.gold,
          title: 'My wins', subtitle: 'Prizes you\'ve won',
          onTap: () => _push(context, const CollectionScreen()),
        ),
        const SizedBox(height: 10),
        HubListRow(
          icon: Icons.history_rounded, iconColor: AppColors.brandPrimary,
          title: 'Past tombolas', subtitle: 'Results of previous draws',
          onTap: () => _push(context, const RafflesScreen()),
        ),
        const SizedBox(height: 10),
        HubListRow(
          icon: Icons.help_outline_rounded, iconColor: AppColors.textNormal,
          title: 'How the tombola works', subtitle: 'Free lots, draws & winners',
          onTap: () => _push(context, const RafflesScreen()),
        ),
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
