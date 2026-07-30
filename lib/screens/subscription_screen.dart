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
      children: const [
        _PlanCard(
          name: 'Supporter',
          price: '€4.99',
          highlight: false,
          perks: ['2× Fan Points on purchases', 'Priority ticket window', 'Exclusive newsletter'],
        ),
        SizedBox(height: 12),
        _PlanCard(
          name: 'Superfan',
          price: '€9.99',
          highlight: true,
          perks: [
            '3× Fan Points on everything',
            'Meet & greet raffles',
            'Free matchday scratch cards',
            'Members-only experiences',
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
  final List<String> perks;
  const _PlanCard({required this.name, required this.price, required this.highlight, required this.perks});

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
                  child: Text(tr('POPULAR'), style: AppText.caption1.copyWith(color: AppColors.brandDarkest)),
                ),
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
                      child: Text(p,
                          style: AppText.body2.copyWith(color: highlight ? Colors.white : AppColors.textNormal)),
                    ),
                  ],
                ),
              )),
          const SizedBox(height: 8),
          Builder(
            builder: (context) => PrimaryButton(
              'Upgrade to $name',
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
