import 'package:flutter/material.dart';
import '../theme/app_theme.dart';
import '../widgets/app_widgets.dart';
import '../widgets/scratch_card.dart';
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

  @override
  Widget build(BuildContext context) {
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
                  Text(tr('Scratch the card to win rewards!'), style: AppText.body2.copyWith(color: AppColors.textLight)),
                  const SizedBox(height: 12),
                  Pill(
                    color: AppColors.brandLightest,
                    child: Text(tr('1 Scratch Left'), style: AppText.caption1.copyWith(color: AppColors.brandPrimary, fontSize: 11)),
                  ),
                  const SizedBox(height: 20),
                  ScratchCard(
                    height: 200,
                    onRevealed: () => setState(() => _revealed = true),
                    reward: Container(
                      decoration: const BoxDecoration(gradient: LinearGradient(colors: AppColors.goldGradient)),
                      child: Center(
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(Icons.emoji_events_rounded, color: AppColors.brandDarkest, size: 44),
                            const SizedBox(height: 8),
                            Text(tr('+50 Points'), style: AppText.h2.copyWith(color: AppColors.brandDarkest)),
                          ],
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  if (_revealed)
                    PrimaryButton(tr('Claim +50 Points'), onTap: () => Navigator.of(context).maybePop())
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
}
