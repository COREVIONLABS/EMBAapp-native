import 'package:flutter/material.dart';
import '../theme/app_theme.dart';
import '../widgets/app_widgets.dart';
import '../widgets/sub_scaffold.dart';
import 'upgrade_plan_screen.dart';
import '../l10n/strings.dart';

/// Fan membership plans — final subscription concept: Free Fan / Fan Member /
/// Super Fan (+ optional Ultra). Super Fan is sold on priority & access, not
/// on a points boost; every paid tier "pays for itself" in savings.
class SubscriptionScreen extends StatelessWidget {
  const SubscriptionScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return SubScaffold(
      title: tr('Membership Plans'),
      children: [
        Text(tr('Every membership pays for itself — Fan Member gets €6+ back a month, Super Fan €14+.'),
            style: AppText.body2.copyWith(color: AppColors.textNormal, height: 1.5)),
        const SizedBox(height: 16),
        const _PlanCard(
          name: 'Free Fan',
          price: '€0',
          job: "I'm in",
          current: true,
          perks: [
            'Full app access & club news',
            'Daily games & 1 free spin',
            'Earn Fan Points · 100 pts = €1',
            'Public raffles & supporter streak',
          ],
        ),
        const SizedBox(height: 12),
        const _PlanCard(
          name: 'Fan Member',
          price: '€4.50',
          job: 'I save',
          highlight: true,
          badge: 'Most popular',
          perks: [
            'Guaranteed €6+ back every month',
            '24h ticket presale + discounts',
            'Sponsor vouchers & offers',
            '+1 VIP raffle ticket / month',
            'Streak protection · 2 spins · +50% points',
          ],
        ),
        const SizedBox(height: 12),
        const _PlanCard(
          name: 'Super Fan',
          price: '€9.00',
          job: "I'm first in line",
          premium: true,
          badge: 'Priority',
          perks: [
            'Priority access to top matches (48–72h)',
            'Best seats first + matchday upgrades',
            'Monthly exclusive FOMO drop',
            'Superfan Elite badge + name on the big screen',
            'Guaranteed €14+ back · ad-free · +3 VIP raffles',
          ],
        ),
        const SizedBox(height: 12),
        const _UltraRow(),
        const SizedBox(height: 12),
        Row(children: [
          Icon(Icons.lock_outline_rounded, size: 14, color: AppColors.textLight),
          const SizedBox(width: 6),
          Expanded(child: Text(tr('Points are never cashed out — they unlock discounts, access and sponsor rewards.'),
              style: AppText.caption1.copyWith(color: AppColors.textLight))),
        ]),
      ],
    );
  }
}

class _PlanCard extends StatelessWidget {
  final String name;
  final String price;
  final String job;
  final bool highlight;
  final bool premium;
  final bool current;
  final String? badge;
  final List<String> perks;
  const _PlanCard({
    required this.name,
    required this.price,
    required this.job,
    this.highlight = false,
    this.premium = false,
    this.current = false,
    this.badge,
    required this.perks,
  });

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
        border: highlight
            ? null
            : Border.all(color: premium ? AppColors.gold : AppColors.borderLightest, width: premium ? 1.5 : 1),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  Text(name, style: AppText.label1.copyWith(color: onColor)),
                  Text('“${tr(job)}”', style: AppText.body3.copyWith(color: highlight ? Colors.white70 : AppColors.textLight)),
                ]),
              ),
              if (current)
                Pill(color: highlight ? Colors.white24 : AppColors.brandLightest, child: Text(tr('Current Plan'), style: AppText.caption1.copyWith(color: highlight ? Colors.white : AppColors.brandPrimary)))
              else if (badge != null)
                Pill(
                  gradient: LinearGradient(colors: premium ? AppColors.goldGradient : (highlight ? AppColors.goldGradient : AppColors.pointsGradient)),
                  child: Text(tr(badge!), style: AppText.caption1.copyWith(color: premium || highlight ? AppColors.brandDarkest : Colors.white, fontWeight: FontWeight.w700)),
                ),
            ],
          ),
          const SizedBox(height: 10),
          Row(
            crossAxisAlignment: CrossAxisAlignment.baseline,
            textBaseline: TextBaseline.alphabetic,
            children: [
              Text(price, style: AppText.h2.copyWith(color: onColor)),
              const SizedBox(width: 4),
              Text(tr('/ month'), style: AppText.body2.copyWith(color: highlight ? Colors.white70 : AppColors.textLight)),
            ],
          ),
          const SizedBox(height: 16),
          ...perks.asMap().entries.map((e) => Padding(
                padding: const EdgeInsets.only(bottom: 10),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Icon(e.key == 0 && premium ? Icons.bolt_rounded : Icons.check_circle_rounded,
                        size: 18, color: highlight ? AppColors.gold : (premium && e.key == 0 ? AppColors.gold : AppColors.brandPrimary)),
                    const SizedBox(width: 10),
                    Expanded(child: Text(tr(e.value), style: AppText.body2.copyWith(color: highlight ? Colors.white : AppColors.textNormal))),
                  ],
                ),
              )),
          if (!current) ...[
            const SizedBox(height: 8),
            Builder(
              builder: (context) => PrimaryButton(
                '${tr('Upgrade to')} $name',
                color: premium ? AppColors.gold : (highlight ? AppColors.gold : AppColors.brandPrimary),
                textColor: premium || highlight ? AppColors.brandDarkest : Colors.white,
                onTap: () => Navigator.of(context).push(
                  MaterialPageRoute(builder: (_) => UpgradePlanScreen(plan: name, price: price)),
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}

/// Optional whale tier — configurable per club.
class _UltraRow extends StatelessWidget {
  const _UltraRow();
  @override
  Widget build(BuildContext context) {
    return SurfaceCard(
      child: Row(children: [
        Container(
          width: 40, height: 40,
          decoration: BoxDecoration(color: AppColors.brandDarkest, borderRadius: BorderRadius.circular(11)),
          child: const Icon(Icons.diamond_rounded, color: AppColors.gold, size: 20),
        ),
        const SizedBox(width: 12),
        Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Row(children: [
            Text(tr('Ultra'), style: AppText.body2.copyWith(color: AppColors.textDarker)),
            const SizedBox(width: 6),
            Pill(color: AppColors.brandLightest, child: Text('~€19', style: AppText.caption1.copyWith(color: AppColors.brandPrimary, fontWeight: FontWeight.w700))),
          ]),
          Text(tr('The maximum — exclusive drops, top priority, concierge'), style: AppText.body3Regular),
        ])),
        Icon(Icons.chevron_right_rounded, color: AppColors.textLight),
      ]),
    );
  }
}
