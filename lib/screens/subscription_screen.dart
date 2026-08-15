import 'package:flutter/material.dart';
import '../theme/app_theme.dart';
import '../widgets/app_widgets.dart';
import '../widgets/sub_scaffold.dart';
import '../model/fan_model.dart';
import 'upgrade_plan_screen.dart';
import 'benefits_screen.dart';
import '../l10n/strings.dart';

/// Membership plans — a true side-by-side comparison: a selectable price header
/// (Free / Member / Super) above a shared feature matrix, with the held tier
/// marked "Current" and the selected tier driving the checkout CTA.
class SubscriptionScreen extends StatefulWidget {
  const SubscriptionScreen({super.key});
  @override
  State<SubscriptionScreen> createState() => _SubscriptionScreenState();
}

class _Tier {
  final String name;
  final String tabLabel;
  final double monthly; // 0 for the free tier
  final String tagline;
  final String? badge; // 'Most popular' / 'Best value'
  final List<Color> gradient;
  final List<(IconData, String)> features;
  final int partners;
  final int moreBenefits;
  const _Tier(this.name, this.tabLabel, this.monthly, this.tagline, this.badge, this.gradient, this.features, this.partners, this.moreBenefits);
  bool get isFree => partners == 0;
  // Annual = 10× monthly (2 months free).
  String priceLabel(bool annual) => isFree ? '€0' : annual ? '€${(monthly * 10).toStringAsFixed(2)}' : '€${monthly.toStringAsFixed(2)}';
}

class _SubscriptionScreenState extends State<SubscriptionScreen> {
  // Selected tier drives the CTA; open on the plan the fan currently holds.
  late int _selected = () {
    final i = _tiers.indexWhere((t) => t.name == tierNotifier.value);
    return i < 0 ? 1 : i;
  }();
  bool _annual = false;

  // Free + two paid tiers. Entry (€4.99) is the volume hero; Super Fan (€9.99)
  // is the value upsell.
  static const _tiers = [
    _Tier('Free Fan', 'Free', 0, 'Free for every fan', null, [Color(0xFF475467), Color(0xFF1D2939)], [], 0, 3),
    _Tier('Fan Member', 'Member', 4.99, 'The one every fan takes', 'Most popular', AppColors.pointsGradient, [], 8, 12),
    _Tier('Super Fan', 'Super', 9.99, 'First in line', 'Best value', [Color(0xFF0A2A5E), Color(0xFF000D22)], [], 12, 24),
  ];

  // Feature comparison matrix — one row per feature, a value per tier
  // (Free / Member / Super). '✓' renders a check, '—' a dash, else the text.
  static const _compare = <(String, String, String, String)>[
    ('Free tombola lots', '0', '3', '8'),
    ('Monthly bonus points', '—', '+500', '+1,200'),
    ('Points per purchase', '1×', '2×', '2×'),
    ('Ticket presale', '—', '24h', '48–72h'),
    ('Best seats + upgrades', '—', '—', '✓'),
    ('Member discounts', '—', '✓', '✓'),
    ('Monthly member drop', '—', '—', '✓'),
    ('Partner perks', '—', '8', '12'),
    ('Daily games & Fan Points', '✓', '✓', '✓'),
  ];

  bool get _isCurrent => _tiers[_selected].name == tierNotifier.value;

