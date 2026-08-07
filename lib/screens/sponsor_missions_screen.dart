import 'package:flutter/material.dart';
import '../theme/app_theme.dart';
import '../widgets/app_widgets.dart';
import '../widgets/sub_scaffold.dart';
import '../widgets/action_sheets.dart';
import '../model/sponsor_missions.dart';
import '../model/fan_model.dart';
import '../l10n/strings.dart';

/// Sponsor Missions — the club's third revenue stream made tangible. Partners
/// pay to activate fans (watch, survey, scan, share); the fan earns Fan Points.
/// Every card is co-branded "powered by `sponsor`". Pushed from Home / Earn.
class SponsorMissionsScreen extends StatelessWidget {
  const SponsorMissionsScreen({super.key});

  Future<void> _run(BuildContext context, SponsorMission m) async {
    bool ok = false;
    switch (m.kind) {
      case MissionKind.watch:
        ok = await _showFlow(context, _WatchFlow(mission: m));
      case MissionKind.survey:
        ok = await _showFlow(context, _SurveyFlow(mission: m));
      case MissionKind.quiz:
        ok = await _showFlow(context, _QuizFlow(mission: m));
      case MissionKind.receipt:
        ok = await _showFlow(context, _ReceiptFlow(mission: m));
      case MissionKind.share:
        await showShareSheet(context, subject: '${tr(m.title)} · ${m.sponsor}');
        ok = true;
    }
    if (!ok || !context.mounted) return;
    sponsorMissionStore.complete(m);
    FanModel.addPoints(m.reward);
    await showSuccessSheet(context,
        title: trp('You earned {n} points', n: '${m.reward}'),
        message: '${m.sponsor} ${tr('funded this reward — it’s been added to your balance.')}');
  }

  Future<bool> _showFlow(BuildContext context, Widget sheet) async {
    final r = await showModalBottomSheet<bool>(
      context: context,
      backgroundColor: AppColors.surface,
      isScrollControlled: true,
      isDismissible: true,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(28))),
      builder: (_) => sheet,
    );
    return r ?? false;
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: sponsorMissionStore,
      builder: (context, _) {
        final open = sponsorMissionStore.open;
        final done = sponsorMissionStore.completed;
        return SubScaffold(
          title: tr('Sponsor missions'),
          children: [
            // Hero — the "partners reward you" story.
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(18),
              decoration: BoxDecoration(
                gradient: const LinearGradient(begin: Alignment.topLeft, end: Alignment.bottomRight, colors: [Color(0xFF0A2A5E), Color(0xFF000D22)]),
                borderRadius: BorderRadius.circular(AppRadii.card),
              ),
              child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Row(children: [
                  const Icon(Icons.handshake_rounded, color: AppColors.gold, size: 22),
                  const SizedBox(width: 8),
                  Text(tr('Our partners reward you'), style: AppText.label1.copyWith(color: Colors.white)),
                ]),
                const SizedBox(height: 6),
                Text(tr('Complete a partner mission and the sponsor pays you in Fan Points.'),
                    style: AppText.body3.copyWith(color: Colors.white70)),
                const SizedBox(height: 14),
                Row(children: [
                  const Icon(Icons.hexagon_rounded, size: 16, color: AppColors.gold),
                  const SizedBox(width: 6),
                  Text('+${FanModel.fmtPublic(sponsorMissionStore.availablePoints)} ${tr('pts')}', style: AppText.body2.copyWith(color: Colors.white, fontWeight: FontWeight.w800)),
                  const SizedBox(width: 6),
                  Text(tr('to earn right now'), style: AppText.body3.copyWith(color: Colors.white60)),
                ]),
              ]),
            ),
            const SizedBox(height: 20),

            if (open.isNotEmpty) ...[
              Align(alignment: Alignment.centerLeft, child: Text(tr('Open missions'), style: AppText.label1)),
              const SizedBox(height: 12),
              for (final m in open) ...[
                _MissionCard(mission: m, onTap: () => _run(context, m)),
                const SizedBox(height: 12),
              ],
            ],

            const SizedBox(height: 4),
            Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(color: AppColors.brandLightest, borderRadius: BorderRadius.circular(AppRadii.tile)),
              child: Row(children: [
                Icon(Icons.info_outline_rounded, size: 18, color: AppColors.brandPrimary),
                const SizedBox(width: 10),
                Expanded(child: Text(tr('Fresh missions drop every week — the more you do, the more the sponsors give back.'), style: AppText.body3.copyWith(color: AppColors.onAccent))),
              ]),
            ),

            if (done.isNotEmpty) ...[
              const SizedBox(height: 24),
              Align(alignment: Alignment.centerLeft, child: Text(tr('Completed'), style: AppText.label1)),
              const SizedBox(height: 12),
              for (final m in done) ...[
                _MissionCard(mission: m, onTap: null),
                const SizedBox(height: 12),
              ],
            ],
          ],
        );
      },
    );
  }
}

