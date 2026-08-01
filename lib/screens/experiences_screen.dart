import 'package:flutter/material.dart';
import '../theme/app_theme.dart';
import '../model/fan_model.dart';
import '../widgets/app_widgets.dart';
import '../widgets/hub_widgets.dart';
import '../widgets/sub_scaffold.dart';
import 'experience_detail_screen.dart';
import 'my_bookings_screen.dart';
import '../l10n/strings.dart';

/// Branded gradient + glyph per experience category (stand-in for photos).
(List<Color>, IconData) _catStyle(String category) => switch (category) {
      'Players' => ([const Color(0xFF6A1B9A), const Color(0xFF311B92)], Icons.sports_soccer_rounded),
      'VIP' => ([const Color(0xFF2A2440), const Color(0xFF0B0616)], Icons.workspace_premium_rounded),
      'Family' => ([const Color(0xFF00897B), const Color(0xFF004D40)], Icons.family_restroom_rounded),
      'Raffle' => ([const Color(0xFFC62828), const Color(0xFF7F1414)], Icons.local_activity_rounded),
      _ => (AppColors.pointsGradient, Icons.stadium_rounded),
    };

/// Experiences (Figma 2162:6476).
class ExperiencesScreen extends StatefulWidget {
  const ExperiencesScreen({super.key});
  @override
  State<ExperiencesScreen> createState() => _ExperiencesScreenState();
}

class _ExperiencesScreenState extends State<ExperiencesScreen> {
  int _cat = 0;
  static const _cats = ['All', 'Raffle', 'Stadium', 'Players', 'VIP', 'Family'];
  @override
  Widget build(BuildContext context) {
    final highlights = kExperiences.where((e) => e.featured || e.category == 'VIP' || e.category == 'Players').take(5).toList();
    final upcoming = kExperiences.where((e) => !e.featured && (_cat == 0 || e.category == _cats[_cat])).toList();
    return SubScaffold(
      title: tr('Experiences'),
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
                child: Text(tr(_cats[i]), style: AppText.body2.copyWith(color: i == _cat ? Colors.white : AppColors.textNormal, fontWeight: FontWeight.w600)),
              ),
            ),
          ),
        ),
        const SizedBox(height: 16),
        const SectionHeader('Highlights', action: null),
        const SizedBox(height: 12),
        SizedBox(
          height: 194,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            itemCount: highlights.length,
            separatorBuilder: (_, __) => const SizedBox(width: 12),
            itemBuilder: (_, i) {
              final e = highlights[i];
              final style = _catStyle(e.category);
              return FeaturedImageCard(
                title: e.title,
                subtitle: e.pointsLabel,
                category: e.category,
                glyph: style.$2,
                gradient: style.$1,
                badge: e.featured ? 'Featured' : (e.raffle ? 'Raffle' : null),
                onTap: () => Navigator.of(context).push(MaterialPageRoute(builder: (_) => ExperienceDetailScreen(exp: e))),
              );
            },
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
            Row(children: [
              Flexible(child: Text(tr(e.title), maxLines: 1, overflow: TextOverflow.ellipsis, style: AppText.body2.copyWith(color: AppColors.textDarker))),
              if (e.raffle) ...[
                const SizedBox(width: 6),
                Pill(gradient: const LinearGradient(colors: AppColors.goldGradient), padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2), child: Text(tr('Raffle'), style: AppText.caption1.copyWith(color: AppColors.brandDarkest, fontWeight: FontWeight.w700, fontSize: 10))),
              ],
            ]),
            const SizedBox(height: 2),
            Text('${e.date} · ${e.venue}', style: AppText.body3Regular),
          ])),
          Text(e.raffle ? tr('Enter') : e.pointsLabel, style: AppText.body2.copyWith(color: AppColors.brandPrimary, fontWeight: FontWeight.w700)),
        ]),
      ),
    );
  }
}
