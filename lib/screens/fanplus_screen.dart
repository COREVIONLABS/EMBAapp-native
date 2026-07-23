import 'package:flutter/material.dart';
import '../theme/app_theme.dart';
import '../widgets/app_widgets.dart';
import '../widgets/tab_scaffold.dart';
import 'upgrade_plan_screen.dart';

/// Fan+ tab — subscription tiers (Figma 364:1415 / 365:1414, 404:9927 …).
class FanPlusScreen extends StatelessWidget {
  const FanPlusScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return TabScaffold(
      children: [
        const TabHeader('Fan+', subtitle: 'Unlock more as a Superfan'),
        const SizedBox(height: 20),
        const Padding(padding: EdgeInsets.symmetric(horizontal: 20), child: _CurrentPlan()),
        const SizedBox(height: 24),
        const Padding(
          padding: EdgeInsets.symmetric(horizontal: 20),
          child: Text('Choose your plan', style: AppText.label1),
        ),
        const SizedBox(height: 12),
        const Padding(
          padding: EdgeInsets.symmetric(horizontal: 20),
          child: _PlanCard(
            name: 'Supporter',
            price: '€4.99',
            highlight: false,
            perks: ['2× Fan Points on purchases', 'Priority ticket window', 'Exclusive newsletter'],
          ),
        ),
        const SizedBox(height: 12),
        const Padding(
          padding: EdgeInsets.symmetric(horizontal: 20),
          child: _PlanCard(
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
        ),
      ],
    );
  }
}

class _CurrentPlan extends StatelessWidget {
  const _CurrentPlan();
  @override
  Widget build(BuildContext context) {
    return SurfaceCard(
      padding: const EdgeInsets.all(16),
      child: Row(
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(color: AppColors.surfaceMinimal, borderRadius: BorderRadius.circular(12)),
            child: const Icon(Icons.person_outline_rounded, color: AppColors.textNormal),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Current plan', style: AppText.body3Regular),
                const SizedBox(height: 2),
                Text('Free', style: AppText.label2.copyWith(color: AppColors.textDarker)),
              ],
            ),
          ),
          Pill(
            color: AppColors.surfaceMinimal,
            child: Text('Active', style: AppText.caption1.copyWith(color: AppColors.textNormal)),
          ),
        ],
      ),
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
                  child: Text('POPULAR', style: AppText.caption1.copyWith(color: AppColors.textDarker)),
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
              Text('/ month',
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
                          style: AppText.body2
                              .copyWith(color: highlight ? Colors.white : AppColors.textNormal)),
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
