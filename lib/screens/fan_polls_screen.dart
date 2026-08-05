import 'dart:async';
import 'package:flutter/material.dart';
import '../theme/app_theme.dart';
import '../widgets/app_widgets.dart';
import '../widgets/sub_scaffold.dart';
import '../widgets/action_sheets.dart';
import 'player_vote_screen.dart';
import '../l10n/strings.dart';

class _Poll {
  final String title;
  final String context;
  final IconData icon;
  final List<String> options;
  final List<int> shares; // vote-share % shown after voting
  final Duration endsIn;
  final int reward;
  const _Poll(this.title, this.context, this.icon, this.options, this.shares, this.endsIn, this.reward);
}

/// Fan Polls — a hub where fans influence real club decisions (captain armband,
/// third kit, walk-out song …) and vote for Player of the Month. Each poll has
/// a live countdown and rewards Fan Points, driving repeat visits (Socios-style).
class FanPollsScreen extends StatefulWidget {
  const FanPollsScreen({super.key});
  @override
  State<FanPollsScreen> createState() => _FanPollsScreenState();
}

class _FanPollsScreenState extends State<FanPollsScreen> {
  static const _polls = <_Poll>[
    _Poll('Kapitän gegen den BVB', 'Revierderby · Startelf', Icons.military_tech_rounded,
        ['Luca Brandt · Nr. 7', 'Deniz Aydin · Nr. 10', 'Malik Osei · Nr. 9'], [46, 33, 21], Duration(days: 2, hours: 4, minutes: 12), 30),
    _Poll('Drittes Trikot 25/26', 'Fans entscheiden das Design', Icons.checkroom_rounded,
        ['Retro Weiß', 'Königsblau Camo', 'Schwarz-Gold'], [28, 41, 31], Duration(days: 5, hours: 9), 30),
    _Poll('Einlauf-Song am Heimspiel', 'Was läuft beim Anpfiff?', Icons.music_note_rounded,
        ['Steigerlied', 'Blau und Weiß', 'Königsblauer S04'], [52, 27, 21], Duration(hours: 20, minutes: 40), 20),
  ];

  final Map<int, int> _voted = {};
  late final List<DateTime> _ends;
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    final now = DateTime.now();
    _ends = [for (final p in _polls) now.add(p.endsIn)];
    _timer = Timer.periodic(const Duration(seconds: 1), (_) {
      if (mounted) setState(() {});
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  String _two(int n) => n.toString().padLeft(2, '0');
  Duration _left(int i) {
    final d = _ends[i].difference(DateTime.now());
    return d.isNegative ? Duration.zero : d;
  }

  void _vote(int poll, int option) {
    setState(() => _voted[poll] = option);
    showSuccessSheet(context, title: 'Stimme gezählt!', message: 'Danke fürs Mitbestimmen — +${_polls[poll].reward} Punkte gutgeschrieben.');
  }

  @override
  Widget build(BuildContext context) {
    return SubScaffold(
      title: tr('Fan votes'),
      children: [
        // Hero
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(gradient: const LinearGradient(colors: AppColors.pointsGradient), borderRadius: BorderRadius.circular(AppRadii.card)),
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Row(children: [
              const Icon(Icons.how_to_vote_rounded, color: AppColors.gold, size: 22),
              const SizedBox(width: 8),
              Text(tr('Your vote counts'), style: AppText.body2.copyWith(color: Colors.white)),
            ]),
            const SizedBox(height: 12),
            Text(tr('Shape real club decisions'), style: AppText.h4.copyWith(color: Colors.white)),
            const SizedBox(height: 4),
            Text(tr('Vote on the captain, the kit and more — and earn points.'), style: AppText.body3.copyWith(color: Colors.white70)),
          ]),
        ),
        const SizedBox(height: 20),
        // Featured: Player of the Month (rich screen)
        Text(tr('Featured vote'), style: AppText.label1),
        const SizedBox(height: 12),
        Tappable(
          scale: 0.98,
          onTap: () => Navigator.of(context).push(MaterialPageRoute(builder: (_) => const PlayerVoteScreen())),
          child: Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(gradient: const LinearGradient(colors: [Color(0xFF0A2A5E), Color(0xFF000D22)]), borderRadius: BorderRadius.circular(AppRadii.card)),
            child: Row(children: [
              Container(width: 48, height: 48, decoration: BoxDecoration(color: Colors.white.withValues(alpha: 0.14), borderRadius: BorderRadius.circular(14)), child: const Icon(Icons.emoji_events_rounded, color: AppColors.gold, size: 26)),
              const SizedBox(width: 14),
              Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Text(tr('Player of the Month'), style: AppText.label2.copyWith(color: Colors.white)),
                const SizedBox(height: 2),
                Text(tr('Back your Knappe — earn +50 points'), style: AppText.body3.copyWith(color: Colors.white70)),
              ])),
              const Icon(Icons.chevron_right_rounded, color: Colors.white54),
            ]),
          ),
        ),
        const SizedBox(height: 22),
        Text(tr('Open polls'), style: AppText.label1),
        const SizedBox(height: 12),
        for (var i = 0; i < _polls.length; i++) ...[
          _PollCard(
            poll: _polls[i],
            left: _left(i),
            two: _two,
            voted: _voted[i],
            onVote: (o) => _vote(i, o),
          ),
          const SizedBox(height: 12),
        ],
        const SizedBox(height: 6),
        Row(children: [
          Icon(Icons.info_outline_rounded, size: 14, color: AppColors.textLight),
          const SizedBox(width: 6),
          Expanded(child: Text(tr('One vote per fan per poll. Results are shared with the club.'), style: AppText.caption1.copyWith(color: AppColors.textLight))),
        ]),
      ],
    );
  }
}