/// Co-branded mission card: sponsor mark + "powered by", the ask, a kind chip
/// and the reward. Flips to a done state once completed.
class _MissionCard extends StatelessWidget {
  final SponsorMission mission;
  final VoidCallback? onTap;
  const _MissionCard({required this.mission, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final m = mission;
    return Tappable(
      scale: 0.98,
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: m.done ? AppColors.surfaceMinimal : AppColors.surface,
          borderRadius: BorderRadius.circular(AppRadii.card),
          border: Border.all(color: AppColors.borderLightest),
        ),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Row(children: [
            Container(
              width: 46, height: 46,
              decoration: BoxDecoration(color: m.sponsorColor, borderRadius: BorderRadius.circular(13)),
              child: Icon(m.sponsorIcon, color: Colors.white, size: 24),
            ),
            const SizedBox(width: 12),
            Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text('${tr('powered by')} ${m.sponsor}', style: AppText.caption1.copyWith(color: AppColors.textLight, fontWeight: FontWeight.w700)),
              const SizedBox(height: 2),
              Text(tr(m.title), maxLines: 2, overflow: TextOverflow.ellipsis, style: AppText.body2.copyWith(color: AppColors.textDarker, fontWeight: FontWeight.w800)),
            ])),
            const SizedBox(width: 8),
            if (m.done)
              const Icon(Icons.check_circle_rounded, color: AppColors.success, size: 24)
            else
              Pill(gradient: const LinearGradient(colors: AppColors.goldGradient), child: Text('+${m.reward}', style: AppText.caption1.copyWith(color: AppColors.brandDarkest, fontWeight: FontWeight.w800))),
          ]),
          const SizedBox(height: 12),
          Text(tr(m.blurb), style: AppText.body3.copyWith(color: AppColors.textNormal)),
          const SizedBox(height: 14),
          Row(children: [
            Pill(color: AppColors.brandLightest, child: Row(mainAxisSize: MainAxisSize.min, children: [
              Icon(m.kindIcon, size: 13, color: AppColors.brandPrimary),
              const SizedBox(width: 5),
              Text(tr(m.kindLabel), style: AppText.caption1.copyWith(color: AppColors.brandPrimary, fontWeight: FontWeight.w800)),
            ])),
            const Spacer(),
            if (m.done)
              Text(tr('Done'), style: AppText.body3.copyWith(color: AppColors.success, fontWeight: FontWeight.w800))
            else
              Row(children: [
                Text(tr(m.cta), style: AppText.body3.copyWith(color: AppColors.brandPrimary, fontWeight: FontWeight.w800)),
                const Icon(Icons.chevron_right_rounded, size: 18, color: AppColors.brandPrimary),
              ]),
          ]),
        ]),
      ),
    );
  }
}

// ── Shared sheet chrome ──
Widget _sheetHandle() => Center(
      child: Container(width: 40, height: 4, margin: const EdgeInsets.only(bottom: 16), decoration: BoxDecoration(color: AppColors.borderLightest, borderRadius: BorderRadius.circular(2))),
    );

Widget _sponsorTag(SponsorMission m) => Row(children: [
      Container(width: 32, height: 32, decoration: BoxDecoration(color: m.sponsorColor, borderRadius: BorderRadius.circular(9)), child: Icon(m.sponsorIcon, color: Colors.white, size: 17)),
      const SizedBox(width: 10),
      Expanded(child: Text('${tr('powered by')} ${m.sponsor}', style: AppText.caption1.copyWith(color: AppColors.textLight, fontWeight: FontWeight.w700))),
      Pill(gradient: const LinearGradient(colors: AppColors.goldGradient), child: Text('+${m.reward}', style: AppText.caption1.copyWith(color: AppColors.brandDarkest, fontWeight: FontWeight.w800))),
    ]);

