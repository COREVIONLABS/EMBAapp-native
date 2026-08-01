import 'package:flutter/material.dart';
import '../theme/app_theme.dart';
import '../widgets/app_widgets.dart';
import 'login_screen.dart';
import '../l10n/strings.dart';

/// Welcome 1–3 (Figma 2145:11369 / 11385 / 11400) — branded gradient hero art
/// (self-contained so it always renders, independent of asset fetch) with a
/// bottom sheet.
class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});
  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final _controller = PageController();
  int _page = 0;

  // (gradient, title, body, glyph)
  static const _slides = [
    (
      [Color(0xFF0055AA), Color(0xFF001B44)],
      'Earn Points Everywhere',
      'Shop at sponsors, spin daily, complete missions, and earn 3x Points on matchday with Stadium Boost.',
      Icons.stadium_rounded,
    ),
    (
      [Color(0xFF6A1B9A), Color(0xFF1A1350)],
      'Redeem for Merch & Rewards',
      'Use Fan Points for exclusive jerseys, scarves, signed memorabilia, and partner discounts.',
      Icons.redeem_rounded,
    ),
    (
      [Color(0xFF004B9C), Color(0xFF000D22)],
      'Win Exclusive Rewards',
      "Enter VIP raffles, scratch cards, and daily spins. Meet the players, win signed gear, and unlock experiences money can't buy.",
      Icons.emoji_events_rounded,
    ),
  ];

  void _next() {
    if (_page < _slides.length - 1) {
      _controller.nextPage(duration: const Duration(milliseconds: 300), curve: Curves.easeOut);
    } else {
      _goLogin();
    }
  }

  void _goLogin() {
    Navigator.of(context).pushReplacement(MaterialPageRoute(builder: (_) => const LoginScreen()));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.surface,
      body: Stack(
        children: [
          // Hero photo (full-bleed, top ~55%)
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            height: MediaQuery.of(context).size.height * 0.6,
            child: PageView.builder(
              controller: _controller,
              onPageChanged: (i) => setState(() => _page = i),
              itemCount: _slides.length,
              itemBuilder: (_, i) => _HeroArt(gradient: _slides[i].$1, glyph: _slides[i].$4),
            ),
          ),
          // Bottom sheet
          Align(
            alignment: Alignment.bottomCenter,
            child: Container(
              width: double.infinity,
              decoration: BoxDecoration(
                color: AppColors.surface,
                borderRadius: BorderRadius.vertical(top: Radius.circular(40)),
              ),
              padding: const EdgeInsets.fromLTRB(28, 28, 28, 40),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(tr(_slides[_page].$2),
                      style: AppText.h4.copyWith(color: AppColors.textDarker)),
                  const SizedBox(height: 10),
                  Text(tr(_slides[_page].$3),
                      style: AppText.body2.copyWith(color: AppColors.textLight, fontWeight: FontWeight.w400)),
                  const SizedBox(height: 24),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      for (var i = 0; i < _slides.length; i++)
                        AnimatedContainer(
                          duration: const Duration(milliseconds: 200),
                          margin: const EdgeInsets.symmetric(horizontal: 3),
                          width: i == _page ? 22 : 8,
                          height: 8,
                          decoration: BoxDecoration(
                            color: i == _page ? AppColors.brandPrimary : AppColors.surfaceLowContrast,
                            borderRadius: BorderRadius.circular(999),
                          ),
                        ),
                    ],
                  ),
                  const SizedBox(height: 20),
                  PrimaryButton(_page == _slides.length - 1 ? tr('Get Started') : tr('Continue'), onTap: _next),
                  const SizedBox(height: 12),
                  Center(
                    child: GestureDetector(
                      onTap: _goLogin,
                      child: Text(tr('Skip'),
                          style: AppText.body2.copyWith(color: AppColors.textLight, fontWeight: FontWeight.w600)),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// Self-contained branded hero art for an onboarding slide — a full-bleed
/// gradient with decorative rings, a large glyph and the S04 crest. Renders
/// without any bundled photo so the tour always shows a visual.
class _HeroArt extends StatelessWidget {
  final List<Color> gradient;
  final IconData glyph;
  const _HeroArt({required this.gradient, required this.glyph});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(begin: Alignment.topLeft, end: Alignment.bottomRight, colors: gradient),
      ),
      child: Stack(
        children: [
          // Decorative rings
          Positioned(top: -60, right: -50, child: _ring(230)),
          Positioned(bottom: 40, left: -70, child: _ring(200)),
          Positioned(top: 120, left: 30, child: _ring(70)),
          // Crest watermark
          const Positioned(top: 70, left: 24, child: Opacity(opacity: 0.9, child: Svg('logo_s04', size: 40))),
          // Central glyph
          Center(
            child: Container(
              width: 132,
              height: 132,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.white.withValues(alpha: 0.12),
                border: Border.all(color: Colors.white24, width: 1.5),
              ),
              child: Icon(glyph, size: 64, color: Colors.white),
            ),
          ),
        ],
      ),
    );
  }

  Widget _ring(double size) => Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: Colors.white.withValues(alpha: 0.06),
        ),
      );
}
