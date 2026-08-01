import 'package:flutter/material.dart';
import '../theme/app_theme.dart';
import '../widgets/app_widgets.dart';
import '../widgets/sub_scaffold.dart';
import '../l10n/strings.dart';

/// Deal Detail (Figma 2162:5966).
class DealDetailScreen extends StatelessWidget {
  final String brand, offer, category;
  final Color color;
  const DealDetailScreen({super.key, required this.brand, required this.offer, required this.category, required this.color});
  @override
  Widget build(BuildContext context) {
    return SubScaffold(
      title: '',
      bottomBar: PrimaryButton(tr('Activate Deal'), onTap: () {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('$brand deal activated')));
        Navigator.of(context).maybePop();
      }),
      children: [
        Container(
          height: 160,
          decoration: BoxDecoration(color: color, borderRadius: BorderRadius.circular(AppRadii.card)),
          alignment: Alignment.center,
          child: Text(brand, style: AppText.h2.copyWith(color: Colors.white)),
        ),
        const SizedBox(height: 20),
        Row(children: [
          Expanded(child: Text(brand, style: AppText.h4)),
          Pill(color: AppColors.brandLightest, child: Text(category, style: AppText.caption1.copyWith(color: AppColors.brandPrimary))),
        ]),
        const SizedBox(height: 8),
        Text(offer, style: AppText.label2.copyWith(color: AppColors.brandPrimary)),
        const SizedBox(height: 20),
        Text(tr('How it works'), style: AppText.label2),
        const SizedBox(height: 6),
        Text(tr('Activate this partner deal and pay with your connected S04 card or app to automatically apply the offer and earn bonus Fan Points. Valid at all participating locations until the end of the season.'),
            style: AppText.body1.copyWith(color: AppColors.textNormal, height: 1.6, fontSize: 14)),
        const SizedBox(height: 16),
        SurfaceCard(
          color: AppColors.brandLightest,
          child: Row(children: [
            const Icon(Icons.monetization_on_rounded, color: AppColors.gold),
            const SizedBox(width: 12),
            Expanded(child: Text(tr('Earn 2× Fan Points on this deal'), style: AppText.body2.copyWith(color: AppColors.onAccent))),
          ]),
        ),
      ],
    );
  }
}
