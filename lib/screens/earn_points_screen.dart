import 'package:flutter/material.dart';
import '../theme/app_theme.dart';
import '../model/fan_model.dart';
import '../widgets/app_widgets.dart';
import '../widgets/sub_scaffold.dart';
import 'redeem_screen.dart';
import '../l10n/strings.dart';

class _Way {
  final IconData icon;
  final String title, sub, pts;
  const _Way(this.icon, this.title, this.sub, this.pts);
}

/// Earn Points (Figma 2162:5111) — balance + ways to earn Fan Points.
class EarnPointsScreen extends StatelessWidget {
  const EarnPointsScreen({super.key});

  static const _ways = [
    _Way(Icons.confirmation_number_outlined, 'Attend a Match', 'Earn points for each home match', '+100'),
    _Way(Icons.shopping_bag_outlined, 'Fanshop Purchase', '1 point per €1 spent', '+1/€1'),
    _Way(Icons.share_outlined, 'Share on Social', 'Share Schalke content', '+25'),
    _Way(Icons.group_add_outlined, 'Refer a Friend', 'Invite friends to join', '+200'),
    _Way(Icons.calendar_today_outlined, 'Daily Check-in', 'Open the app every day', '+10'),
    _Way(Icons.person_outline_rounded, 'Complete Profile', 'Fill in all profile fields', '+50'),
  ];

  @override
  Widget build(BuildContext context) {
    return SubScaffold(
      title: tr('Earn Points'),
      children: [
        // Balance card
        Container(
          padding: const EdgeInsets.all(18),
          decoration: BoxDecoration(
            gradient: const LinearGradient(colors: AppColors.pointsGradient),
            borderRadius: BorderRadius.circular(AppRadii.card),
          ),
          child: Row(children: [
            Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(color: Colors.white.withValues(alpha: 0.15), borderRadius: BorderRadius.circular(12)),
              child: const Icon(Icons.monetization_on_rounded, color: AppColors.gold, size: 26),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Text(tr('Your Balance'), style: AppText.body3.copyWith(color: Colors.white70)),
                Text('${FanModel.pointsFormatted} pts', style: AppText.h4.copyWith(color: Colors.white)),
              ]),
            ),
            GestureDetector(
              onTap: () => Navigator.of(context).push(MaterialPageRoute(builder: (_) => const RedeemScreen())),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 9),
                decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(999)),
                child: Row(mainAxisSize: MainAxisSize.min, children: [
                  Text(tr('Redeem'), style: AppText.body3.copyWith(color: AppColors.brandPrimary, fontWeight: FontWeight.w700)),
                  const Icon(Icons.chevron_right_rounded, size: 16, color: AppColors.brandPrimary),
                ]),
              ),
            ),
          ]),
        ),
        const SizedBox(height: 22),
        Align(alignment: Alignment.centerLeft, child: Text(tr('Ways to Earn'), style: AppText.label2)),
        const SizedBox(height: 12),
        for (final w in _ways) ...[
          SurfaceCard(
            child: Row(children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(color: AppColors.brandLightest, borderRadius: BorderRadius.circular(11)),
                child: Icon(w.icon, size: 20, color: AppColors.brandPrimary),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  Text(w.title, style: AppText.body2.copyWith(color: AppColors.textDarker)),
                  const SizedBox(height: 2),
                  Text(w.sub, style: AppText.body3Regular),
                ]),
              ),
              Pill(color: AppColors.brandLightest, child: Text(w.pts, style: AppText.caption1.copyWith(color: AppColors.brandPrimary, fontWeight: FontWeight.w700))),
            ]),
          ),
          const SizedBox(height: 10),
        ],
      ],
    );
  }
}
