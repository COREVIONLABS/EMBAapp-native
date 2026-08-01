import 'package:flutter/material.dart';
import '../theme/app_theme.dart';
import '../widgets/app_widgets.dart';
import '../widgets/asset_img.dart';
import '../widgets/sub_scaffold.dart';
import 'deal_detail_screen.dart';
import 'category_detail_screen.dart';
import '../l10n/strings.dart';

class _Cat {
  final IconData icon;
  final String label;
  const _Cat(this.icon, this.label);
}

const _cats = [
  _Cat(Icons.local_offer_rounded, 'All Deals'),
  _Cat(Icons.restaurant_rounded, 'Food'),
  _Cat(Icons.confirmation_number_rounded, 'Events'),
  _Cat(Icons.local_mall_rounded, 'Shopping'),
  _Cat(Icons.flight_rounded, 'Travel'),
  _Cat(Icons.spa_rounded, 'Health & Wellness'),
];

class _Brand {
  final String imageKey, name, discount;
  const _Brand(this.imageKey, this.name, this.discount);
}

const _brands = [
  _Brand('brand_nike', 'Nike', '16% Off'),
  _Brand('brand_puma', 'Puma', '16% Off'),
  _Brand('brand_levis', 'Levis', '16% Off'),
  _Brand('brand_nike', 'Adidas', '15% Off'),
];

class _Featured {
  final String imageKey, title, place, discount;
  const _Featured(this.imageKey, this.title, this.place, this.discount);
}

const _featured = [
  _Featured('deal_matchday_meal', 'Matchday Meal', 'Arena Food Court', '20% OFF'),
  _Featured('deal_banner', 'Banner Gelsenkirchen-Schalke', 'Schalke Fanshop', '30% OFF'),
  _Featured('deal_helene_fischer', 'HELENE FISCHER 360° Stadion Tour 2026', 'VELTINS-Arena', '20% OFF'),
  _Featured('deal_museum', 'Museum Tour', 'Schalke Museum', 'FREE'),
];

/// Deals Hub (Figma 2162:5814).
class DealsHubScreen extends StatelessWidget {
  const DealsHubScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return SubScaffold(
      title: tr('Deals Hub'),
      children: [
        // Search bar
        Container(
          height: 48,
          padding: const EdgeInsets.symmetric(horizontal: 16),
          decoration: BoxDecoration(color: AppColors.surfaceMinimal, borderRadius: BorderRadius.circular(AppRadii.pill)),
          child: Row(children: [
            Icon(Icons.search_rounded, size: 20, color: AppColors.textLight),
            const SizedBox(width: 12),
            Expanded(child: Text(tr('Search deals...'), style: AppText.body2.copyWith(color: AppColors.textLight))),
            Icon(Icons.tune_rounded, size: 20, color: AppColors.textLight),
          ]),
        ),
        const SizedBox(height: 20),
        // Category chips
        SizedBox(
          height: 76,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            itemCount: _cats.length,
            separatorBuilder: (_, __) => const SizedBox(width: 16),
            itemBuilder: (_, i) => _CatTile(cat: _cats[i], active: i == 0),
          ),
        ),
        const SizedBox(height: 20),
        SectionHeader(tr('Partner Brands'), onAction: () {}),
        const SizedBox(height: 12),
        SizedBox(
          height: 58,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            itemCount: _brands.length,
            separatorBuilder: (_, __) => const SizedBox(width: 10),
            itemBuilder: (_, i) => _BrandCard(_brands[i]),
          ),
        ),
        const SizedBox(height: 20),
        SectionHeader(tr('Featured Deals'), onAction: () {}),
        const SizedBox(height: 12),
        GridView.count(
          crossAxisCount: 2,
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          mainAxisSpacing: 14,
          crossAxisSpacing: 14,
          childAspectRatio: 160 / 190,
          children: [for (final f in _featured) _FeaturedCard(f)],
        ),
      ],
    );
  }
}

class _CatTile extends StatelessWidget {
  final _Cat cat;
  final bool active;
  const _CatTile({required this.cat, required this.active});
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        if (cat.label == 'All Deals') return;
        Navigator.of(context).push(MaterialPageRoute(builder: (_) => CategoryDetailScreen(category: cat.label)));
      },
      child: SizedBox(
        width: 56,
        child: Column(children: [
          Container(
            width: 52,
            height: 52,
            decoration: BoxDecoration(
              color: active ? AppColors.brandPrimary : AppColors.brandLightest,
              borderRadius: BorderRadius.circular(16),
            ),
            child: Icon(cat.icon, size: 24, color: active ? Colors.white : AppColors.brandPrimary),
          ),
          const SizedBox(height: 6),
          Text(tr(cat.label.split(' ').first),
              maxLines: 1, overflow: TextOverflow.ellipsis, style: AppText.caption1.copyWith(color: AppColors.textNormal)),
        ]),
      ),
    );
  }
}

class _BrandCard extends StatelessWidget {
  final _Brand b;
  const _BrandCard(this.b);
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(8, 8, 16, 8),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppRadii.pill),
        border: Border.all(color: AppColors.borderLightest),
      ),
      child: Row(mainAxisSize: MainAxisSize.min, children: [
        ClipOval(
          child: Container(
            width: 34,
            height: 34,
            color: AppColors.brandDarkest,
            padding: const EdgeInsets.all(6),
            child: AssetImg(b.imageKey, fit: BoxFit.contain, fallbackIcon: Icons.storefront_rounded),
          ),
        ),
        const SizedBox(width: 10),
        Column(crossAxisAlignment: CrossAxisAlignment.start, mainAxisSize: MainAxisSize.min, children: [
          Text(b.name, style: AppText.caption1.copyWith(color: AppColors.textDarker, fontWeight: FontWeight.w700)),
          Text(b.discount, style: AppText.body3.copyWith(color: AppColors.brandPrimary, fontWeight: FontWeight.w700, fontSize: 13)),
        ]),
      ]),
    );
  }
}

class _FeaturedCard extends StatelessWidget {
  final _Featured f;
  const _FeaturedCard(this.f);
  @override
  Widget build(BuildContext context) {
    final isFree = f.discount == 'FREE';
    return GestureDetector(
      onTap: () => Navigator.of(context).push(MaterialPageRoute(
          builder: (_) => DealDetailScreen(brand: f.title, offer: f.discount, category: f.place, color: AppColors.brandDarkest))),
      child: Container(
        clipBehavior: Clip.antiAlias,
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(AppRadii.card),
          border: Border.all(color: AppColors.borderLightest),
        ),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Expanded(
            child: Stack(
              children: [
                Positioned.fill(child: AssetImg(f.imageKey, fit: BoxFit.cover, fallbackIcon: Icons.local_offer_rounded)),
                Positioned(
                  left: 8,
                  top: 8,
                  child: Pill(
                    color: isFree ? AppColors.gold : AppColors.brandPrimary,
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    child: Text(f.discount,
                        style: AppText.caption1.copyWith(
                            color: isFree ? AppColors.brandDarkest : Colors.white, fontWeight: FontWeight.w800, fontSize: 10.5)),
                  ),
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(12),
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text(f.title,
                  maxLines: 1, overflow: TextOverflow.ellipsis,
                  style: AppText.body2.copyWith(color: AppColors.textDarker)),
              const SizedBox(height: 2),
              Text(f.place, maxLines: 1, overflow: TextOverflow.ellipsis, style: AppText.body3Regular),
            ]),
          ),
        ]),
      ),
    );
  }
}