  @override
  Widget build(BuildContext context) {
    final t = _tiers[_selected];
    return SubScaffold(
      title: tr('Membership Plans'),
      bottomBar: _isCurrent
          ? Container(
              padding: const EdgeInsets.symmetric(vertical: 16),
              alignment: Alignment.center,
              decoration: BoxDecoration(color: AppColors.surfaceMinimal, borderRadius: BorderRadius.circular(AppRadii.pill)),
              child: Row(mainAxisSize: MainAxisSize.min, children: [
                Icon(Icons.check_circle_rounded, size: 18, color: AppColors.brandPrimary),
                const SizedBox(width: 8),
                Text('${tr(t.name)} · ${tr('your current plan')}', style: AppText.label2.copyWith(color: AppColors.textNormal)),
              ]),
            )
          : t.isFree
              ? SecondaryButton(tr('Continue with Free'), onTap: () { tierNotifier.value = t.name; Navigator.of(context).maybePop(); })
              : Column(mainAxisSize: MainAxisSize.min, children: [
                  PrimaryButton('${tr('Choose')} ${tr(t.name)} · ${tr('7-day free trial')}',
                      onTap: () => Navigator.of(context).push(
                          MaterialPageRoute(builder: (_) => UpgradePlanScreen(plan: t.name, price: t.priceLabel(_annual), period: _annual ? tr('/ year') : tr('/ month'))))),
                  const SizedBox(height: 8),
                  Text('${tr('7 days free, then')} ${t.priceLabel(_annual)} ${_annual ? tr('/ year') : tr('/ month')} · ${tr('cancel anytime')}',
                      textAlign: TextAlign.center, style: AppText.caption1.copyWith(color: AppColors.textLight)),
                ]),
      children: [
        Text(tr('Compare plans and pick what fits — all in one view.'), style: AppText.body3Regular),
        const SizedBox(height: 14),
        // Billing toggle (applies to the paid tiers).
        Container(
          padding: const EdgeInsets.all(4),
          decoration: BoxDecoration(color: AppColors.surfaceMinimal, borderRadius: BorderRadius.circular(AppRadii.pill)),
          child: Row(children: [
            _billSeg(tr('Monthly'), !_annual, () => setState(() => _annual = false)),
            _billSeg(tr('Yearly · 2 months free'), _annual, () => setState(() => _annual = true)),
          ]),
        ),
        const SizedBox(height: 16),
        // ── Price header: all three tiers side by side, selectable ──
        IntrinsicHeight(
          child: Row(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
            for (var i = 0; i < _tiers.length; i++) ...[
              Expanded(child: _priceCol(i)),
              if (i < _tiers.length - 1) const SizedBox(width: 8),
            ],
          ]),
        ),
        const SizedBox(height: 16),
        // ── Feature comparison matrix ──
        Container(
          decoration: BoxDecoration(color: AppColors.surface, borderRadius: BorderRadius.circular(AppRadii.card), border: Border.all(color: AppColors.borderLightest)),
          child: Column(children: [
            for (var r = 0; r < _compare.length; r++)
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 11),
                decoration: BoxDecoration(
                  border: r == 0 ? null : Border(top: BorderSide(color: AppColors.borderLightest)),
                ),
                child: Row(children: [
                  Expanded(flex: 5, child: Text(tr(_compare[r].$1), style: AppText.body3.copyWith(color: AppColors.textDark, fontWeight: FontWeight.w600))),
                  Expanded(flex: 3, child: _cell(_compare[r].$2, 0)),
                  Expanded(flex: 3, child: _cell(_compare[r].$3, 1)),
                  Expanded(flex: 3, child: _cell(_compare[r].$4, 2)),
                ]),
              ),
          ]),
        ),
        const SizedBox(height: 14),
        Center(
          child: GestureDetector(
            onTap: () => Navigator.of(context).push(MaterialPageRoute(builder: (_) => AllBenefitsScreen(tierName: t.name))),
            child: Text('${tr('Show all')} ${t.moreBenefits}+ ${tr('benefits')}', style: AppText.body3.copyWith(color: AppColors.brandPrimary, fontWeight: FontWeight.w700)),
          ),
        ),
        const SizedBox(height: 14),
        Row(children: [
          Icon(Icons.lock_outline_rounded, size: 14, color: AppColors.textLight),
          const SizedBox(width: 6),
          Expanded(child: Text(tr('Points are never cashed out — they unlock discounts, access and sponsor rewards.'),
              style: AppText.caption1.copyWith(color: AppColors.textLight))),
        ]),
      ],
    );
  }

  Widget _billSeg(String label, bool selected, VoidCallback onTap) {
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 180),
          padding: const EdgeInsets.symmetric(vertical: 10),
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: selected ? AppColors.surface : Colors.transparent,
            borderRadius: BorderRadius.circular(AppRadii.pill),
            boxShadow: selected ? const [BoxShadow(color: Color(0x14000000), blurRadius: 6, offset: Offset(0, 1))] : null,
          ),
          child: Text(label, maxLines: 1, overflow: TextOverflow.ellipsis,
              style: AppText.body3.copyWith(color: selected ? AppColors.brandPrimary : AppColors.textLight, fontWeight: FontWeight.w700)),
        ),
      ),
    );
  }

  // Selectable tier price column in the header row.
  Widget _priceCol(int i) {
    final t = _tiers[i];
    final on = i == _selected;
    final isCurrent = t.name == tierNotifier.value;
    return Tappable(
      scale: 0.97,
      onTap: () => setState(() => _selected = i),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 6),
        decoration: BoxDecoration(
          color: on ? AppColors.brandLightest : AppColors.surface,
          borderRadius: BorderRadius.circular(AppRadii.tile),
          border: Border.all(color: on ? AppColors.brandPrimary : AppColors.borderLightest, width: on ? 1.6 : 1),
        ),
        child: Column(children: [
          SizedBox(
            height: 16,
            child: isCurrent
                ? Text(tr('Current'), maxLines: 1, overflow: TextOverflow.ellipsis, style: AppText.caption1.copyWith(color: AppColors.success, fontWeight: FontWeight.w800, fontSize: 9))
                : (t.badge != null
                    ? Text(tr(t.badge!), maxLines: 1, overflow: TextOverflow.ellipsis, style: AppText.caption1.copyWith(color: const Color(0xFF9A6B00), fontWeight: FontWeight.w800, fontSize: 9))
                    : const SizedBox.shrink()),
          ),
          const SizedBox(height: 4),
          Text(tr(t.tabLabel), maxLines: 1, overflow: TextOverflow.ellipsis, style: AppText.body2.copyWith(color: AppColors.textDarker, fontWeight: FontWeight.w800)),
          const SizedBox(height: 4),
          Text(t.priceLabel(_annual), style: AppText.label1.copyWith(color: on ? AppColors.brandPrimary : AppColors.textDarker, fontSize: 17)),
          Text(t.isFree ? tr('forever') : (_annual ? tr('/ year') : tr('/ month')), style: AppText.caption1.copyWith(color: AppColors.textLight, fontSize: 10)),
          if (!t.isFree && _annual) ...[
            const SizedBox(height: 2),
            Text('≈ €${(t.monthly * 10 / 12).toStringAsFixed(2)}/mo', style: AppText.caption1.copyWith(color: AppColors.success, fontWeight: FontWeight.w700, fontSize: 9)),
          ],
        ]),
      ),
    );
  }

  // A comparison matrix cell for tier column [col].
  Widget _cell(String value, int col) {
    final on = col == _selected;
    Widget child;
    if (value == '✓') {
      child = Icon(Icons.check_circle_rounded, size: 17, color: on ? AppColors.brandPrimary : AppColors.success);
    } else if (value == '—') {
      child = Text('—', style: AppText.body3.copyWith(color: AppColors.textLight));
    } else {
      child = Text(value, textAlign: TextAlign.center, maxLines: 1, overflow: TextOverflow.ellipsis,
          style: AppText.caption1.copyWith(color: on ? AppColors.brandPrimary : AppColors.textDarker, fontWeight: FontWeight.w800, fontSize: 11.5));
    }
    return Container(
      alignment: Alignment.center,
      padding: const EdgeInsets.symmetric(vertical: 2),
      decoration: on ? BoxDecoration(color: AppColors.brandLightest, borderRadius: BorderRadius.circular(6)) : null,
      child: child,
    );
  }
}
