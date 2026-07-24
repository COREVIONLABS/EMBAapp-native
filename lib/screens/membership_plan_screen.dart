import 'package:flutter/material.dart';
import '../theme/app_theme.dart';
import '../widgets/app_widgets.dart';
import '../widgets/sub_scaffold.dart';

/// Membership Plan (Figma 2162:5498).
class MembershipPlanScreen extends StatelessWidget {
  const MembershipPlanScreen({super.key});
  @override
  Widget build(BuildContext context) {
    return SubScaffold(
      title: 'Membership Plan',
      bottomBar: SecondaryButton('Manage Subscription'),
      children: [
        Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(gradient: const LinearGradient(colors: AppColors.pointsGradient), borderRadius: BorderRadius.circular(AppRadii.card)),
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Row(children: [
              Text('Fan+ Superfan', style: AppText.label1.copyWith(color: Colors.white)),
              const Spacer(),
              Pill(gradient: const LinearGradient(colors: AppColors.goldGradient), child: Text('Active', style: AppText.caption1.copyWith(color: AppColors.brandDarkest))),
            ]),
            const SizedBox(height: 8),
            Text('€9.99 / month', style: AppText.h4.copyWith(color: Colors.white)),
            const SizedBox(height: 6),
            Text('Next billing: 15 May 2026', style: AppText.body3.copyWith(color: Colors.white70)),
          ]),
        ),
        const SizedBox(height: 20),
        Text('Your benefits', style: AppText.label2),
        const SizedBox(height: 12),
        for (final b in const ['3× Fan Points on everything', 'Meet & greet raffles', 'Free matchday scratch cards', 'Members-only experiences', 'Priority ticket access'])
          Padding(padding: const EdgeInsets.only(bottom: 10), child: Row(children: [
            const Icon(Icons.check_circle_rounded, color: AppColors.brandPrimary, size: 20),
            const SizedBox(width: 12),
            Expanded(child: Text(b, style: AppText.body1.copyWith(color: AppColors.textNormal, fontSize: 14.5))),
          ])),
      ],
    );
  }
}
