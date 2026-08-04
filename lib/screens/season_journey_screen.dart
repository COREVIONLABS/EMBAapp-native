import 'package:flutter/material.dart';
import '../theme/app_theme.dart';
import '../widgets/app_widgets.dart';
import '../widgets/sub_scaffold.dart';
import '../model/fan_model.dart';
import '../l10n/strings.dart';

/// A single stop on the season-long journey. The point thresholds are tied to
/// FC Schalke 04's history so the ladder tells the club's story as the fan
/// climbs it (Club Brugge "Road to Gold" inspired).
class _Milestone {
  final int points;
  final String year; // Schalke-history anchor
  final String title;
  final String reward;
  final IconData icon;
  const _Milestone(this.points, this.year, this.title, this.reward, this.icon);
}

/// "Road to Gold" — a season journey where each milestone is a moment from S04
/// history, and reaching it unlocks a real fan reward. The final stop is Gold:
/// becoming an S04 Legend.
class SeasonJourneyScreen extends StatelessWidget {
  const SeasonJourneyScreen({super.key});

  static const _stops = <_Milestone>[
    _Milestone(1904, '1904', 'Die Gründung', 'Glückauf welcome badge', Icons.flag_rounded),
    _Milestone(3000, '1934', 'Erste Meisterschaft', 'Digital sticker pack', Icons.emoji_events_outlined),
    _Milestone(5800, '1958', '7× Deutscher Meister', 'Double-points weekend', Icons.stars_rounded),
    _Milestone(9700, '1997', 'UEFA-Cup Legende', 'VIP Arena upgrade', Icons.military_tech_rounded),
    _Milestone(15000, 'Heute', 'Ehrenmitglied', 'Signed shirt raffle entry', Icons.workspace_premium_rounded),
    _Milestone(25000, 'Gold', 'S04-Legende', 'Money-can\'t-buy legend day', Icons.diamond_rounded),
  ];

  @override
  Widget build(BuildContext context) {
    final pts = FanModel.fanPoints;
    // Next locked milestone (for the hero progress).
    final next = _stops.firstWhere((m) => m.points > pts, orElse: () => _stops.last);
    final prevPoints = _stops.where((m) => m.points <= pts).fold<int>(0, (a, m) => m.points > a ? m.points : a);
    final span = (next.points - prevPoints).clamp(1, 1 << 30);
    final into = (pts - prevPoints).clamp(0, span);
    final progress = into / span;
    final remaining = (next.points - pts).clamp(0, 1 << 30);
    final unlockedCount = _stops.where((m) => m.points <= pts).length;

    return SubScaffold(
      title: tr('Road to Gold'),
      children: [
        // ── Hero: progress to the next historic milestone ──
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(gradient: const LinearGradient(colors: AppColors.pointsGradient), borderRadius: BorderRadius.circular(AppRadii.card)),
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Row(children: [
              const Icon(Icons.route_rounded, color: AppColors.gold, size: 20),
              const SizedBox(width: 8),
              Text(tr('Your season journey'), style: AppText.body2.copyWith(color: Colors.white)),
              const Spacer(),
              Pill(gradient: const LinearGradient(colors: AppColors.goldGradient), child: Text('$unlockedCount / ${_stops.length}', style: AppText.caption1.copyWith(color: AppColors.brandDarkest, fontWeight: FontWeight.w800))),
            ]),
            const SizedBox(height: 16),
            Text(tr(next.title), style: AppText.h4.copyWith(color: Colors.white)),
            const SizedBox(height: 2),
            Text('${tr('Next stop')} · ${next.year} · ${tr('unlocks')} ${tr(next.reward)}', style: AppText.body3.copyWith(color: Colors.white70)),
            const SizedBox(height: 14),
            ClipRRect(
              borderRadius: BorderRadius.circular(4),
              child: LinearProgressIndicator(value: progress, minHeight: 8, backgroundColor: Colors.white24, valueColor: const AlwaysStoppedAnimation(AppColors.gold)),
            ),
            const SizedBox(height: 10),
            Row(children: [
              Text('${FanModel.pointsFormatted} ${tr('pts')}', style: AppText.body3.copyWith(color: Colors.white, fontWeight: FontWeight.w700)),
              const Spacer(),
              Text('${FanModel.fmtPublic(remaining)} ${tr('pts to go')}', style: AppText.body3.copyWith(color: Colors.white70)),
            ]),
          ]),
        ),
        const SizedBox(height: 20),
        Align(alignment: Alignment.centerLeft, child: Text(tr('120 years of blue & white'), style: AppText.label1)),
        const SizedBox(height: 4),
        Padding(
          padding: const EdgeInsets.only(bottom: 14),
          child: Text(tr('Every milestone is a moment from S04 history. Reach it, unlock the reward.'), style: AppText.body3Regular),
        ),

