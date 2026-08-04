import 'package:flutter/material.dart';
import '../theme/app_theme.dart';
import '../widgets/app_widgets.dart';
import '../widgets/sub_scaffold.dart';
import '../model/fan_model.dart';
import 'upgrade_plan_screen.dart';
import 'benefits_screen.dart';
import '../l10n/strings.dart';

/// Membership plans — tabbed upgrade screen: pick a tier tab, see one rich card
/// (price + headline benefits + partner perks), then a "show all benefits" link
/// and a "become a …" CTA. EMBA/S04 tiers.
class SubscriptionScreen extends StatefulWidget {
  const SubscriptionScreen({super.key});
  @override
  State<SubscriptionScreen> createState() => _SubscriptionScreenState();
}

class _Tier {
  final String name;
  final String tabLabel;
  final String price;
  final String tagline;
  final List<Color> gradient;
  final List<(IconData, String)> features;
  final int partners;
  final int moreBenefits;
  const _Tier(this.name, this.tabLabel, this.price, this.tagline, this.gradient, this.features, this.partners, this.moreBenefits);
  bool get isFree => partners == 0;
}

class _SubscriptionScreenState extends State<SubscriptionScreen> {
  // Free Fan is the user's current tier; land on the first paid upgrade.
  int _tab = 1;

  static const _tiers = [
    _Tier('Free Fan', 'Free', '€0', 'Free for every fan', [Color(0xFF475467), Color(0xFF1D2939)], [
      (Icons.check_circle_rounded, 'Full app access & club news'),
      (Icons.casino_rounded, 'Daily games & 1 free spin'),
      (Icons.savings_rounded, 'Earn Fan Points · 100 pts = €1'),
    ], 0, 0),
    _Tier('Fan Member', 'Member', '€4.50', 'More points, more perks', AppColors.pointsGradient, [
      (Icons.bolt_rounded, 'Double Fan Points on every purchase'),
      (Icons.confirmation_number_rounded, '24h ticket presale + discounts'),
      (Icons.card_giftcard_rounded, 'Sponsor vouchers & offers'),
    ], 8, 12),
    _Tier('Super Fan', 'Super', '€9.00', 'First in line', [Color(0xFF0A2A5E), Color(0xFF000D22)], [
      (Icons.bolt_rounded, 'Priority access to top matches (48–72h)'),
      (Icons.event_seat_rounded, 'Best seats first + matchday upgrades'),
      (Icons.local_fire_department_rounded, 'Monthly exclusive FOMO drop'),
    ], 12, 24),
    _Tier('Ultra', 'Ultra', '€19.00', 'The maximum', [Color(0xFF2A1A3E), Color(0xFF0B0616)], [
      (Icons.diamond_rounded, 'Everything in Super Fan'),
      (Icons.support_agent_rounded, 'Top priority + personal concierge'),
      (Icons.workspace_premium_rounded, 'Exclusive drops & money-can’t-buy days'),
    ], 20, 35),
  ];

