import 'package:flutter/material.dart';
import '../theme/app_theme.dart';
import '../widgets/app_widgets.dart';
import '../widgets/sub_scaffold.dart';
import 'upgrade_plan_screen.dart';
import '../l10n/strings.dart';

/// Subscription / Fan+ plans (Figma 2145:12518, 8275).
class SubscriptionScreen extends StatelessWidget {
  const SubscriptionScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return SubScaffold(
      title: tr('Fan+ Plans'),
      children: [
        Text(tr('Every membership pays for itself — you get at least 100% of your fee back in Fan Points.'),
            style: AppText.body2.copyWith(color: AppColors.textNormal, height: 1.5)),
        const SizedBox(height: 16),
        const _PlanCard(
          name: 'Free',
          price: '€0',
          highlight: false,
          current: true,
          perks: ['Daily games & challenges', 'Fan Points & partner offers', 'Club news & matchday info'],
        ),
        const SizedBox(height: 12),
        const _PlanCard(
          name: 'Fan+',
          price: '€4.50',
          highlight: false,
          perks: [
            '2× Fan Points boost',
            'Exclusive content & clips',
            'Bigger raffles & better rewards',
            '100% of your fee back in points',
          ],
        ),
        const SizedBox(height: 12),
        const _PlanCard(
          name: 'Fan+ Premium',
          price: '€9.00',
          highlight: true,
          perks: [
            'Everything in Fan+',
            '3× Fan Points (max boost)',
            "Money-can't-buy experiences",
            'VIP draws & premium raffles',
            'Branded VISA fan card & wallet',
          ],
        ),
      ],
    );
  }
}

class _PlanCard extends StatelessWidget {
  final String name;
  final String price;
  final bool highlight;
  final bool current;
  final List<String> perks;
  const _PlanCard({required this.name, required this.price, required this.highlight, this.current = false, required this.perks});

  @override
  Widget build(BuildContext context) {
    final onColor = highlight ? Colors.white : AppColors.textDarker;
    return Container(
      padding: const EdgeInsets.all(20),
      clipBehavior: Clip.antiAlias,
      decoration: BoxDecoration(
        gradient: highlight ? const LinearGradient(colors: AppColors.pointsGradient) : null,
        color: highlight ? null : AppColors.surface,
        borderRadius: BorderRadius.circular(AppRadii.card),
        border: highlight ? null : Border.all(color: AppColors.borderLightest),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(name, style: AppText.label1.copyWith(color: onColor)),
              if (highlight)
                Pill(
                  gradient: const LinearGradient(colors: AppColors.goldGradient),
                  child: Text(tr('BEST VALUE'), style: AppText.caption1.copyWith(color: AppColors.brandDarkest)),
                )
              else if (current)
                Pill(color: AppColors.brandLightest, child: Text(tr('Current Plan'), style: AppText.caption1.copyWith(color: AppColors.brandPrimary))),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            crossAxisAlignment: CrossAxisAlignment.baseline,
            textBaseline: TextBaseline.alphabetic,
            children: [
              Text(price, style: AppText.h2.copyWith(color: onColor)),
              const SizedBox(width: 4),
              Text(tr('/ month'),
                  style: AppText.body2.copyWith(color: highlight ? Colors.white70 : AppColors.textLight)),
            ],
          ),
          const SizedBox(height: 16),
          ...perks.map((p) => Padding(
                padding: const EdgeInsets.only(bottom: 10),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Icon(Icons.check_circle_rounded,
                        size: 18, color: highlight ? AppColors.gold : AppColors.brandPrimary),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Text(tr(p),
                          style: AppText.body2.copyWith(color: highlight ? Colors.white : AppColors.textNormal)),
                    ),
                  ],
                ),
              )),
          const SizedBox(height: 8),
          if (!current)
            Builder(
              builder: (context) => PrimaryButton(
                '${tr('Upgrade to')} $name',
                color: highlight ? AppColors.gold : AppColors.brandPrimary,
                textColor: highlight ? AppColors.brandDarkest : Colors.white,
                onTap: () => Navigator.of(context).push(
                  MaterialPageRoute(builder: (_) => UpgradePlanScreen(plan: name, price: price)),
                ),
              ),
            ),
        ],
      ),
    );
  }
}
