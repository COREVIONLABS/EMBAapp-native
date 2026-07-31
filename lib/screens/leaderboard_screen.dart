import 'package:flutter/material.dart';
import '../theme/app_theme.dart';
import '../widgets/app_widgets.dart';
import '../widgets/sub_scaffold.dart';
import '../model/fan_model.dart';
import '../l10n/strings.dart';

/// Top Supporter leaderboard — ranks fans by points *earned* this season only
/// (never by points bought or membership tier), so it can't be paid into.
/// Resets each season; past winners live in the Hall of Fame.
class LeaderboardScreen extends StatefulWidget {
  const LeaderboardScreen({super.key});
  @override
  State<LeaderboardScreen> createState() => _LeaderboardScreenState();
}

class _LeaderboardScreenState extends State<LeaderboardScreen> {
  int _seg = 0;

  // Ranked by points earned this season (engagement only).
  static const _season = [
    ('Nordkurve_Nils', 48210, true),
    ('BlauWeissBabsi', 44980, true),
    ('KnappeKevin', 41120, false),
    ('SchalkeSina', 38750, false),
    ('Max Mustermann', 27430, true), // you
    ('UltraUlf', 25990, false),
    ('FanzoneFatih', 24310, false),
    ('ArenaAnna', 22870, false),
  ];

  @override
  Widget build(BuildContext context) {
    return SubScaffold(
      title: tr('Top Supporters'),
      children: [
        _Segmented(labels: const ['This Season', 'Hall of Fame'], index: _seg, onChanged: (i) => setState(() => _seg = i)),
        const SizedBox(height: 16),
        if (_seg == 0) ..._season2526() else ..._hallOfFame(),
      ],
    );
  }

  List<Widget> _season2526() {
    final rows = <Widget>[
      // Season reset banner
      SurfaceCard(
        color: AppColors.brandLightest,
        child: Row(children: [
          const Icon(Icons.emoji_events_rounded, color: AppColors.gold),
          const SizedBox(width: 12),
          Expanded(child: Text(tr('Ranked by points earned this season — never by points bought. Resets 30 June.'),
              style: AppText.body3.copyWith(color: AppColors.brandDarkest))),
        ]),
      ),
      const SizedBox(height: 16),
    ];
    for (var i = 0; i < _season.length; i++) {
      final r = _season[i];
      final you = r.$1 == 'Max Mustermann';
      rows.add(Padding(
        padding: const EdgeInsets.only(bottom: 8),
        child: _RankRow(rank: i + 1, name: r.$1, points: r.$2, verified: r.$3, you: you),
      ));
    }
    return rows;
  }

  List<Widget> _hallOfFame() {
    const past = [
      ('Season 24/25', 'Nordkurve_Nils', '512,900 pts earned'),
      ('Season 23/24', 'SchalkeSina', '498,140 pts earned'),
      ('Season 22/23', 'UltraUlf', '451,720 pts earned'),
    ];
    return [
      for (final p in past)
        Padding(
          padding: const EdgeInsets.only(bottom: 12),
          child: Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              gradient: const LinearGradient(colors: AppColors.pointsGradient),
              borderRadius: BorderRadius.circular(AppRadii.card),
            ),
            child: Row(children: [
              Container(
                width: 44, height: 44,
                decoration: BoxDecoration(color: Colors.white24, borderRadius: BorderRadius.circular(12)),
                child: const Icon(Icons.workspace_premium_rounded, color: AppColors.gold, size: 24),
              ),
              const SizedBox(width: 14),
              Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Text(tr(p.$1), style: AppText.body3.copyWith(color: Colors.white70)),
                const SizedBox(height: 2),
                Text(p.$2, style: AppText.label2.copyWith(color: Colors.white)),
                Text(tr(p.$3), style: AppText.body3.copyWith(color: Colors.white70)),
              ])),
              const Icon(Icons.star_rounded, color: AppColors.gold),
            ]),
          ),
        ),
    ];
  }
}

class _RankRow extends StatelessWidget {
  final int rank;
  final String name;
  final int points;
  final bool verified;
  final bool you;
  const _RankRow({required this.rank, required this.name, required this.points, required this.verified, required this.you});

  @override
  Widget build(BuildContext context) {
    final medal = rank <= 3;
    final medalColor = rank == 1 ? AppColors.gold : (rank == 2 ? const Color(0xFFB8C0CC) : const Color(0xFFCD8B5A));
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: you ? AppColors.brandLightest : AppColors.surface,
        borderRadius: BorderRadius.circular(AppRadii.tile),
        border: Border.all(color: you ? AppColors.brandPrimary : AppColors.borderLightest, width: you ? 1.5 : 1),
      ),
      child: Row(children: [
        SizedBox(
          width: 28,
          child: medal
              ? Icon(Icons.workspace_premium_rounded, color: medalColor, size: 22)
              : Text('$rank', textAlign: TextAlign.center, style: AppText.label2.copyWith(color: AppColors.textLight)),
        ),
        const SizedBox(width: 8),
        Container(
          width: 38, height: 38,
          decoration: BoxDecoration(shape: BoxShape.circle, gradient: const LinearGradient(colors: AppColors.pointsGradient)),
          alignment: Alignment.center,
          child: Text(name.characters.first, style: const TextStyle(fontFamily: 'Urbanist', color: Colors.white, fontWeight: FontWeight.w800)),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Row(children: [
            Flexible(child: Text(you ? tr('You') : name, overflow: TextOverflow.ellipsis, style: AppText.body2.copyWith(color: AppColors.textDarker, fontWeight: FontWeight.w700))),
            if (verified) ...[
              const SizedBox(width: 4),
              const Icon(Icons.verified_rounded, size: 15, color: AppColors.brandPrimary),
            ],
          ]),
        ),
        Text('${FanModel.fmtPublic(points)} pts', style: AppText.body3.copyWith(color: AppColors.textNormal, fontWeight: FontWeight.w700)),
      ]),
    );
  }
}

class _Segmented extends StatelessWidget {
  final List<String> labels;
  final int index;
  final ValueChanged<int> onChanged;
  const _Segmented({required this.labels, required this.index, required this.onChanged});
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(color: AppColors.surfaceMinimal, borderRadius: BorderRadius.circular(AppRadii.pill)),
      child: Row(
        children: [
          for (var i = 0; i < labels.length; i++)
            Expanded(
              child: GestureDetector(
                onTap: () => onChanged(i),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 180),
                  padding: const EdgeInsets.symmetric(vertical: 10),
                  decoration: BoxDecoration(
                    color: i == index ? AppColors.surface : Colors.transparent,
                    borderRadius: BorderRadius.circular(AppRadii.pill),
                    boxShadow: i == index ? const [BoxShadow(color: Color(0x14000000), blurRadius: 6, offset: Offset(0, 1))] : null,
                  ),
                  child: Center(
                    child: Text(tr(labels[i]), style: AppText.body2.copyWith(color: i == index ? AppColors.brandPrimary : AppColors.textLight, fontWeight: FontWeight.w700)),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}