        // ── Vertical journey timeline ──
        for (var i = 0; i < _stops.length; i++)
          _StopRow(
            m: _stops[i],
            reached: _stops[i].points <= pts,
            isCurrent: _stops[i].points == next.points && next.points > pts,
            isLast: i == _stops.length - 1,
          ),
      ],
    );
  }
}

class _StopRow extends StatelessWidget {
  final _Milestone m;
  final bool reached;
  final bool isCurrent;
  final bool isLast;
  const _StopRow({required this.m, required this.reached, required this.isCurrent, required this.isLast});

  @override
  Widget build(BuildContext context) {
    final Color nodeColor = reached ? AppColors.success : (isCurrent ? AppColors.brandPrimary : AppColors.surfaceLowContrast);
    return IntrinsicHeight(
      child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
        // Spine: node + connector
        Column(children: [
          Container(
            width: 40, height: 40,
            decoration: BoxDecoration(color: reached ? AppColors.successBg : (isCurrent ? AppColors.brandLightest : AppColors.surfaceMinimal), shape: BoxShape.circle, border: Border.all(color: nodeColor, width: 2)),
            child: Icon(reached ? Icons.check_rounded : (isCurrent ? m.icon : Icons.lock_outline_rounded), color: reached ? AppColors.success : (isCurrent ? AppColors.brandPrimary : AppColors.textLight), size: 20),
          ),
          if (!isLast) Expanded(child: Container(width: 2, color: reached ? AppColors.success.withValues(alpha: 0.35) : AppColors.borderLightest)),
        ]),
        const SizedBox(width: 14),
        // Card
        Expanded(
          child: Padding(
            padding: EdgeInsets.only(bottom: isLast ? 0 : 14),
            child: Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: isCurrent ? AppColors.brandLightest : AppColors.surface,
                borderRadius: BorderRadius.circular(AppRadii.tile),
                border: Border.all(color: isCurrent ? AppColors.brandPrimary.withValues(alpha: 0.4) : AppColors.borderLightest),
              ),
              child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Row(children: [
                  Pill(color: AppColors.surfaceMinimal, child: Text(m.year, style: AppText.caption1.copyWith(color: AppColors.textNormal, fontWeight: FontWeight.w800))),
                  const SizedBox(width: 8),
                  Text('${FanModel.fmtPublic(m.points)} ${tr('pts')}', style: AppText.caption1.copyWith(color: AppColors.textLight, fontWeight: FontWeight.w700)),
                  const Spacer(),
                  if (reached) Text(tr('Unlocked'), style: AppText.caption1.copyWith(color: AppColors.success, fontWeight: FontWeight.w800))
                  else if (isCurrent) Text(tr('Next'), style: AppText.caption1.copyWith(color: AppColors.brandPrimary, fontWeight: FontWeight.w800)),
                ]),
                const SizedBox(height: 8),
                Text(tr(m.title), style: AppText.body2.copyWith(color: AppColors.textDarker, fontWeight: FontWeight.w700)),
                const SizedBox(height: 4),
                Row(children: [
                  Icon(Icons.card_giftcard_rounded, size: 15, color: reached ? AppColors.success : AppColors.brandPrimary),
                  const SizedBox(width: 6),
                  Expanded(child: Text(tr(m.reward), style: AppText.body3Regular)),
                ]),
              ]),
            ),
          ),
        ),
      ]),
    );
  }
}
