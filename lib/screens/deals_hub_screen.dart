import 'package:flutter/material.dart';
import '../theme/app_theme.dart';
import '../widgets/app_widgets.dart';
import '../widgets/sub_scaffold.dart';

class _Deal {
  final String brand, offer, category;
  final Color color;
  const _Deal(this.brand, this.offer, this.category, this.color);
}

const _deals = [
  _Deal('Adidas', '20% off + 2x points', 'Sports', Color(0xFF111111)),
  _Deal("McDonald's", 'Free fries with app order', 'Food', Color(0xFFDA291C)),
  _Deal('Veltins', 'Matchday combo -15%', 'Food', Color(0xFF00693C)),
  _Deal('Vodafone', '500 bonus points on plans', 'Telecom', Color(0xFFE60000)),
  _Deal('Gazprom Store', '10% cashback in points', 'Retail', Color(0xFF002F63)),
];

/// Deals Hub (Figma 2162:5814).
class DealsHubScreen extends StatelessWidget {
  const DealsHubScreen({super.key});
  @override
  Widget build(BuildContext context) {
    return SubScaffold(
      title: 'Deals Hub',
      children: [
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(gradient: const LinearGradient(colors: AppColors.goldGradient), borderRadius: BorderRadius.circular(AppRadii.card)),
          child: Row(children: [
            const Icon(Icons.local_offer_rounded, color: AppColors.brandDarkest),
            const SizedBox(width: 12),
            Expanded(child: Text('Matchday Specials — extra points on gameday!', style: AppText.body2.copyWith(color: AppColors.brandDarkest, fontWeight: FontWeight.w700))),
          ]),
        ),
        const SizedBox(height: 20),
        Align(alignment: Alignment.centerLeft, child: Text('Partner Deals', style: AppText.label2)),
        const SizedBox(height: 12),
        for (final d in _deals)
          Padding(
            padding: const EdgeInsets.only(bottom: 10),
            child: SurfaceCard(
              child: Row(children: [
                Container(width: 48, height: 48, decoration: BoxDecoration(color: d.color, shape: BoxShape.circle), alignment: Alignment.center, child: Text(d.brand.characters.first, style: const TextStyle(fontFamily: 'Urbanist', color: Colors.white, fontWeight: FontWeight.w800))),
                const SizedBox(width: 12),
                Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  Text(d.brand, style: AppText.body2.copyWith(color: AppColors.textDarker)),
                  const SizedBox(height: 2),
                  Text(d.offer, style: AppText.body3Regular),
                ])),
                const Svg('arrow_right', size: 16),
              ]),
            ),
          ),
      ],
    );
  }
}