/// Watch-to-earn: a sponsor clip stand-in whose progress bar fills, then unlocks
/// the reward.
class _WatchFlow extends StatefulWidget {
  final SponsorMission mission;
  const _WatchFlow({required this.mission});
  @override
  State<_WatchFlow> createState() => _WatchFlowState();
}

class _WatchFlowState extends State<_WatchFlow> with SingleTickerProviderStateMixin {
  late final AnimationController _c = AnimationController(vsync: this, duration: const Duration(seconds: 4))
    ..addListener(() => setState(() {}))
    ..forward();

  @override
  void dispose() {
    _c.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final m = widget.mission;
    final done = _c.value >= 1.0;
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 12, 20, 24),
      child: Column(mainAxisSize: MainAxisSize.min, crossAxisAlignment: CrossAxisAlignment.start, children: [
        _sheetHandle(),
        _sponsorTag(m),
        const SizedBox(height: 16),
        AspectRatio(
          aspectRatio: 16 / 9,
          child: Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(begin: Alignment.topLeft, end: Alignment.bottomRight, colors: [m.sponsorColor, Color.lerp(m.sponsorColor, Colors.black, 0.55)!]),
              borderRadius: BorderRadius.circular(AppRadii.card),
            ),
            child: Center(
              child: Icon(done ? Icons.check_circle_rounded : Icons.play_circle_fill_rounded, color: Colors.white, size: 54),
            ),
          ),
        ),
        const SizedBox(height: 14),
        ClipRRect(
          borderRadius: BorderRadius.circular(4),
          child: LinearProgressIndicator(value: _c.value, minHeight: 6, backgroundColor: AppColors.surfaceLowContrast, valueColor: const AlwaysStoppedAnimation(AppColors.brandPrimary)),
        ),
        const SizedBox(height: 8),
        Text(done ? tr('Thanks for watching!') : tr('Playing sponsor clip…'), style: AppText.body3Regular),
        const SizedBox(height: 18),
        PrimaryButton(done ? '${tr('Collect')} +${m.reward}' : tr('Watching…'), onTap: done ? () => Navigator.of(context).pop(true) : null),
      ]),
    );
  }
}

/// Survey-to-earn: three quick single-choice questions (market research the
/// sponsor pays for).
class _SurveyFlow extends StatefulWidget {
  final SponsorMission mission;
  const _SurveyFlow({required this.mission});
  @override
  State<_SurveyFlow> createState() => _SurveyFlowState();
}

class _SurveyFlowState extends State<_SurveyFlow> {
  int _q = 0;
  final _questions = const [
    ('Which away kit colour?', ['Anthracite', 'White', 'Retro green']),
    ('Where do you buy your kit?', ['Fanshop', 'Online', 'At the stadium']),
    ('How often do you buy new kit?', ['Every season', 'Every 2 years', 'Rarely']),
  ];

  @override
  Widget build(BuildContext context) {
    final m = widget.mission;
    final q = _questions[_q];
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 12, 20, 24),
      child: Column(mainAxisSize: MainAxisSize.min, crossAxisAlignment: CrossAxisAlignment.start, children: [
        _sheetHandle(),
        _sponsorTag(m),
        const SizedBox(height: 16),
        Text(trp('Question {a} of {b}', a: '${_q + 1}', b: '${_questions.length}'), style: AppText.caption1.copyWith(color: AppColors.textLight)),
        const SizedBox(height: 6),
        Text(tr(q.$1), style: AppText.label1),
        const SizedBox(height: 16),
        for (final opt in q.$2) ...[
          Tappable(
            onTap: () {
              if (_q < _questions.length - 1) {
                setState(() => _q++);
              } else {
                Navigator.of(context).pop(true);
              }
            },
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              margin: const EdgeInsets.only(bottom: 10),
              decoration: BoxDecoration(color: AppColors.surfaceMinimal, borderRadius: BorderRadius.circular(AppRadii.tile)),
              child: Row(children: [
                Expanded(child: Text(tr(opt), style: AppText.body2.copyWith(color: AppColors.textDarker, fontWeight: FontWeight.w600))),
                Icon(Icons.chevron_right_rounded, color: AppColors.textLight),
              ]),
            ),
          ),
        ],
      ]),
    );
  }
}

