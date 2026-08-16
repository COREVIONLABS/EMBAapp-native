import 'dart:async';
import 'package:flutter/material.dart';
import '../theme/app_theme.dart';
import '../widgets/app_widgets.dart';
import '../widgets/sub_scaffold.dart';
import '../widgets/filter_bar.dart';
import '../widgets/action_sheets.dart';
import '../model/fan_model.dart';
import 'player_vote_screen.dart';
import '../l10n/strings.dart';

/// A fan vote. Socios-style: a poll is either **binding** (the club implements
/// the winning option) or **advisory** (guidance only). Ended polls show the
/// decided outcome; running polls flip to "ending soon" in their last 24h.
class _Poll {
  final String title;
  final String sender; // club / star / who's asking
  final String category; // Matchday / Kit / Squad / Fun
  final IconData icon;
  final List<Color> gradient;
  final List<String> options;
  final List<int> shares; // final vote-share %
  final Duration endsIn;
  final int reward;
  final bool binding; // club implements the winning option
  final int participants; // total votes cast (social proof)
  final bool ended;
  const _Poll(this.title, this.sender, this.category, this.icon, this.gradient, this.options, this.shares, this.endsIn, this.reward,
      {this.binding = true, this.participants = 0, this.ended = false});

  int get winner {
    var wi = 0;
    for (var i = 1; i < shares.length; i++) {
      if (shares[i] > shares[wi]) wi = i;
    }
    return wi;
  }
}

enum _Status { open, endingSoon, ended }

/// Fan Polls — a Socios-inspired voting feed. Fans decide real club matters
/// (captain, kit, walk-out song, goal celebration, matchday MotM …). Each poll
/// shows whether it's **binding** (the club will implement the result) plus how
/// many fans have voted, a live countdown and result bars once decided.
class FanPollsScreen extends StatefulWidget {
  const FanPollsScreen({super.key});
  @override
  State<FanPollsScreen> createState() => _FanPollsScreenState();
}

class _FanPollsScreenState extends State<FanPollsScreen> {
  static const _polls = <_Poll>[
    _Poll('Kapitän gegen den BVB', 'FC Schalke 04', 'Squad', Icons.military_tech_rounded, [Color(0xFF0A2A5E), Color(0xFF000D22)],
        ['Luca Brandt · Nr. 7', 'Deniz Aydin · Nr. 10', 'Malik Osei · Nr. 9'], [46, 33, 21], Duration(days: 2, hours: 4, minutes: 12), 30, participants: 8420),
    _Poll('Torjubel der Saison', 'FC Schalke 04', 'Fun', Icons.celebration_rounded, [Color(0xFFB54708), Color(0xFF7A2E00)],
        ['Knappen-Salut', 'Nordkurve-Sprung', 'Kumpel-Handschlag'], [39, 44, 17], Duration(hours: 18, minutes: 40), 20, participants: 15240),
    _Poll('Drittes Trikot 25/26', 'Fans entscheiden das Design', 'Kit', Icons.checkroom_rounded, [Color(0xFF6A1B9A), Color(0xFF311B92)],
        ['Retro Weiß', 'Königsblau Camo', 'Schwarz-Gold'], [28, 41, 31], Duration(days: 5, hours: 9), 30, participants: 22110),
    _Poll('Einlauf-Song am Heimspiel', 'Nordkurve', 'Matchday', Icons.music_note_rounded, [Color(0xFF00695C), Color(0xFF003D33)],
        ['Steigerlied', 'Blau und Weiß', 'Königsblauer S04'], [52, 27, 21], Duration(days: 1, hours: 3), 20, participants: 11870),
    _Poll('Wandbild an der Nordtribüne', 'FC Schalke 04', 'Fun', Icons.brush_rounded, [Color(0xFF1B5E20), Color(0xFF0B2E10)],
        ['Legenden-Collage', 'Meisterschaft 1958', 'Fan-Mosaik'], [34, 29, 37], Duration(days: 8, hours: 2), 25, binding: false, participants: 6410),
    _Poll('Spieler des Spiels · Derbysieg', 'FC Schalke 04', 'Matchday', Icons.star_rounded, [Color(0xFF1D2939), Color(0xFF000D22)],
        ['Luca Brandt', 'Deniz Aydin', 'Jonas Weber'], [58, 27, 15], Duration.zero, 0, binding: false, participants: 31280, ended: true),
  ];
  static const _cats = ['All', 'Matchday', 'Kit', 'Squad', 'Fun'];

