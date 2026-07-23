import 'package:flutter/material.dart';
import '../theme/app_theme.dart';
import 'app_widgets.dart';

/// The S04 Fan Points hero card, shared by Home and Points (Figma 2145:7214).
class S04PointsCard extends StatelessWidget {
  final String value;
  final String tickets;
  final String boost;
  const S04PointsCard({super.key, this.value = '2,850', this.tickets = '12 Raffle Tickets', this.boost = '3x Stadium Boost'});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      clipBehavior: Clip.antiAlias,
      decoration: BoxDecoration(
        gradient: const LinearGradient(colors: AppColors.pointsGradient),
        borderRadius: BorderRadius.circular(AppRadii.card),
      ),
      child: Stack(
        children: [
          Positioned(
            left: -23,
            top: -22,
            child: Container(
              width: 193,
              height: 193,
              decoration: BoxDecoration(shape: BoxShape.circle, color: Colors.white.withValues(alpha: 0.05)),
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text('S04 Fan Points', style: AppText.body2.copyWith(color: Colors.white)),
                  Container(
                    padding: const EdgeInsets.fromLTRB(6, 4, 4, 4),
                    decoration: BoxDecoration(color: Colors.white.withValues(alpha: 0.24), borderRadius: BorderRadius.circular(999)),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(Icons.keyboard_double_arrow_down_rounded, size: 14, color: Colors.white),
                        const SizedBox(width: 4),
                        Text('Superfan', style: AppText.caption1.copyWith(color: Colors.white, fontWeight: FontWeight.w600, fontSize: 11)),
                        const SizedBox(width: 4),
                        const Icon(Icons.chevron_right_rounded, size: 14, color: Colors.white),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 6),
              Text(value, style: AppText.h1.copyWith(color: Colors.white)),
              const SizedBox(height: 8),
              Row(
                children: [
                  Pill(color: AppColors.brandDark, child: Text(tickets, style: AppText.caption1.copyWith(color: AppColors.textLightest))),
                  const SizedBox(width: 8),
                  Pill(
                    gradient: const LinearGradient(colors: AppColors.goldGradient),
                    child: Text(boost, style: AppText.caption1.copyWith(color: AppColors.textDarker)),
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }
}
