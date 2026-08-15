import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../theme/app_theme.dart';
import '../widgets/app_widgets.dart';
import '../widgets/sub_scaffold.dart';
import '../widgets/action_sheets.dart';
import '../model/fan_model.dart';
import 'subscription_screen.dart';
import '../l10n/strings.dart';

/// Monthly Tombola hub — luck-based prize draws (VIP tickets, signed gear …),
/// separate from Experiences (which are bookable moments). Each draw shows a
/// live countdown to the draw, the entry cost (points, or a free Fan+ entry)
/// and the fan's own entries. Prototype: entering is instant and free-form.
class RafflesScreen extends StatefulWidget {
  const RafflesScreen({super.key});
  @override
  State<RafflesScreen> createState() => _RafflesScreenState();
}

class _Raffle {
  final String title;
  final String prize;
  final IconData glyph;
  final List<Color> gradient;
  final Duration drawIn;
  final int entries;
  const _Raffle(this.title, this.prize, this.glyph, this.gradient, this.drawIn, this.entries);
}

class _RafflesScreenState extends State<RafflesScreen> {
  static const _raffles = <_Raffle>[
    _Raffle('Derby Tombola', '2× VIP tickets — vs Dortmund', Icons.confirmation_number_rounded,
        [Color(0xFF0A2A5E), Color(0xFF000D22)], Duration(days: 3, hours: 6, minutes: 12), 1840),
    _Raffle('Play on the pitch', 'Play a match in the VELTINS-Arena', Icons.sports_soccer_rounded,
        [Color(0xFF0A2A5E), Color(0xFF000D22)], Duration(days: 5, hours: 8), 1290),
    _Raffle('VIP box on matchday', 'Private box incl. catering', Icons.stadium_rounded,
        [Color(0xFF0A2A5E), Color(0xFF000D22)], Duration(days: 6, hours: 2), 970),
    _Raffle('Signed Home Shirt', 'Match-worn, signed by the squad', Icons.checkroom_rounded,
        [Color(0xFF0A2A5E), Color(0xFF000D22)], Duration(days: 8, hours: 14), 860),
    _Raffle('Meet the team', 'Meet & Greet backstage before kickoff', Icons.groups_rounded,
        [Color(0xFF0A2A5E), Color(0xFF000D22)], Duration(days: 12, hours: 4), 410),
  ];

  /// Cost of one extra lot in points (the "extra lots cost points" economy — a
  /// real points sink and the destination for daily-game points).
  static const int _extraLotCost = 200;

  /// Extra lots the fan has bought into each draw (on top of their free lots).
  final List<int> _extra = List<int>.filled(_raffles.length, 0);

  late final List<DateTime> _ends;
  Timer? _timer;

  /// Free lots that automatically enter every open draw (from membership).
  int get _freeLots => FanModel.perks.freeLots;

  /// The fan's total entries in draw [i] = free lots + bought extra lots.
  int _myEntries(int i) => _freeLots + _extra[i];

  /// Total entries shown for a draw = the seeded crowd + your extra lots.
  int _entriesFor(int i) => _raffles[i].entries + _extra[i];

  Future<void> _addExtraLot(int i) async {
    if (FanModel.fanPoints < _extraLotCost) {
      await showConfirmDialog(context,
          title: 'Not enough points',
          message: trp('An extra lot costs {n} points. Earn or top up to boost your chances.', n: '$_extraLotCost'),
          confirmLabel: 'OK');
      return;
    }
    if (!FanModel.spendPoints(_extraLotCost)) return;
    HapticFeedback.mediumImpact();
    setState(() => _extra[i] += 1);
    if (!mounted) return;
    await showSuccessSheet(context,
        title: 'Lot added! 🎉',
        message: trp('You now have {n} lots in this draw — more lots, more chances.', n: '${_myEntries(i)}'));
  }

