import 'package:flutter/material.dart';
import '../theme/app_theme.dart';
import '../widgets/app_widgets.dart';
import '../widgets/scratch_card.dart';
import '../model/fan_model.dart';
import '../model/daily_games.dart';
import '../model/voucher_store.dart';
import '../widgets/sponsor_banner.dart';
import '../l10n/strings.dart';

/// Presents Daily Card Scratch as a modal sheet over the current screen
/// (Figma 2145:8564). Real finger-scratch reveal.
void showScratchCard(BuildContext context) {
  Navigator.of(context).push(PageRouteBuilder(
    opaque: false,
    barrierColor: Colors.black54,
    barrierDismissible: true,
    pageBuilder: (_, a, _) => const ScratchCardScreen(),
    transitionsBuilder: (_, a, _, child) =>
        SlideTransition(position: Tween(begin: const Offset(0, 1), end: Offset.zero).animate(CurvedAnimation(parent: a, curve: Curves.easeOutCubic)), child: child),
  ));
}

class ScratchCardScreen extends StatefulWidget {
  const ScratchCardScreen({super.key});
  @override
  State<ScratchCardScreen> createState() => _ScratchCardScreenState();
}

class _ScratchCardScreenState extends State<ScratchCardScreen> {
  bool _revealed = false;

  // Prize decided up front (so the revealed art matches), weighted to small.
  late final DailyPrize _prize = kScratchPrizes[rollPrizeIndex(kScratchWeights)];

  void _award() {
    switch (_prize.type) {
      case DailyPrizeType.points:
        FanModel.addPoints(_prize.points);
        break;
      case DailyPrizeType.ticket:
        voucherStore.issue(title: _prize.label, category: 'Tickets', points: 0, detail: tr('Won on the Scratch Card'));
        break;
      case DailyPrizeType.sponsor:
        voucherStore.issue(title: _prize.label, category: 'Sponsor', points: 0, sponsor: _prize.sponsor, detail: tr('Won on the Scratch Card'));
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    final isPoints = _prize.type == DailyPrizeType.points;
    return Scaffold(
      backgroundColor: Colors.transparent,
      body: Column(
        children: [
          Expanded(child: GestureDetector(onTap: () => Navigator.of(context).maybePop(), behavior: HitTestBehavior.opaque)),
          Container(
            width: double.infinity,
            decoration: BoxDecoration(color: AppColors.surface, borderRadius: BorderRadius.vertical(top: Radius.circular(28))),
            padding: const EdgeInsets.fromLTRB(24, 12, 24, 32),
            child: SafeArea(
              top: false,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(width: 40, height: 5, decoration: BoxDecoration(color: AppColors.surfaceLowContrast, borderRadius: BorderRadius.circular(3))),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      const Spacer(),
                      Text(tr('Daily Card Scratch'), style: AppText.label1),
                      Expanded(
                        child: Align(
                          alignment: Alignment.centerRight,
                          child: GestureDetector(
                            onTap: () => Navigator.of(context).maybePop(),
                            child: Icon(Icons.close_rounded, color: AppColors.textLight),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(tr('Scratch to win points, tickets or sponsor prizes!'), textAlign: TextAlign.center, style: AppText.body2.copyWith(color: AppColors.textLight)),
                  const SizedBox(height: 14),
                  const SponsorAdBanner(),
                  const SizedBox(height: 18),
                  ScratchCard(
                    height: 200,
                    onRevealed: () {
                      _award();
                      setState(() => _revealed = true);
                    },
                    reward: _prizeArt(_prize),
                  ),
                  const SizedBox(height: 16),
                  if (_revealed)
                    PrimaryButton(
                      isPoints ? '${tr('Claim')} +${_prize.points} ${tr('Points')}' : tr('Save to My Vouchers'),
                      onTap: () => Navigator.of(context).maybePop(),
                    )
                  else
                    Text(tr('Scratch at least 40% of the card to reveal your reward'),
                        textAlign: TextAlign.center, style: AppText.body3Regular),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _prizeArt(DailyPrize p) {
    switch (p.type) {
      case DailyPrizeType.points:
        return Container(
          decoration: const BoxDecoration(gradient: LinearGradient(colors: AppColors.goldGradient)),
          child: Center(child: Column(mainAxisSize: MainAxisSize.min, children: [
            const Icon(Icons.emoji_events_rounded, color: AppColors.brandDarkest, size: 44),
            const SizedBox(height: 8),
            Text('+${p.points} ${tr('Points')}', style: AppText.h2.copyWith(color: AppColors.brandDarkest)),
          ])),
        );
      default:
        return Container(
          decoration: BoxDecoration(gradient: LinearGradient(colors: [p.color, Color.lerp(p.color, Colors.black, 0.4)!], begin: Alignment.topLeft, end: Alignment.bottomRight)),
          child: Center(child: Column(mainAxisSize: MainAxisSize.min, children: [
            Icon(p.icon, color: Colors.white, size: 42),
            const SizedBox(height: 8),
            Text(p.label, textAlign: TextAlign.center, style: AppText.label1.copyWith(color: Colors.white)),
            if (p.type == DailyPrizeType.sponsor) ...[
              const SizedBox(height: 2),
              Text(tr('Sponsor prize'), style: AppText.caption1.copyWith(color: Colors.white70)),
            ],
          ])),
        );
    }
  }
}
