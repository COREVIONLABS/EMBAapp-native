import 'package:flutter/material.dart';
import '../theme/app_theme.dart';
import '../widgets/app_widgets.dart';
import '../widgets/scratch_card.dart';
import '../widgets/sub_scaffold.dart';

/// Daily Card Scratch (Figma 401:3295 / reward / already scratched).
/// Uses the real finger-scratch interaction from the EMBA prototype.
class ScratchCardScreen extends StatefulWidget {
  const ScratchCardScreen({super.key});
  @override
  State<ScratchCardScreen> createState() => _ScratchCardScreenState();
}

class _ScratchCardScreenState extends State<ScratchCardScreen> {
  bool _revealed = false;

  @override
  Widget build(BuildContext context) {
    return SubScaffold(
      title: 'Scratch Card',
      bottomBar: _revealed ? PrimaryButton('Claim +50 Points', onTap: () => Navigator.of(context).maybePop()) : null,
      children: [
        const SizedBox(height: 8),
        Text('Scratch to reveal', textAlign: TextAlign.center, style: AppText.h4),
        const SizedBox(height: 6),
        Text('Swipe across the card to uncover today’s prize',
            textAlign: TextAlign.center, style: AppText.body1.copyWith(color: AppColors.textLight)),
        const SizedBox(height: 32),
        ScratchCard(
          onRevealed: () => setState(() => _revealed = true),
          reward: Container(
            decoration: const BoxDecoration(gradient: LinearGradient(colors: AppColors.pointsGradient)),
            child: Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.emoji_events_rounded, color: AppColors.gold, size: 48),
                  const SizedBox(height: 8),
                  Text('+50 Points', style: AppText.h2.copyWith(color: Colors.white)),
                  const SizedBox(height: 4),
                  Text('Nice one!', style: AppText.body2.copyWith(color: Colors.white70)),
                ],
              ),
            ),
          ),
        ),
        const SizedBox(height: 16),
        if (_revealed)
          Center(child: Text('\u{1F389} Prize unlocked', style: AppText.body2.copyWith(color: AppColors.success))),
      ],
    );
  }
}