  String _cat = 'All';
  final Map<int, int> _selected = {}; // pre-vote selection
  final Map<int, int> _voted = {}; // confirmed vote
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

  Duration _left(int i) {
    final d = _ends[i].difference(DateTime.now());
    return d.isNegative ? Duration.zero : d;
  }

  _Status _status(int i) {
    if (_polls[i].ended || _left(i) == Duration.zero) return _Status.ended;
    return _left(i) < const Duration(hours: 24) ? _Status.endingSoon : _Status.open;
  }

  bool _match(int i) => _cat == 'All' || _polls[i].category == _cat;

  void _vote(int i) {
    final o = _selected[i];
    if (o == null) return;
    setState(() => _voted[i] = o);
    showSuccessSheet(context, title: 'Stimme gezählt!', message: trp('Thanks for voting — +{n} points added.', n: '${_polls[i].reward}'));
  }

  @override
  Widget build(BuildContext context) {
    final open = [for (var i = 0; i < _polls.length; i++) if (_status(i) != _Status.ended && _match(i)) i];
    final closed = [for (var i = 0; i < _polls.length; i++) if (_status(i) == _Status.ended && _match(i)) i];
    return SubScaffold(
      title: tr('Fan votes'),
      children: [
        // Compact hero
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(gradient: const LinearGradient(colors: AppColors.pointsGradient), borderRadius: BorderRadius.circular(AppRadii.card)),
          child: Row(children: [
            Container(width: 44, height: 44, decoration: BoxDecoration(color: Colors.white.withValues(alpha: 0.14), borderRadius: BorderRadius.circular(13)), child: const Icon(Icons.how_to_vote_rounded, color: AppColors.gold, size: 24)),
            const SizedBox(width: 14),
            Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text(tr('Shape real club decisions'), style: AppText.label2.copyWith(color: Colors.white)),
              const SizedBox(height: 2),
              Text(tr('Vote on the captain, the kit and more — and earn points.'), style: AppText.body3.copyWith(color: Colors.white70)),
            ])),
          ]),
        ),
        const SizedBox(height: 12),
        // How voting works — the binding/advisory explainer (Socios-style, honest).
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(color: AppColors.brandLightest, borderRadius: BorderRadius.circular(AppRadii.tile)),
          child: Row(children: [
            Icon(Icons.gavel_rounded, size: 16, color: AppColors.brandPrimary),
            const SizedBox(width: 8),
            Expanded(child: Text(tr('Binding votes are implemented by the club · 1 fan = 1 vote.'), style: AppText.caption1.copyWith(color: AppColors.onAccent, fontWeight: FontWeight.w600))),
          ]),
        ),
        const SizedBox(height: 20),
        // Featured — Player of the Month (rich screen)
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
        const SizedBox(height: 20),
        // Category chips (shared filter system)
        CategoryChips(categories: _cats, selected: _cat, onSelect: (c) => setState(() => _cat = c), labelOf: (c) => c == 'All' ? tr('All') : tr(c)),
        const SizedBox(height: 20),
        // Open votes feed
        Text(tr('Open votes'), style: AppText.label1),
        const SizedBox(height: 12),
        if (open.isEmpty)
          _emptyState()
        else
          for (final i in open) ...[_pollCard(i), const SizedBox(height: 14)],
        // Closed votes
        if (closed.isNotEmpty) ...[
          const SizedBox(height: 8),
          Text(tr('Closed votes'), style: AppText.label1),
          const SizedBox(height: 12),
          for (final i in closed) ...[_pollCard(i), const SizedBox(height: 14)],
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

  Widget _emptyState() => Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(vertical: 36, horizontal: 20),
        decoration: BoxDecoration(color: AppColors.surfaceMinimal, borderRadius: BorderRadius.circular(AppRadii.card)),
        child: Column(children: [
          Container(width: 60, height: 60, decoration: const BoxDecoration(color: Colors.white, shape: BoxShape.circle), child: Icon(Icons.how_to_vote_rounded, size: 28, color: AppColors.textLight)),
          const SizedBox(height: 14),
          Text(tr('No open vote right now'), style: AppText.body2.copyWith(color: AppColors.textDarker, fontWeight: FontWeight.w800)),
          const SizedBox(height: 4),
          Text(tr('New fan votes drop regularly — check back soon.'), textAlign: TextAlign.center, style: AppText.body3Regular),
        ]),
      );

  Widget _statusBadge(_Status st) {
    final (label, bg, fg) = switch (st) {
      _Status.open => (tr('OPEN'), AppColors.success, Colors.white),
      _Status.endingSoon => (tr('ENDING SOON'), const Color(0xFFE08600), Colors.white),
      _Status.ended => (tr('CLOSED'), Colors.black.withValues(alpha: 0.45), Colors.white),
    };
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(color: bg, borderRadius: BorderRadius.circular(999)),
      child: Row(mainAxisSize: MainAxisSize.min, children: [
        if (st != _Status.ended) Container(width: 6, height: 6, decoration: const BoxDecoration(color: Colors.white, shape: BoxShape.circle)),
        if (st != _Status.ended) const SizedBox(width: 5),
        Text(label, style: AppText.caption1.copyWith(color: fg, fontWeight: FontWeight.w800, fontSize: 10)),
      ]),
    );
  }

  // ── A single vote card — visual band (status + binding + sender + question),
  //    a meta row (binding + participants), then options / results. ──
  Widget _pollCard(int i) {
    final p = _polls[i];
    final st = _status(i);
    final left = _left(i);
    final voted = _voted[i];
    final showResults = voted != null || st == _Status.ended;
    final grad = st == _Status.ended ? const [Color(0xFF3A3F47), Color(0xFF20242B)] : p.gradient;
    return Opacity(
      opacity: st == _Status.ended ? 0.94 : 1,
      child: Container(
        clipBehavior: Clip.antiAlias,
        decoration: BoxDecoration(color: AppColors.surface, borderRadius: BorderRadius.circular(AppRadii.card), border: Border.all(color: AppColors.borderLightest)),
        child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
          // Visual band
          SizedBox(
            height: 130,
            child: Stack(fit: StackFit.expand, children: [
              DecoratedBox(decoration: BoxDecoration(gradient: LinearGradient(colors: grad, begin: Alignment.topLeft, end: Alignment.bottomRight))),
              Positioned(right: -12, bottom: -18, child: Icon(p.icon, size: 120, color: Colors.white.withValues(alpha: 0.12))),
              Padding(
                padding: const EdgeInsets.all(14),
                child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  Row(children: [
                    _statusBadge(st),
                    const SizedBox(width: 8),
                    Pill(color: Colors.black.withValues(alpha: 0.4), child: Text(tr(p.category), style: AppText.caption1.copyWith(color: Colors.white, fontWeight: FontWeight.w700, fontSize: 10))),
                    const Spacer(),
                    if (st != _Status.ended && p.reward > 0)
                      Pill(gradient: const LinearGradient(colors: AppColors.goldGradient), child: Text('+${p.reward}', style: AppText.caption1.copyWith(color: AppColors.brandDarkest, fontWeight: FontWeight.w800))),
                  ]),
                  const Spacer(),
                  Row(children: [
                    Icon(Icons.verified_rounded, size: 13, color: Colors.white.withValues(alpha: 0.8)),
                    const SizedBox(width: 5),
                    Flexible(child: Text(tr(p.sender), maxLines: 1, overflow: TextOverflow.ellipsis, style: AppText.caption1.copyWith(color: Colors.white70, fontWeight: FontWeight.w700))),
                  ]),
                  const SizedBox(height: 4),
                  Text(tr(p.title), maxLines: 2, overflow: TextOverflow.ellipsis, style: AppText.label1.copyWith(color: Colors.white, height: 1.1)),
                ]),
              ),
            ]),
          ),
          // Body
          Padding(
            padding: const EdgeInsets.all(14),
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              // Meta: binding chip + participants (social proof).
              Row(children: [
                Pill(
                  color: p.binding ? AppColors.successBg : AppColors.surfaceMinimal,
                  child: Row(mainAxisSize: MainAxisSize.min, children: [
                    Icon(p.binding ? Icons.gavel_rounded : Icons.chat_bubble_outline_rounded, size: 11, color: p.binding ? AppColors.success : AppColors.textLight),
                    const SizedBox(width: 4),
                    Text(p.binding ? tr('Binding — will be implemented') : tr('Advisory'), style: AppText.caption1.copyWith(color: p.binding ? AppColors.success : AppColors.textNormal, fontWeight: FontWeight.w800, fontSize: 10)),
                  ]),
                ),
                const Spacer(),
                Icon(Icons.groups_rounded, size: 14, color: AppColors.textLight),
                const SizedBox(width: 4),
                Text('${FanModel.fmtPublic(p.participants)} ${tr('fans')}', style: AppText.caption1.copyWith(color: AppColors.textLight, fontWeight: FontWeight.w700)),
              ]),
              const SizedBox(height: 12),
              // Countdown / status line.
              Row(children: [
                Icon(st == _Status.ended ? Icons.flag_rounded : Icons.schedule_rounded, size: 14, color: st == _Status.endingSoon ? const Color(0xFFE08600) : AppColors.textLight),
                const SizedBox(width: 6),
                Text(
                  st == _Status.ended
                      ? tr('Voting closed')
                      : '${tr('Ends in')} ${left.inDays > 0 ? '${left.inDays}d ' : ''}${left.inHours % 24}h ${left.inMinutes % 60}m',
                  style: AppText.caption1.copyWith(color: st == _Status.endingSoon ? const Color(0xFFE08600) : AppColors.textLight, fontWeight: FontWeight.w700),
                ),
                if (voted != null) ...[
                  const Spacer(),
                  const Icon(Icons.check_circle_rounded, size: 14, color: AppColors.brandPrimary),
                  const SizedBox(width: 4),
                  Text(tr('You voted'), style: AppText.caption1.copyWith(color: AppColors.brandPrimary, fontWeight: FontWeight.w700)),
                ],
              ]),
              // Decided-outcome banner for closed polls.
              if (st == _Status.ended) ...[
                const SizedBox(height: 12),
                Container(
                  padding: const EdgeInsets.all(11),
                  decoration: BoxDecoration(color: AppColors.brandLightest, borderRadius: BorderRadius.circular(AppRadii.tile)),
                  child: Row(children: [
                    const Icon(Icons.emoji_events_rounded, size: 16, color: AppColors.gold),
                    const SizedBox(width: 8),
                    Expanded(child: Text(
                      p.binding
                          ? '${tr('Chosen by the fans')}: ${tr(p.options[p.winner])} · ${tr('will be implemented')}'
                          : '${tr('Chosen by the fans')}: ${tr(p.options[p.winner])}',
                      style: AppText.caption1.copyWith(color: AppColors.onAccent, fontWeight: FontWeight.w700))),
                  ]),
                ),
              ],
              const SizedBox(height: 12),
              for (var o = 0; o < p.options.length; o++) ...[
                if (o > 0) const SizedBox(height: 8),
                showResults ? _resultRow(p, o, voted) : _selectRow(i, o),
              ],
              // Your-influence feedback after voting.
              if (voted != null) ...[
                const SizedBox(height: 10),
                Row(children: [
                  Icon(voted == p.winner ? Icons.thumb_up_rounded : Icons.groups_rounded, size: 14, color: voted == p.winner ? AppColors.success : AppColors.textLight),
                  const SizedBox(width: 6),
                  Expanded(child: Text(
                    voted == p.winner ? tr('You’re with the majority.') : trp('The majority chose {a}.', a: tr(p.options[p.winner])),
                    style: AppText.caption1.copyWith(color: voted == p.winner ? AppColors.success : AppColors.textLight, fontWeight: FontWeight.w700))),
                ]),
              ],
              if (!showResults) ...[
                const SizedBox(height: 14),
                Opacity(
                  opacity: _selected[i] != null ? 1 : 0.5,
                  child: PrimaryButton(
                    tr('Vote now'),
                    onTap: _selected[i] != null ? () => _vote(i) : null,
                  ),
                ),
              ],
            ]),
          ),
        ]),
      ),
    );
  }

  // Selectable option (pre-vote).
  Widget _selectRow(int i, int o) {
    final chosen = _selected[i] == o;
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: () => setState(() => _selected[i] = o),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
        decoration: BoxDecoration(
          color: chosen ? AppColors.brandLightest : AppColors.surface,
          borderRadius: BorderRadius.circular(AppRadii.tile),
          border: Border.all(color: chosen ? AppColors.brandPrimary : AppColors.borderLightest, width: chosen ? 1.6 : 1),
        ),
        child: Row(children: [
          Icon(chosen ? Icons.radio_button_checked_rounded : Icons.radio_button_unchecked_rounded, size: 20, color: chosen ? AppColors.brandPrimary : AppColors.textLight),
          const SizedBox(width: 10),
          Expanded(child: Text(tr(_polls[i].options[o]), style: AppText.body2.copyWith(color: AppColors.textDarker, fontWeight: FontWeight.w600))),
        ]),
      ),
    );
  }

  // Result row with a share bar (post-vote / ended).
  Widget _resultRow(_Poll p, int o, int? voted) {
    final share = p.shares[o];
    final chosen = voted == o;
    final isWinner = o == p.winner;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 11),
      decoration: BoxDecoration(
        color: chosen ? AppColors.brandLightest : AppColors.surface,
        borderRadius: BorderRadius.circular(AppRadii.tile),
        border: Border.all(color: chosen ? AppColors.brandPrimary : AppColors.borderLightest, width: chosen ? 1.6 : 1),
      ),
      child: Column(children: [
        Row(children: [
          if (chosen) ...[const Icon(Icons.check_circle_rounded, size: 16, color: AppColors.brandPrimary), const SizedBox(width: 8)]
          else if (isWinner) ...[const Icon(Icons.emoji_events_rounded, size: 16, color: AppColors.gold), const SizedBox(width: 8)],
          Expanded(child: Text(tr(p.options[o]), style: AppText.body2.copyWith(color: AppColors.textDarker, fontWeight: (chosen || isWinner) ? FontWeight.w800 : FontWeight.w600))),
          Text('$share%', style: AppText.body2.copyWith(color: AppColors.brandPrimary, fontWeight: FontWeight.w800)),
        ]),
        const SizedBox(height: 8),
        ClipRRect(
          borderRadius: BorderRadius.circular(4),
          child: LinearProgressIndicator(value: share / 100, minHeight: 6, backgroundColor: AppColors.surfaceLowContrast, valueColor: AlwaysStoppedAnimation(chosen ? AppColors.brandPrimary : (isWinner ? AppColors.gold : AppColors.borderLightest))),
        ),
      ]),
    );
  }
}
