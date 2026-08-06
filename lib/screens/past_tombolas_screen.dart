import 'package:flutter/material.dart';
import '../theme/app_theme.dart';
import '../widgets/app_widgets.dart';
import '../widgets/sub_scaffold.dart';
import '../model/fan_model.dart';
import '../l10n/strings.dart';

/// "Past tombolas" — the results of previous monthly draws: the prize, the
/// winner and how many fans entered. Builds trust that the draws are real and
/// that winners actually get their prizes.
class PastTombolasScreen extends StatelessWidget {
  const PastTombolasScreen({super.key});

  // (month, prize, winner, city, entries, youEntered)
  static const _past = <(String, String, String, String, int, bool)>[
    ('July 2026', '2× VIP tickets — vs Bayern', 'Jonas K.', 'Gelsenkirchen', 1840, true),
    ('June 2026', 'Signed home shirt 25/26', 'Mia R.', 'Essen', 970, true),
    ('May 2026', 'The signed matchball', 'Tom B.', 'Bochum', 640, false),
    ('April 2026', 'Meet & Greet with the squad', 'Lena S.', 'Herne', 410, true),
    ('March 2026', 'Away-day travel package', 'David P.', 'Dortmund', 720, false),
  ];

  @override
  Widget build(BuildContext context) {
    return SubScaffold(
      title: tr('Past tombolas'),
      children: [
        Text(tr('Winners are drawn automatically at month-end and notified in the app.'), style: AppText.body3Regular),
        const SizedBox(height: 16),
        for (final t in _past) ...[
          _card(month: t.$1, prize: t.$2, winner: t.$3, city: t.$4, entries: t.$5, youEntered: t.$6),
          const SizedBox(height: 12),
        ],
      ],
    );
  }

  Widget _card({required String month, required String prize, required String winner, required String city, required int entries, required bool youEntered}) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(color: AppColors.surface, borderRadius: BorderRadius.circular(AppRadii.card), border: Border.all(color: AppColors.borderLightest)),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Row(children: [
          Pill(color: AppColors.surfaceMinimal, child: Text(tr(month), style: AppText.caption1.copyWith(color: AppColors.textNormal, fontWeight: FontWeight.w700))),
          const Spacer(),
          if (youEntered)
            Pill(color: AppColors.brandLightest, child: Row(mainAxisSize: MainAxisSize.min, children: [
              Icon(Icons.local_activity_rounded, size: 12, color: AppColors.brandPrimary),
              const SizedBox(width: 4),
              Text(tr('You entered'), style: AppText.caption1.copyWith(color: AppColors.brandPrimary, fontWeight: FontWeight.w800)),
            ])),
        ]),
        const SizedBox(height: 12),
        Text(tr(prize), style: AppText.body1.copyWith(color: AppColors.textDarker, fontWeight: FontWeight.w700, fontSize: 16)),
        const SizedBox(height: 12),
        Row(children: [
          Container(width: 40, height: 40, decoration: BoxDecoration(color: AppColors.gold.withValues(alpha: 0.16), borderRadius: BorderRadius.circular(11)), child: const Icon(Icons.emoji_events_rounded, color: AppColors.gold, size: 20)),
          const SizedBox(width: 12),
          Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text(tr('Winner'), style: AppText.caption1.copyWith(color: AppColors.textLight, fontWeight: FontWeight.w700)),
            const SizedBox(height: 1),
            Text('$winner · ${tr(city)}', style: AppText.body2.copyWith(color: AppColors.textDarker, fontWeight: FontWeight.w700)),
          ])),
          Column(crossAxisAlignment: CrossAxisAlignment.end, children: [
            Text(FanModel.fmtPublic(entries), style: AppText.body2.copyWith(color: AppColors.textDarker, fontWeight: FontWeight.w800)),
            Text(tr('entries'), style: AppText.caption1.copyWith(color: AppColors.textLight)),
          ]),
        ]),
      ]),
    );
  }
}
