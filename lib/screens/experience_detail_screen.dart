import 'package:flutter/material.dart';
import '../theme/app_theme.dart';
import '../model/fan_model.dart';
import '../widgets/app_widgets.dart';
import '../widgets/sub_scaffold.dart';
import 'booking_confirmation_screen.dart';
import '../l10n/strings.dart';

/// Experience Detail (Figma 2162:6574).
class ExperienceDetailScreen extends StatelessWidget {
  final FanExperience exp;
  const ExperienceDetailScreen({super.key, required this.exp});
  @override
  Widget build(BuildContext context) {
    return SubScaffold(
      title: '',
      bottomBar: PrimaryButton('Book with ${exp.pointsLabel}', onTap: () {
        Navigator.of(context).push(MaterialPageRoute(builder: (_) => BookingConfirmationScreen(title: exp.title)));
      }),
      children: [
        Container(
          height: 220,
          decoration: BoxDecoration(gradient: const LinearGradient(colors: AppColors.pointsGradient), borderRadius: BorderRadius.circular(AppRadii.card)),
          child: const Center(child: Icon(Icons.stadium_rounded, size: 96, color: Colors.white24)),
        ),
        const SizedBox(height: 20),
        Text(tr(exp.title), style: AppText.h4),
        const SizedBox(height: 8),
        Row(children: [
          Icon(Icons.calendar_today_rounded, size: 16, color: AppColors.textLight),
          const SizedBox(width: 6),
          Text('${exp.date} · ${exp.venue}', style: AppText.body2.copyWith(color: AppColors.textLight)),
        ]),
        const SizedBox(height: 12),
        Pill(gradient: const LinearGradient(colors: AppColors.goldGradient), child: Text(exp.pointsLabel, style: AppText.caption1.copyWith(color: AppColors.brandDarkest))),
        const SizedBox(height: 20),
        Text(tr('About this experience'), style: AppText.label2),
        const SizedBox(height: 6),
        Text(tr('An exclusive FC Schalke 04 experience for Fan+ members. Limited spots available — redeem your Fan Points to secure your place and create memories money can’t buy.'),
            style: AppText.body1.copyWith(color: AppColors.textNormal, height: 1.6, fontSize: 14)),
      ],
    );
  }
}
