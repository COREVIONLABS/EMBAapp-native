import 'package:flutter/material.dart';
import '../theme/app_theme.dart';
import '../widgets/app_widgets.dart';
import '../widgets/sub_scaffold.dart';
import '../widgets/action_sheets.dart';
import 'raffles_screen.dart';
import '../l10n/strings.dart';

/// "My wins" — everything the fan has actually won: tombola prizes and daily-game
/// rewards. Prizes that still need collecting show a Claim button; the rest read
/// as already claimed. Falls back to a clear empty state when nothing is won yet.
class MyWinsScreen extends StatefulWidget {
  const MyWinsScreen({super.key});
  @override
  State<MyWinsScreen> createState() => _MyWinsScreenState();
}

class _Win {
  final String title;
  final String source; // Tombola / Daily Spin / Scratch
  final String date;
  final IconData icon;
  final bool claimable; // still needs collecting
  const _Win(this.title, this.source, this.date, this.icon, {this.claimable = false});
}

class _MyWinsScreenState extends State<MyWinsScreen> {
  // Prototype win history — newest first.
  final _wins = <_Win>[
    _Win('2× VIP tickets — vs Dortmund', 'Tombola', 'Won 12 Jul 2026', Icons.confirmation_number_rounded, claimable: true),
    _Win('Signed matchball', 'Tombola', 'Won 3 Jun 2026', Icons.sports_soccer_rounded),
    _Win('+500 bonus points', 'Daily Spin', '28 May 2026', Icons.casino_rounded),
    _Win('Fanshop 20% voucher', 'Scratch Card', '14 May 2026', Icons.style_rounded),
  ];

  final Set<int> _claimed = {};

  Future<void> _claim(int i) async {
    final ok = await showConfirmDialog(
      context,
      title: 'Claim this prize?',
      message: '${tr(_wins[i].title)} · ${tr('we\'ll email you the collection details.')}',
      confirmLabel: 'Claim',
    );
    if (!ok || !mounted) return;
    setState(() => _claimed.add(i));
    await showSuccessSheet(context, title: 'Prize claimed!', message: 'It\'s reserved for you — check your email for the details.');
  }

  @override
  Widget build(BuildContext context) {
    final open = [for (var i = 0; i < _wins.length; i++) if (_wins[i].claimable && !_claimed.contains(i)) i];
    return SubScaffold(
      title: tr('My wins'),
      children: _wins.isEmpty
          ? [_empty(context)]
          : [
              // Summary strip.
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(color: AppColors.brandLightest, borderRadius: BorderRadius.circular(AppRadii.card)),
                child: Row(children: [
                  Container(width: 44, height: 44, decoration: BoxDecoration(color: AppColors.gold.withValues(alpha: 0.18), borderRadius: BorderRadius.circular(12)), child: const Icon(Icons.emoji_events_rounded, color: AppColors.gold, size: 24)),
                  const SizedBox(width: 14),
                  Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                    Text('${_wins.length} ${tr('prizes won')}', style: AppText.body2.copyWith(color: AppColors.onAccent, fontWeight: FontWeight.w800)),
                    Text(open.isEmpty ? tr('All prizes claimed') : '${open.length} ${tr('ready to claim')}', style: AppText.body3.copyWith(color: AppColors.onAccent)),
                  ])),
                ]),
              ),
              const SizedBox(height: 20),
              for (var i = 0; i < _wins.length; i++) ...[
                _row(i),
                const SizedBox(height: 10),
              ],
              const SizedBox(height: 6),
              Row(children: [
                Icon(Icons.info_outline_rounded, size: 14, color: AppColors.textLight),
                const SizedBox(width: 6),
                Expanded(child: Text(tr('Prizes are drawn automatically at month-end and land here.'), style: AppText.caption1.copyWith(color: AppColors.textLight))),
              ]),
            ],
    );
  }

  Widget _row(int i) {
    final w = _wins[i];
    final claimed = !w.claimable || _claimed.contains(i);
    return SurfaceCard(
      child: Row(children: [
        Container(width: 46, height: 46, decoration: BoxDecoration(color: AppColors.brandLightest, borderRadius: BorderRadius.circular(12)), child: Icon(w.icon, color: AppColors.brandPrimary, size: 22)),
        const SizedBox(width: 12),
        Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text(tr(w.title), maxLines: 2, overflow: TextOverflow.ellipsis, style: AppText.body2.copyWith(color: AppColors.textDarker, fontWeight: FontWeight.w700)),
          const SizedBox(height: 2),
          Text('${tr(w.source)} · ${tr(w.date)}', style: AppText.body3Regular),
        ])),
        const SizedBox(width: 8),
        if (claimed)
          Pill(color: AppColors.successBg, child: Row(mainAxisSize: MainAxisSize.min, children: [
            const Icon(Icons.check_rounded, size: 12, color: AppColors.success),
            const SizedBox(width: 3),
            Text(tr('Claimed'), style: AppText.caption1.copyWith(color: AppColors.success, fontWeight: FontWeight.w800)),
          ]))
        else
          Tappable(
            onTap: () => _claim(i),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              decoration: BoxDecoration(color: AppColors.brandPrimary, borderRadius: BorderRadius.circular(999)),
              child: Text(tr('Claim'), style: AppText.caption1.copyWith(color: Colors.white, fontWeight: FontWeight.w800)),
            ),
          ),
      ]),
    );
  }

  Widget _empty(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 44, horizontal: 20),
      decoration: BoxDecoration(color: AppColors.surfaceMinimal, borderRadius: BorderRadius.circular(AppRadii.card)),
      child: Column(children: [
        Icon(Icons.emoji_events_outlined, size: 44, color: AppColors.textLight),
        const SizedBox(height: 12),
        Text(tr('No wins yet'), style: AppText.body1.copyWith(color: AppColors.textDarker, fontWeight: FontWeight.w700)),
        const SizedBox(height: 4),
        Text(tr('Enter the monthly tombola for your chance to win.'), textAlign: TextAlign.center, style: AppText.body3Regular),
        const SizedBox(height: 16),
        Tappable(
          onTap: () => Navigator.of(context).push(MaterialPageRoute(builder: (_) => const RafflesScreen())),
          child: Pill(color: AppColors.brandLightest, child: Text(tr('Open Tombola'), style: AppText.caption1.copyWith(color: AppColors.brandPrimary, fontWeight: FontWeight.w800))),
        ),
      ]),
    );
  }
}
