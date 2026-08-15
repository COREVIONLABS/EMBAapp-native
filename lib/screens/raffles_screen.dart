import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../theme/app_theme.dart';
import '../widgets/app_widgets.dart';
import '../widgets/sub_scaffold.dart';
import '../widgets/action_sheets.dart';
import '../model/fan_model.dart';
import '../model/tombola.dart';
import 'subscription_screen.dart';
import '../l10n/strings.dart';

/// Tombola — ONE big monthly draw that holds many prizes and many winners,
/// plus occasional specials. There is no "enter" step: your lots (free from
/// membership) auto-participate. You can only buy extra lots with points to
/// raise your chance.
class RafflesScreen extends StatefulWidget {
  const RafflesScreen({super.key});
  @override
  State<RafflesScreen> createState() => _RafflesScreenState();
}

class _RafflesScreenState extends State<RafflesScreen> {
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _timer = Timer.periodic(const Duration(seconds: 1), (_) {
      if (mounted) setState(() {});
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  bool get _topTier => tierNotifier.value == 'Super Fan';

  void _showTerms() => showConfirmDialog(context,
      title: 'How the tombola works',
      message: tr('Members get free lots each month; free lots enter automatically and extra lots cost points. One lot = one entry, more lots = more chances. No purchase necessary — you can always take part with your free lots. 18+. Winners are drawn at the timer and notified in the app.'),
      confirmLabel: 'Got it');

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: raffleStore,
      builder: (context, _) => SubScaffold(
        title: tr('Tombola'),
        bottomBar: PrimaryButton(
          tr('Raise your chance'),
          color: AppColors.gold,
          textColor: AppColors.brandDarkest,
          onTap: () => _openBuySheet(kMonthlyRaffle),
        ),
        children: [
          _hero(kMonthlyRaffle),
          const SizedBox(height: 14),
          _autoInNote(kMonthlyRaffle),
          const SizedBox(height: 22),
          // ── Prizes in the monthly draw (many prizes, many winners) ──
          Row(children: [
            Expanded(child: Text('${tr('Prizes in')} ${raffleMonthName()}', style: AppText.label1)),
            Text('${kMonthlyRaffle.totalPrizes} ${tr('prizes')}', style: AppText.body3.copyWith(color: AppColors.textLight)),
          ]),
          const SizedBox(height: 12),
          for (final p in kMonthlyRaffle.prizes) ...[_prizeRow(p), const SizedBox(height: 10)],
          const SizedBox(height: 12),
          // ── Occasional specials (hidden entirely when there are none) ──
          if (kSpecialRaffles.isNotEmpty) ...[
            Text(tr('Special raffles'), style: AppText.label1),
            const SizedBox(height: 12),
            for (final r in kSpecialRaffles) ...[_specialCard(r), const SizedBox(height: 12)],
          ],
          const SizedBox(height: 4),
          Tappable(
            onTap: _showTerms,
            child: Row(children: [
              Icon(Icons.info_outline_rounded, size: 14, color: AppColors.textLight),
              const SizedBox(width: 6),
              Expanded(child: Text(tr('18+ · No purchase necessary — take part with free lots · Terms apply'),
                  style: AppText.caption1.copyWith(color: AppColors.textLight, decoration: TextDecoration.underline))),
            ]),
          ),
        ],
      ),
    );
  }

