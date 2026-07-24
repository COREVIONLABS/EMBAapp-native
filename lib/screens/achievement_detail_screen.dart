import 'package:flutter/material.dart';
import '../theme/app_theme.dart';
import '../widgets/app_widgets.dart';
import '../widgets/sub_scaffold.dart';

/// Achievement Detail (Figma 2162:6817).
class AchievementDetailScreen extends StatelessWidget {
  final String name;
  final IconData icon;
  final bool unlocked;
  const AchievementDetailScreen({super.key, required this.name, required this.icon, required this.unlocked});
  @override
  Widget build(BuildContext context) {
    return SubScaffold(
      title: 'Achievement',
      children: [
        const SizedBox(height: 12),
        Center(
          child: Container(
            width: 120,
            height: 120,
            decoration: BoxDecoration(color: unlocked ? AppColors.brandLightest : AppColors.surfaceMinimal, shape: BoxShape.circle),
            child: Icon(icon, size: 60, color: unlocked ? AppColors.brandPrimary : AppColors.textLight),
          ),
        ),
        const SizedBox(height: 20),
        Center(child: Text(name, style: AppText.h4)),
        const SizedBox(height: 8),
        Center(child: Pill(color: unlocked ? AppColors.successBg : AppColors.surfaceMinimal, child: Text(unlocked ? 'Unlocked' : 'Locked', style: AppText.caption1.copyWith(color: unlocked ? AppColors.success : AppColors.textLight)))),
        const SizedBox(height: 24),
        Text('How to earn', style: AppText.label2),
        const SizedBox(height: 6),
        Text('Complete the required action to unlock the "$name" badge and earn bonus Fan Points. Badges show off your status on your fan profile.',
            style: AppText.body1.copyWith(color: AppColors.textNormal, height: 1.6, fontSize: 14)),
        const SizedBox(height: 16),
        SurfaceCard(
          child: Row(children: [
            const Icon(Icons.card_giftcard_rounded, color: AppColors.brandPrimary),
            const SizedBox(width: 12),
            Expanded(child: Text('Reward: +250 Fan Points', style: AppText.body2.copyWith(color: AppColors.textDarker))),
          ]),
        ),
      ],
    );
  }
}
