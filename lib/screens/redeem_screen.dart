import 'package:flutter/material.dart';
import '../theme/app_theme.dart';
import '../widgets/app_widgets.dart';
import '../widgets/sub_scaffold.dart';
import '../l10n/strings.dart';

/// Redeem Points (Figma 2145:12395): featured brand rewards + ways to redeem.
class RedeemScreen extends StatelessWidget {
  const RedeemScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return SubScaffold(
      title: tr('Redeem Points'),
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(tr('Featured Rewards'), style: AppText.label2),
            Text(tr('See All'), style: AppText.body3.copyWith(color: AppColors.brandPrimary)),
          ],
        ),
        const SizedBox(height: 12),
        SizedBox(
          height: 150,
          child: ListView(
            scrollDirection: Axis.horizontal,
            children: const [
              _BrandCard(brand: 'Nike Stores', cat: 'Clothing', from: '775', color: Color(0xFF111111)),
              SizedBox(width: 12),
              _BrandCard(brand: 'Starbucks', cat: 'Food', from: '520', color: Color(0xFF00704A)),
              SizedBox(width: 12),
              _BrandCard(brand: 'Adidas', cat: 'Clothing', from: '690', color: Color(0xFF1A2432)),
            ],
          ),
        ),
        const SizedBox(height: 24),
        Text(tr('Ways to redeem'), style: AppText.label2),
        const SizedBox(height: 12),
        for (final w in const [
          (Icons.checkroom_rounded, 'Clothing', 'Get Clothing rewards'),
          (Icons.hotel_rounded, 'Stays', 'Book hotels and more'),
          (Icons.sim_card_rounded, 'eSIM', 'Get mobile data worldwide'),
          (Icons.confirmation_number_rounded, 'Experiences', 'Stadium tours, VIP events'),
        ])
          Padding(
            padding: const EdgeInsets.only(bottom: 10),
            child: SurfaceCard(
              child: Row(
                children: [
                  Container(
                    width: 44,
                    height: 44,
                    decoration: BoxDecoration(color: AppColors.brandLightest, borderRadius: BorderRadius.circular(12)),
                    child: Icon(w.$1, color: AppColors.brandPrimary, size: 22),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(w.$2, style: AppText.body1.copyWith(color: AppColors.textDarker, fontSize: 15)),
                        const SizedBox(height: 2),
                        Text(w.$3, style: AppText.body3Regular),
                      ],
                    ),
                  ),
                  const Icon(Icons.chevron_right_rounded, color: AppColors.textLight),
                ],
              ),
            ),
          ),
      ],
    );
  }
}

class _BrandCard extends StatelessWidget {
  final String brand;
  final String cat;
  final String from;
  final Color color;
  const _BrandCard({required this.brand, required this.cat, required this.from, required this.color});
  @override
  Widget build(BuildContext context) {
    return Container(
      width: 165,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(color: color, borderRadius: BorderRadius.circular(AppRadii.tile)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(brand.characters.first, style: const TextStyle(fontFamily: 'Urbanist', color: Colors.white, fontSize: 24, fontWeight: FontWeight.w800)),
              Text(cat, style: AppText.caption1.copyWith(color: Colors.white70, fontSize: 11)),
            ],
          ),
          const Spacer(),
          Text(brand, style: AppText.body2.copyWith(color: Colors.white, fontWeight: FontWeight.w700)),
          const SizedBox(height: 6),
          Row(
            children: [
              const Icon(Icons.monetization_on_rounded, color: AppColors.gold, size: 16),
              const SizedBox(width: 4),
              Text('From $from', style: AppText.body3.copyWith(color: Colors.white)),
            ],
          ),
        ],
      ),
    );
  }
}
