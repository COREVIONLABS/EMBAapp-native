import 'package:flutter/material.dart';
import '../theme/app_theme.dart';
import '../model/fan_model.dart';
import '../widgets/app_widgets.dart';
import '../widgets/sub_scaffold.dart';
import 'raffles_screen.dart';
import '../l10n/strings.dart';

/// Experience Detail — a money-can't-buy experience presented as a **tombola
/// prize**, not a direct point purchase. Points only ever become vouchers or
/// tombola lots, so the way to get an experience is to win it: the CTA enters
/// the monthly tombola.
class ExperienceDetailScreen extends StatelessWidget {
  final FanExperience exp;
  const ExperienceDetailScreen({super.key, required this.exp});
  @override
  Widget build(BuildContext context) {
    return SubScaffold(
      title: '',
      bottomBar: PrimaryButton(tr('Enter tombola to win'), onTap: () {
        Navigator.of(context).push(MaterialPageRoute(builder: (_) => const RafflesScreen()));
      }),
      children: [
        Container(
          height: 220,
          decoration: BoxDecoration(gradient: const LinearGradient(colors: AppColors.pointsGradient), borderRadius: BorderRadius.circular(AppRadii.card)),
          child: const Center(child: Icon(Icons.stadium_rounded, size: 96, color: Colors.white24)),
        ),
        const SizedBox(height: 20),
        Text(tr(exp.title), style: AppText.h4),
        const SizedBox(height: 8),
        Row(children: [
          Icon(Icons.calendar_today_rounded, size: 16, color: AppColors.textLight),
          const SizedBox(width: 6),
          Text('${exp.date} · ${exp.venue}', style: AppText.body2.copyWith(color: AppColors.textLight)),
        ]),
        const SizedBox(height: 12),
        Pill(gradient: const LinearGradient(colors: AppColors.goldGradient), child: Row(mainAxisSize: MainAxisSize.min, children: [
          const Icon(Icons.emoji_events_rounded, size: 12, color: AppColors.brandDarkest),
          const SizedBox(width: 4),
          Text(tr('Tombola prize'), style: AppText.caption1.copyWith(color: AppColors.brandDarkest, fontWeight: FontWeight.w800)),
        ])),
        const SizedBox(height: 20),
        Text(tr('About this experience'), style: AppText.label2),
        const SizedBox(height: 6),
        Text(tr('An exclusive, money-can\'t-buy FC Schalke 04 experience. You can\'t buy it with points — enter the monthly tombola with lots for your chance to win it.'),
            style: AppText.body1.copyWith(color: AppColors.textNormal, height: 1.6, fontSize: 14)),
      ],
    );
  }
}
