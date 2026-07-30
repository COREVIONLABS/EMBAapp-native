import 'package:flutter/material.dart';
import '../theme/app_theme.dart';
import '../widgets/app_widgets.dart';
import '../widgets/sub_scaffold.dart';
import '../l10n/strings.dart';

/// Membership Plan (Figma 2162:5498).
class MembershipPlanScreen extends StatelessWidget {
  const MembershipPlanScreen({super.key});
  @override
  Widget build(BuildContext context) {
    return SubScaffold(
      title: tr('Membership Plan'),
      bottomBar: SecondaryButton(tr('Manage Subscription')),
      children: [
        Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(gradient: const LinearGradient(colors: AppColors.pointsGradient), borderRadius: BorderRadius.circular(AppRadii.card)),
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Row(children: [
              Text(tr('Fan+ Premium'), style: AppText.label1.copyWith(color: Colors.white)),
              const Spacer(),
              Pill(gradient: const LinearGradient(colors: AppColors.goldGradient), child: Text(tr('Active'), style: AppText.caption1.copyWith(color: AppColors.brandDarkest))),
            ]),
            const SizedBox(height: 8),
            Text(tr('€9.00 / month'), style: AppText.h4.copyWith(color: Colors.white)),
            const SizedBox(height: 6),
            Text(tr('Next billing: 15 May 2026'), style: AppText.body3.copyWith(color: Colors.white70)),
          ]),
        ),
        const SizedBox(height: 16),
        SurfaceCard(
          color: AppColors.brandLightest,
          child: Row(children: [
            const Icon(Icons.savings_rounded, color: AppColors.gold),
            const SizedBox(width: 12),
            Expanded(child: Text(tr('You have earned back €11.20 in points this month — your membership pays for itself.'),
                style: AppText.body2.copyWith(color: AppColors.brandDarkest))),
          ]),
        ),
        const SizedBox(height: 20),
        Text(tr('Your benefits'), style: AppText.label2),
        const SizedBox(height: 12),
        for (final b in const ['3× Fan Points (max boost)', "Money-can't-buy experiences", 'VIP draws & premium raffles', 'Branded VISA fan card (from Season 2)', 'Exclusive content & clips'])
          Padding(padding: const EdgeInsets.only(bottom: 10), child: Row(children: [
            const Icon(Icons.check_circle_rounded, color: AppColors.brandPrimary, size: 20),
            const SizedBox(width: 12),
            Expanded(child: Text(tr(b), style: AppText.body1.copyWith(color: AppColors.textNormal, fontSize: 14.5))),
          ])),
      ],
    );
  }
}
