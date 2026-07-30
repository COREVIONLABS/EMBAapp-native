import 'package:flutter/material.dart';
import '../theme/app_theme.dart';
import '../widgets/app_widgets.dart';
import '../widgets/ios_chrome.dart';
import '../l10n/strings.dart';

/// Booking Confirmation (Figma 2162:6427/7547).
class BookingConfirmationScreen extends StatelessWidget {
  final String title;
  const BookingConfirmationScreen({super.key, required this.title});
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.surface,
      body: SafeArea(
        child: Column(children: [
          const IOSStatusBar(),
          const Spacer(),
          Container(width: 88, height: 88, decoration: BoxDecoration(color: AppColors.successBg, shape: BoxShape.circle), child: const Icon(Icons.check_rounded, color: AppColors.success, size: 48)),
          const SizedBox(height: 20),
          Text(tr('Booking Confirmed!'), style: AppText.h4),
          const SizedBox(height: 8),
          Padding(padding: const EdgeInsets.symmetric(horizontal: 40), child: Text('$title is booked. Details are in My Bookings — see you there!', textAlign: TextAlign.center, style: AppText.body1.copyWith(color: AppColors.textLight))),
          const Spacer(),
          Padding(padding: const EdgeInsets.all(20), child: PrimaryButton(tr('Done'), onTap: () => Navigator.of(context).popUntil((r) => r.isFirst))),
          const HomeIndicator(),
        ]),
      ),
    );
  }
}
