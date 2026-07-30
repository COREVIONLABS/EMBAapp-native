import 'package:flutter/material.dart';
import '../theme/app_theme.dart';
import '../model/fan_model.dart';
import '../model/cart.dart';
import '../widgets/app_widgets.dart';
import '../widgets/asset_img.dart';
import '../widgets/sub_scaffold.dart';
import 'cart_screen.dart';
import '../l10n/strings.dart';

/// Product Detail (Figma 2162:6304).
class ProductDetailScreen extends StatefulWidget {
  final FanProduct product;
  const ProductDetailScreen({super.key, required this.product});
  @override
  State<ProductDetailScreen> createState() => _ProductDetailScreenState();
}

class _ProductDetailScreenState extends State<ProductDetailScreen> {
  int _size = 2;
  static const _sizes = ['XS', 'S', 'M', 'L', 'XL', 'XXL'];

  @override
  Widget build(BuildContext context) {
    final p = widget.product;
    final light = p.color.computeLuminance() > 0.6;
    return SubScaffold(
      title: '',
      bottomBar: PrimaryButton(tr('Add to Cart'), onTap: () {
        cartStore.add(p, _sizes[_size]);
        Navigator.of(context).push(MaterialPageRoute(builder: (_) => const CartScreen()));
      }),
      children: [
        Container(
          height: 300,
          clipBehavior: Clip.antiAlias,
          decoration: BoxDecoration(color: AppColors.surfaceMinimal, borderRadius: BorderRadius.circular(AppRadii.card)),
          child: p.imageKey != null
              ? Padding(padding: const EdgeInsets.all(20), child: AssetImg(p.imageKey!, fit: BoxFit.contain, fallbackIcon: Icons.checkroom_rounded))
              : Center(child: Icon(Icons.checkroom_rounded, size: 120, color: light ? AppColors.brandPrimary : AppColors.textLight)),
        ),
        const SizedBox(height: 20),
        Text(p.name, style: AppText.h4),
        const SizedBox(height: 6),
        Row(children: [
          Text(p.priceEur, style: AppText.label1.copyWith(color: AppColors.textDarker)),
          const SizedBox(width: 8),
          Text('or ${p.pointsLabel}', style: AppText.body1.copyWith(color: AppColors.brandPrimary, fontSize: 15)),
        ]),
        const SizedBox(height: 20),
        Text(tr('Select Size'), style: AppText.label2),
        const SizedBox(height: 10),
        Row(
          children: [
            for (var i = 0; i < _sizes.length; i++)
              Expanded(
                child: GestureDetector(
                  onTap: () => setState(() => _size = i),
                  child: Container(
                    margin: const EdgeInsets.only(right: 8),
                    height: 44,
                    decoration: BoxDecoration(
                      color: i == _size ? AppColors.brandPrimary : AppColors.surface,
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(color: i == _size ? AppColors.brandPrimary : AppColors.borderLightest),
                    ),
                    alignment: Alignment.center,
                    child: Text(_sizes[i], style: AppText.body2.copyWith(color: i == _size ? Colors.white : AppColors.textDarker, fontWeight: FontWeight.w700)),
                  ),
                ),
              ),
          ],
        ),
        const SizedBox(height: 20),
        Text(tr('Description'), style: AppText.label2),
        const SizedBox(height: 6),
        Text('Official FC Schalke 04 ${p.category.toLowerCase()} item for the 2025/26 season. Made with recycled polyester for comfort and sustainability. Features the iconic royal blue design.',
            style: AppText.body1.copyWith(color: AppColors.textNormal, height: 1.6, fontSize: 14)),
      ],
    );
  }
}
