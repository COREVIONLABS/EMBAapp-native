import 'package:flutter/material.dart';
import '../theme/app_theme.dart';
import '../widgets/app_widgets.dart';
import '../widgets/sub_scaffold.dart';
import '../l10n/strings.dart';

/// Season Collection — a Panini-style digital sticker album. Fans earn or
/// win stickers through activity and drops; completing sets unlocks rewards.
/// A retention loop that gives points a collectible destination.
class CollectionScreen extends StatelessWidget {
  const CollectionScreen({super.key});

  // (name, owned, rare)
  static const _stickers = [
    ('Karaman', true, false),
    ('Terodde', true, true),
    ('Kaminski', true, false),
    ('Höwedt', false, false),
    ('Brunner', true, false),
    ('Murkin', false, false),
    ('Kalas', true, false),
    ('Aydın', false, true),
    ('Sylla', true, false),
    ('Bülter', false, false),
    ('Grüger', true, false),
    ('Coach', false, true),
  ];

  @override
  Widget build(BuildContext context) {
    final owned = _stickers.where((s) => s.$2).length;
    final total = _stickers.length;
    return SubScaffold(
      title: tr('Season Collection'),
      bottomBar: PrimaryButton(tr('Open a sticker pack · 200 pts')),
      children: [
        // Progress
        Container(
          padding: const EdgeInsets.all(18),
          decoration: BoxDecoration(gradient: const LinearGradient(colors: AppColors.pointsGradient), borderRadius: BorderRadius.circular(AppRadii.card)),
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Row(children: [
              Text(tr('Team 25/26'), style: AppText.label2.copyWith(color: Colors.white)),
              const Spacer(),
              Text('$owned / $total', style: AppText.label2.copyWith(color: AppColors.gold)),
            ]),
            const SizedBox(height: 10),
            ClipRRect(
              borderRadius: BorderRadius.circular(4),
              child: LinearProgressIndicator(value: owned / total, minHeight: 8, backgroundColor: Colors.white24, valueColor: const AlwaysStoppedAnimation(AppColors.gold)),
            ),
            const SizedBox(height: 10),
            Text(tr('Complete the set to win 2 VIP tickets'), style: AppText.body3.copyWith(color: Colors.white70)),
          ]),
        ),
        const SizedBox(height: 20),
        Text(tr('Your stickers'), style: AppText.label1),
        const SizedBox(height: 12),
        GridView.count(
          crossAxisCount: 3,
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          mainAxisSpacing: 12,
          crossAxisSpacing: 12,
          childAspectRatio: 0.72,
          children: [
            for (final s in _stickers) _StickerTile(name: s.$1, owned: s.$2, rare: s.$3),
          ],
        ),
      ],
    );
  }
}

class _StickerTile extends StatelessWidget {
  final String name;
  final bool owned;
  final bool rare;
  const _StickerTile({required this.name, required this.owned, required this.rare});
  @override
  Widget build(BuildContext context) {
    return Container(
      clipBehavior: Clip.antiAlias,
      decoration: BoxDecoration(
        color: owned ? AppColors.surface : AppColors.surfaceMinimal,
        borderRadius: BorderRadius.circular(AppRadii.tile),
        border: Border.all(color: rare && owned ? AppColors.gold : AppColors.borderLightest, width: rare && owned ? 1.6 : 1),
      ),
      child: Column(children: [
        Expanded(
          child: Container(
            width: double.infinity,
            color: owned ? AppColors.brandLightest : Colors.transparent,
            child: owned
                ? Column(mainAxisAlignment: MainAxisAlignment.center, children: [
                    Container(width: 44, height: 44, decoration: BoxDecoration(shape: BoxShape.circle, gradient: const LinearGradient(colors: AppColors.pointsGradient)), alignment: Alignment.center, child: Text(name.characters.first, style: const TextStyle(fontFamily: 'Urbanist', color: Colors.white, fontSize: 18, fontWeight: FontWeight.w800))),
                    if (rare) ...[
                      const SizedBox(height: 6),
                      const Icon(Icons.star_rounded, color: AppColors.gold, size: 16),
                    ],
                  ])
                : const Center(child: Icon(Icons.help_outline_rounded, color: AppColors.textLight, size: 28)),
          ),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 7, horizontal: 4),
          child: Text(owned ? name : tr('Missing'), textAlign: TextAlign.center, maxLines: 1, overflow: TextOverflow.ellipsis, style: AppText.caption1.copyWith(color: owned ? AppColors.textDarker : AppColors.textLight, fontWeight: FontWeight.w700)),
        ),
      ]),
    );
  }
}