  @override
  void initState() {
    super.initState();
    final now = DateTime.now();
    _ends = [for (final r in _raffles) now.add(r.drawIn)];
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

  bool get _topTier => tierNotifier.value == 'Super Fan';

  void _showTerms() {
    showConfirmDialog(context,
        title: 'How the tombola works',
        message: tr('Members get free lots each month; free lots enter automatically and extra lots cost points. One lot = one entry, more lots = more chances. No purchase necessary — you can always take part with your free lots. 18+. Winners are drawn at the timer and notified in the app.'),
        confirmLabel: 'Got it');
  }

  @override
  Widget build(BuildContext context) {
    return SubScaffold(
      title: tr('Tombola'),
      children: [
        // Free lots auto-enter every open draw; extra lots can be added for points.
        if (_freeLots == 0)
          Tappable(
            scale: 0.99,
            onTap: () => Navigator.of(context).push(MaterialPageRoute(builder: (_) => const SubscriptionScreen())),
            child: Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(color: AppColors.brandLightest, borderRadius: BorderRadius.circular(AppRadii.tile)),
              child: Row(children: [
                Icon(Icons.info_outline_rounded, size: 16, color: AppColors.brandPrimary),
                const SizedBox(width: 8),
                Expanded(child: Text(tr('You have no free lots yet — become a member to enter every draw, or add a lot for points below.'), style: AppText.body3.copyWith(color: AppColors.onAccent, fontWeight: FontWeight.w600))),
                Icon(Icons.chevron_right_rounded, size: 18, color: AppColors.brandPrimary),
              ]),
            ),
          )
        else
          Row(children: [
            Icon(Icons.bolt_rounded, size: 15, color: AppColors.brandPrimary),
            const SizedBox(width: 6),
            Expanded(child: Text(trp('Your {n} free lots enter every open draw automatically — add extra lots for even more chances.', n: '$_freeLots'),
                style: AppText.body3.copyWith(color: AppColors.textNormal, fontWeight: FontWeight.w600))),
          ]),
        const SizedBox(height: 10),
        // Upgrade nudge — only when NOT already on the top tier (no dead end).
        if (!_topTier)
          Tappable(
            scale: 0.99,
            onTap: () => Navigator.of(context).push(MaterialPageRoute(builder: (_) => const SubscriptionScreen())),
            child: Row(children: [
              Icon(Icons.arrow_circle_up_rounded, size: 16, color: AppColors.brandPrimary),
              const SizedBox(width: 6),
              Expanded(child: Text(tr('Higher membership = more free lots every month'), style: AppText.body3.copyWith(color: AppColors.brandPrimary, fontWeight: FontWeight.w700))),
              Icon(Icons.chevron_right_rounded, size: 18, color: AppColors.brandPrimary),
            ]),
          )
        else
          Row(children: [
            Icon(Icons.verified_rounded, size: 16, color: AppColors.success),
            const SizedBox(width: 6),
            Expanded(child: Text('${tr(tierNotifier.value)} · ${tr('you get the most free lots every month')}', style: AppText.body3.copyWith(color: AppColors.textNormal, fontWeight: FontWeight.w600))),
          ]),
        const SizedBox(height: 18),
        // Tombola of the month (featured)
        Text(tr('Tombola of the month'), style: AppText.label1),
        const SizedBox(height: 12),
        Tappable(scale: 0.99, onTap: () => _openDraw(0), child: _featured(0)),
        const SizedBox(height: 22),
        Text(tr('More draws'), style: AppText.label1),
        const SizedBox(height: 12),
        for (var i = 1; i < _raffles.length; i++) ...[_row(i), const SizedBox(height: 10)],
        const SizedBox(height: 8),
        Tappable(
          onTap: _showTerms,
          child: Row(children: [
            Icon(Icons.info_outline_rounded, size: 14, color: AppColors.textLight),
            const SizedBox(width: 6),
            Expanded(child: Text(tr('18+ · No purchase necessary — take part with free lots · Terms apply'),
                style: AppText.caption1.copyWith(color: AppColors.textLight, decoration: TextDecoration.underline))),
          ]),
        ),
      ],
    );
  }

