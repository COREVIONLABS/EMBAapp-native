import 'package:flutter/material.dart';
import '../theme/app_theme.dart';
import '../widgets/app_widgets.dart';
import '../widgets/sub_scaffold.dart';
import 'fanplus_screen.dart';
import '../model/fan_model.dart';
import '../l10n/strings.dart';

/// Upgrade Plan checkout (Figma 404:10693 / 404:11074).
class UpgradePlanScreen extends StatelessWidget {
  final String plan;
  final String price;
  final String period;
  const UpgradePlanScreen({super.key, this.plan = 'Super Fan', this.price = '€9.99', this.period = '/ month'});

  // Benefits + badge for the actually-chosen tier (not always Super Fan).
  String _badge(String plan) => switch (plan) {
        'Fan Member' => 'Most popular',
        _ => 'Best value',
      };

  List<String> _benefits(String plan) => switch (plan) {
        'Fan Member' => const [
            '3 free tombola lots every month',
            '+500 bonus points every month',
            'Double Fan Points on every purchase',
            '24h ticket presale + member discounts',
          ],
        _ => const [
            '8 free tombola lots every month',
            '+1,200 bonus points every month',
            'Priority access to top matches (48–72h)',
            'Best seats first + matchday upgrades',
          ],
      };

  @override
  Widget build(BuildContext context) {
    return SubScaffold(
      title: tr('Upgrade Plan'),
      bottomBar: Column(mainAxisSize: MainAxisSize.min, children: [
        PrimaryButton(tr('Start 7-day free trial'), onTap: () {
          // Reflect the new tier across the app (Home chip + Fan+ hub).
          tierNotifier.value = plan;
          showModalBottomSheet(
            context: context,
            backgroundColor: Colors.transparent,
            builder: (_) => _SuccessSheet(plan: plan),
          );
        }),
        const SizedBox(height: 8),
        Text('${tr('7 days free, then')} $price $period · ${tr('cancel anytime')}',
            textAlign: TextAlign.center, style: AppText.caption1.copyWith(color: AppColors.textLight)),
      ]),
      children: [
        Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            gradient: const LinearGradient(colors: AppColors.pointsGradient),
            borderRadius: BorderRadius.circular(AppRadii.card),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text('${tr(plan)} ${tr('plan')}', style: AppText.label1.copyWith(color: Colors.white)),
                  Pill(
                    gradient: const LinearGradient(colors: AppColors.goldGradient),
                    child: Text(tr(_badge(plan)), style: AppText.caption1.copyWith(color: AppColors.brandDarkest)),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Row(
                crossAxisAlignment: CrossAxisAlignment.baseline,
                textBaseline: TextBaseline.alphabetic,
                children: [
                  Text(price, style: AppText.h1.copyWith(color: Colors.white)),
                  const SizedBox(width: 4),
                  Text(period, style: AppText.body2.copyWith(color: Colors.white70)),
                ],
              ),
            ],
          ),
        ),
        const SizedBox(height: 20),
        Text(tr("What's included"), style: AppText.label2),
        const SizedBox(height: 12),
        for (final b in _benefits(plan))
          Padding(
            padding: const EdgeInsets.only(bottom: 10),
            child: Row(
              children: [
                const Icon(Icons.check_circle_rounded, color: AppColors.brandPrimary, size: 20),
                const SizedBox(width: 12),
                Expanded(child: Text(tr(b), style: AppText.body1.copyWith(color: AppColors.textNormal, fontSize: 15))),
              ],
            ),
          ),
        const SizedBox(height: 12),
        Text(tr('Payment method'), style: AppText.label2),
        const SizedBox(height: 12),
        SurfaceCard(
          child: Row(
            children: [
              Icon(Icons.credit_card_rounded, color: AppColors.textNormal),
              const SizedBox(width: 12),
              Expanded(child: Text(tr('Visa •••• 4921'), style: AppText.body1.copyWith(color: AppColors.textDarker, fontSize: 15))),
              Text(tr('Change'), style: AppText.body2.copyWith(color: AppColors.brandPrimary, fontWeight: FontWeight.w700)),
            ],
          ),
        ),
      ],
    );
  }
}

class _SuccessSheet extends StatelessWidget {
  final String plan;
  const _SuccessSheet({required this.plan});
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(24, 28, 24, 32),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 72,
            height: 72,
            decoration: BoxDecoration(color: AppColors.successBg, shape: BoxShape.circle),
            child: const Icon(Icons.check_rounded, color: AppColors.success, size: 40),
          ),
          const SizedBox(height: 18),
          Text("${tr("You're a")} $plan!", style: AppText.h4),
          const SizedBox(height: 8),
          Text(tr('Your plan is active. Enjoy priority access and exclusive perks.'),
              textAlign: TextAlign.center, style: AppText.body1.copyWith(color: AppColors.textLight)),
          const SizedBox(height: 24),
          PrimaryButton(tr('Done'), onTap: () {
            Navigator.of(context).pop(); // close sheet
            Navigator.of(context).pushReplacement(
              MaterialPageRoute(builder: (_) => const FanPlusScreen(subscribed: true)),
            );
          }),
        ],
      ),
    );
  }
}
