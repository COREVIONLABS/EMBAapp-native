import 'package:flutter/material.dart';
import '../theme/app_theme.dart';
import '../widgets/sub_scaffold.dart';
import '../l10n/strings.dart';

/// Points History (Figma 2162:5427).
class PointsHistoryScreen extends StatelessWidget {
  const PointsHistoryScreen({super.key});
  static const _rows = [
    ('Adidas Store Purchase', 'Today', '+252', true),
    ('Daily Spin Win', 'Today', '+50', true),
    ('Mission Complete: Spend €200', 'Yesterday', '+100', true),
    ('Match Prediction (Correct)', 'Saturday', '+75', true),
    ('Redeemed: Home Jersey', 'Thursday', '-1,500', false),
    ('Stadium check-in', 'Last week', '+120', true),
    ('Redeemed: Stadium Tour', '2 weeks ago', '-2,500', false),
  ];
  @override
  Widget build(BuildContext context) {
    return SubScaffold(
      title: tr('Points History'),
      children: [
        for (final r in _rows)
          Padding(
            padding: const EdgeInsets.only(bottom: 8),
            child: Row(children: [
              Container(width: 36, height: 36, decoration: BoxDecoration(color: r.$4 ? AppColors.successBg : const Color(0xFFFDE7E7), borderRadius: BorderRadius.circular(10)), child: Icon(r.$4 ? Icons.arrow_upward_rounded : Icons.arrow_downward_rounded, color: r.$4 ? AppColors.success : AppColors.danger, size: 18)),
              const SizedBox(width: 12),
              Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Text(r.$1, style: AppText.body2.copyWith(color: AppColors.textDarker)),
                const SizedBox(height: 2),
                Text(r.$2, style: AppText.body3Regular),
              ])),
              Text('${r.$3} pts', style: AppText.body2.copyWith(color: r.$4 ? AppColors.success : AppColors.danger, fontWeight: FontWeight.w700)),
            ]),
          ),
      ],
    );
  }
}
