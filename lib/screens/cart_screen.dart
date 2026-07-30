import 'package:flutter/material.dart';
import '../theme/app_theme.dart';
import '../model/cart.dart';
import '../widgets/app_widgets.dart';
import '../widgets/sub_scaffold.dart';
import 'checkout_screen.dart';
import '../l10n/strings.dart';

/// Cart (Figma 2162:6348).
class CartScreen extends StatelessWidget {
  const CartScreen({super.key});
  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: cartStore,
      builder: (context, _) {
        final items = cartStore.items;
        return SubScaffold(
          title: tr('Cart'),
          bottomBar: items.isEmpty
              ? null
              : PrimaryButton('Checkout · €${cartStore.subtotal.toStringAsFixed(2)}',
                  onTap: () => Navigator.of(context).push(MaterialPageRoute(builder: (_) => const CheckoutScreen()))),
          children: items.isEmpty
              ? [
                  const SizedBox(height: 80),
                  const Center(child: Icon(Icons.shopping_bag_outlined, size: 64, color: AppColors.surfaceLowContrast)),
                  const SizedBox(height: 16),
                  Center(child: Text(tr('Your cart is empty'), style: AppText.label2.copyWith(color: AppColors.textLight))),
                ]
              : [
                  for (final it in items) ...[
                    _CartRow(item: it),
                    const SizedBox(height: 10),
                  ],
                  const SizedBox(height: 8),
                  SurfaceCard(
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(tr('Subtotal'), style: AppText.body1.copyWith(color: AppColors.textDarker)),
                        Text('€${cartStore.subtotal.toStringAsFixed(2)}', style: AppText.label2),
                      ],
                    ),
                  ),
                ],
        );
      },
    );
  }
}

class _CartRow extends StatelessWidget {
  final CartItem item;
  const _CartRow({required this.item});
  @override
  Widget build(BuildContext context) {
    final p = item.product;
    final light = p.color.computeLuminance() > 0.6;
    return SurfaceCard(
      padding: const EdgeInsets.all(12),
      child: Row(
        children: [
          Container(
            width: 60,
            height: 60,
            decoration: BoxDecoration(color: p.color, borderRadius: BorderRadius.circular(12)),
            child: Icon(Icons.checkroom_rounded, color: light ? AppColors.brandPrimary : Colors.white),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(p.name, style: AppText.body2.copyWith(color: AppColors.textDarker)),
                const SizedBox(height: 2),
                Text('Size ${item.size}', style: AppText.body3Regular),
                const SizedBox(height: 4),
                Text(p.priceEur, style: AppText.body2.copyWith(color: AppColors.brandPrimary, fontWeight: FontWeight.w700)),
              ],
            ),
          ),
          Row(
            children: [
              _qtyBtn(Icons.remove_rounded, () => cartStore.changeQty(item, -1)),
              Padding(padding: const EdgeInsets.symmetric(horizontal: 10), child: Text('${item.qty}', style: AppText.body2)),
              _qtyBtn(Icons.add_rounded, () => cartStore.changeQty(item, 1)),
            ],
          ),
        ],
      ),
    );
  }

  Widget _qtyBtn(IconData icon, VoidCallback onTap) => GestureDetector(
        onTap: onTap,
        child: Container(
          width: 28,
          height: 28,
          decoration: BoxDecoration(color: AppColors.surfaceMinimal, borderRadius: BorderRadius.circular(8)),
          child: Icon(icon, size: 16, color: AppColors.textDarker),
        ),
      );
}
