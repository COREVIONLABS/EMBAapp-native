import 'package:flutter/material.dart';
import '../theme/app_theme.dart';
import '../model/cart.dart';
import '../widgets/app_widgets.dart';
import '../widgets/sub_scaffold.dart';
import 'order_confirmation_screen.dart';
import '../l10n/strings.dart';

/// Checkout (Figma 2162:7425) — pay with card or Fan Points.
class CheckoutScreen extends StatefulWidget {
  const CheckoutScreen({super.key});
  @override
  State<CheckoutScreen> createState() => _CheckoutScreenState();
}

class _CheckoutScreenState extends State<CheckoutScreen> {
  int _pay = 0; // 0 card, 1 points
  @override
  Widget build(BuildContext context) {
    final subtotal = cartStore.subtotal;
    final pointsDiscount = _pay == 1 ? 15.0 : 0.0;
    final total = subtotal - pointsDiscount;
    return SubScaffold(
      title: tr('Checkout'),
      bottomBar: PrimaryButton('Place Order · €${total.toStringAsFixed(2)}', onTap: () {
        final earned = cartStore.earnPoints;
        cartStore.clear();
        Navigator.of(context).pushReplacement(MaterialPageRoute(builder: (_) => OrderConfirmationScreen(earned: earned)));
      }),
      children: [
        Text(tr('Shipping Address'), style: AppText.label2),
        const SizedBox(height: 8),
        SurfaceCard(
          child: Row(
            children: [
              const Icon(Icons.location_on_rounded, color: AppColors.brandPrimary),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(tr('Max Mustermann'), style: AppText.body2.copyWith(color: AppColors.textDarker)),
                    const SizedBox(height: 2),
                    Text(tr('Kurt-Schumacher-Str. 2, 45897 Gelsenkirchen'), style: AppText.body3Regular),
                  ],
                ),
              ),
              Text(tr('Change'), style: AppText.body3.copyWith(color: AppColors.brandPrimary, fontWeight: FontWeight.w700)),
            ],
          ),
        ),
        const SizedBox(height: 20),
        Text(tr('Payment Method'), style: AppText.label2),
        const SizedBox(height: 8),
        _PayOption(icon: Icons.credit_card_rounded, title: tr('Credit Card'), sub: tr('Visa ending in 4242'), selected: _pay == 0, onTap: () => setState(() => _pay = 0)),
        const SizedBox(height: 8),
        _PayOption(icon: Icons.monetization_on_rounded, title: tr('Fan Points'), sub: tr('2,450 pts available (≈ €24.50)'), selected: _pay == 1, onTap: () => setState(() => _pay = 1)),
        const SizedBox(height: 20),
        Text(tr('Order Summary'), style: AppText.label2),
        const SizedBox(height: 8),
        SurfaceCard(
          child: Column(
            children: [
              for (final it in cartStore.items)
                Padding(
                  padding: const EdgeInsets.only(bottom: 8),
                  child: Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                    Expanded(child: Text('${it.product.name} × ${it.qty}', style: AppText.body2.copyWith(color: AppColors.textNormal))),
                    Text('€${(it.product.price * it.qty).toStringAsFixed(2)}', style: AppText.body2.copyWith(color: AppColors.textDarker)),
                  ]),
                ),
              const Divider(color: AppColors.borderLightest),
              _row('Subtotal', '€${subtotal.toStringAsFixed(2)}'),
              if (pointsDiscount > 0) _row('Points Discount', '-€${pointsDiscount.toStringAsFixed(2)}', color: AppColors.success),
              _row('Shipping', 'Free', color: AppColors.success),
              const SizedBox(height: 4),
              Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                Text(tr('Total'), style: AppText.label1),
                Text('€${total.toStringAsFixed(2)}', style: AppText.label1.copyWith(color: AppColors.brandPrimary)),
              ]),
            ],
          ),
        ),
        const SizedBox(height: 12),
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(color: const Color(0xFFFFF3DC), borderRadius: BorderRadius.circular(AppRadii.tile)),
          child: Row(children: [
            const Icon(Icons.monetization_on_rounded, color: AppColors.gold, size: 18),
            const SizedBox(width: 8),
            Text("You'll earn +${cartStore.earnPoints} Fan Points with this order!", style: AppText.body3.copyWith(color: AppColors.brandDarkest)),
          ]),
        ),
      ],
    );
  }

  Widget _row(String l, String r, {Color? color}) => Padding(
        padding: const EdgeInsets.symmetric(vertical: 3),
        child: Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
          Text(l, style: AppText.body2.copyWith(color: AppColors.textLight)),
          Text(r, style: AppText.body2.copyWith(color: color ?? AppColors.textDarker, fontWeight: FontWeight.w600)),
        ]),
      );
}

class _PayOption extends StatelessWidget {
  final IconData icon;
  final String title;
  final String sub;
  final bool selected;
  final VoidCallback onTap;
  const _PayOption({required this.icon, required this.title, required this.sub, required this.selected, required this.onTap});
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: SurfaceCard(
        color: selected ? AppColors.brandLightest : AppColors.surface,
        border: Border.all(color: selected ? AppColors.brandPrimary : AppColors.borderLightest, width: selected ? 1.5 : 1),
        child: Row(
          children: [
            Icon(icon, color: AppColors.brandPrimary),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title, style: AppText.body2.copyWith(color: AppColors.textDarker)),
                  const SizedBox(height: 2),
                  Text(sub, style: AppText.body3Regular),
                ],
              ),
            ),
            Icon(selected ? Icons.radio_button_checked_rounded : Icons.radio_button_unchecked_rounded, color: selected ? AppColors.brandPrimary : AppColors.textLight),
          ],
        ),
      ),
    );
  }
}
