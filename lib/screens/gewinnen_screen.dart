import 'package:flutter/material.dart';
import '../theme/app_theme.dart';
import '../widgets/app_widgets.dart';
import '../widgets/hub_widgets.dart';
import '../widgets/sub_scaffold.dart';
import '../widgets/asset_img.dart';
import '../widgets/action_sheets.dart';
import '../model/fan_model.dart';
import '../model/daily_games.dart';
import 'raffles_screen.dart';
import 'auctions_screen.dart';
import '../model/auctions.dart';
import 'my_wins_screen.dart';
import 'past_tombolas_screen.dart';
import 'collection_screen.dart';
import 'subscription_screen.dart';
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

  // Top hero — same shape as the Redeem intro: a brand-gradient header with a
  // headline stat (free lots this month) and the two ways to win below.
  Widget _hero() {
    return Container(
      clipBehavior: Clip.antiAlias,
      decoration: BoxDecoration(borderRadius: BorderRadius.circular(AppRadii.card)),
      child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
        Container(
          padding: const EdgeInsets.fromLTRB(18, 18, 18, 16),
          decoration: const BoxDecoration(gradient: LinearGradient(begin: Alignment.topLeft, end: Alignment.bottomRight, colors: AppColors.pointsGradient)),
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text(tr('Play & win'), style: AppText.label1.copyWith(color: Colors.white)),
            const SizedBox(height: 4),
            Text(tr('Daily games, the monthly tombola, points auctions & your collection.'), style: AppText.body3.copyWith(color: Colors.white70)),
            const SizedBox(height: 14),
            ValueListenableBuilder<int>(
              valueListenable: pointsNotifier,
              builder: (context, _, __) => Row(children: [
                const Icon(Icons.hexagon_rounded, size: 18, color: AppColors.gold),
                const SizedBox(width: 6),
                Text(FanModel.pointsFormatted, style: AppText.h4.copyWith(color: Colors.white, fontSize: 26)),
                const SizedBox(width: 6),
                Padding(padding: const EdgeInsets.only(top: 4), child: Text('${tr('points')} · ${tr('≈')} ${FanModel.balanceEuro}', style: AppText.body3.copyWith(color: Colors.white70))),
              ]),
            ),
          ]),
        ),
      ]),
    );
  }

  // Clear the quick-access grid (with a confirm so it isn't lost by accident).
  Future<void> _dismissQuickNav(BuildContext context) async {
    final ok = await showConfirmDialog(
      context,
      title: 'Hide quick access?',
      message: 'You can turn this shortcut grid back on anytime under Account → Demo.',
      confirmLabel: 'Hide',
    );
    if (ok) winQuickNavNotifier.value = false;
  }

  @override
  Widget build(BuildContext context) {
    return SubScaffold(
      title: tr('Prizes'),
      showBack: false,
      children: [
        // ── Hero — mirrors the Redeem intro: gradient header + live balance ──
        _hero(),
        const SizedBox(height: 14),
        // ── Quick access — dismissible 2×2 grid (same pattern as Redeem) ──
        ValueListenableBuilder<bool>(
          valueListenable: winQuickNavNotifier,
          builder: (context, show, __) => show
              ? Padding(
                  padding: const EdgeInsets.only(bottom: 24),
                  child: QuickNavCard(
                    title: 'Ways to win',
                    onDismiss: () => _dismissQuickNav(context),
                    items: [
                      QuickNavItem(icon: Icons.casino_rounded, color: AppColors.brandPrimary, label: tr('Daily games'), sub: tr('Spin & scratch'),
                          onTap: () { if (!dailyGames.spinDone) dailyGames.playSpin(); showDailySpin(context); }),
                      QuickNavItem(icon: Icons.local_activity_rounded, color: const Color(0xFFC62828), label: tr('Monthly tombola'), sub: tr('Win big prizes'),
                          onTap: () => _push(context, const RafflesScreen())),
                      QuickNavItem(icon: Icons.gavel_rounded, color: AppColors.gold, label: tr('Points auctions'), sub: tr('Bid to win'),
                          onTap: () => _push(context, const AuctionsScreen())),
                      QuickNavItem(icon: Icons.grid_view_rounded, color: const Color(0xFF6A1B9A), label: tr('Collection'), sub: tr('Stickers & badges'),
                          onTap: () => _push(context, const CollectionScreen())),
                    ],
                  ),
                )
              : const SizedBox.shrink(),
        ),
        // ── 1) Your daily chance (retention hook) ──
        AnimatedBuilder(
          animation: dailyGames,
          builder: (context, _) => Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Row(children: [
              Text(tr('Your daily chance'), style: AppText.label1),
              const Spacer(),
              Pill(color: AppColors.brandLightest, child: Row(mainAxisSize: MainAxisSize.min, children: [
                const Icon(Icons.local_fire_department_rounded, size: 13, color: AppColors.brandPrimary),
                const SizedBox(width: 3),
                Text('${dailyGames.streakDays} ${tr('day streak')}', style: AppText.caption1.copyWith(color: AppColors.brandPrimary, fontWeight: FontWeight.w800)),
              ])),
            ]),
            const SizedBox(height: 12),
            Row(children: [
              Expanded(child: _DailyGameCard(
                icon: Icons.casino_rounded, label: tr('Daily Spin'),
                done: dailyGames.spinDone,
                onPlay: () { dailyGames.playSpin(); showDailySpin(context); },
              )),
              const SizedBox(width: 12),
              Expanded(child: _DailyGameCard(
                icon: Icons.style_rounded, label: tr('Scratch Card'),
                done: dailyGames.scratchDone,
                onPlay: () { dailyGames.playScratch(); showScratchCard(context); },
              )),
            ]),
          ]),
        ),
        const SizedBox(height: 22),

        // ── Auctions — bid points on money-can't-buy lots (Socios-style) ──
        SectionHeader('Points auctions', action: 'See all', onAction: () => _push(context, const AuctionsScreen())),
        const SizedBox(height: 12),
        AnimatedBuilder(
          animation: auctionStore,
          builder: (context, _) {
            final a = auctionStore.live.isNotEmpty ? auctionStore.live.first : null;
            if (a == null) return const SizedBox.shrink();
            return Tappable(
              scale: 0.98,
              onTap: () => _push(context, AuctionDetailScreen(id: a.id)),
              child: Container(
                clipBehavior: Clip.antiAlias,
                decoration: BoxDecoration(borderRadius: BorderRadius.circular(AppRadii.card)),
                child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
                  SizedBox(
                    height: 120,
                    child: Stack(fit: StackFit.expand, children: [
                      // Always a branded motif so the header never looks empty;
                      // a real product photo layers on top when one is bundled.
                      DecoratedBox(decoration: BoxDecoration(gradient: LinearGradient(begin: Alignment.topLeft, end: Alignment.bottomRight, colors: [a.color, Color.lerp(a.color, Colors.black, 0.5)!])), child: Center(child: Icon(a.glyph, size: 54, color: Colors.white70))),
                      if (a.image != null)
                        Positioned.fill(child: Image.asset('assets/images/${a.image}.png', fit: BoxFit.cover, errorBuilder: (_, __, ___) => const SizedBox.shrink())),
                      const DecoratedBox(decoration: BoxDecoration(gradient: LinearGradient(begin: Alignment.topCenter, end: Alignment.bottomCenter, colors: [Color(0x33000D22), Color(0x66000D22)]))),
                      Padding(
                        padding: const EdgeInsets.all(12),
                        child: Row(children: [
                          Pill(gradient: const LinearGradient(colors: AppColors.goldGradient), child: Row(mainAxisSize: MainAxisSize.min, children: [
                            const Icon(Icons.gavel_rounded, size: 12, color: AppColors.brandDarkest),
                            const SizedBox(width: 4),
                            Text(tr('Live auction'), style: AppText.caption1.copyWith(color: AppColors.brandDarkest, fontWeight: FontWeight.w800)),
                          ])),
                          const Spacer(),
                          Pill(color: AppColors.danger, child: Row(mainAxisSize: MainAxisSize.min, children: [
                            const Icon(Icons.schedule_rounded, size: 12, color: Colors.white),
                            const SizedBox(width: 4),
                            Text(tr(a.endsInLabel), style: AppText.caption1.copyWith(color: Colors.white, fontWeight: FontWeight.w700)),
                          ])),
                        ]),
                      ),
                    ]),
                  ),
                  Container(
                    color: AppColors.brandDarkest,
                    padding: const EdgeInsets.all(16),
                    child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                      Text(tr(a.title), style: AppText.label1.copyWith(color: Colors.white)),
                      const SizedBox(height: 4),
                      Text(tr('Bid with your Fan Points — win what money can’t buy.'), style: AppText.body3.copyWith(color: Colors.white70)),
                      const SizedBox(height: 12),
                      Row(children: [
                        const Icon(Icons.hexagon_rounded, size: 15, color: AppColors.gold),
                        const SizedBox(width: 6),
                        Text('${FanModel.fmtPublic(a.currentBid)} ${tr('pts')}', style: AppText.body2.copyWith(color: Colors.white, fontWeight: FontWeight.w800)),
                        const SizedBox(width: 6),
                        Text(trp('· {n} bids', n: '${a.bidCount}'), style: AppText.body3.copyWith(color: Colors.white60)),
                        const Spacer(),
                        Text(tr('Bid now'), style: AppText.body2.copyWith(color: AppColors.gold, fontWeight: FontWeight.w800)),
                        const Icon(Icons.chevron_right_rounded, color: AppColors.gold, size: 18),
                      ]),
                    ]),
                  ),
                ]),
              ),
            );
          },
        ),
        const SizedBox(height: 22),

        // ── 2) Your lots (membership) — tier-driven free lots ──
        ValueListenableBuilder<String>(
          valueListenable: tierNotifier,
          builder: (context, tier, __) => Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(color: AppColors.brandLightest, borderRadius: BorderRadius.circular(AppRadii.card)),
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Row(children: [
                const Icon(Icons.local_activity_rounded, color: AppColors.brandPrimary),
                const SizedBox(width: 12),
                Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  Text('${perksFor(tier).freeLots} ${tr('lots this month')}', style: AppText.body2.copyWith(color: AppColors.onAccent, fontWeight: FontWeight.w800)),
                  Text('${tr(tierNotifier.value)} · ${tr('free lots enter automatically — more lots, more chances')}', style: AppText.body3.copyWith(color: AppColors.onAccent)),
                ])),
                Tappable(
                  onTap: () => _push(context, const RafflesScreen()),
                  child: Pill(color: AppColors.surface, child: Text(tr('Open Tombola'), style: AppText.caption1.copyWith(color: AppColors.brandPrimary, fontWeight: FontWeight.w800))),
                ),
              ]),
              if (tierNotifier.value != 'Super Fan') ...[
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
              ],
            ]),
          ),
        ),
        const SizedBox(height: 22),

        // ── 3) Tombola of the month — clean card: photo on top, all text on a
        //    solid panel below (no wild text-over-busy-photo) ──
        SectionHeader('Tombola of the month', action: 'See all', onAction: () => _push(context, const RafflesScreen())),
        const SizedBox(height: 12),
        Tappable(
          scale: 0.98,
          onTap: () => _push(context, const RafflesScreen()),
          child: Container(
            width: double.infinity,
            clipBehavior: Clip.antiAlias,
            decoration: BoxDecoration(borderRadius: BorderRadius.circular(AppRadii.card)),
            child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
              // Photo strip with just the two small badges over a light scrim.
              SizedBox(
                height: 132,
                child: Stack(fit: StackFit.expand, children: [
                  const AssetImg('img_tickets', fit: BoxFit.cover, fallbackIcon: Icons.emoji_events_rounded),
                  const DecoratedBox(decoration: BoxDecoration(gradient: LinearGradient(begin: Alignment.topCenter, end: Alignment.bottomCenter, colors: [Color(0x55000D22), Color(0x11000D22)]))),
                  Padding(
                    padding: const EdgeInsets.all(12),
                    child: Row(children: [
                      Pill(gradient: const LinearGradient(colors: AppColors.goldGradient), child: Text(tr('Draw of the month'), style: AppText.caption1.copyWith(color: AppColors.brandDarkest, fontWeight: FontWeight.w800))),
                      const Spacer(),
                      Pill(color: Colors.black.withValues(alpha: 0.5), child: Row(mainAxisSize: MainAxisSize.min, children: [
                        const Icon(Icons.schedule_rounded, size: 12, color: Colors.white),
                        const SizedBox(width: 4),
                        Text(tr('Ends in 3d 6h'), style: AppText.caption1.copyWith(color: Colors.white, fontWeight: FontWeight.w700)),
                      ])),
                    ]),
                  ),
                ]),
              ),
              // Solid info panel — clean, legible text.
              Container(
                color: AppColors.brandDarkest,
                padding: const EdgeInsets.all(18),
                child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  Text(tr('2× VIP tickets — vs Dortmund'), style: AppText.label1.copyWith(color: Colors.white)),
                  const SizedBox(height: 4),
                  Text(tr('You\'re automatically in — more lots, more chances.'), style: AppText.body3.copyWith(color: Colors.white70)),
                  const SizedBox(height: 14),
                  Row(children: [
                    const Icon(Icons.local_activity_rounded, size: 15, color: AppColors.gold),
                    const SizedBox(width: 6),
                    Text('${FanModel.fmtPublic(1840)} ${tr('entries')}', style: AppText.body3.copyWith(color: Colors.white70, fontWeight: FontWeight.w700)),
                    const Spacer(),
                    Text(tr('See all draws'), style: AppText.body2.copyWith(color: AppColors.gold, fontWeight: FontWeight.w800)),
                    const Icon(Icons.chevron_right_rounded, color: AppColors.gold, size: 18),
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
            Expanded(child: Text(tr('Your free lots enter every monthly draw automatically.'), style: AppText.body3.copyWith(color: AppColors.textDarker, fontWeight: FontWeight.w600))),
          ]),
        ),
        const SizedBox(height: 12),
        HubListRow(
          icon: Icons.emoji_events_rounded, iconColor: AppColors.gold,
          title: 'My wins', subtitle: 'Prizes you\'ve won',
          onTap: () => _push(context, const MyWinsScreen()),
        ),
        const SizedBox(height: 10),
        HubListRow(
          icon: Icons.history_rounded, iconColor: AppColors.brandPrimary,
          title: 'Past tombolas', subtitle: 'Results of previous draws',
          onTap: () => _push(context, const PastTombolasScreen()),
        ),
        const SizedBox(height: 10),
        HubListRow(
          icon: Icons.grid_view_rounded, iconColor: AppColors.textNormal,
          title: 'Season Collection', subtitle: 'Your player stickers & badges',
          onTap: () => _push(context, const CollectionScreen()),
        ),
      ],
    );
  }
}

/// A daily game card that flips to a "done today, come back tomorrow" state.
/// Calm, brand-consistent surface card (was a loud purple/gold gradient).
class _DailyGameCard extends StatelessWidget {
  final IconData icon;
  final String label;
  final bool done;
  final VoidCallback onPlay;
  const _DailyGameCard({required this.icon, required this.label, required this.done, required this.onPlay});

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
        decoration: BoxDecoration(color: AppColors.surface, borderRadius: BorderRadius.circular(AppRadii.card), border: Border.all(color: AppColors.borderLightest)),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
          Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
            Container(width: 40, height: 40, decoration: BoxDecoration(color: AppColors.brandLightest, borderRadius: BorderRadius.circular(12)), child: Icon(icon, color: AppColors.brandPrimary, size: 22)),
            Container(width: 26, height: 26, decoration: const BoxDecoration(color: AppColors.brandPrimary, shape: BoxShape.circle), child: const Icon(Icons.play_arrow_rounded, color: Colors.white, size: 17)),
          ]),
          Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text(tr(label), style: AppText.body2.copyWith(color: AppColors.textDarker, fontWeight: FontWeight.w800)),
            Text(tr('Free once a day'), style: AppText.body3Regular),
          ]),
        ]),
      ),
    );
  }
}
