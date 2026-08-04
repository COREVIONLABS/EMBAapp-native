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
  const UpgradePlanScreen({super.key, this.plan = 'Super Fan', this.price = '€9.00'});

  // Benefits + badge for the actually-chosen tier (not always Super Fan).
  String _badge(String plan) => switch (plan) {
        'Fan Member' => 'POPULAR',
        'Ultra' => 'MAXIMUM',
        _ => 'BEST VALUE',
      };

  List<String> _benefits(String plan) => switch (plan) {
        'Fan Member' => const [
            'Guaranteed €6+ back every month',
            '24h ticket presale + member discounts',
            'Sponsor vouchers & offers',
            '8 partner perks included',
          ],
        'Ultra' => const [
            'Everything in Super Fan',
            'Top priority + personal concierge',
            'Exclusive drops & money-can\'t-buy days',
            '20 partner perks included',
          ],
        _ => const [
            'Priority access to top matches (48–72h)',
            'Best seats first + matchday upgrades',
            'Monthly exclusive FOMO drop',
            'Guaranteed €14+ back every month',
            '12 partner perks included',
          ],
      };

  @override
  Widget build(BuildContext context) {
    return SubScaffold(
      title: tr('Upgrade Plan'),
      bottomBar: PrimaryButton('Confirm & Pay $price', onTap: () {
        // Reflect the new tier across the app (Home chip + Fan+ hub).
        tierNotifier.value = plan;
        showModalBottomSheet(
          context: context,
          backgroundColor: Colors.transparent,
          builder: (_) => _SuccessSheet(plan: plan),
        );
      }),
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
                  Text('$plan plan', style: AppText.label1.copyWith(color: Colors.white)),
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
                  Text(tr('/ month'), style: AppText.body2.copyWith(color: Colors.white70)),
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
                Expanded(child: Text(b, style: AppText.body1.copyWith(color: AppColors.textNormal, fontSize: 15))),
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
