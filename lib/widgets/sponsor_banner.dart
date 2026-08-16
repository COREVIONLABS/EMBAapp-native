import 'package:flutter/material.dart';
import '../theme/app_theme.dart';
import '../model/daily_games.dart';
import '../l10n/strings.dart';

/// The sellable "presented by" ad slot that runs on the daily games.
/// A full-width, branded card — big enough to read as real paid inventory,
/// clearly labelled "Anzeige" so it stays honest.
class SponsorAdBanner extends StatelessWidget {
  final GameSponsor sponsor;
  const SponsorAdBanner({super.key, this.sponsor = kDailyGamesSponsor});

  @override
  Widget build(BuildContext context) {
    final s = sponsor;
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(AppRadii.tile),
        gradient: LinearGradient(
          begin: Alignment.centerLeft,
          end: Alignment.centerRight,
          colors: [s.color.withValues(alpha: 0.16), s.color.withValues(alpha: 0.06)],
        ),
        border: Border.all(color: s.color.withValues(alpha: 0.28)),
      ),
      child: Row(
        children: [
          // Brand logo tile
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: s.color,
              borderRadius: BorderRadius.circular(14),
              boxShadow: [BoxShadow(color: s.color.withValues(alpha: 0.35), blurRadius: 12, offset: const Offset(0, 4))],
            ),
            child: Icon(s.icon, size: 26, color: Colors.white),
          ),
          const SizedBox(width: 12),
          // Eyebrow + name
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  tr('presented by').toUpperCase(),
                  style: AppText.caption1.copyWith(color: AppColors.textLight, fontWeight: FontWeight.w700, letterSpacing: 1.2),
                ),
                const SizedBox(height: 3),
                Text(
                  s.name,
                  style: AppText.label1.copyWith(color: AppColors.textDarkest, fontWeight: FontWeight.w800),
                ),
              ],
            ),
          ),
          // Ad label
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: AppColors.surface.withValues(alpha: 0.85),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: AppColors.surfaceLowContrast),
            ),
            child: Text(
              tr('Ad'),
              style: AppText.caption1.copyWith(color: AppColors.textLight, fontWeight: FontWeight.w700, letterSpacing: 0.5),
            ),
          ),
        ],
      ),
    );
  }
}
