import 'package:flutter/material.dart';
import '../theme/app_theme.dart';
import '../model/fan_model.dart';
import '../widgets/app_widgets.dart';
import '../widgets/sub_scaffold.dart';
import 'experience_detail_screen.dart';
import 'my_bookings_screen.dart';

/// Experiences (Figma 2162:6476).
class ExperiencesScreen extends StatefulWidget {
  const ExperiencesScreen({super.key});
  @override
  State<ExperiencesScreen> createState() => _ExperiencesScreenState();
}

class _ExperiencesScreenState extends State<ExperiencesScreen> {
  int _cat = 0;
  static const _cats = ['All', 'Stadium', 'Players', 'VIP', 'Family'];
  @override
  Widget build(BuildContext context) {
    final featured = kExperiences.firstWhere((e) => e.featured);
    final upcoming = kExperiences.where((e) => !e.featured && (_cat == 0 || e.category == _cats[_cat])).toList();
    return SubScaffold(
      title: 'Experiences',
      children: [
        SizedBox(
          height: 34,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            itemCount: _cats.length,
            separatorBuilder: (_, __) => const SizedBox(width: 8),
            itemBuilder: (_, i) => GestureDetector(
              onTap: () => setState(() => _cat = i),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 7),
                decoration: BoxDecoration(color: i == _cat ? AppColors.brandPrimary : AppColors.surfaceMinimal, borderRadius: BorderRadius.circular(AppRadii.pill)),
                child: Text(_cats[i], style: AppText.body2.copyWith(color: i == _cat ? Colors.white : AppColors.textNormal, fontWeight: FontWeight.w600)),
              ),
            ),
          ),
        ),
        const SizedBox(height: 16),
        GestureDetector(
          onTap: () => Navigator.of(context).push(MaterialPageRoute(builder: (_) => ExperienceDetailScreen(exp: featured))),
          child: Container(
            height: 150,
            clipBehavior: Clip.antiAlias,
            decoration: BoxDecoration(gradient: const LinearGradient(colors: AppColors.pointsGradient), borderRadius: BorderRadius.circular(AppRadii.card)),
            child: Stack(
              children: [
                const Positioned.fill(child: Icon(Icons.stadium_rounded, size: 120, color: Colors.white10)),
                Positioned(left: 16, top: 16, child: Pill(color: AppColors.brandPrimary, child: Text('Featured', style: AppText.caption1.copyWith(color: Colors.white)))),
                Positioned(
                  left: 16, right: 16, bottom: 16,
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                        Text(featured.title, style: AppText.label1.copyWith(color: Colors.white)),
                        Text(featured.date, style: AppText.body3.copyWith(color: Colors.white70)),
                      ])),
                      Text(featured.pointsLabel, style: AppText.label2.copyWith(color: AppColors.gold)),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 20),
        SectionHeader('Upcoming', onAction: () => Navigator.of(context).push(MaterialPageRoute(builder: (_) => const MyBookingsScreen()))),
        const SizedBox(height: 12),
        for (final e in upcoming) ...[_ExpRow(e), const SizedBox(height: 10)],
      ],
    );
  }
}

class _ExpRow extends StatelessWidget {
  final FanExperience e;
  const _ExpRow(this.e);
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => Navigator.of(context).push(MaterialPageRoute(builder: (_) => ExperienceDetailScreen(exp: e))),
      child: SurfaceCard(
        padding: const EdgeInsets.all(12),
        child: Row(children: [
          Container(width: 52, height: 52, decoration: BoxDecoration(gradient: const LinearGradient(colors: AppColors.pointsGradient), borderRadius: BorderRadius.circular(12)), child: const Icon(Icons.event_rounded, color: Colors.white70)),
          const SizedBox(width: 12),
          Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text(e.title, style: AppText.body2.copyWith(color: AppColors.textDarker)),
            const SizedBox(height: 2),
            Text('${e.date} · ${e.venue}', style: AppText.body3Regular),
          ])),
          Text(e.pointsLabel, style: AppText.body2.copyWith(color: AppColors.brandPrimary, fontWeight: FontWeight.w700)),
        ]),
      ),
    );
  }
}
