import 'package:flutter/material.dart';
import '../theme/app_theme.dart';
import '../widgets/app_widgets.dart';
import '../widgets/sub_scaffold.dart';
import '../l10n/strings.dart';

/// Matchday Specials (Figma 2162:6061).
class MatchdaySpecialsScreen extends StatelessWidget {
  const MatchdaySpecialsScreen({super.key});
  @override
  Widget build(BuildContext context) {
    return SubScaffold(
      title: tr('Matchday Specials'),
      children: [
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(gradient: const LinearGradient(colors: AppColors.pointsGradient), borderRadius: BorderRadius.circular(AppRadii.card)),
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Row(children: [
              const Icon(Icons.sports_soccer_rounded, color: AppColors.gold),
              const SizedBox(width: 10),
              Text(tr('Schalke 04 vs. Bayern'), style: AppText.label2.copyWith(color: Colors.white)),
            ]),
            const SizedBox(height: 4),
            Text(tr('Sat, Apr 5 · 15:30 · Only on gameday'), style: AppText.body3.copyWith(color: Colors.white70)),
          ]),
        ),
        const SizedBox(height: 20),
        for (final s in const [
          ('Double Points at the Fanshop', 'On all matchday purchases', Icons.shopping_bag_rounded),
          ('Free Bratwurst combo', 'With any Veltins order', Icons.lunch_dining_rounded),
          ('Scarf 2-for-1', 'At the stadium store', Icons.style_rounded),
          ('3× spin rewards', 'Extra Daily Spin on gameday', Icons.casino_rounded),
        ])
          Padding(
            padding: const EdgeInsets.only(bottom: 10),
            child: SurfaceCard(
              child: Row(children: [
                Container(width: 44, height: 44, decoration: BoxDecoration(color: AppColors.brandLightest, borderRadius: BorderRadius.circular(12)), child: Icon(s.$3, color: AppColors.brandPrimary)),
                const SizedBox(width: 12),
                Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  Text(s.$1, style: AppText.body2.copyWith(color: AppColors.textDarker)),
                  const SizedBox(height: 2),
                  Text(s.$2, style: AppText.body3Regular),
                ])),
                Pill(gradient: const LinearGradient(colors: AppColors.goldGradient), child: Text(tr('Today'), style: AppText.caption1.copyWith(color: AppColors.brandDarkest))),
              ]),
            ),
          ),
      ],
    );
  }
}