  @override
  Widget build(BuildContext context) {
    final t = _tiers[_tab];
    return SubScaffold(
      title: tr('Membership Plans'),
      bottomBar: t.isFree
          ? Container(
              padding: const EdgeInsets.symmetric(vertical: 16),
              alignment: Alignment.center,
              decoration: BoxDecoration(color: AppColors.surfaceMinimal, borderRadius: BorderRadius.circular(AppRadii.pill)),
              child: Row(mainAxisSize: MainAxisSize.min, children: [
                Icon(Icons.check_circle_rounded, size: 18, color: AppColors.brandPrimary),
                const SizedBox(width: 8),
                Text(tr('Your current plan'), style: AppText.label2.copyWith(color: AppColors.textNormal)),
              ]),
            )
          : Column(mainAxisSize: MainAxisSize.min, children: [
              SecondaryButton('${tr('Show all')} ${t.moreBenefits}+ ${tr('benefits')}',
                  onTap: () => Navigator.of(context).push(
                      MaterialPageRoute(builder: (_) => AllBenefitsScreen(tierName: t.name)))),
              const SizedBox(height: 10),
              PrimaryButton('${tr('Become a')} ${t.name}',
                  onTap: () => Navigator.of(context).push(
                      MaterialPageRoute(builder: (_) => UpgradePlanScreen(plan: t.name, price: t.price)))),
            ]),
      children: [
        // Tabs
        Container(
          padding: const EdgeInsets.all(4),
          decoration: BoxDecoration(color: AppColors.surfaceMinimal, borderRadius: BorderRadius.circular(AppRadii.pill)),
          child: Row(children: [
            for (var i = 0; i < _tiers.length; i++)
              Expanded(
                child: GestureDetector(
                  onTap: () => setState(() => _tab = i),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 180),
                    padding: const EdgeInsets.symmetric(vertical: 10),
                    decoration: BoxDecoration(
                      color: i == _tab ? AppColors.surface : Colors.transparent,
                      borderRadius: BorderRadius.circular(AppRadii.pill),
                      boxShadow: i == _tab ? const [BoxShadow(color: Color(0x14000000), blurRadius: 6, offset: Offset(0, 1))] : null,
                    ),
                    child: Center(
                      child: Text(tr(_tiers[i].tabLabel),
                          maxLines: 1, overflow: TextOverflow.ellipsis,
                          style: AppText.body2.copyWith(color: i == _tab ? AppColors.brandPrimary : AppColors.textLight, fontWeight: FontWeight.w700)),
                    ),
                  ),
                ),
              ),
          ]),
        ),
        const SizedBox(height: 20),
        // Hero tier card
        Container(
          width: double.infinity,
          clipBehavior: Clip.antiAlias,
          padding: const EdgeInsets.all(22),
          decoration: BoxDecoration(
            gradient: LinearGradient(begin: Alignment.topLeft, end: Alignment.bottomRight, colors: t.gradient),
            borderRadius: BorderRadius.circular(AppRadii.card),
          ),
          child: Stack(children: [
            // Decorative membership card, top-right
            Positioned(
              right: -18,
              top: -6,
              child: Transform.rotate(
                angle: 0.28,
                child: Container(
                  width: 128,
                  height: 82,
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(colors: AppColors.goldGradient),
                    borderRadius: BorderRadius.circular(12),
                    boxShadow: const [BoxShadow(color: Color(0x33000000), blurRadius: 16, offset: Offset(0, 6))],
                  ),
                  padding: const EdgeInsets.all(10),
                  child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                    const Svg('logo_s04', size: 22),
                    const Spacer(),
                    Text(tr(t.name), style: AppText.caption1.copyWith(color: AppColors.brandDarkest, fontWeight: FontWeight.w800)),
                  ]),
                ),
              ),
            ),
            Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              if (t.name == 'Super Fan') ...[
                Pill(
                  gradient: const LinearGradient(colors: AppColors.goldGradient),
                  child: Row(mainAxisSize: MainAxisSize.min, children: [
                    const Icon(Icons.star_rounded, size: 13, color: AppColors.brandDarkest),
                    const SizedBox(width: 4),
                    Text(tr('Most popular'), style: AppText.caption1.copyWith(color: AppColors.brandDarkest, fontWeight: FontWeight.w800)),
                  ]),
                ),
                const SizedBox(height: 12),
              ],
              Text(tr(t.tagline), style: AppText.body3.copyWith(color: Colors.white70)),
              const SizedBox(height: 2),
              Text(tr(t.name), style: AppText.h2.copyWith(color: Colors.white)),
              const SizedBox(height: 4),
              Row(crossAxisAlignment: CrossAxisAlignment.baseline, textBaseline: TextBaseline.alphabetic, children: [
                Text(t.price, style: AppText.h4.copyWith(color: Colors.white)),
                const SizedBox(width: 4),
                Text(tr('/ month'), style: AppText.body2.copyWith(color: Colors.white70)),
              ]),
              const SizedBox(height: 20),
              for (final f in t.features) ...[
                Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  Icon(f.$1, color: AppColors.gold, size: 22),
                  const SizedBox(width: 14),
                  Expanded(child: Text(tr(f.$2), style: AppText.body1.copyWith(color: Colors.white, fontSize: 15))),
                ]),
                const SizedBox(height: 16),
              ],
              // Partner perks row (paid tiers only)
              if (t.partners > 0)
              Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
                const Icon(Icons.apps_rounded, color: AppColors.gold, size: 22),
                const SizedBox(width: 14),
                Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  Text('${t.partners} ${tr('partner perks included')}', style: AppText.body1.copyWith(color: Colors.white, fontSize: 15)),
                  const SizedBox(height: 10),
                  Row(children: [
                    for (final s in kSponsors.take(5))
                      Container(
                        width: 30, height: 30,
                        margin: const EdgeInsets.only(right: 6),
                        decoration: BoxDecoration(shape: BoxShape.circle, color: s.color, border: Border.all(color: Colors.white24)),
                        child: Icon(s.icon, color: Colors.white, size: 15),
                      ),
                    Container(
                      height: 30,
                      padding: const EdgeInsets.symmetric(horizontal: 10),
                      alignment: Alignment.center,
                      decoration: BoxDecoration(color: Colors.white24, borderRadius: BorderRadius.circular(999)),
                      child: Text('+${t.partners - 5}', style: AppText.caption1.copyWith(color: Colors.white, fontWeight: FontWeight.w700)),
                    ),
                  ]),
                ])),
              ]),
            ]),
          ]),
        ),
        const SizedBox(height: 16),
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
