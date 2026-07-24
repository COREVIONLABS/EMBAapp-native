import 'package:flutter/material.dart';
import '../theme/app_theme.dart';
import '../widgets/app_widgets.dart';
import '../widgets/sub_scaffold.dart';

/// Club News (Figma 2162:5325).
class ClubNewsScreen extends StatelessWidget {
  const ClubNewsScreen({super.key});

  static const _news = [
    ('Matchday', 'Königsblau secures vital home win against Bayern', '2h ago'),
    ('Transfers', 'Academy talent signs first professional contract', '5h ago'),
    ('Club', 'New Fan+ experiences announced for the spring', 'Yesterday'),
    ('Community', 'Knappenkids visit the Knappenschmiede academy', '2d ago'),
  ];

  @override
  Widget build(BuildContext context) {
    return SubScaffold(
      title: 'Club News',
      children: [
        for (final n in _news)
          Padding(
            padding: const EdgeInsets.only(bottom: 14),
            child: SurfaceCard(
              padding: EdgeInsets.zero,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    height: 150,
                    width: double.infinity,
                    decoration: const BoxDecoration(
                      gradient: LinearGradient(colors: AppColors.pointsGradient),
                      borderRadius: BorderRadius.vertical(top: Radius.circular(AppRadii.tile)),
                    ),
                    child: const Center(child: Icon(Icons.image_rounded, color: Colors.white24, size: 48)),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(14),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(children: [
                          Pill(color: AppColors.brandLightest, child: Text(n.$1, style: AppText.caption1.copyWith(color: AppColors.brandPrimary))),
                          const Spacer(),
                          Text(n.$3, style: AppText.body3Regular),
                        ]),
                        const SizedBox(height: 8),
                        Text(n.$2, style: AppText.label2.copyWith(color: AppColors.textDarker)),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
      ],
    );
  }
}
