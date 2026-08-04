import 'package:flutter/material.dart';
import '../theme/app_theme.dart';
import '../widgets/app_widgets.dart';
import '../widgets/sub_scaffold.dart';
import '../l10n/strings.dart';

class _Question {
  final String q;
  final List<String> options;
  final int answer; // index of correct option
  final int points;
  const _Question(this.q, this.options, this.answer, this.points);
}

/// Live Matchday Quiz — a fast, in-game quiz that runs on matchday (AFL fan-zone
/// style). Answer live questions for Fan Points. Gated behind the matchday demo
/// state so it only appears when there's a game on.
class MatchdayQuizScreen extends StatefulWidget {
  const MatchdayQuizScreen({super.key});

  @override
  State<MatchdayQuizScreen> createState() => _MatchdayQuizScreenState();
}

class _MatchdayQuizScreenState extends State<MatchdayQuizScreen> {
  static const _questions = <_Question>[
    _Question('In which year was FC Schalke 04 founded?', ['1904', '1919', '1892', '1948'], 0, 50),
    _Question('What is the VELTINS-Arena\'s nickname?', ['Der Tempel', 'Auf Schalke', 'Nordkurve', 'Die Knappen'], 1, 50),
    _Question('How many German championships has S04 won?', ['3', '5', '7', '9'], 2, 75),
    _Question('Who does Schalke meet in the Revierderby?', ['Bayern', 'Dortmund', 'Köln', 'Bremen'], 1, 75),
  ];

  int _i = 0;
  int? _picked;
  bool _locked = false;
  int _score = 0;

  void _pick(int idx) {
    if (_locked) return;
    setState(() {
      _picked = idx;
      _locked = true;
      if (idx == _questions[_i].answer) _score += _questions[_i].points;
    });
  }

  void _next() {
    if (_i < _questions.length - 1) {
      setState(() {
        _i++;
        _picked = null;
        _locked = false;
      });
    } else {
      setState(() => _i = _questions.length); // finished
    }
  }

  @override
  Widget build(BuildContext context) {
    final finished = _i >= _questions.length;
    return SubScaffold(
      title: tr('Live Quiz'),
      bottomBar: finished
          ? PrimaryButton(tr('Back to matchday'), onTap: () => Navigator.of(context).pop())
          : (_locked
              ? PrimaryButton(_i == _questions.length - 1 ? tr('See result') : tr('Next question'), onTap: _next)
              : null),
      children: finished ? _result() : _quiz(),
    );
  }

  List<Widget> _result() {
    final max = _questions.fold<int>(0, (a, q) => a + q.points);
    return [
      const SizedBox(height: 8),
      Center(child: Container(
        width: 88, height: 88,
        decoration: BoxDecoration(gradient: const LinearGradient(colors: AppColors.pointsGradient), shape: BoxShape.circle),
        child: const Icon(Icons.emoji_events_rounded, color: AppColors.gold, size: 46),
      )),
      const SizedBox(height: 18),
      Center(child: Text(tr('Full time!'), style: AppText.h4)),
      const SizedBox(height: 6),
      Center(child: Text('${tr('You earned')} +$_score ${tr('of')} $max ${tr('pts')}', textAlign: TextAlign.center, style: AppText.body1.copyWith(color: AppColors.textLight))),
      const SizedBox(height: 20),
      SurfaceCard(child: Row(children: [
        Container(width: 44, height: 44, decoration: BoxDecoration(color: AppColors.successBg, borderRadius: BorderRadius.circular(12)), child: const Icon(Icons.leaderboard_rounded, color: AppColors.success, size: 22)),
        const SizedBox(width: 14),
        Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text(tr('You climbed to #8 on the matchday board'), style: AppText.body2.copyWith(color: AppColors.textDarker, fontWeight: FontWeight.w700)),
          Text(tr('Come back at half-time for the next round'), style: AppText.body3Regular),
        ])),
      ])),
    ];
  }

  List<Widget> _quiz() {
    final que = _questions[_i];
    return [
      // Live header
      Row(children: [
        Pill(color: const Color(0x1AC62828), child: Row(mainAxisSize: MainAxisSize.min, children: [
          Container(width: 7, height: 7, decoration: const BoxDecoration(color: Color(0xFFC62828), shape: BoxShape.circle)),
          const SizedBox(width: 6),
          Text(tr('LIVE'), style: AppText.caption1.copyWith(color: const Color(0xFFC62828), fontWeight: FontWeight.w800)),
        ])),
        const Spacer(),
        Text('${tr('Question')} ${_i + 1} ${tr('of')} ${_questions.length}', style: AppText.body3Regular),
      ]),
      const SizedBox(height: 12),
      ClipRRect(
        borderRadius: BorderRadius.circular(4),
        child: LinearProgressIndicator(value: (_i + 1) / _questions.length, minHeight: 6, backgroundColor: AppColors.surfaceLowContrast, valueColor: const AlwaysStoppedAnimation(AppColors.brandPrimary)),
      ),
      const SizedBox(height: 20),
      Row(children: [
        Icon(Icons.stars_rounded, size: 16, color: AppColors.gold),
        const SizedBox(width: 6),
        Text('+${que.points} ${tr('pts')}', style: AppText.body3.copyWith(color: AppColors.textNormal, fontWeight: FontWeight.w700)),
      ]),
      const SizedBox(height: 10),
      Text(tr(que.q), style: AppText.h4.copyWith(color: AppColors.textDarker)),
      const SizedBox(height: 20),
      for (var o = 0; o < que.options.length; o++) ...[
        _OptionRow(
          label: que.options[o],
          state: !_locked
              ? _OptState.idle
              : (o == que.answer ? _OptState.correct : (o == _picked ? _OptState.wrong : _OptState.idle)),
          onTap: () => _pick(o),
        ),
        const SizedBox(height: 10),
      ],
    ];
  }
}

enum _OptState { idle, correct, wrong }

class _OptionRow extends StatelessWidget {
  final String label;
  final _OptState state;
  final VoidCallback onTap;
  const _OptionRow({required this.label, required this.state, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final Color border = switch (state) {
      _OptState.correct => AppColors.success,
      _OptState.wrong => AppColors.danger,
      _OptState.idle => AppColors.borderLightest,
    };
    final Color bg = switch (state) {
      _OptState.correct => AppColors.successBg,
      _OptState.wrong => AppColors.dangerBg,
      _OptState.idle => AppColors.surface,
    };
    return Tappable(
      scale: state == _OptState.idle ? 0.99 : 1.0,
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 15),
        decoration: BoxDecoration(color: bg, borderRadius: BorderRadius.circular(AppRadii.tile), border: Border.all(color: border, width: state == _OptState.idle ? 1 : 1.6)),
        child: Row(children: [
          Expanded(child: Text(tr(label), style: AppText.body1.copyWith(color: AppColors.textDarker, fontSize: 15, fontWeight: FontWeight.w600))),
          if (state == _OptState.correct) const Icon(Icons.check_circle_rounded, color: AppColors.success, size: 22)
          else if (state == _OptState.wrong) const Icon(Icons.cancel_rounded, color: AppColors.danger, size: 22),
        ]),
      ),
    );
  }
}
