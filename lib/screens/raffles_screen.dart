import 'dart:async';
import 'package:flutter/material.dart';
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
  final int entryPoints;
  final Duration drawIn;
  final int entries;
  final bool superFanFree;
  const _Raffle(this.title, this.prize, this.glyph, this.gradient, this.entryPoints, this.drawIn, this.entries, {this.superFanFree = false});
}

class _RafflesScreenState extends State<RafflesScreen> {
  static const _raffles = <_Raffle>[
    _Raffle('Derby Tombola', '2× VIP tickets — vs Dortmund', Icons.confirmation_number_rounded,
        [Color(0xFF0A2A5E), Color(0xFF000D22)], 500, Duration(days: 3, hours: 6, minutes: 12), 1840, superFanFree: true),
    _Raffle('Play on the pitch', 'Play a match in the VELTINS-Arena', Icons.sports_soccer_rounded,
        [Color(0xFF0A2A5E), Color(0xFF000D22)], 800, Duration(days: 5, hours: 8), 1290),
    _Raffle('VIP box on matchday', 'Private box incl. catering', Icons.stadium_rounded,
        [Color(0xFF0A2A5E), Color(0xFF000D22)], 700, Duration(days: 6, hours: 2), 970),
    _Raffle('Signed Home Shirt', 'Match-worn, signed by the squad', Icons.checkroom_rounded,
        [Color(0xFF0A2A5E), Color(0xFF000D22)], 300, Duration(days: 8, hours: 14), 860),
    _Raffle('Meet the team', 'Meet & Greet backstage before kickoff', Icons.groups_rounded,
        [Color(0xFF0A2A5E), Color(0xFF000D22)], 400, Duration(days: 12, hours: 4), 410),
  ];

  /// One extra lot costs this many points (the single conversion: points → lots).
  static const int _kLotCost = 500;

  final Map<int, int> _myEntries = {}; // draw index → how many lots you placed
  late final List<int> _entries; // live entry pool per draw
  late final List<DateTime> _ends;
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    final now = DateTime.now();
    _ends = [for (final r in _raffles) now.add(r.drawIn)];
    _entries = [for (final r in _raffles) r.entries];
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

  Future<void> _buyLot() async {
    if (FanModel.fanPoints < _kLotCost) {
      await showConfirmDialog(context,
          title: 'Not enough points',
          message: '${tr('An extra lot costs')} ${FanModel.fmtPublic(_kLotCost)} ${tr('points')} · ${tr('you have')} ${FanModel.pointsFormatted}.',
          confirmLabel: 'OK');
      return;
    }
    final ok = await showConfirmDialog(context,
        title: 'Get an extra lot?',
        message: '${FanModel.fmtPublic(_kLotCost)} ${tr('points')} → 1 ${tr('lot')} · ${tr('More lots = more chances.')}',
        confirmLabel: 'Get lot');
    if (!ok || !mounted) return;
    FanModel.spendPoints(_kLotCost);
    lotsNotifier.value += 1;
  }

