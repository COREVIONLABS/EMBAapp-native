import 'package:flutter/material.dart';
import '../theme/app_theme.dart';
import '../widgets/app_widgets.dart';
import '../widgets/sub_scaffold.dart';
import 'subscription_screen.dart';
import '../l10n/strings.dart';

/// Monthly FOMO Drop — a single, time-limited exclusive item that only
/// Super Fan members can claim. Non-members see the drop but hit a paywall,
/// which is the whole point: scarcity + membership as the key.
class FomoDropScreen extends StatelessWidget {
  final bool subscribed;
  const FomoDropScreen({super.key, this.subscribed = false});

  @override
  Widget build(BuildContext context) {
    return SubScaffold(
      title: tr('This Month\'s Drop'),
      bottomBar: subscribed
          ? PrimaryButton(tr('Claim your drop'), color: AppColors.gold, textColor: AppColors.brandDarkest)
          : PrimaryButton(tr('Unlock with Super Fan'),
              onTap: () => Navigator.of(context).push(MaterialPageRoute(builder: (_) => const SubscriptionScreen()))),
      children: [
        // Hero drop card
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(22),
          decoration: BoxDecoration(
            gradient: const LinearGradient(colors: AppColors.pointsGradient),
            borderRadius: BorderRadius.circular(AppRadii.card),
          ),
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Row(children: [
              Pill(gradient: const LinearGradient(colors: AppColors.goldGradient), child: Text(tr('Super Fan only'), style: AppText.caption1.copyWith(color: AppColors.brandDarkest, fontWeight: FontWeight.w700))),
              const Spacer(),
              Pill(color: Colors.white24, child: Text(tr('Only 50 made'), style: AppText.caption1.copyWith(color: Colors.white))),
            ]),
            const SizedBox(height: 16),
            const Icon(Icons.local_fire_department_rounded, color: AppColors.gold, size: 40),
            const SizedBox(height: 10),
            Text(tr('Signed Retro Shirt — April Drop'), style: AppText.h4.copyWith(color: Colors.white)),
            const SizedBox(height: 6),
            Text(tr('A limited signed 1997 UEFA Cup retro shirt — dropped once, never restocked.'),
                style: AppText.body3.copyWith(color: Colors.white70)),
          ]),
        ),
        const SizedBox(height: 16),
        // Countdown
        Text(tr('Drop closes in'), style: AppText.label2),
        const SizedBox(height: 12),
        Row(children: const [
          Expanded(child: _CountBox(value: '02', unit: 'Days')),
          SizedBox(width: 10),
          Expanded(child: _CountBox(value: '14', unit: 'Hrs')),
          SizedBox(width: 10),
          Expanded(child: _CountBox(value: '38', unit: 'Min')),
          SizedBox(width: 10),
          Expanded(child: _CountBox(value: '05', unit: 'Sec')),
        ]),
        const SizedBox(height: 20),
        if (!subscribed)
          SurfaceCard(
            color: AppColors.brandLightest,
            child: Row(children: [
              const Icon(Icons.lock_rounded, color: AppColors.brandPrimary),
              const SizedBox(width: 12),
              Expanded(child: Text(tr('This drop is reserved for Super Fan members. One exclusive drop lands every month.'),
                  style: AppText.body2.copyWith(color: AppColors.brandDarkest))),
            ]),
          )
        else
          SurfaceCard(
            color: AppColors.successBg,
            child: Row(children: [
              const Icon(Icons.check_circle_rounded, color: AppColors.success),
              const SizedBox(width: 12),
              Expanded(child: Text(tr('You\'re eligible. Claim before the timer runs out — first come, first served.'),
                  style: AppText.body2.copyWith(color: AppColors.textDarker))),
            ]),
          ),
        const SizedBox(height: 20),
        Text(tr('Past drops'), style: AppText.label2),
        const SizedBox(height: 12),
        for (final d in const [
          ('March', 'Away-day travel mug', 'Claimed by 50 fans'),
          ('February', 'Matchday scarf — numbered', 'Sold out in 3h'),
          ('January', 'Training-worn gloves', 'Sold out in 1h'),
        ])
          Padding(
            padding: const EdgeInsets.only(bottom: 10),
            child: SurfaceCard(
              child: Row(children: [
                Container(
                  width: 40, height: 40,
                  decoration: BoxDecoration(color: AppColors.surfaceMinimal, borderRadius: BorderRadius.circular(11)),
                  child: const Icon(Icons.history_rounded, color: AppColors.textNormal, size: 20),
                ),
                const SizedBox(width: 12),
                Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  Text(tr(d.$2), style: AppText.body2.copyWith(color: AppColors.textDarker)),
                  Text('${tr(d.$1)} · ${tr(d.$3)}', style: AppText.body3Regular),
                ])),
                const Icon(Icons.lock_rounded, color: AppColors.textLight, size: 18),
              ]),
            ),
          ),
      ],
    );
  }
}

class _CountBox extends StatelessWidget {
  final String value;
  final String unit;
  const _CountBox({required this.value, required this.unit});
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 14),
      decoration: BoxDecoration(color: AppColors.brandDarkest, borderRadius: BorderRadius.circular(AppRadii.tile)),
      child: Column(children: [
        Text(value, style: AppText.h4.copyWith(color: Colors.white)),
        const SizedBox(height: 2),
        Text(tr(unit), style: AppText.caption1.copyWith(color: Colors.white70)),
      ]),
    );
  }
}
