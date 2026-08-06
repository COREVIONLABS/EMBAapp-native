import 'package:flutter/material.dart';
import '../theme/app_theme.dart';
import '../widgets/app_widgets.dart';
import '../widgets/sub_scaffold.dart';
import '../widgets/action_sheets.dart';
import '../model/fan_model.dart';
import '../l10n/strings.dart';

class _Match {
  final String opp;
  final Color color;
  final String when;
  const _Match(this.opp, this.color, this.when);
}

const _upcoming = [
  _Match('Dortmund', Color(0xFF1A1A1A), 'Sat. 12 Apr · 15:30 · Veltins-Arena'),
  _Match('Nürnberg', Color(0xFF002F63), 'Sat. 19 Apr · 15:30 · Veltins-Arena'),
  _Match('Köln', Color(0xFF002F63), 'Sat. 26 Apr · 15:30 · Veltins-Arena'),
];

/// Predictions (Figma 2145:13125) — Upcoming / Past Results.
class PredictionsScreen extends StatefulWidget {
  const PredictionsScreen({super.key});
  @override
  State<PredictionsScreen> createState() => _PredictionsScreenState();
}

class _PredictionsScreenState extends State<PredictionsScreen> {
  int _seg = 0;
  @override
  Widget build(BuildContext context) {
    return SubScaffold(
      title: tr('Predictions'),
      children: [
        Container(
          padding: const EdgeInsets.all(4),
          decoration: BoxDecoration(color: AppColors.surfaceMinimal, borderRadius: BorderRadius.circular(AppRadii.pill)),
          child: Row(
            children: [
              for (var i = 0; i < 2; i++)
                Expanded(
                  child: GestureDetector(
                    onTap: () => setState(() => _seg = i),
                    child: Container(
                      padding: const EdgeInsets.symmetric(vertical: 10),
                      decoration: BoxDecoration(
                        color: i == _seg ? AppColors.surface : Colors.transparent,
                        borderRadius: BorderRadius.circular(AppRadii.pill),
                      ),
                      child: Center(child: Text(i == 0 ? tr('Upcoming') : tr('Past Results'), style: AppText.body2.copyWith(color: i == _seg ? AppColors.brandPrimary : AppColors.textLight, fontWeight: FontWeight.w700))),
                    ),
                  ),
                ),
            ],
          ),
        ),
        const SizedBox(height: 16),
        if (_seg == 0) ...[
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(color: const Color(0xFFFFF3DC), borderRadius: BorderRadius.circular(AppRadii.tile)),
            child: Row(children: [
              const Icon(Icons.emoji_events_rounded, color: AppColors.gold, size: 20),
              const SizedBox(width: 10),
              Text(tr('Earn +50 pts for a correct prediction!'), style: AppText.body2.copyWith(color: AppColors.onAccent)),
            ]),
          ),
          const SizedBox(height: 16),
          for (final m in _upcoming) ...[_MatchCard(m), const SizedBox(height: 12)],
        ] else ...[
          _ResultCard(opp: 'Freiburg', score: '2 : 1', predicted: '2 : 1', correct: true),
          const SizedBox(height: 12),
          _ResultCard(opp: 'Leipzig', score: '0 : 3', predicted: '1 : 1', correct: false),
        ],
      ],
    );
  }
}

