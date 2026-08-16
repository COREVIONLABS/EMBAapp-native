import 'package:flutter/material.dart';
import '../theme/app_theme.dart';
import '../model/fan_model.dart';
import '../widgets/app_widgets.dart';
import '../widgets/asset_img.dart';
import '../widgets/sub_scaffold.dart';
import '../widgets/voucher_flow.dart';
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
      bottomBar: PrimaryButton('${tr('Get voucher')} · ${p.pointsLabel}', onTap: () {
        redeemForVoucher(context, title: p.name, category: 'Fanshop', points: p.points, detail: '${tr('Size')} ${_sizes[_size]}');
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
        Row(crossAxisAlignment: CrossAxisAlignment.baseline, textBaseline: TextBaseline.alphabetic, children: [
          Text(p.pointsLabel, style: AppText.label1.copyWith(color: AppColors.brandPrimary)),
          const SizedBox(width: 8),
          Text('${tr('Store value')} ${p.priceEur}', style: AppText.body3Regular),
        ]),
        const SizedBox(height: 10),
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(color: AppColors.brandLightest, borderRadius: BorderRadius.circular(AppRadii.tile)),
          child: Row(children: [
            Icon(Icons.confirmation_number_rounded, size: 18, color: AppColors.brandPrimary),
            const SizedBox(width: 10),
            Expanded(child: Text(tr('Redeem points for a voucher — collect this item in the official Fanshop.'),
                style: AppText.body3.copyWith(color: AppColors.onAccent))),
          ]),
        ),
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
        Text(tr('Official FC Schalke 04 merchandise for the 2025/26 season. Made from recycled polyester for comfort and sustainability, with the iconic royal-blue design.'),
            style: AppText.body1.copyWith(color: AppColors.textNormal, height: 1.6, fontSize: 14)),
      ],
    );
  }
}
