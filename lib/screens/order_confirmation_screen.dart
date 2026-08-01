import 'package:flutter/material.dart';
import '../theme/app_theme.dart';
import '../widgets/app_widgets.dart';
import '../widgets/ios_chrome.dart';
import '../l10n/strings.dart';

/// Order Confirmation (Figma 2162:7502).
class OrderConfirmationScreen extends StatelessWidget {
  final int earned;
  const OrderConfirmationScreen({super.key, required this.earned});
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.surface,
      body: SafeArea(
        child: Column(
          children: [
            const Spacer(),
            Container(
              width: 88,
              height: 88,
              decoration: BoxDecoration(color: AppColors.successBg, shape: BoxShape.circle),
              child: const Icon(Icons.check_rounded, color: AppColors.success, size: 48),
            ),
            const SizedBox(height: 20),
            Text(tr('Order Confirmed!'), style: AppText.h4),
            const SizedBox(height: 8),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 40),
              child: Text(tr('Your order #S04-24815 is on its way. You can track it under My Orders.'),
                  textAlign: TextAlign.center, style: AppText.body1.copyWith(color: AppColors.textLight)),
            ),
            const SizedBox(height: 20),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
              decoration: BoxDecoration(gradient: const LinearGradient(colors: AppColors.goldGradient), borderRadius: BorderRadius.circular(999)),
              child: Row(mainAxisSize: MainAxisSize.min, children: [
                const Icon(Icons.monetization_on_rounded, size: 16, color: AppColors.brandDarkest),
                const SizedBox(width: 6),
                Text('+$earned Fan Points earned', style: AppText.body2.copyWith(color: AppColors.brandDarkest, fontWeight: FontWeight.w700)),
              ]),
            ),
            const Spacer(),
            Padding(
              padding: const EdgeInsets.all(20),
              child: PrimaryButton(tr('Continue Shopping'), onTap: () => Navigator.of(context).popUntil((r) => r.isFirst)),
            ),
            const HomeIndicator(),
          ],
        ),
      ),
    );
  }
}
