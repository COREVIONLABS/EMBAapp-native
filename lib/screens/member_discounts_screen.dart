import 'package:flutter/material.dart';
import '../theme/app_theme.dart';
import '../widgets/app_widgets.dart';
import '../widgets/hub_widgets.dart';
import '../widgets/sub_scaffold.dart';
import '../widgets/action_sheets.dart';
import '../model/voucher_store.dart';
import 'voucher_screen.dart';
import '../l10n/strings.dart';

/// Member discounts — fixed % discount vouchers at the club's Fanshop, partners
/// and sponsors. These are a Fan+ membership perk: claiming issues a voucher
/// (code) the fan redeems in-store or online. No points, no surprises — just a
/// clear, fixed rate at every partner.
class MemberDiscountsScreen extends StatelessWidget {
  const MemberDiscountsScreen({super.key});

  // (partner, category, discount, subtitle, icon, color)
  static const _discounts = <(String, String, String, String, IconData, Color)>[
    ('Official Fanshop', 'Club', '15% off', 'Jerseys, scarves & more', Icons.storefront_rounded, Color(0xFF004B9C)),
    ('adidas', 'Sportswear', '20% off', 'Online & in-store', Icons.sports_soccer_rounded, Color(0xFF111111)),
    ('Veltins', 'Beverages', '10% off', 'Matchday crates & more', Icons.sports_bar_rounded, Color(0xFF00623A)),
    ('Vivawest', 'Housing', '10% off', 'Rent & services', Icons.apartment_rounded, Color(0xFF6A1B9A)),
    ("Ernsting's family", 'Fashion', '15% off', 'Family fashion', Icons.checkroom_rounded, Color(0xFFE30613)),
    ('REWE', 'Groceries', '5% off', 'In all REWE stores', Icons.shopping_cart_rounded, Color(0xFFC8102E)),
    // ── Local partners around Gelsenkirchen (regional sponsor tier) ──
    ('ZOOM Erlebniswelt', 'Local', '20% off', 'Gelsenkirchen zoo tickets', Icons.pets_rounded, Color(0xFF2E7D32)),
    ('Cineworld GE', 'Local', '25% off', 'Cinema tickets on matchdays', Icons.local_movies_rounded, Color(0xFF5E35B1)),
    ('McFit Gelsenkirchen', 'Fitness', '10% off', 'Monthly gym membership', Icons.fitness_center_rounded, Color(0xFFEF6C00)),
    ('Trattoria Napoli', 'Dining', '15% off', 'Post-match dinner in GE', Icons.restaurant_rounded, Color(0xFFC62828)),
    ('VRR / Bahn', 'Transport', '10% off', 'Matchday travel to the arena', Icons.directions_bus_rounded, Color(0xFF00695C)),
  ];

  Future<void> _claim(BuildContext context, String partner, String discount) async {
    final ok = await showConfirmDialog(
      context,
      title: 'Get this member voucher?',
      message: '$discount ${tr('at')} $partner · ${tr('redeem in-store or online.')}',
      confirmLabel: 'Get voucher',
    );
    if (!ok || !context.mounted) return;
    final v = voucherStore.issue(title: '$partner · $discount', category: 'Sponsor', points: 0, sponsor: partner);
    if (!context.mounted) return;
    await Navigator.of(context).push(MaterialPageRoute(builder: (_) => VoucherScreen.fromIssued(v)));
  }

  @override
  Widget build(BuildContext context) {
    return SubScaffold(
      title: tr('Member discounts'),
      children: [
        // Intro strip.
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(color: AppColors.brandLightest, borderRadius: BorderRadius.circular(AppRadii.card)),
          child: Row(children: [
            Container(width: 44, height: 44, decoration: BoxDecoration(color: AppColors.gold.withValues(alpha: 0.16), borderRadius: BorderRadius.circular(12)), child: const Icon(Icons.workspace_premium_rounded, color: AppColors.gold, size: 24)),
            const SizedBox(width: 14),
            Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text(tr('Fixed rates for members'), style: AppText.body2.copyWith(color: AppColors.onAccent, fontWeight: FontWeight.w800)),
              Text(tr('Claim a voucher and redeem it at the partner.'), style: AppText.body3.copyWith(color: AppColors.onAccent)),
            ])),
          ]),
        ),
        const SizedBox(height: 20),
        for (final d in _discounts) ...[
          _row(context, partner: d.$1, category: d.$2, discount: d.$3, sub: d.$4, icon: d.$5, color: d.$6),
          const SizedBox(height: 12),
        ],
        const SizedBox(height: 4),
        Row(children: [
          Icon(Icons.info_outline_rounded, size: 14, color: AppColors.textLight),
          const SizedBox(width: 6),
          Expanded(child: Text(tr('Discounts are a Fan+ perk — free to claim, as often as you like.'), style: AppText.caption1.copyWith(color: AppColors.textLight))),
        ]),
      ],
    );
  }

  Widget _row(BuildContext context, {required String partner, required String category, required String discount, required String sub, required IconData icon, required Color color}) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(color: AppColors.surface, borderRadius: BorderRadius.circular(AppRadii.card), border: Border.all(color: AppColors.borderLightest)),
      child: Row(children: [
        SponsorLogo(name: partner, size: 46, bg: color, fg: Colors.white, symbol: icon),
        const SizedBox(width: 12),
        Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Row(children: [
            Expanded(child: Text(partner, maxLines: 1, overflow: TextOverflow.ellipsis, style: AppText.body2.copyWith(color: AppColors.textDarker, fontWeight: FontWeight.w800))),
            const SizedBox(width: 8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(color: AppColors.brandLightest, borderRadius: BorderRadius.circular(AppRadii.chip)),
              child: Text(tr(discount), style: AppText.caption1.copyWith(color: AppColors.brandPrimary, fontWeight: FontWeight.w800, fontSize: 12)),
            ),
          ]),
          const SizedBox(height: 2),
          Text('${tr(category)} · ${tr(sub)}', maxLines: 1, overflow: TextOverflow.ellipsis, style: AppText.body3Regular),
          const SizedBox(height: 10),
          Align(
            alignment: Alignment.centerLeft,
            child: Tappable(
              onTap: () => _claim(context, partner, discount),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                decoration: BoxDecoration(color: AppColors.brandPrimary, borderRadius: BorderRadius.circular(999)),
                child: Row(mainAxisSize: MainAxisSize.min, children: [
                  const Icon(Icons.confirmation_number_rounded, size: 14, color: Colors.white),
                  const SizedBox(width: 6),
                  Text(tr('Get voucher'), style: AppText.caption1.copyWith(color: Colors.white, fontWeight: FontWeight.w800)),
                ]),
              ),
            ),
          ),
        ])),
      ]),
    );
  }
}