class _MatchCard extends StatelessWidget {
  final _Match m;
  const _MatchCard(this.m);
  @override
  Widget build(BuildContext context) {
    return SurfaceCard(
      child: Column(
        children: [
          Text(m.when, style: AppText.body3Regular),
          const SizedBox(height: 14),
          Row(
            children: [
              Expanded(child: _team('Schalke 04', AppColors.brandPrimary, isS04: true)),
              Text(tr('VS'), style: AppText.body2.copyWith(color: AppColors.textLight, fontWeight: FontWeight.w700)),
              Expanded(child: _team(m.opp, m.color)),
            ],
          ),
          const SizedBox(height: 16),
          Builder(
            builder: (context) => SizedBox(
              width: double.infinity,
              height: 44,
              child: OutlinedButton(
                onPressed: () => Navigator.of(context).push(MaterialPageRoute(builder: (_) => PredictScoreScreen(opp: m.opp, color: m.color, when: m.when))),
                style: OutlinedButton.styleFrom(
                  side: const BorderSide(color: AppColors.brandPrimary),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppRadii.pill)),
                ),
                child: Row(mainAxisSize: MainAxisSize.min, children: [
                  Text(tr('Predict Score'), style: AppText.body2.copyWith(color: AppColors.brandPrimary, fontWeight: FontWeight.w700)),
                  const SizedBox(width: 6),
                  const Icon(Icons.arrow_forward_rounded, size: 16, color: AppColors.brandPrimary),
                ]),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _team(String name, Color color, {bool isS04 = false}) {
    return Column(
      children: [
        isS04
            ? const Svg('logo_s04', size: 44)
            : Container(
                width: 44, height: 44,
                decoration: BoxDecoration(color: color, shape: BoxShape.circle),
                alignment: Alignment.center,
                child: Text(name.characters.first, style: const TextStyle(fontFamily: 'Urbanist', color: Colors.white, fontWeight: FontWeight.w800)),
              ),
        const SizedBox(height: 6),
        Text(name, maxLines: 1, overflow: TextOverflow.ellipsis, style: AppText.body3),
      ],
    );
  }
}

class _ResultCard extends StatelessWidget {
  final String opp;
  final String score;
  final String predicted;
  final bool correct;
  const _ResultCard({required this.opp, required this.score, required this.predicted, required this.correct});
  @override
  Widget build(BuildContext context) {
    return SurfaceCard(
      child: Row(
        children: [
          Expanded(child: Text('Schalke 04  $score  $opp', style: AppText.body2.copyWith(color: AppColors.textDarker, fontWeight: FontWeight.w700))),
          Pill(
            color: correct ? AppColors.successBg : AppColors.surfaceMinimal,
            child: Text(correct ? '✓ $predicted' : '✗ $predicted', style: AppText.caption1.copyWith(color: correct ? AppColors.success : AppColors.textLight, fontSize: 11)),
          ),
        ],
      ),
    );
  }
}

/// Predict Score entry (Figma 2145:13317).
class PredictScoreScreen extends StatefulWidget {
  final String opp;
  final Color color;
  final String when;
  const PredictScoreScreen({super.key, required this.opp, required this.color, required this.when});
  @override
  State<PredictScoreScreen> createState() => _PredictScoreScreenState();
}

class _PredictScoreScreenState extends State<PredictScoreScreen> {
  int _h = 0, _a = 0;
  @override
  Widget build(BuildContext context) {
    return SubScaffold(
      title: tr('Predict Score'),
      bottomBar: PrimaryButton(tr('Submit Prediction'), onTap: () async {
        FanModel.addPoints(50); // credit for taking part
        await showSuccessSheet(context,
            title: 'Prediction submitted!',
            message: 'Schalke $_h : $_a ${widget.opp} · +50 points. A correct score wins you more — good luck!');
        if (context.mounted) Navigator.of(context).maybePop();
      }),
      children: [
        const SizedBox(height: 8),
        Text(widget.when, textAlign: TextAlign.center, style: AppText.body3Regular),
        const SizedBox(height: 24),
        Row(
          children: [
            Expanded(child: Column(children: [const Svg('logo_s04', size: 64), const SizedBox(height: 8), Text(tr('Schalke 04'), style: AppText.body2)])),
            _stepper(_h, (v) => setState(() => _h = v)),
            Padding(padding: const EdgeInsets.symmetric(horizontal: 8), child: Text(tr(':'), style: AppText.h2)),
            _stepper(_a, (v) => setState(() => _a = v)),
            Expanded(child: Column(children: [
              Container(width: 64, height: 64, decoration: BoxDecoration(color: widget.color, shape: BoxShape.circle), alignment: Alignment.center, child: Text(widget.opp.characters.first, style: const TextStyle(fontFamily: 'Urbanist', color: Colors.white, fontSize: 26, fontWeight: FontWeight.w800))),
              const SizedBox(height: 8),
              Text(widget.opp, maxLines: 1, overflow: TextOverflow.ellipsis, style: AppText.body2),
            ])),
          ],
        ),
      ],
    );
  }

  Widget _stepper(int value, ValueChanged<int> onChanged) {
    return Column(children: [
      _btn(Icons.keyboard_arrow_up_rounded, () => onChanged(value + 1)),
      Padding(padding: const EdgeInsets.symmetric(vertical: 4), child: Text('$value', style: AppText.h2.copyWith(color: AppColors.brandPrimary))),
      _btn(Icons.keyboard_arrow_down_rounded, () => onChanged(value > 0 ? value - 1 : 0)),
    ]);
  }

  Widget _btn(IconData icon, VoidCallback onTap) => InkWell(
        onTap: onTap,
        child: Container(decoration: BoxDecoration(color: AppColors.brandLightest, borderRadius: BorderRadius.circular(8)), child: Icon(icon, color: AppColors.brandPrimary, size: 24)),
      );
}
