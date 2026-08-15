import 'dart:async';
import 'package:flutter/material.dart';
import '../theme/app_theme.dart';
import '../widgets/app_widgets.dart';
import '../widgets/sub_scaffold.dart';
import '../widgets/action_sheets.dart';
import 'player_vote_screen.dart';
import '../l10n/strings.dart';

/// A fan vote. `ended` polls show final results; running polls flip to
/// "ending soon" in their last 24h.
class _Poll {
  final String title;
  final String sender; // club / star / who's asking
  final IconData icon;
  final List<Color> gradient;
  final List<String> options;
  final List<int> shares; // final vote-share %
  final Duration endsIn;
  final int reward;
  final bool ended;
  const _Poll(this.title, this.sender, this.icon, this.gradient, this.options, this.shares, this.endsIn, this.reward, {this.ended = false});
}

enum _Status { open, endingSoon, ended }

/// Fan Polls — a card-based voting feed (Socios-style): each vote is a large
/// card with a status badge, the club/star behind it, the question, a live
/// countdown and a clear "Jetzt abstimmen" CTA. After voting (or once ended) it
/// shows the result bars.
class FanPollsScreen extends StatefulWidget {
  const FanPollsScreen({super.key});
  @override
  State<FanPollsScreen> createState() => _FanPollsScreenState();
}

class _FanPollsScreenState extends State<FanPollsScreen> {
  static const _polls = <_Poll>[
    _Poll('Kapitän gegen den BVB', 'FC Schalke 04', Icons.military_tech_rounded, [Color(0xFF0A2A5E), Color(0xFF000D22)],
        ['Luca Brandt · Nr. 7', 'Deniz Aydin · Nr. 10', 'Malik Osei · Nr. 9'], [46, 33, 21], Duration(days: 2, hours: 4, minutes: 12), 30),
    _Poll('Einlauf-Song am Heimspiel', 'Nordkurve', Icons.music_note_rounded, [Color(0xFF00695C), Color(0xFF003D33)],
        ['Steigerlied', 'Blau und Weiß', 'Königsblauer S04'], [52, 27, 21], Duration(hours: 18, minutes: 40), 20),
    _Poll('Drittes Trikot 25/26', 'Fans entscheiden das Design', Icons.checkroom_rounded, [Color(0xFF6A1B9A), Color(0xFF311B92)],
        ['Retro Weiß', 'Königsblau Camo', 'Schwarz-Gold'], [28, 41, 31], Duration(days: 5, hours: 9), 30),
    _Poll('Spieler des Spiels · Derbysieg', 'FC Schalke 04', Icons.star_rounded, [Color(0xFF1D2939), Color(0xFF000D22)],
        ['Luca Brandt', 'Deniz Aydin', 'Jonas Weber'], [58, 27, 15], Duration.zero, 0, ended: true),
  ];

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

  void _vote(int i) {
    final o = _selected[i];
    if (o == null) return;
    setState(() => _voted[i] = o);
    showSuccessSheet(context, title: 'Stimme gezählt!', message: trp('Thanks for voting — +{n} points added.', n: '${_polls[i].reward}'));
  }

  @override
  Widget build(BuildContext context) {
    final open = [for (var i = 0; i < _polls.length; i++) if (_status(i) != _Status.ended) i];
    final closed = [for (var i = 0; i < _polls.length; i++) if (_status(i) == _Status.ended) i];
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
        const SizedBox(height: 22),
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

  // ── A single vote card — visual band (status + sender), question, then
  //    options (selectable) + "Jetzt abstimmen", or the result bars. ──
  Widget _pollCard(int i) {
    final p = _polls[i];
    final st = _status(i);
    final left = _left(i);
    final voted = _voted[i];
    final showResults = voted != null || st == _Status.ended;
    final grad = st == _Status.ended ? const [Color(0xFF3A3F47), Color(0xFF20242B)] : p.gradient;
    return Opacity(
      opacity: st == _Status.ended ? 0.92 : 1,
      child: Container(
        clipBehavior: Clip.antiAlias,
        decoration: BoxDecoration(color: AppColors.surface, borderRadius: BorderRadius.circular(AppRadii.card), border: Border.all(color: AppColors.borderLightest)),
        child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
          // Visual band — status, reward, sender, question over a gradient.
          SizedBox(
            height: 128,
            child: Stack(fit: StackFit.expand, children: [
              DecoratedBox(decoration: BoxDecoration(gradient: LinearGradient(colors: grad, begin: Alignment.topLeft, end: Alignment.bottomRight))),
              Positioned(right: -12, bottom: -18, child: Icon(p.icon, size: 120, color: Colors.white.withValues(alpha: 0.12))),
              Padding(
                padding: const EdgeInsets.all(14),
                child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  Row(children: [
                    _statusBadge(st),
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
          // Body — countdown, then options or results, then CTA.
          Padding(
            padding: const EdgeInsets.all(14),
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Row(children: [
                Icon(st == _Status.ended ? Icons.flag_rounded : Icons.schedule_rounded, size: 14, color: st == _Status.endingSoon ? const Color(0xFFE08600) : AppColors.textLight),
                const SizedBox(width: 6),
                Text(
                  st == _Status.ended
                      ? tr('Voting closed')
                      : '${tr('Ends in')} ${left.inDays > 0 ? '${left.inDays}d ' : ''}${left.inHours % 24}h ${left.inMinutes % 60}m',
                  style: AppText.caption1.copyWith(color: st == _Status.endingSoon ? const Color(0xFFE08600) : AppColors.textLight, fontWeight: FontWeight.w700),
                ),
                if (showResults) ...[
                  const Spacer(),
                  Icon(voted != null ? Icons.check_circle_rounded : Icons.bar_chart_rounded, size: 14, color: AppColors.brandPrimary),
                  const SizedBox(width: 4),
                  Text(voted != null ? tr('You voted') : tr('Final result'), style: AppText.caption1.copyWith(color: AppColors.brandPrimary, fontWeight: FontWeight.w700)),
                ],
              ]),
              const SizedBox(height: 12),
              for (var o = 0; o < p.options.length; o++) ...[
                if (o > 0) const SizedBox(height: 8),
                showResults ? _resultRow(p, o, voted) : _selectRow(i, o),
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
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 11),
      decoration: BoxDecoration(
        color: chosen ? AppColors.brandLightest : AppColors.surface,
        borderRadius: BorderRadius.circular(AppRadii.tile),
        border: Border.all(color: chosen ? AppColors.brandPrimary : AppColors.borderLightest, width: chosen ? 1.6 : 1),
      ),
      child: Column(children: [
        Row(children: [
          if (chosen) ...[const Icon(Icons.check_circle_rounded, size: 16, color: AppColors.brandPrimary), const SizedBox(width: 8)],
          Expanded(child: Text(tr(p.options[o]), style: AppText.body2.copyWith(color: AppColors.textDarker, fontWeight: chosen ? FontWeight.w800 : FontWeight.w600))),
          Text('$share%', style: AppText.body2.copyWith(color: AppColors.brandPrimary, fontWeight: FontWeight.w800)),
        ]),
        const SizedBox(height: 8),
        ClipRRect(
          borderRadius: BorderRadius.circular(4),
          child: LinearProgressIndicator(value: share / 100, minHeight: 6, backgroundColor: AppColors.surfaceLowContrast, valueColor: AlwaysStoppedAnimation(chosen ? AppColors.brandPrimary : AppColors.borderLightest)),
        ),
      ]),
    );
  }
}
