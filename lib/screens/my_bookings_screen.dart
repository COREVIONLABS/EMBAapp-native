import 'package:flutter/material.dart';
import '../theme/app_theme.dart';
import '../widgets/app_widgets.dart';
import '../widgets/sub_scaffold.dart';
import '../l10n/strings.dart';

/// My Bookings (Figma 2162:6647).
class MyBookingsScreen extends StatelessWidget {
  const MyBookingsScreen({super.key});
  @override
  Widget build(BuildContext context) {
    return SubScaffold(
      title: tr('My Bookings'),
      children: [
        for (final b in const [
          ('Stadium Tour VIP', 'Apr 15, 2026 · VELTINS-Arena', 'Confirmed', true),
          ('Museum Tour', 'May 3 · VELTINS-Arena', 'Confirmed', true),
          ('Legends Dinner', 'May 18 · VIP Lounge', 'Waitlist', false),
        ])
          Padding(
            padding: const EdgeInsets.only(bottom: 10),
            child: SurfaceCard(
              child: Row(children: [
                Container(width: 48, height: 48, decoration: BoxDecoration(gradient: const LinearGradient(colors: AppColors.pointsGradient), borderRadius: BorderRadius.circular(12)), child: const Icon(Icons.confirmation_number_rounded, color: Colors.white70, size: 22)),
                const SizedBox(width: 12),
                Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  Text(b.$1, style: AppText.body2.copyWith(color: AppColors.textDarker)),
                  const SizedBox(height: 2),
                  Text(b.$2, style: AppText.body3Regular),
                ])),
                Pill(color: b.$4 ? AppColors.successBg : AppColors.surfaceMinimal, child: Text(b.$3, style: AppText.caption1.copyWith(color: b.$4 ? AppColors.success : AppColors.textLight))),
              ]),
            ),
          ),
      ],
    );
  }
}