  // Place one lot on a draw. Free lots first; when out, one lot is bought with
  // points. Multi-entry is allowed — more lots, more chances.
  Future<void> _enter(int i) async {
    final usingPaid = FanModel.raffleTickets <= 0;
    if (usingPaid && FanModel.fanPoints < _kLotCost) {
      await showConfirmDialog(context,
          title: 'No lots left',
          message: '${tr('You\'re out of free lots — an extra lot costs')} ${FanModel.fmtPublic(_kLotCost)} ${tr('points')}.',
          confirmLabel: 'OK');
      return;
    }
    final msg = usingPaid
        ? '${tr('Places 1 extra lot for')} ${FanModel.fmtPublic(_kLotCost)} ${tr('points')}. ${tr('More lots = more chances.')}'
        : '${tr('Places 1 of your lots.')} ${tr('More lots = more chances.')}';
    final ok = await showConfirmDialog(context, title: 'Place a lot?', message: msg, confirmLabel: 'Place lot');
    if (!ok || !mounted) return;
    if (usingPaid) {
      FanModel.spendPoints(_kLotCost);
    } else {
      lotsNotifier.value -= 1;
    }
    setState(() {
      _myEntries[i] = (_myEntries[i] ?? 0) + 1;
      _entries[i] += 1;
    });
    await showSuccessSheet(context,
        title: 'You\'re in!',
        message: 'Lot placed — the winner is drawn when the timer ends. Good luck!');
  }

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
        // Your lots — one honest number, one unit.
        ValueListenableBuilder<int>(
          valueListenable: lotsNotifier,
          builder: (context, lots, __) => Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(color: AppColors.brandLightest, borderRadius: BorderRadius.circular(AppRadii.tile)),
            child: Row(children: [
              const Icon(Icons.local_activity_rounded, color: AppColors.brandPrimary),
              const SizedBox(width: 12),
              Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Text('$lots ${tr('lots left')}', style: AppText.body2.copyWith(color: AppColors.onAccent, fontWeight: FontWeight.w800)),
                Text('${tr(tierNotifier.value)} · ${tr('free lots enter automatically — more lots, more chances')}', style: AppText.body3.copyWith(color: AppColors.onAccent)),
              ])),
              Tappable(
                onTap: _buyLot,
                child: Pill(color: AppColors.surface, child: Text('${tr('Extra lot')} · $_kLotCost', style: AppText.caption1.copyWith(color: AppColors.brandPrimary, fontWeight: FontWeight.w800))),
              ),
            ]),
          ),
        ),
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
        _featured(0),
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
    final myN = _myEntries[i] ?? 0;
    final hasFree = FanModel.raffleTickets > 0;
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(gradient: LinearGradient(colors: r.gradient, begin: Alignment.topLeft, end: Alignment.bottomRight), borderRadius: BorderRadius.circular(AppRadii.card)),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Row(children: [
          Pill(gradient: const LinearGradient(colors: AppColors.goldGradient), child: Text(tr('Draw of the month'), style: AppText.caption1.copyWith(color: AppColors.brandDarkest, fontWeight: FontWeight.w800))),
          const Spacer(),
          Pill(color: Colors.white24, child: Text('${FanModel.fmtPublic(_entries[i])} ${tr('entries')}', style: AppText.caption1.copyWith(color: Colors.white))),
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
          const SizedBox(width: 8),
          _count(_two(left.inSeconds % 60), 'Sec'),
        ]),
        const SizedBox(height: 18),
        if (myN > 0) ...[
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(vertical: 10),
            alignment: Alignment.center,
            decoration: BoxDecoration(color: Colors.white24, borderRadius: BorderRadius.circular(AppRadii.pill)),
            child: Row(mainAxisSize: MainAxisSize.min, children: [
              const Icon(Icons.check_circle_rounded, color: Colors.white, size: 16),
              const SizedBox(width: 8),
              Text('${tr('You\'re in')} · $myN ${myN == 1 ? tr('lot') : tr('lots')}', style: AppText.label2.copyWith(color: Colors.white)),
            ]),
          ),
          const SizedBox(height: 10),
        ],
        PrimaryButton(
          hasFree ? (myN > 0 ? tr('Place another lot') : tr('Place a lot')) : '${tr('Extra lot')} · ${FanModel.fmtPublic(_kLotCost)} ${tr('pts')}',
          color: AppColors.gold, textColor: AppColors.brandDarkest,
          onTap: () => _enter(i)),
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
    final myN = _myEntries[i] ?? 0;
    final hasFree = FanModel.raffleTickets > 0;
    return SurfaceCard(
      onTap: () => _enter(i),
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
          ]),
        ])),
        const SizedBox(width: 8),
        if (myN > 0)
          Pill(color: AppColors.successBg, child: Text('$myN ×', style: AppText.caption1.copyWith(color: AppColors.success, fontWeight: FontWeight.w800)))
        else
          Text(hasFree ? '1 ${tr('lot')}' : '$_kLotCost ${tr('pts')}', style: AppText.body2.copyWith(color: AppColors.brandPrimary, fontWeight: FontWeight.w700)),
      ]),
    );
  }
}
