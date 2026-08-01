import 'package:flutter/material.dart';
import '../theme/app_theme.dart';
import '../widgets/app_widgets.dart';
import '../widgets/sub_scaffold.dart';
import '../l10n/strings.dart';

/// Matchday Live — the live engagement layer during a game: real-time score,
/// quick live predictions (next goal / next corner) that earn points, and
/// end-of-match MVP voting. Members get a points multiplier on live actions.
class MatchdayLiveScreen extends StatefulWidget {
  const MatchdayLiveScreen({super.key});
  @override
  State<MatchdayLiveScreen> createState() => _MatchdayLiveScreenState();
}

class _MatchdayLiveScreenState extends State<MatchdayLiveScreen> {
  int? _pred;
  int? _mvp;

  static const _mvps = ['Karaman', 'Terodde', 'Kaminski', 'Höwedt'];

  @override
  Widget build(BuildContext context) {
    return SubScaffold(
      title: tr('Matchday Live'),
      children: [
        // Live scoreboard
        Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(gradient: const LinearGradient(colors: AppColors.pointsGradient), borderRadius: BorderRadius.circular(AppRadii.card)),
          child: Column(children: [
            Row(mainAxisAlignment: MainAxisAlignment.center, children: [
              Container(width: 8, height: 8, decoration: const BoxDecoration(color: AppColors.danger, shape: BoxShape.circle)),
              const SizedBox(width: 6),
              Text(tr('LIVE · 67’'), style: AppText.caption1.copyWith(color: Colors.white, fontWeight: FontWeight.w700)),
            ]),
            const SizedBox(height: 14),
            Row(children: [
              Expanded(child: Column(children: [
                const Svg('logo_s04', size: 44),
                const SizedBox(height: 6),
                Text(tr('Schalke'), style: AppText.body3.copyWith(color: Colors.white)),
              ])),
              Text('2 : 1', style: AppText.h1.copyWith(color: Colors.white)),
              Expanded(child: Column(children: [
                Container(width: 44, height: 44, decoration: const BoxDecoration(color: Colors.white24, shape: BoxShape.circle), child: const Icon(Icons.sports_soccer_rounded, color: Colors.white)),
                const SizedBox(height: 6),
                Text(tr('Dortmund'), style: AppText.body3.copyWith(color: Colors.white)),
              ])),
            ]),
          ]),
        ),
        const SizedBox(height: 16),
        // Live prediction
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(color: AppColors.surface, borderRadius: BorderRadius.circular(AppRadii.card), border: Border.all(color: AppColors.borderLightest)),
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Row(children: [
              const Icon(Icons.bolt_rounded, color: AppColors.gold, size: 20),
              const SizedBox(width: 6),
              Expanded(child: Text(tr('Who scores next?'), style: AppText.label2.copyWith(color: AppColors.textDarker))),
              Pill(gradient: const LinearGradient(colors: AppColors.goldGradient), padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3), child: Text('+50 pts · 2× ${tr('member')}', style: AppText.caption1.copyWith(color: AppColors.brandDarkest, fontWeight: FontWeight.w700, fontSize: 10))),
            ]),
            const SizedBox(height: 6),
            Text(tr('Closes in 00:24'), style: AppText.body3Regular),
            const SizedBox(height: 12),
            Row(children: [
              Expanded(child: _ChoiceBtn(label: tr('Schalke'), selected: _pred == 0, onTap: () => setState(() => _pred = 0))),
              const SizedBox(width: 10),
              Expanded(child: _ChoiceBtn(label: tr('No goal'), selected: _pred == 1, onTap: () => setState(() => _pred = 1))),
              const SizedBox(width: 10),
              Expanded(child: _ChoiceBtn(label: tr('Dortmund'), selected: _pred == 2, onTap: () => setState(() => _pred = 2))),
            ]),
          ]),
        ),
        const SizedBox(height: 16),
        // MVP voting
        Text(tr('Vote for MVP'), style: AppText.label1),
        const SizedBox(height: 4),
        Text(tr('Voting opens after the final whistle'), style: AppText.body3Regular),
        const SizedBox(height: 12),
        for (var i = 0; i < _mvps.length; i++) ...[
          GestureDetector(
            onTap: () => setState(() => _mvp = i),
            child: Container(
              padding: const EdgeInsets.all(14),
              margin: const EdgeInsets.only(bottom: 10),
              decoration: BoxDecoration(
                color: _mvp == i ? AppColors.brandLightest : AppColors.surface,
                borderRadius: BorderRadius.circular(AppRadii.tile),
                border: Border.all(color: _mvp == i ? AppColors.brandPrimary : AppColors.borderLightest, width: _mvp == i ? 1.6 : 1),
              ),
              child: Row(children: [
                Container(width: 38, height: 38, decoration: BoxDecoration(shape: BoxShape.circle, gradient: const LinearGradient(colors: AppColors.pointsGradient)), alignment: Alignment.center, child: Text(_mvps[i].characters.first, style: const TextStyle(fontFamily: 'Urbanist', color: Colors.white, fontWeight: FontWeight.w800))),
                const SizedBox(width: 12),
                Expanded(child: Text(_mvps[i], style: AppText.body2.copyWith(color: AppColors.textDarker, fontWeight: FontWeight.w700))),
                Icon(_mvp == i ? Icons.check_circle_rounded : Icons.radio_button_unchecked_rounded, color: _mvp == i ? AppColors.brandPrimary : AppColors.textLight, size: 22),
              ]),
            ),
          ),
        ],
      ],
    );
  }
}

class _ChoiceBtn extends StatelessWidget {
  final String label;
  final bool selected;
  final VoidCallback onTap;
  const _ChoiceBtn({required this.label, required this.selected, required this.onTap});
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12),
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: selected ? AppColors.brandPrimary : AppColors.surfaceMinimal,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Text(label, textAlign: TextAlign.center, maxLines: 1, overflow: TextOverflow.ellipsis, style: AppText.body3.copyWith(color: selected ? Colors.white : AppColors.textNormal, fontWeight: FontWeight.w700)),
      ),
    );
  }
}
