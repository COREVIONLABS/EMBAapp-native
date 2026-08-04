import 'package:flutter/material.dart';
import '../theme/app_theme.dart';
import '../widgets/app_widgets.dart';
import '../widgets/sub_scaffold.dart';
import '../model/fan_model.dart';
import '../l10n/strings.dart';

/// Points History — a running balance header plus grouped transaction cards
/// (earned in green, redeemed in red) with the amount shown as a pill.
class PointsHistoryScreen extends StatelessWidget {
  const PointsHistoryScreen({super.key});

  // (icon, title, when, amount, isCredit)
  static const _rows = <(IconData, String, String, String, bool)>[
    (Icons.storefront_rounded, 'adidas Store Purchase', 'Today', '+252', true),
    (Icons.casino_rounded, 'Daily Spin Win', 'Today', '+50', true),
    (Icons.flag_rounded, 'Mission Complete: Spend €200', 'Yesterday', '+100', true),
    (Icons.sports_soccer_rounded, 'Match Prediction (Correct)', 'Saturday', '+75', true),
    (Icons.confirmation_number_rounded, 'Voucher: Home Scarf 25/26', 'Thursday', '-900', false),
    (Icons.qr_code_rounded, 'Stadium check-in', 'Last week', '+120', true),
    (Icons.stadium_rounded, 'Voucher: Stadium Tour VIP', '2 weeks ago', '-2,500', false),
  ];

  @override
  Widget build(BuildContext context) {
    return SubScaffold(
      title: tr('Points History'),
      children: [
        // Compact balance strip (the full gradient hero lives on the Points tab)
        SurfaceCard(
          color: AppColors.brandLightest,
          child: Row(children: [
            Container(
              width: 40, height: 40,
              decoration: BoxDecoration(gradient: const LinearGradient(colors: AppColors.pointsGradient), borderRadius: BorderRadius.circular(11)),
              child: const Icon(Icons.hexagon_rounded, color: AppColors.gold, size: 20),
            ),
            const SizedBox(width: 12),
            Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text(tr('Current balance'), style: AppText.body3.copyWith(color: AppColors.onAccent)),
              Text('${FanModel.pointsFormatted} ${tr('pts')}', style: AppText.label1.copyWith(color: AppColors.textDarker)),
            ])),
            Text('≈ ${FanModel.balanceEuro}', style: AppText.body2.copyWith(color: AppColors.textLight, fontWeight: FontWeight.w700)),
          ]),
        ),
        const SizedBox(height: 16),
        SurfaceCard(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
          child: Column(children: [
            for (final (i, r) in _rows.indexed) ...[
              if (i > 0) Divider(height: 1, color: AppColors.borderLightest),
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 12),
                child: Row(children: [
                  Container(
                    width: 38, height: 38,
                    decoration: BoxDecoration(color: r.$5 ? AppColors.successBg : AppColors.dangerBg, borderRadius: BorderRadius.circular(11)),
                    child: Icon(r.$1, color: r.$5 ? AppColors.success : AppColors.danger, size: 19),
                  ),
                  const SizedBox(width: 12),
                  Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                    Text(tr(r.$2), maxLines: 1, overflow: TextOverflow.ellipsis, style: AppText.body2.copyWith(color: AppColors.textDarker, fontWeight: FontWeight.w600)),
                    const SizedBox(height: 2),
                    Text(tr(r.$3), style: AppText.body3Regular),
                  ])),
                  const SizedBox(width: 8),
                  Pill(
                    color: r.$5 ? AppColors.successBg : AppColors.dangerBg,
                    child: Text('${r.$4} ${tr('pts')}', style: AppText.caption1.copyWith(color: r.$5 ? AppColors.success : AppColors.danger, fontWeight: FontWeight.w800)),
                  ),
                ]),
              ),
            ],
          ]),
        ),
      ],
    );
  }
}