class _PollCard extends StatelessWidget {
  final _Poll poll;
  final Duration left;
  final String Function(int) two;
  final int? voted;
  final ValueChanged<int> onVote;
  const _PollCard({required this.poll, required this.left, required this.two, required this.voted, required this.onVote});

  @override
  Widget build(BuildContext context) {
    return SurfaceCard(
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Row(children: [
          Container(width: 40, height: 40, decoration: BoxDecoration(color: AppColors.brandLightest, borderRadius: BorderRadius.circular(11)), child: Icon(poll.icon, color: AppColors.brandPrimary, size: 20)),
          const SizedBox(width: 12),
          Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text(tr(poll.title), style: AppText.body2.copyWith(color: AppColors.textDarker, fontWeight: FontWeight.w800)),
            Text(tr(poll.context), maxLines: 1, overflow: TextOverflow.ellipsis, style: AppText.body3Regular),
          ])),
        ]),
        const SizedBox(height: 8),
        // Countdown row (flip-clock style)
        Row(children: [
          Text('${tr('Ends in')} ', style: AppText.caption1.copyWith(color: AppColors.textLight)),
          _clock(two(left.inDays)), _colon(), _clock(two(left.inHours % 24)), _colon(), _clock(two(left.inMinutes % 60)),
          const Spacer(),
          Pill(color: AppColors.successBg, child: Text('+${poll.reward}', style: AppText.caption1.copyWith(color: AppColors.success, fontWeight: FontWeight.w800))),
        ]),
        const SizedBox(height: 12),
        for (var o = 0; o < poll.options.length; o++) ...[
          if (o > 0) const SizedBox(height: 8),
          _option(context, o),
        ],
      ]),
    );
  }

  Widget _option(BuildContext context, int o) {
    final hasVoted = voted != null;
    final chosen = voted == o;
    final share = poll.shares[o];
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: hasVoted ? null : () => onVote(o),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 11),
        decoration: BoxDecoration(
          color: chosen ? AppColors.brandLightest : AppColors.surface,
          borderRadius: BorderRadius.circular(AppRadii.tile),
          border: Border.all(color: chosen ? AppColors.brandPrimary : AppColors.borderLightest, width: chosen ? 1.6 : 1),
        ),
        child: Column(children: [
          Row(children: [
            if (!hasVoted) Icon(Icons.radio_button_unchecked_rounded, size: 18, color: AppColors.textLight)
            else Icon(chosen ? Icons.check_circle_rounded : Icons.circle_outlined, size: 18, color: chosen ? AppColors.brandPrimary : AppColors.textLight),
            const SizedBox(width: 10),
            Expanded(child: Text(tr(poll.options[o]), style: AppText.body2.copyWith(color: AppColors.textDarker, fontWeight: FontWeight.w600))),
            if (hasVoted) Text('$share%', style: AppText.body2.copyWith(color: AppColors.brandPrimary, fontWeight: FontWeight.w800)),
          ]),
          if (hasVoted) ...[
            const SizedBox(height: 8),
            ClipRRect(
              borderRadius: BorderRadius.circular(4),
              child: LinearProgressIndicator(value: share / 100, minHeight: 5, backgroundColor: AppColors.surfaceLowContrast, valueColor: AlwaysStoppedAnimation(chosen ? AppColors.brandPrimary : AppColors.borderLightest)),
            ),
          ],
        ]),
      ),
    );
  }

  Widget _clock(String v) => Container(
        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 3),
        decoration: BoxDecoration(color: AppColors.brandPrimary, borderRadius: BorderRadius.circular(6)),
        child: Text(v, style: AppText.caption1.copyWith(color: Colors.white, fontWeight: FontWeight.w800)),
      );
  Widget _colon() => Padding(padding: const EdgeInsets.symmetric(horizontal: 2), child: Text(':', style: AppText.caption1.copyWith(color: AppColors.textLight, fontWeight: FontWeight.w800)));
}
