import 'package:flutter/material.dart';
import '../theme/app_theme.dart';
import '../widgets/app_widgets.dart';
import '../widgets/sub_scaffold.dart';
import '../l10n/strings.dart';

/// Supporter Streak detail — the flame/level, progress to the next level and a
/// calendar strip of the last two weeks. Opened from the Home streak widget.
class StreakScreen extends StatelessWidget {
  const StreakScreen({super.key});

  // Last 14 days, newest last: (weekday letter, completed).
  static const _days = <(String, bool)>[
    ('M', true), ('T', true), ('W', true), ('T', false), ('F', true), ('S', true), ('S', true),
    ('M', true), ('T', true), ('W', true), ('T', true), ('F', true), ('S', true), ('S', true),
  ];

  @override
  Widget build(BuildContext context) {
    const done = 5; // current streak length
    const toNext = 2; // days to the next level
    return SubScaffold(
      title: tr('Your Streak'),
      children: [
        // Hero
        Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(vertical: 26),
          decoration: BoxDecoration(gradient: const LinearGradient(colors: AppColors.pointsGradient), borderRadius: BorderRadius.circular(AppRadii.card)),
          child: Column(children: [
            Container(
              width: 72, height: 72,
              decoration: BoxDecoration(gradient: const LinearGradient(colors: AppColors.goldGradient), shape: BoxShape.circle),
              child: const Icon(Icons.local_fire_department_rounded, color: AppColors.brandDarkest, size: 40),
            ),
            const SizedBox(height: 12),
            Text('$done', style: AppText.h1.copyWith(color: Colors.white, fontWeight: FontWeight.w800, fontSize: 44)),
            Text(tr('day streak'), style: AppText.body2.copyWith(color: Colors.white70)),
            const SizedBox(height: 10),
            Pill(gradient: const LinearGradient(colors: AppColors.goldGradient), child: Text(tr('Level 2 · Fire'), style: AppText.caption1.copyWith(color: AppColors.brandDarkest, fontWeight: FontWeight.w800))),
          ]),
        ),
        const SizedBox(height: 16),
        // Progress to next level
        SurfaceCard(
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
              Text(tr('Next: Level 3 · Gold'), style: AppText.body2.copyWith(color: AppColors.textDarker, fontWeight: FontWeight.w700)),
              Text('$toNext ${tr('days to go')}', style: AppText.body3.copyWith(color: AppColors.brandPrimary, fontWeight: FontWeight.w700)),
            ]),
            const SizedBox(height: 10),
            ClipRRect(
              borderRadius: BorderRadius.circular(4),
              child: LinearProgressIndicator(value: 0.5, minHeight: 8, backgroundColor: AppColors.surfaceLowContrast, valueColor: const AlwaysStoppedAnimation(AppColors.brandPrimary)),
            ),
            const SizedBox(height: 8),
            Text(tr('Keep your streak going for 2 more days to reach Gold.'), style: AppText.body3Regular),
          ]),
        ),
        const SizedBox(height: 20),
        Align(alignment: Alignment.centerLeft, child: Text(tr('Last 14 days'), style: AppText.label1)),
        const SizedBox(height: 12),
        GridView.count(
          crossAxisCount: 7,
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          mainAxisSpacing: 10,
          crossAxisSpacing: 10,
          childAspectRatio: 0.74,
          children: [
            for (final d in _days)
              Column(children: [
                Expanded(
                  child: Container(
                    width: double.infinity,
                    decoration: BoxDecoration(
                      color: d.$2 ? AppColors.brandPrimary : AppColors.surfaceMinimal,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Icon(d.$2 ? Icons.check_rounded : Icons.close_rounded, size: 16, color: d.$2 ? Colors.white : AppColors.textLight),
                  ),
                ),
                const SizedBox(height: 4),
                Text(d.$1, style: AppText.caption1.copyWith(color: AppColors.textLight, fontSize: 10)),
              ]),
          ],
        ),
        const SizedBox(height: 20),
        SurfaceCard(
          color: AppColors.successBg,
          child: Row(children: [
            const Icon(Icons.shield_rounded, color: AppColors.success),
            const SizedBox(width: 12),
            Expanded(child: Text(tr('Streak protected — one missed day won\'t reset it (Fan+ perk).'), style: AppText.body2.copyWith(color: AppColors.textDarker))),
          ]),
        ),
        const SizedBox(height: 20),
        Align(alignment: Alignment.centerLeft, child: Text(tr('How streaks work'), style: AppText.label1)),
        const SizedBox(height: 10),
        for (final s in const [
          'Open the app and do one fan action a day — a spin, a prediction, a check-in.',
          'Every day extends your streak and earns bonus points at each new level.',
          'Super Fan members get one free streak freeze a month so a missed day won\'t reset it.',
        ]) ...[
          Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
            const Padding(padding: EdgeInsets.only(top: 2), child: Icon(Icons.check_circle_rounded, size: 16, color: AppColors.brandPrimary)),
            const SizedBox(width: 10),
            Expanded(child: Text(tr(s), style: AppText.body2.copyWith(color: AppColors.textNormal))),
          ]),
          const SizedBox(height: 10),
        ],
      ],
    );
  }
}