  // ── Hero / key visual — the month, the total prizes, a mixed-prize cluster,
  //    a live countdown and your lots. Reusable: swap the prize glyphs. ──
  Widget _hero(Raffle r) {
    final lots = raffleMyLots(r.id);
    return Container(
      width: double.infinity,
      clipBehavior: Clip.antiAlias,
      decoration: BoxDecoration(borderRadius: BorderRadius.circular(AppRadii.card)),
      child: SizedBox(
        height: 226,
        child: Stack(fit: StackFit.expand, children: [
          DecoratedBox(decoration: BoxDecoration(gradient: LinearGradient(colors: r.gradient, begin: Alignment.topLeft, end: Alignment.bottomRight))),
          Positioned(right: -22, top: -26, child: Icon(r.heroGlyph, size: 170, color: Colors.white.withValues(alpha: 0.10))),
          Padding(
            padding: const EdgeInsets.all(18),
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
                Text('${r.totalPrizes}', style: AppText.h1.copyWith(color: Colors.white, fontWeight: FontWeight.w800)),
                const SizedBox(width: 8),
                Padding(padding: const EdgeInsets.only(bottom: 4), child: Text(tr('prizes to win'), style: AppText.body2.copyWith(color: Colors.white))),
              ]),
              const SizedBox(height: 6),
              Row(children: [
                const Icon(Icons.check_circle_rounded, size: 15, color: AppColors.gold),
                const SizedBox(width: 6),
                Text(trp('You’re in with {n} lots', n: '$lots'), style: AppText.body3.copyWith(color: Colors.white70, fontWeight: FontWeight.w700)),
              ]),
              const SizedBox(height: 12),
              // Mixed prize cluster — a glimpse of the variety on offer.
              Row(children: [
                for (final p in r.prizes.take(6)) ...[
                  Container(
                    width: 34, height: 34,
                    decoration: BoxDecoration(color: Colors.white.withValues(alpha: 0.16), borderRadius: BorderRadius.circular(10)),
                    child: Icon(p.glyph, size: 18, color: Colors.white),
                  ),
                  const SizedBox(width: 8),
                ],
              ]),
            ]),
          ),
        ]),
      ),
    );
  }

  // ── Auto-participation note + your lots & points (no "enter" CTA) ──
  Widget _autoInNote(Raffle r) {
    final lots = raffleMyLots(r.id);
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(color: AppColors.brandLightest, borderRadius: BorderRadius.circular(AppRadii.card)),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Row(children: [
          const Icon(Icons.verified_rounded, size: 18, color: AppColors.brandPrimary),
          const SizedBox(width: 8),
          Expanded(child: Text(tr('You’re automatically in with your lots — no sign-up needed. More lots, more chances.'),
              style: AppText.body3.copyWith(color: AppColors.onAccent, fontWeight: FontWeight.w600))),
        ]),
        const SizedBox(height: 14),
        Row(children: [
          Expanded(child: _stat('$lots', tr('Your lots'), Icons.local_activity_rounded)),
          Container(width: 1, height: 34, color: AppColors.borderLightest),
          Expanded(child: ValueListenableBuilder<int>(
            valueListenable: pointsNotifier,
            builder: (_, __, ___) => _stat(FanModel.pointsFormatted, tr('Your points'), Icons.hexagon_rounded),
          )),
        ]),
        if (!_topTier) ...[
          const SizedBox(height: 6),
          Tappable(
            scale: 0.99,
            onTap: () => Navigator.of(context).push(MaterialPageRoute(builder: (_) => const SubscriptionScreen())),
            child: Row(children: [
              Icon(Icons.arrow_circle_up_rounded, size: 15, color: AppColors.brandPrimary),
              const SizedBox(width: 6),
              Expanded(child: Text(tr('Higher membership = more free lots every month'), style: AppText.caption1.copyWith(color: AppColors.brandPrimary, fontWeight: FontWeight.w700))),
              Icon(Icons.chevron_right_rounded, size: 16, color: AppColors.brandPrimary),
            ]),
          ),
        ],
      ]),
    );
  }

  Widget _stat(String value, String label, IconData icon) => Column(children: [
        Row(mainAxisSize: MainAxisSize.min, children: [
          Icon(icon, size: 15, color: AppColors.brandPrimary),
          const SizedBox(width: 5),
          Text(value, style: AppText.h4.copyWith(color: AppColors.onAccent, fontSize: 20)),
        ]),
        const SizedBox(height: 2),
        Text(label, style: AppText.caption1.copyWith(color: AppColors.onAccent)),
      ]);

  // ── A single prize row: motif thumbnail, title, quantity (winners) ──
  Widget _prizeRow(RafflePrize p) {
    return Container(
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(color: AppColors.surface, borderRadius: BorderRadius.circular(AppRadii.card), border: Border.all(color: AppColors.borderLightest)),
      child: Row(children: [
        Container(
          width: 52, height: 52,
          decoration: BoxDecoration(color: p.color.withValues(alpha: 0.12), borderRadius: BorderRadius.circular(13)),
          child: Icon(p.glyph, color: p.color, size: 24),
        ),
        const SizedBox(width: 12),
        Expanded(child: Text(tr(p.title), maxLines: 2, overflow: TextOverflow.ellipsis, style: AppText.body2.copyWith(color: AppColors.textDarker, fontWeight: FontWeight.w700))),
        const SizedBox(width: 8),
        Pill(color: AppColors.brandLightest, child: Text('${p.quantity}× ${tr('winners')}', style: AppText.caption1.copyWith(color: AppColors.brandPrimary, fontWeight: FontWeight.w800))),
      ]),
    );
  }

  // ── Special raffle card — same visual language, its own countdown & lots ──
  Widget _specialCard(Raffle r) {
    final lots = raffleMyLots(r.id);
    final prize = r.prizes.first;
    return Tappable(
      scale: 0.99,
      onTap: () => _openBuySheet(r),
      child: Container(
        clipBehavior: Clip.antiAlias,
        decoration: BoxDecoration(borderRadius: BorderRadius.circular(AppRadii.card)),
        child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
          SizedBox(
            height: 120,
            child: Stack(fit: StackFit.expand, children: [
              DecoratedBox(decoration: BoxDecoration(gradient: LinearGradient(colors: r.gradient, begin: Alignment.topLeft, end: Alignment.bottomRight))),
              Positioned(right: -16, bottom: -20, child: Icon(r.heroGlyph, size: 130, color: Colors.white.withValues(alpha: 0.12))),
              Padding(
                padding: const EdgeInsets.all(14),
                child: Row(children: [
                  Pill(gradient: const LinearGradient(colors: AppColors.goldGradient), child: Text(tr('Special raffle'), style: AppText.caption1.copyWith(color: AppColors.brandDarkest, fontWeight: FontWeight.w800))),
                  const Spacer(),
                  Pill(color: Colors.black.withValues(alpha: 0.4), child: Row(mainAxisSize: MainAxisSize.min, children: [
                    const Icon(Icons.schedule_rounded, size: 12, color: Colors.white),
                    const SizedBox(width: 4),
                    CountdownText(raffleDrawEnd(r), style: AppText.caption1.copyWith(color: Colors.white, fontWeight: FontWeight.w700)),
                  ])),
                ]),
              ),
            ]),
          ),
          Container(
            color: AppColors.brandDarkest,
            padding: const EdgeInsets.all(18),
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text(tr(r.title), style: AppText.label1.copyWith(color: Colors.white)),
              const SizedBox(height: 4),
              Text(tr(prize.title), style: AppText.body3.copyWith(color: Colors.white70)),
              const SizedBox(height: 12),
              Row(children: [
                const Icon(Icons.check_circle_rounded, size: 15, color: AppColors.gold),
                const SizedBox(width: 6),
                Text(trp('You’re in with {n} lots', n: '$lots'), style: AppText.body3.copyWith(color: Colors.white70, fontWeight: FontWeight.w700)),
                const Spacer(),
                Text(tr('Raise your chance'), style: AppText.body3.copyWith(color: AppColors.gold, fontWeight: FontWeight.w800)),
                const Icon(Icons.chevron_right_rounded, color: AppColors.gold, size: 18),
              ]),
            ]),
          ),
        ]),
      ),
    );
  }

  // ── Buy extra lots — a bottom sheet with the packs (mobile-first) ──
  void _openBuySheet(Raffle r) {
    showModalBottomSheet<void>(
      context: context,
      backgroundColor: AppColors.surface,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
      builder: (sheetCtx) => AnimatedBuilder(
        animation: Listenable.merge([raffleStore, pointsNotifier]),
        builder: (sheetCtx, _) {
          final lots = raffleMyLots(r.id);
          return SafeArea(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(20, 12, 20, 20),
              child: Column(mainAxisSize: MainAxisSize.min, crossAxisAlignment: CrossAxisAlignment.start, children: [
                Center(child: Container(width: 40, height: 4, decoration: BoxDecoration(color: AppColors.borderLightest, borderRadius: BorderRadius.circular(999)))),
                const SizedBox(height: 16),
                Text(tr('Raise your chance'), style: AppText.h4),
                const SizedBox(height: 4),
                Text(tr('More lots, higher chance to win.'), style: AppText.body3Regular),
                const SizedBox(height: 16),
                Row(children: [
                  Expanded(child: _sheetStat('$lots', tr('Your lots'), Icons.local_activity_rounded)),
                  const SizedBox(width: 12),
                  Expanded(child: _sheetStat(FanModel.pointsFormatted, tr('Your points'), Icons.hexagon_rounded)),
                ]),
                const SizedBox(height: 16),
                for (final pack in kLotPacks) ...[_packTile(r, pack), const SizedBox(height: 10)],
                const SizedBox(height: 4),
                Text(tr('100 points = €1 · bought points never affect the leaderboard'), style: AppText.caption1.copyWith(color: AppColors.textLight)),
              ]),
            ),
          );
        },
      ),
    );
  }

  Widget _sheetStat(String value, String label, IconData icon) => Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(color: AppColors.surfaceMinimal, borderRadius: BorderRadius.circular(AppRadii.card)),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text(label, style: AppText.caption1.copyWith(color: AppColors.textLight)),
          const SizedBox(height: 4),
          Row(children: [
            Icon(icon, size: 16, color: AppColors.brandPrimary),
            const SizedBox(width: 6),
            Text(value, style: AppText.label1.copyWith(color: AppColors.textDarker)),
          ]),
        ]),
      );

  Widget _packTile(Raffle r, LotPack pack) {
    return Tappable(
      scale: 0.98,
      onTap: () => _buyLots(r, pack),
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(color: AppColors.surface, borderRadius: BorderRadius.circular(AppRadii.card), border: Border.all(color: AppColors.borderLightest)),
        child: Row(children: [
          Container(width: 46, height: 46, decoration: BoxDecoration(color: AppColors.brandLightest, borderRadius: BorderRadius.circular(13)), child: const Icon(Icons.local_activity_rounded, color: AppColors.brandPrimary, size: 24)),
          const SizedBox(width: 14),
          Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text('+${pack.lots} ${pack.lots == 1 ? tr('lot') : tr('lots')}', style: AppText.body1.copyWith(color: AppColors.textDarker, fontWeight: FontWeight.w800, fontSize: 16)),
            Text(trp('{n} more chances in the draw', n: '${pack.lots}'), style: AppText.body3Regular),
          ])),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 9),
            decoration: BoxDecoration(color: AppColors.brandPrimary, borderRadius: BorderRadius.circular(999)),
            child: Text('${FanModel.fmtPublic(pack.points)} ${tr('pts')}', style: AppText.body3.copyWith(color: Colors.white, fontWeight: FontWeight.w800)),
          ),
        ]),
      ),
    );
  }

  Future<void> _buyLots(Raffle r, LotPack pack) async {
    if (FanModel.fanPoints < pack.points) {
      await showConfirmDialog(context,
          title: 'Not enough points',
          message: trp('This pack costs {n} points. Earn or top up to boost your chances.', n: FanModel.fmtPublic(pack.points)),
          confirmLabel: 'OK');
      return;
    }
    if (!FanModel.spendPoints(pack.points)) return;
    HapticFeedback.mediumImpact();
    raffleStore.addLots(r.id, pack.lots);
    if (!mounted) return;
    Navigator.of(context).pop(); // close the sheet
    await showSuccessSheet(context,
        title: 'Lots added! 🎉',
        message: trp('You now have {n} lots — more lots, more chances.', n: '${raffleMyLots(r.id)}'));
  }
}
