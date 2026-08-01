import 'package:flutter/material.dart';
import '../theme/app_theme.dart';
import '../model/fan_model.dart';
import '../widgets/app_widgets.dart';
import '../widgets/sub_scaffold.dart';
import 'points_history_screen.dart';
import '../l10n/strings.dart';

/// Loyalty Tiers (Figma 2162:5368) — Nordkurve → Legende ladder.
class LoyaltyTiersScreen extends StatelessWidget {
  const LoyaltyTiersScreen({super.key});

  static const _meta = {
    'Legende': (Icons.emoji_events_rounded, Color(0xFFFFB800)),
    'Ehrenmitglied': (Icons.military_tech_rounded, Color(0xFF8A94A6)),
    'Schalker': (Icons.shield_rounded, AppColors.brandPrimary),
    'Knappenschmiede': (Icons.school_rounded, Color(0xFF667085)),
    'Nordkurve': (Icons.groups_rounded, Color(0xFF98A2B3)),
  };

  @override
  Widget build(BuildContext context) {
    final tiersDesc = FanModel.tiers.reversed.toList();
    return SubScaffold(
      title: tr('Loyalty Tiers'),
      bottomBar: SecondaryButton(tr('View Points History'),
          onTap: () => Navigator.of(context).push(MaterialPageRoute(builder: (_) => const PointsHistoryScreen()))),
      children: [
        // Current tier card
        Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            gradient: const LinearGradient(colors: AppColors.pointsGradient),
            borderRadius: BorderRadius.circular(AppRadii.card),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(tr('Your Current Tier'), style: AppText.body3.copyWith(color: Colors.white70)),
              const SizedBox(height: 4),
              Text(FanModel.currentTier, style: AppText.h4.copyWith(color: Colors.white)),
              const SizedBox(height: 4),
              Text('${FanModel.pointsFormatted} / ${FanModel.nextTierFormatted} pts to next tier',
                  style: AppText.body3.copyWith(color: Colors.white70)),
              const SizedBox(height: 12),
              ClipRRect(
                borderRadius: BorderRadius.circular(3),
                child: LinearProgressIndicator(
                  value: FanModel.tierProgress,
                  minHeight: 6,
                  backgroundColor: Colors.white24,
                  valueColor: const AlwaysStoppedAnimation(AppColors.gold),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 12),
        Row(children: [
          Icon(Icons.info_outline_rounded, size: 15, color: AppColors.textLight),
          const SizedBox(width: 6),
          Expanded(child: Text(tr('Free for every fan — your tier rises automatically as you collect Fan Points.'),
              style: AppText.body3Regular.copyWith(fontSize: 12.5))),
        ]),
        const SizedBox(height: 16),
        for (final t in tiersDesc) ...[
          _TierRow(tier: t, current: t.name == FanModel.currentTier, meta: _meta[t.name]!),
          const SizedBox(height: 10),
        ],
      ],
    );
  }
}

class _TierRow extends StatelessWidget {
  final FanTier tier;
  final bool current;
  final (IconData, Color) meta;
  const _TierRow({required this.tier, required this.current, required this.meta});
  @override
  Widget build(BuildContext context) {
    return SurfaceCard(
      color: current ? AppColors.brandLightest : AppColors.surface,
      border: Border.all(color: current ? AppColors.brandPrimary.withValues(alpha: 0.4) : AppColors.borderLightest),
      child: Row(
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(color: meta.$2.withValues(alpha: 0.12), borderRadius: BorderRadius.circular(12)),
            child: Icon(meta.$1, color: meta.$2, size: 24),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(tier.name, style: AppText.body1.copyWith(color: AppColors.textDarker, fontSize: 15, fontWeight: FontWeight.w700)),
                const SizedBox(height: 2),
                Text(tier.minPoints == 25000 ? '25,000+ pts' : '${FanModel.fmtPublic(tier.minPoints)} pts', style: AppText.body3Regular),
              ],
            ),
          ),
          if (current)
            Pill(color: AppColors.brandPrimary, child: Text(tr('Current'), style: AppText.caption1.copyWith(color: Colors.white))),
        ],
      ),
    );
  }
}
