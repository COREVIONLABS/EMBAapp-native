import 'package:flutter/material.dart';
import '../theme/app_theme.dart';
import '../widgets/app_widgets.dart';
import '../widgets/sub_scaffold.dart';
import '../widgets/action_sheets.dart';
import '../l10n/strings.dart';

/// A candidate for Player of the Month. Squad placeholders (number + position)
/// so no real identity is implied in this prototype.
class _Candidate {
  final int number;
  final String name;
  final String position;
  final int share; // current vote share %
  const _Candidate(this.number, this.name, this.position, this.share);
}

/// Player of the Month — a club-emotional monthly vote. Casting a vote earns
/// Fan Points and shows the live standings, tying loyalty to the squad.
class PlayerVoteScreen extends StatefulWidget {
  const PlayerVoteScreen({super.key});

  @override
  State<PlayerVoteScreen> createState() => _PlayerVoteScreenState();
}

class _PlayerVoteScreenState extends State<PlayerVoteScreen> {
  static const _candidates = <_Candidate>[
    _Candidate(7, 'Nr. 7 · Flügelspieler', 'Winger', 38),
    _Candidate(10, 'Nr. 10 · Spielmacher', 'Playmaker', 27),
    _Candidate(9, 'Nr. 9 · Mittelstürmer', 'Striker', 21),
    _Candidate(1, 'Nr. 1 · Torwart', 'Keeper', 14),
  ];

  int? _selected;
  bool _voted = false;

  @override
  Widget build(BuildContext context) {
    return SubScaffold(
      title: tr('Player of the Month'),
      bottomBar: _voted
          ? null
          : PrimaryButton(
              _selected == null ? tr('Select a player to vote') : '${tr('Cast my vote')} · +50 ${tr('pts')}',
              onTap: _selected == null
                  ? null
                  : () {
                      setState(() => _voted = true);
                      showSuccessSheet(context,
                          title: 'Vote counted!',
                          message: 'Thanks for backing your player. +50 Fan Points added — results are announced after the last match of the month.');
                    },
            ),
      children: [
        // ── Hero ──
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(gradient: const LinearGradient(colors: AppColors.pointsGradient), borderRadius: BorderRadius.circular(AppRadii.card)),
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Row(children: [
              const Icon(Icons.emoji_events_rounded, color: AppColors.gold, size: 22),
              const SizedBox(width: 8),
              Text(tr('August · your call'), style: AppText.body2.copyWith(color: Colors.white)),
              const Spacer(),
              Pill(gradient: const LinearGradient(colors: AppColors.goldGradient), child: Text('+50 ${tr('pts')}', style: AppText.caption1.copyWith(color: AppColors.brandDarkest, fontWeight: FontWeight.w800))),
            ]),
            const SizedBox(height: 14),
            Text(tr('Who was your Knappe of the month?'), style: AppText.h4.copyWith(color: Colors.white)),
            const SizedBox(height: 4),
            Text(tr('Vote once. Earn points. See the live standings.'), style: AppText.body3.copyWith(color: Colors.white70)),
          ]),
        ),
        const SizedBox(height: 20),
        Align(alignment: Alignment.centerLeft, child: Text(_voted ? tr('Live standings') : tr('The nominees'), style: AppText.label1)),
        const SizedBox(height: 12),
        for (var i = 0; i < _candidates.length; i++) ...[
          _CandidateRow(
            c: _candidates[i],
            selected: _selected == i,
            voted: _voted,
            onTap: _voted ? null : () => setState(() => _selected = i),
          ),
          const SizedBox(height: 10),
        ],
        const SizedBox(height: 6),
        Row(children: [
          Icon(Icons.info_outline_rounded, size: 14, color: AppColors.textLight),
          const SizedBox(width: 6),
          Expanded(child: Text(tr('One vote per fan per month. The winner is revealed on matchday.'), style: AppText.caption1.copyWith(color: AppColors.textLight))),
        ]),
      ],
    );
  }
}

class _CandidateRow extends StatelessWidget {
  final _Candidate c;
  final bool selected;
  final bool voted;
  final VoidCallback? onTap;
  const _CandidateRow({required this.c, required this.selected, required this.voted, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Tappable(
      scale: onTap == null ? 1.0 : 0.99,
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: selected ? AppColors.brandLightest : AppColors.surface,
          borderRadius: BorderRadius.circular(AppRadii.tile),
          border: Border.all(color: selected ? AppColors.brandPrimary : AppColors.borderLightest, width: selected ? 1.6 : 1),
        ),
        child: Column(children: [
          Row(children: [
            // Squad number badge
            Container(
              width: 44, height: 44,
              decoration: BoxDecoration(gradient: const LinearGradient(colors: AppColors.pointsGradient), borderRadius: BorderRadius.circular(12)),
              alignment: Alignment.center,
              child: Text('${c.number}', style: const TextStyle(fontFamily: 'Urbanist', color: Colors.white, fontSize: 18, fontWeight: FontWeight.w800)),
            ),
            const SizedBox(width: 14),
            Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text(tr(c.name), style: AppText.body2.copyWith(color: AppColors.textDarker, fontWeight: FontWeight.w700)),
              Text(tr(c.position), style: AppText.body3Regular),
            ])),
            if (voted)
              Text('${c.share}%', style: AppText.label2.copyWith(color: AppColors.brandPrimary))
            else
              Icon(selected ? Icons.check_circle_rounded : Icons.radio_button_unchecked_rounded, color: selected ? AppColors.brandPrimary : AppColors.textLight, size: 24),
          ]),
          if (voted) ...[
            const SizedBox(height: 10),
            ClipRRect(
              borderRadius: BorderRadius.circular(4),
              child: LinearProgressIndicator(value: c.share / 100, minHeight: 6, backgroundColor: AppColors.surfaceLowContrast, valueColor: const AlwaysStoppedAnimation(AppColors.brandPrimary)),
            ),
          ],
        ]),
      ),
    );
  }
}
