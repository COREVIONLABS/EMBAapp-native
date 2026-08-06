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
        // Lots are entered automatically into the next draw — a short line, not
        // a "lots left" box (which read oddly when you never place them yourself).
        Row(children: [
          Icon(Icons.bolt_rounded, size: 15, color: AppColors.brandPrimary),
          const SizedBox(width: 6),
          Expanded(child: Text(tr('Your lots are entered into the next draw automatically — more lots, more chances.'),
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
        // You're automatically in the next draw — no manual entry.
        Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(vertical: 13),
          alignment: Alignment.center,
          decoration: BoxDecoration(color: Colors.white24, borderRadius: BorderRadius.circular(AppRadii.pill)),
          child: Row(mainAxisSize: MainAxisSize.min, children: [
            const Icon(Icons.check_circle_rounded, color: AppColors.gold, size: 18),
            const SizedBox(width: 8),
            Text(tr('You\'re automatically in this draw'), style: AppText.label2.copyWith(color: Colors.white)),
          ]),
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
        Pill(color: AppColors.surfaceMinimal, child: Text('${FanModel.fmtPublic(r.entries)} ${tr('entries')}', style: AppText.caption1.copyWith(color: AppColors.textNormal, fontWeight: FontWeight.w700))),
      ]),
    );
  }
}
