import 'package:flutter/material.dart';
import '../theme/app_theme.dart';
import '../model/fan_model.dart';
import '../widgets/app_widgets.dart';
import '../widgets/asset_img.dart';
import '../widgets/tab_scaffold.dart';
import '../model/voucher_store.dart';
import 'product_detail_screen.dart';
import 'my_vouchers_screen.dart';
import '../l10n/strings.dart';

/// Fanshop Home (Figma 2162:6193) — Shop tab.
class FanshopScreen extends StatefulWidget {
  const FanshopScreen({super.key});
  @override
  State<FanshopScreen> createState() => _FanshopScreenState();
}

class _FanshopScreenState extends State<FanshopScreen> {
  int _cat = 0;
  static const _cats = ['All', 'Jerseys', 'Jackets', 'Scarves', 'Accessories'];

  @override
  Widget build(BuildContext context) {
    final products = _cat == 0
        ? FanModel.products
        : FanModel.products.where((p) => p.category == _cats[_cat]).toList();
    return TabScaffold(
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Row(
            children: [
              Text(tr('Schalke Fanshop'), style: AppText.h2.copyWith(fontSize: 24)),
              const Spacer(),
              _VouchersButton(),
              const SizedBox(width: 8),
              Container(
                width: 36,
                height: 36,
                decoration: BoxDecoration(color: AppColors.surfaceMinimal, borderRadius: BorderRadius.circular(36)),
                child: const Center(child: Svg('bell_dot', size: 20)),
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
            decoration: BoxDecoration(color: AppColors.surfaceMinimal, borderRadius: BorderRadius.circular(AppRadii.field)),
            child: Row(children: [
              Icon(Icons.search_rounded, color: AppColors.textLight, size: 20),
              const SizedBox(width: 8),
              Text(tr('Search products…'), style: AppText.body1.copyWith(color: AppColors.textLight, fontSize: 14)),
            ]),
          ),
        ),
        const SizedBox(height: 12),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(color: AppColors.brandLightest, borderRadius: BorderRadius.circular(AppRadii.tile)),
            child: Row(children: [
              const Icon(Icons.confirmation_number_rounded, color: AppColors.gold, size: 20),
              const SizedBox(width: 10),
              Expanded(child: Text(tr('Redeem points for a voucher — collect your item in the official Fanshop.'), style: AppText.body2.copyWith(color: AppColors.onAccent))),
            ]),
          ),
        ),
        const SizedBox(height: 16),
        SizedBox(
          height: 34,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 20),
            itemCount: _cats.length,
            separatorBuilder: (_, __) => const SizedBox(width: 8),
            itemBuilder: (_, i) => GestureDetector(
              onTap: () => setState(() => _cat = i),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 7),
                decoration: BoxDecoration(
                  color: i == _cat ? AppColors.brandPrimary : AppColors.surfaceMinimal,
                  borderRadius: BorderRadius.circular(AppRadii.pill),
                ),
                child: Text(_cats[i], style: AppText.body2.copyWith(color: i == _cat ? Colors.white : AppColors.textNormal, fontWeight: FontWeight.w600)),
              ),
            ),
          ),
        ),
        const SizedBox(height: 16),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: GridView.count(
            crossAxisCount: 2,
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            mainAxisSpacing: 14,
            crossAxisSpacing: 14,
            childAspectRatio: 0.68,
            children: [for (final p in products) _ProductTile(p)],
          ),
        ),
      ],
    );
  }
}

/// Wallet shortcut — opens "My Vouchers" with a badge for open (unredeemed) ones.
class _VouchersButton extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: voucherStore,
      builder: (context, _) => GestureDetector(
        onTap: () => Navigator.of(context).push(MaterialPageRoute(builder: (_) => const MyVouchersScreen())),
        child: Stack(
          clipBehavior: Clip.none,
          children: [
            Container(
              width: 36,
              height: 36,
              decoration: BoxDecoration(color: AppColors.surfaceMinimal, borderRadius: BorderRadius.circular(36)),
              child: Icon(Icons.confirmation_number_outlined, size: 20, color: AppColors.textNormal),
            ),
            if (voucherStore.openCount > 0)
              Positioned(
                right: -2,
                top: -2,
                child: Container(
                  padding: const EdgeInsets.all(4),
                  decoration: const BoxDecoration(color: AppColors.brandPrimary, shape: BoxShape.circle),
                  constraints: const BoxConstraints(minWidth: 16, minHeight: 16),
                  child: Text('${voucherStore.openCount}', textAlign: TextAlign.center, style: const TextStyle(fontFamily: 'Urbanist', color: Colors.white, fontSize: 10, fontWeight: FontWeight.w700)),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

class _ProductTile extends StatelessWidget {
  final FanProduct p;
  const _ProductTile(this.p);
  @override
  Widget build(BuildContext context) {
    final light = p.color.computeLuminance() > 0.6;
    return GestureDetector(
      onTap: () => Navigator.of(context).push(MaterialPageRoute(builder: (_) => ProductDetailScreen(product: p))),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Container(
              width: double.infinity,
              clipBehavior: Clip.antiAlias,
              decoration: BoxDecoration(color: AppColors.surfaceMinimal, borderRadius: BorderRadius.circular(AppRadii.tile)),
              child: Stack(
                fit: StackFit.expand,
                children: [
                  if (p.imageKey != null)
                    Padding(padding: const EdgeInsets.all(10), child: AssetImg(p.imageKey!, fit: BoxFit.contain, fallbackIcon: Icons.checkroom_rounded))
                  else
                    Center(child: Icon(Icons.checkroom_rounded, size: 56, color: light ? AppColors.brandPrimary : AppColors.textLight)),
                  Positioned(right: 10, top: 10, child: Icon(Icons.favorite_border_rounded, color: AppColors.textLight, size: 20)),
                ],
              ),
            ),
          ),
          const SizedBox(height: 8),
          Text(p.name, maxLines: 1, overflow: TextOverflow.ellipsis, style: AppText.body2.copyWith(color: AppColors.textDarker)),
          const SizedBox(height: 4),
          Row(children: [
            Text(p.pointsLabel, style: AppText.body2.copyWith(color: AppColors.brandPrimary, fontWeight: FontWeight.w700)),
            const SizedBox(width: 6),
            Flexible(child: Text(p.priceEur, maxLines: 1, overflow: TextOverflow.ellipsis, style: AppText.body3Regular)),
          ]),
        ],
      ),
    );
  }
}
