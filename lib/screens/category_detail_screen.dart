import 'package:flutter/material.dart';
import '../theme/app_theme.dart';
import '../widgets/app_widgets.dart';
import '../widgets/sub_scaffold.dart';
import 'deal_detail_screen.dart';

class CategoryDeal {
  final String title, place, discount;
  const CategoryDeal(this.title, this.place, this.discount);
}

/// Category Detail (Figma 2162:6005) — deals filtered to one category.
class CategoryDetailScreen extends StatelessWidget {
  final String category;
  const CategoryDetailScreen({super.key, required this.category});

  static const _byCategory = {
    'Food': [
      CategoryDeal('Matchday Meal Deal', 'Arena Food Court', '20% OFF'),
      CategoryDeal('Veltins Beer Combo', 'Veltins Lounge', '15% OFF'),
      CategoryDeal('Fan Pizza Special', 'Arena Pizzeria', '€5 OFF'),
      CategoryDeal('VIP Catering', 'Hospitality Suite', '10% OFF'),
      CategoryDeal('Kids Meal Free', 'Family Section', 'FREE'),
    ],
    'Events': [
      CategoryDeal('Museum Tour', 'Schalke Museum', 'FREE'),
      CategoryDeal('360° Stadion Tour', 'VELTINS-Arena', '20% OFF'),
      CategoryDeal('Legends Dinner', 'VIP Lounge', '10% OFF'),
    ],
    'Shopping': [
      CategoryDeal('Home Jersey 25/26', 'Schalke Fanshop', '20% OFF'),
      CategoryDeal('Adidas Sportswear', 'Adidas Store', '15% OFF'),
      CategoryDeal('Puma Fan Gear', 'Puma Store', '16% OFF'),
    ],
    'Travel': [
      CategoryDeal('Away Day Bus', 'Schalke Reisen', '25% OFF'),
      CategoryDeal('Hotel Gelsenkirchen', 'Partner Hotels', '15% OFF'),
    ],
    'Health & Wellness': [
      CategoryDeal('Fan Fitness Pass', 'S04 Gym Partner', '20% OFF'),
      CategoryDeal('Physio Session', 'Reha Zentrum', '10% OFF'),
    ],
  };

  @override
  Widget build(BuildContext context) {
    final deals = _byCategory[category] ?? _byCategory['Food']!;
    return SubScaffold(
      title: category,
      children: [
        Align(
          alignment: Alignment.centerLeft,
          child: Text('${deals.length} deals available', style: AppText.body3Regular),
        ),
        const SizedBox(height: 14),
        for (final d in deals) ...[
          _CategoryDealRow(deal: d, category: category),
          const SizedBox(height: 10),
        ],
      ],
    );
  }
}

class _CategoryDealRow extends StatelessWidget {
  final CategoryDeal deal;
  final String category;
  const _CategoryDealRow({required this.deal, required this.category});

  @override
  Widget build(BuildContext context) {
    final isFree = deal.discount == 'FREE';
    return SurfaceCard(
      onTap: () => Navigator.of(context).push(MaterialPageRoute(
          builder: (_) => DealDetailScreen(
              brand: deal.title, offer: deal.discount, category: category, color: AppColors.brandDarkest))),
      child: Row(children: [
        Container(
          width: 52,
          height: 52,
          decoration: BoxDecoration(color: AppColors.brandDarkest, borderRadius: BorderRadius.circular(12)),
          child: const Icon(Icons.local_offer_rounded, color: Colors.white54, size: 22),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text(deal.title, style: AppText.body2.copyWith(color: AppColors.textDarker)),
            const SizedBox(height: 2),
            Text(deal.place, style: AppText.body3Regular),
          ]),
        ),
        const SizedBox(width: 8),
        Pill(
          color: isFree ? AppColors.brandPrimary : AppColors.brandLightest,
          child: Text(deal.discount,
              style: AppText.caption1.copyWith(
                  color: isFree ? Colors.white : AppColors.brandPrimary, fontWeight: FontWeight.w700)),
        ),
      ]),
    );
  }
}