  Widget _featured(int i) {
    final r = _raffles[i];
    final left = _left(i);
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(gradient: LinearGradient(colors: r.gradient, begin: Alignment.topLeft, end: Alignment.bottomRight), borderRadius: BorderRadius.circular(AppRadii.card)),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Row(children: [
          Pill(gradient: const LinearGradient(colors: AppColors.goldGradient), child: Text(tr('Draw of the month'), style: AppText.caption1.copyWith(color: AppColors.brandDarkest, fontWeight: FontWeight.w800))),
          const Spacer(),
          Pill(color: Colors.white24, child: Text('${FanModel.fmtPublic(_entriesFor(i))} ${tr('entries')}', style: AppText.caption1.copyWith(color: Colors.white))),
        ]),
        const SizedBox(height: 16),
        Icon(r.glyph, color: AppColors.gold, size: 40),
        const SizedBox(height: 10),
        Text(tr(r.prize), style: AppText.h4.copyWith(color: Colors.white)),
        const SizedBox(height: 6),
        Text(tr('Every lot boosts your chance.'), style: AppText.body3.copyWith(color: Colors.white70)),
        const SizedBox(height: 16),
        Text(tr('Draw in'), style: AppText.caption1.copyWith(color: Colors.white70)),
        const SizedBox(height: 8),
        Row(children: [
          _count(_two(left.inDays), 'Days'),
          const SizedBox(width: 8),
          _count(_two(left.inHours % 24), 'Hrs'),
          const SizedBox(width: 8),
          _count(_two(left.inMinutes % 60), 'Min'),
        ]),
        const SizedBox(height: 16),
        // Your entries in this draw + an active "add an extra lot" action.
        Row(children: [
          const Icon(Icons.local_activity_rounded, color: AppColors.gold, size: 18),
          const SizedBox(width: 8),
          Expanded(child: Text(
            _myEntries(i) > 0 ? trp('You’re in with {n} lots', n: '${_myEntries(i)}') : tr('You have no lots in this draw yet'),
            style: AppText.body2.copyWith(color: Colors.white, fontWeight: FontWeight.w700),
          )),
        ]),
        const SizedBox(height: 12),
        Tappable(
          onTap: () => _addExtraLot(i),
          child: Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(vertical: 14),
            alignment: Alignment.center,
            decoration: BoxDecoration(gradient: const LinearGradient(colors: AppColors.goldGradient), borderRadius: BorderRadius.circular(AppRadii.pill)),
            child: Row(mainAxisSize: MainAxisSize.min, children: [
              const Icon(Icons.add_rounded, color: AppColors.brandDarkest, size: 20),
              const SizedBox(width: 8),
              Text('${tr('Add an extra lot')} · $_extraLotCost ${tr('pts')}', style: AppText.label2.copyWith(color: AppColors.brandDarkest, fontWeight: FontWeight.w800)),
            ]),
          ),
        ),
      ]),
    );
  }

  Widget _count(String value, String unit) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12),
        decoration: BoxDecoration(color: Colors.black.withValues(alpha: 0.22), borderRadius: BorderRadius.circular(AppRadii.tile)),
        child: Column(children: [
          Text(value, style: AppText.h4.copyWith(color: Colors.white)),
          const SizedBox(height: 2),
          Text(tr(unit), style: AppText.caption1.copyWith(color: Colors.white70)),
        ]),
      ),
    );
  }

  Widget _row(int i) {
    final r = _raffles[i];
    final left = _left(i);
    return SurfaceCard(
      onTap: () => _openDraw(i),
      child: Row(children: [
        Container(
          width: 52, height: 52,
          decoration: BoxDecoration(color: AppColors.brandLightest, borderRadius: BorderRadius.circular(12)),
          child: Icon(r.glyph, color: AppColors.brandPrimary, size: 24),
        ),
        const SizedBox(width: 12),
        Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text(tr(r.prize), maxLines: 1, overflow: TextOverflow.ellipsis, style: AppText.body2.copyWith(color: AppColors.textDarker, fontWeight: FontWeight.w700)),
          const SizedBox(height: 2),
          Row(children: [
            Icon(Icons.schedule_rounded, size: 13, color: AppColors.textLight),
            const SizedBox(width: 4),
            Text('${tr('Draw in')} ${left.inDays}d ${left.inHours % 24}h', style: AppText.body3Regular),
            const SizedBox(width: 8),
            const Icon(Icons.local_activity_rounded, size: 12, color: AppColors.brandPrimary),
            const SizedBox(width: 3),
            Text(trp('you: {n}', n: '${_myEntries(i)}'), style: AppText.body3.copyWith(color: AppColors.brandPrimary, fontWeight: FontWeight.w700)),
          ]),
        ])),
        const SizedBox(width: 8),
        Icon(Icons.chevron_right_rounded, color: AppColors.textLight),
      ]),
    );
  }

  /// Draw detail — prize, live countdown, your entries vs the crowd, and the
  /// active "add an extra lot" action.
  void _openDraw(int i) {
    final r = _raffles[i];
    showModalBottomSheet<void>(
      context: context,
      backgroundColor: AppColors.surface,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(28))),
      builder: (sheetCtx) {
        final left = _left(i);
        return Padding(
          padding: const EdgeInsets.fromLTRB(20, 12, 20, 24),
          child: Column(mainAxisSize: MainAxisSize.min, crossAxisAlignment: CrossAxisAlignment.start, children: [
            Center(child: Container(width: 40, height: 4, margin: const EdgeInsets.only(bottom: 16), decoration: BoxDecoration(color: AppColors.borderLightest, borderRadius: BorderRadius.circular(2)))),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(18),
              decoration: BoxDecoration(gradient: LinearGradient(colors: r.gradient, begin: Alignment.topLeft, end: Alignment.bottomRight), borderRadius: BorderRadius.circular(AppRadii.card)),
              child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Icon(r.glyph, color: AppColors.gold, size: 36),
                const SizedBox(height: 10),
                Text(tr(r.prize), style: AppText.h4.copyWith(color: Colors.white, fontSize: 22)),
                const SizedBox(height: 4),
                Text('${tr('Draw in')} ${left.inDays}d ${left.inHours % 24}h ${left.inMinutes % 60}m', style: AppText.body3.copyWith(color: Colors.white70)),
              ]),
            ),
            const SizedBox(height: 16),
            Row(children: [
              Expanded(child: _sheetStat(trp('{n} lots', n: '${_myEntries(i)}'), tr('your entries'))),
              const SizedBox(width: 12),
              Expanded(child: _sheetStat(FanModel.fmtPublic(_entriesFor(i)), tr('total entries'))),
            ]),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(color: AppColors.brandLightest, borderRadius: BorderRadius.circular(AppRadii.tile)),
              child: Row(children: [
                Icon(Icons.bolt_rounded, size: 15, color: AppColors.brandPrimary),
                const SizedBox(width: 8),
                Expanded(child: Text(trp('Your {n} free lots are already in — add extra lots to boost your chances.', n: '$_freeLots'), style: AppText.body3.copyWith(color: AppColors.onAccent))),
              ]),
            ),
            const SizedBox(height: 16),
            PrimaryButton('${tr('Add an extra lot')} · $_extraLotCost ${tr('pts')}', onTap: () {
              Navigator.of(sheetCtx).pop();
              _addExtraLot(i);
            }),
          ]),
        );
      },
    );
  }

  Widget _sheetStat(String value, String label) => Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(color: AppColors.surfaceMinimal, borderRadius: BorderRadius.circular(AppRadii.tile)),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text(value, style: AppText.h4.copyWith(color: AppColors.textDarker, fontSize: 22)),
          Text(label, style: AppText.body3Regular),
        ]),
      );
}
