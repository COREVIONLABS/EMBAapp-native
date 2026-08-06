import 'package:flutter/material.dart';
import '../theme/app_theme.dart';
import '../model/fan_model.dart';
import '../widgets/app_widgets.dart';
import '../widgets/hub_widgets.dart';
import '../widgets/sub_scaffold.dart';
import 'experience_detail_screen.dart';
import 'raffles_screen.dart';
import '../l10n/strings.dart';

/// Category glyph per experience (calm, brand-consistent navy for all — the
/// glyph does the distinguishing, not the colour).
IconData _catGlyph(String category) => switch (category) {
      'Players' => Icons.sports_soccer_rounded,
      'VIP' => Icons.workspace_premium_rounded,
      'Family' => Icons.family_restroom_rounded,
      _ => Icons.stadium_rounded,
    };

/// Experiences — a showcase of the money-can't-buy experiences a fan can WIN
/// through the monthly tombola. They are never sold for points (points only
/// become vouchers or lots), so every card funnels into the tombola.
class ExperiencesScreen extends StatefulWidget {
  const ExperiencesScreen({super.key});
  @override
  State<ExperiencesScreen> createState() => _ExperiencesScreenState();
}

class _ExperiencesScreenState extends State<ExperiencesScreen> {
  int _cat = 0;
  static const _cats = ['All', 'Stadium', 'Players', 'VIP', 'Family'];

  void _toTombola() => Navigator.of(context).push(MaterialPageRoute(builder: (_) => const RafflesScreen()));

  @override
  Widget build(BuildContext context) {
    final highlights = kExperiences.where((e) => e.featured || e.category == 'VIP' || e.category == 'Players').take(5).toList();
    final more = kExperiences.where((e) => !e.featured && (_cat == 0 || e.category == _cats[_cat])).toList();
    return SubScaffold(
      title: tr('Experiences'),
      children: [
        // Intro — these are tombola prizes, not point purchases.
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(color: AppColors.brandLightest, borderRadius: BorderRadius.circular(AppRadii.card)),
          child: Row(children: [
            Container(width: 44, height: 44, decoration: BoxDecoration(color: AppColors.gold.withValues(alpha: 0.16), borderRadius: BorderRadius.circular(12)), child: const Icon(Icons.emoji_events_rounded, color: AppColors.gold, size: 24)),
            const SizedBox(width: 14),
            Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text(tr('Money-can\'t-buy — won in the tombola'), style: AppText.body2.copyWith(color: AppColors.onAccent, fontWeight: FontWeight.w800)),
              Text(tr('Enter the monthly draw with lots for your chance.'), style: AppText.body3.copyWith(color: AppColors.onAccent)),
            ])),
          ]),
        ),
        const SizedBox(height: 20),
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
        const SectionHeader('Top prizes', action: null),
        const SizedBox(height: 12),
        SizedBox(
          height: 194,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            itemCount: highlights.length,
            separatorBuilder: (_, __) => const SizedBox(width: 12),
            itemBuilder: (_, i) {
              final e = highlights[i];
              return FeaturedImageCard(
                title: e.title,
                subtitle: e.venue,
                category: e.category,
                glyph: _catGlyph(e.category),
                gradient: AppColors.pointsGradient,
                badge: e.featured ? 'Featured' : 'Tombola prize',
                onTap: () => Navigator.of(context).push(MaterialPageRoute(builder: (_) => ExperienceDetailScreen(exp: e))),
              );
            },
          ),
        ),
        const SizedBox(height: 20),
        const SectionHeader('More prizes', action: null),
        const SizedBox(height: 12),
        for (final e in more) ...[_ExpRow(e), const SizedBox(height: 10)],
        const SizedBox(height: 6),
        PrimaryButton(tr('Open Tombola'), onTap: _toTombola),
      ],
    );
  }
}

class _ExpRow extends StatelessWidget {
  final FanExperience e;
  const _ExpRow(this.e);
  @override
  Widget build(BuildContext context) {
    return SurfaceCard(
      onTap: () => Navigator.of(context).push(MaterialPageRoute(builder: (_) => ExperienceDetailScreen(exp: e))),
      padding: const EdgeInsets.all(12),
      child: Row(children: [
        Container(width: 52, height: 52, decoration: BoxDecoration(color: AppColors.brandLightest, borderRadius: BorderRadius.circular(12)), child: const Icon(Icons.emoji_events_rounded, color: AppColors.brandPrimary)),
        const SizedBox(width: 12),
        Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text(tr(e.title), maxLines: 1, overflow: TextOverflow.ellipsis, style: AppText.body2.copyWith(color: AppColors.textDarker, fontWeight: FontWeight.w700)),
          const SizedBox(height: 2),
          Text('${e.date} · ${e.venue}', maxLines: 1, overflow: TextOverflow.ellipsis, style: AppText.body3Regular),
        ])),
        const SizedBox(width: 8),
        Pill(color: AppColors.gold.withValues(alpha: 0.16), child: Text(tr('Tombola prize'), style: AppText.caption1.copyWith(color: const Color(0xFF9A6B00), fontWeight: FontWeight.w800))),
      ]),
    );
  }
}
