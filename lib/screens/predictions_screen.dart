import 'package:flutter/material.dart';
import '../theme/app_theme.dart';
import '../widgets/app_widgets.dart';
import '../widgets/sub_scaffold.dart';

/// Predictions + Predict Score (Figma 429:2291 / 430:3576 / 430:4302).
class PredictionsScreen extends StatelessWidget {
  const PredictionsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return SubScaffold(
      title: 'Predictions',
      children: const [
        _PredictCard(home: 'Schalke 04', away: 'Bayern', league: 'Bundesliga · Sat 18:30', open: true),
        SizedBox(height: 12),
        _PredictCard(home: 'Dortmund', away: 'Schalke 04', league: 'Bundesliga · Next Wed', open: true),
        SizedBox(height: 20),
        Padding(padding: EdgeInsets.only(bottom: 8), child: SectionHeader('Past Results', action: null)),
        _ResultCard(home: 'Schalke 04', away: 'Freiburg', score: '2 : 1', predicted: '2 : 1', correct: true),
        SizedBox(height: 12),
        _ResultCard(home: 'Leipzig', away: 'Schalke 04', score: '3 : 0', predicted: '1 : 1', correct: false),
      ],
    );
  }
}

class _PredictCard extends StatefulWidget {
  final String home;
  final String away;
  final String league;
  final bool open;
  const _PredictCard({required this.home, required this.away, required this.league, required this.open});
  @override
  State<_PredictCard> createState() => _PredictCardState();
}

class _PredictCardState extends State<_PredictCard> {
  int _h = 0;
  int _a = 0;

  @override
  Widget build(BuildContext context) {
    return SurfaceCard(
      child: Column(
        children: [
          Text(widget.league, style: AppText.body3Regular),
          const SizedBox(height: 14),
          Row(
            children: [
              Expanded(child: _team(widget.home)),
              _stepper(_h, (v) => setState(() => _h = v)),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8),
                child: Text(':', style: AppText.h4),
              ),
              _stepper(_a, (v) => setState(() => _a = v)),
              Expanded(child: _team(widget.away)),
            ],
          ),
          const SizedBox(height: 16),
          PrimaryButton('Submit Prediction', height: 46, onTap: () {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text('Predicted ${widget.home} $_h : $_a ${widget.away}')),
            );
          }),
        ],
      ),
    );
  }

  Widget _team(String name) {
    return Column(
      children: [
        const Svg('logo_s04', size: 40),
        const SizedBox(height: 6),
        Text(name, textAlign: TextAlign.center, maxLines: 1, overflow: TextOverflow.ellipsis, style: AppText.body3),
      ],
    );
  }

  Widget _stepper(int value, ValueChanged<int> onChanged) {
    return Column(
      children: [
        _btn(Icons.keyboard_arrow_up_rounded, () => onChanged(value + 1)),
        Text('$value', style: AppText.h4.copyWith(color: AppColors.brandPrimary)),
        _btn(Icons.keyboard_arrow_down_rounded, () => onChanged(value > 0 ? value - 1 : 0)),
      ],
    );
  }

  Widget _btn(IconData icon, VoidCallback onTap) => InkWell(
        onTap: onTap,
        child: Container(
          margin: const EdgeInsets.symmetric(vertical: 2),
          decoration: BoxDecoration(color: AppColors.brandLightest, borderRadius: BorderRadius.circular(8)),
          child: Icon(icon, color: AppColors.brandPrimary, size: 22),
        ),
      );
}

class _ResultCard extends StatelessWidget {
  final String home;
  final String away;
  final String score;
  final String predicted;
  final bool correct;
  const _ResultCard(
      {required this.home,
      required this.away,
      required this.score,
      required this.predicted,
      required this.correct});
  @override
  Widget build(BuildContext context) {
    return SurfaceCard(
      child: Row(
        children: [
          Expanded(
            child: Text('$home  $score  $away',
                style: AppText.body2.copyWith(color: AppColors.textDarker, fontWeight: FontWeight.w700)),
          ),
          Pill(
            color: correct ? AppColors.successBg : AppColors.surfaceMinimal,
            child: Text(correct ? '✓ $predicted' : '✗ $predicted',
                style: AppText.caption1
                    .copyWith(color: correct ? AppColors.success : AppColors.textLight, fontSize: 11)),
          ),
        ],
      ),
    );
  }
}
