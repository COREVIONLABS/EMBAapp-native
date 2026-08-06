import 'dart:async';
import 'package:flutter/material.dart';
import '../theme/app_theme.dart';
import '../widgets/app_widgets.dart';
import '../widgets/sub_scaffold.dart';
import '../widgets/action_sheets.dart';
import '../model/fan_model.dart';
import 'buy_points_screen.dart';
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

  final Set<int> _entered = {};
  int _myTickets = FanModel.raffleTickets;
  late final List<DateTime> _ends;
  Timer? _timer;

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

  Future<void> _enter(int i) async {
    final r = _raffles[i];
    final free = r.superFanFree;
    final head = free ? tr('Uses one free Super Fan entry.') : '${FanModel.fmtPublic(r.entryPoints)} ${tr('points')}';
    final ok = await showConfirmDialog(
      context,
      title: 'Enter this tombola?',
      message: '$head · ${tr('You\'ll be notified if you win.')}',
      confirmLabel: 'Enter',
    );
    if (!ok || !mounted) return;
    setState(() {
      _entered.add(i);
      _myTickets += 1;
    });
    await showSuccessSheet(context,
        title: 'You\'re in!',
        message: 'Your entry is confirmed — the winner is drawn when the timer ends.');
  }

  @override
  Widget build(BuildContext context) {
    final enteredCount = _entered.length;
    return SubScaffold(
      title: tr('Tombola'),
      children: [
        // Membership free-lots strip — the core "why upgrade" for tombola.
        Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(color: AppColors.brandLightest, borderRadius: BorderRadius.circular(AppRadii.tile)),
          child: Row(children: [
            const Icon(Icons.local_activity_rounded, color: AppColors.brandPrimary),
            const SizedBox(width: 12),
            Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text('${FanModel.perks.freeLots} ${tr('free lots this month')}', style: AppText.body2.copyWith(color: AppColors.onAccent, fontWeight: FontWeight.w700)),
              Text('${tr(FanModel.membershipTier)} · ${_myTickets + enteredCount} ${tr('lots in total')}', style: AppText.body3.copyWith(color: AppColors.onAccent)),
            ])),
            Tappable(
              onTap: () => Navigator.of(context).push(MaterialPageRoute(builder: (_) => const BuyPointsScreen())),
              child: Pill(color: AppColors.surface, child: Text(tr('Top up points'), style: AppText.caption1.copyWith(color: AppColors.brandPrimary, fontWeight: FontWeight.w800))),
            ),
          ]),
        ),
        const SizedBox(height: 10),
        // Upgrade nudge — higher tier = more free lots each month.
        Tappable(
          scale: 0.99,
          onTap: () => Navigator.of(context).push(MaterialPageRoute(builder: (_) => const SubscriptionScreen())),
          child: Row(children: [
            Icon(Icons.arrow_circle_up_rounded, size: 16, color: AppColors.brandPrimary),
            const SizedBox(width: 6),
            Expanded(child: Text(tr('Higher membership = more free lots every month'), style: AppText.body3.copyWith(color: AppColors.brandPrimary, fontWeight: FontWeight.w700))),
            Icon(Icons.chevron_right_rounded, size: 18, color: AppColors.brandPrimary),
          ]),
        ),
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
        Row(children: [
          Icon(Icons.info_outline_rounded, size: 14, color: AppColors.textLight),
          const SizedBox(width: 6),
          Expanded(child: Text(tr('Winners are drawn automatically when the timer ends and notified in the app.'),
              style: AppText.caption1.copyWith(color: AppColors.textLight))),
        ]),
      ],
    );
  }

  Widget _featured(int i) {
    final r = _raffles[i];
    final left = _left(i);
    final entered = _entered.contains(i);
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(gradient: LinearGradient(colors: r.gradient, begin: Alignment.topLeft, end: Alignment.bottomRight), borderRadius: BorderRadius.circular(AppRadii.card)),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Row(children: [
          Pill(gradient: const LinearGradient(colors: AppColors.goldGradient), child: Text(tr('Draw of the month'), style: AppText.caption1.copyWith(color: AppColors.brandDarkest, fontWeight: FontWeight.w800))),
          const Spacer(),
          Pill(color: Colors.white24, child: Text('${FanModel.fmtPublic(r.entries)} ${tr('entries')}', style: AppText.caption1.copyWith(color: Colors.white))),
        ]),
        const SizedBox(height: 16),
        Icon(r.glyph, color: AppColors.gold, size: 40),
        const SizedBox(height: 10),
        Text(tr(r.prize), style: AppText.h4.copyWith(color: Colors.white)),
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
        entered
            ? Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(vertical: 15),
                alignment: Alignment.center,
                decoration: BoxDecoration(color: Colors.white24, borderRadius: BorderRadius.circular(AppRadii.pill)),
                child: Row(mainAxisSize: MainAxisSize.min, children: [
                  const Icon(Icons.check_circle_rounded, color: Colors.white, size: 18),
                  const SizedBox(width: 8),
                  Text(tr('You\'re entered'), style: AppText.label2.copyWith(color: Colors.white)),
                ]),
              )
            : PrimaryButton(
                r.superFanFree ? tr('Enter — free with Super Fan') : '${tr('Enter')} · ${FanModel.fmtPublic(r.entryPoints)} ${tr('pts')}',
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
    final entered = _entered.contains(i);
    return SurfaceCard(
      onTap: entered ? null : () => _enter(i),
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
        entered
            ? const Icon(Icons.check_circle_rounded, color: AppColors.success)
            : Text('${FanModel.fmtPublic(r.entryPoints)} ${tr('pts')}', style: AppText.body2.copyWith(color: AppColors.brandPrimary, fontWeight: FontWeight.w700)),
      ]),
    );
  }
}