/// Quiz-to-earn: one branded multiple-choice question. Any answer completes the
/// mission (prototype), the right one is highlighted.
class _QuizFlow extends StatefulWidget {
  final SponsorMission mission;
  const _QuizFlow({required this.mission});
  @override
  State<_QuizFlow> createState() => _QuizFlowState();
}

class _QuizFlowState extends State<_QuizFlow> {
  int? _picked;
  static const _options = ['1904', '1963', '1997'];
  static const _correct = 0;

  @override
  Widget build(BuildContext context) {
    final m = widget.mission;
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 12, 20, 24),
      child: Column(mainAxisSize: MainAxisSize.min, crossAxisAlignment: CrossAxisAlignment.start, children: [
        _sheetHandle(),
        _sponsorTag(m),
        const SizedBox(height: 16),
        Text(tr('In which year was FC Schalke 04 founded?'), style: AppText.label1),
        const SizedBox(height: 16),
        for (final (i, opt) in _options.indexed) ...[
          Tappable(
            onTap: _picked == null ? () => setState(() => _picked = i) : null,
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              margin: const EdgeInsets.only(bottom: 10),
              decoration: BoxDecoration(
                color: _picked == null
                    ? AppColors.surfaceMinimal
                    : (i == _correct ? AppColors.successBg : (i == _picked ? AppColors.dangerBg : AppColors.surfaceMinimal)),
                borderRadius: BorderRadius.circular(AppRadii.tile),
                border: _picked != null && i == _correct ? Border.all(color: AppColors.success) : null,
              ),
              child: Row(children: [
                Expanded(child: Text(opt, style: AppText.body2.copyWith(color: AppColors.textDarker, fontWeight: FontWeight.w700))),
                if (_picked != null && i == _correct) const Icon(Icons.check_rounded, color: AppColors.success),
              ]),
            ),
          ),
        ],
        const SizedBox(height: 8),
        PrimaryButton('${tr('Collect')} +${m.reward}', onTap: _picked == null ? null : () => Navigator.of(context).pop(true)),
      ]),
    );
  }
}

/// Receipt-scan-to-earn: a scan stand-in for a partner purchase.
class _ReceiptFlow extends StatefulWidget {
  final SponsorMission mission;
  const _ReceiptFlow({required this.mission});
  @override
  State<_ReceiptFlow> createState() => _ReceiptFlowState();
}

class _ReceiptFlowState extends State<_ReceiptFlow> {
  bool _scanned = false;

  @override
  Widget build(BuildContext context) {
    final m = widget.mission;
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 12, 20, 24),
      child: Column(mainAxisSize: MainAxisSize.min, crossAxisAlignment: CrossAxisAlignment.start, children: [
        _sheetHandle(),
        _sponsorTag(m),
        const SizedBox(height: 16),
        Container(
          width: double.infinity,
          height: 180,
          decoration: BoxDecoration(
            color: AppColors.surfaceMinimal,
            borderRadius: BorderRadius.circular(AppRadii.card),
            border: Border.all(color: _scanned ? AppColors.success : AppColors.borderLightest, width: _scanned ? 1.5 : 1),
          ),
          child: Center(
            child: Column(mainAxisSize: MainAxisSize.min, children: [
              Icon(_scanned ? Icons.check_circle_rounded : Icons.document_scanner_outlined, size: 48, color: _scanned ? AppColors.success : AppColors.textLight),
              const SizedBox(height: 10),
              Text(_scanned ? tr('Receipt recognised · €47.80') : tr('Point the camera at your receipt'), style: AppText.body3.copyWith(color: AppColors.textNormal)),
            ]),
          ),
        ),
        const SizedBox(height: 18),
        if (_scanned)
          PrimaryButton('${tr('Collect')} +${m.reward}', onTap: () => Navigator.of(context).pop(true))
        else
          PrimaryButton(tr('Simulate scan'), onTap: () => setState(() => _scanned = true)),
      ]),
    );
  }
}
