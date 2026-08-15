import 'package:flutter/material.dart';
import '../theme/app_theme.dart';
import '../widgets/app_widgets.dart';
import '../widgets/hub_widgets.dart';
import '../widgets/sub_scaffold.dart';
import '../model/fan_model.dart';
import '../model/daily_games.dart';
import 'raffles_screen.dart';
import 'auctions_screen.dart';
import '../model/auctions.dart';
import '../model/tombola.dart';
import 'my_wins_screen.dart';
import 'past_tombolas_screen.dart';
import 'collection_screen.dart';
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

  // Compact balance chip for the tab header (same as Redeem / Fan+) — the
  // balance is shown once here, not repeated in a big hero box below.
  Widget _pointsChip() => Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
        decoration: BoxDecoration(color: AppColors.brandLightest, borderRadius: BorderRadius.circular(999)),
        child: Row(mainAxisSize: MainAxisSize.min, children: [
          const Icon(Icons.hexagon_rounded, size: 14, color: AppColors.brandPrimary),
          const SizedBox(width: 5),
          ValueListenableBuilder<int>(
            valueListenable: pointsNotifier,
            builder: (_, __, ___) => Text(FanModel.pointsFormatted, style: AppText.caption1.copyWith(color: AppColors.brandPrimary, fontWeight: FontWeight.w800)),
          ),
        ]),
      );

  @override
  Widget build(BuildContext context) {
    return SubScaffold(
      title: tr('Prizes'),
      showBack: false,
      trailing: _pointsChip(),
      children: [
        // ══ BLOCK ① Play today — the daily retention hook, top & prominent ══
        AnimatedBuilder(
          animation: dailyGames,
          builder: (context, _) => Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Row(children: [
              Text(tr('Play today'), style: AppText.label1),
              const Spacer(),
              Pill(color: AppColors.brandLightest, child: Row(mainAxisSize: MainAxisSize.min, children: [
                const Icon(Icons.local_fire_department_rounded, size: 13, color: AppColors.brandPrimary),
                const SizedBox(width: 3),
                Text('${dailyGames.streakDays} ${tr('day streak')}', style: AppText.caption1.copyWith(color: AppColors.brandPrimary, fontWeight: FontWeight.w800)),
              ])),
            ]),
            const SizedBox(height: 4),
            Text(tr('One free spin & one scratch card, every day.'), style: AppText.body3Regular),
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
        const SizedBox(height: 26),

        // ══ BLOCK ② Big prizes — Tombola + Auction, two equal cards ══
        Text(tr('Big prizes'), style: AppText.label1),
        const SizedBox(height: 4),
        Text(tr('The monthly tombola and live points auctions.'), style: AppText.body3Regular),
        const SizedBox(height: 12),
        // Tombola — one consolidated card: prize, countdown AND your free lots.
        _tombolaCard(context),
        const SizedBox(height: 12),
        // Auction — the featured live lot (parallel treatment to the tombola).
        _auctionCard(context),
        const SizedBox(height: 26),

        // ══ BLOCK ③ Your wins & collection ══
        Text(tr('Your wins & collection'), style: AppText.label1),
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

  // ── Monthly-raffle teaser — same key-visual as the Tombola page, so
  //    "Große Preise" and the Tombola read as ONE system. ──
  Widget _tombolaCard(BuildContext context) {
    return AnimatedBuilder(
      animation: Listenable.merge([tierNotifier, raffleStore]),
      builder: (context, __) {
        final r = kMonthlyRaffle;
        final lots = raffleMyLots(r.id);
        return Tappable(
          scale: 0.98,
          onTap: () => _push(context, const RafflesScreen()),
          child: Container(
            width: double.infinity,
            clipBehavior: Clip.antiAlias,
            decoration: BoxDecoration(borderRadius: BorderRadius.circular(AppRadii.card)),
            child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
              // Key-visual band: month, total prizes, live countdown.
              SizedBox(
                height: 150,
                child: Stack(fit: StackFit.expand, children: [
                  DecoratedBox(decoration: BoxDecoration(gradient: LinearGradient(colors: r.gradient, begin: Alignment.topLeft, end: Alignment.bottomRight))),
                  Positioned(right: -18, top: -22, child: Icon(r.heroGlyph, size: 150, color: Colors.white.withValues(alpha: 0.10))),
                  Padding(
                    padding: const EdgeInsets.all(14),
                    child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                      Row(children: [
                        Pill(gradient: const LinearGradient(colors: AppColors.goldGradient), child: Text('${raffleMonthName()} ${tr('monthly raffle')}', style: AppText.caption1.copyWith(color: AppColors.brandDarkest, fontWeight: FontWeight.w800))),
                        const Spacer(),
                        Pill(color: Colors.black.withValues(alpha: 0.4), child: Row(mainAxisSize: MainAxisSize.min, children: [
                          const Icon(Icons.schedule_rounded, size: 12, color: Colors.white),
                          const SizedBox(width: 4),
                          CountdownText(raffleDrawEnd(r), style: AppText.caption1.copyWith(color: Colors.white, fontWeight: FontWeight.w700)),
                        ])),
                      ]),
                      const Spacer(),
                      Row(crossAxisAlignment: CrossAxisAlignment.baseline, textBaseline: TextBaseline.alphabetic, children: [
                        Text('${r.totalPrizes}', style: AppText.h2.copyWith(color: Colors.white, fontWeight: FontWeight.w800)),
                        const SizedBox(width: 6),
                        Padding(padding: const EdgeInsets.only(bottom: 3), child: Text(tr('prizes to win'), style: AppText.body3.copyWith(color: Colors.white))),
                      ]),
                    ]),
                  ),
                ]),
              ),
              // Solid panel: your lots + prize cluster + CTA.
              Container(
                color: AppColors.brandDarkest,
                padding: const EdgeInsets.all(18),
                child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  Row(children: [
                    const Icon(Icons.check_circle_rounded, size: 15, color: AppColors.gold),
                    const SizedBox(width: 6),
                    Expanded(child: Text(trp('You’re in with {n} lots', n: '$lots'), style: AppText.body3.copyWith(color: Colors.white))),
                  ]),
                  const SizedBox(height: 12),
                  Row(children: [
                    for (final p in r.prizes.take(5)) ...[
                      Container(width: 30, height: 30, decoration: BoxDecoration(color: Colors.white.withValues(alpha: 0.14), borderRadius: BorderRadius.circular(9)), child: Icon(p.glyph, size: 16, color: Colors.white)),
                      const SizedBox(width: 6),
                    ],
                    const Spacer(),
                    Text(tr('View prizes'), style: AppText.body2.copyWith(color: AppColors.gold, fontWeight: FontWeight.w800)),
                    const Icon(Icons.chevron_right_rounded, color: AppColors.gold, size: 18),
                  ]),
                ]),
              ),
            ]),
          ),
        );
      },
    );
  }

  // ── Featured live auction — parallel card treatment to the tombola. ──
  Widget _auctionCard(BuildContext context) {
    return AnimatedBuilder(
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
                height: 132,
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
                        a.endsAt != null
                            ? CountdownText(a.endsAt!, style: AppText.caption1.copyWith(color: Colors.white, fontWeight: FontWeight.w700))
                            : Text(tr(a.endsInLabel), style: AppText.caption1.copyWith(color: Colors.white, fontWeight: FontWeight.w700)),
                      ])),
                    ]),
                  ),
                ]),
              ),
              Container(
                color: AppColors.brandDarkest,
                padding: const EdgeInsets.all(18),
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
