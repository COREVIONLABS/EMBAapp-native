import 'package:flutter/material.dart';
import '../theme/app_theme.dart';
import '../widgets/app_widgets.dart';
import '../widgets/asset_img.dart';
import '../widgets/ios_chrome.dart';
import 'login_screen.dart';
import '../l10n/strings.dart';

/// Welcome 1–3 (Figma 2145:11369 / 11385 / 11400) — full-bleed hero photo
/// with a bottom sheet, 1:1 with the design.
class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});
  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final _controller = PageController();
  int _page = 0;

  static const _slides = [
    (
      'onboarding_earn',
      'Earn Points Everywhere',
      'Shop at sponsors, spin daily, complete missions, and earn 3x Points on matchday with Stadium Boost.',
      Icons.stadium_rounded,
    ),
    (
      'onboarding_redeem',
      'Redeem for Merch & Rewards',
      'Use Fan Points for exclusive jerseys, scarves, signed memorabilia, and partner discounts.',
      Icons.redeem_rounded,
    ),
    (
      'onboarding_experiences',
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
              itemBuilder: (_, i) => AssetImg(
                _slides[i].$1,
                fit: BoxFit.cover,
                fallbackIcon: _slides[i].$4,
              ),
            ),
          ),
          // Bottom sheet
          Align(
            alignment: Alignment.bottomCenter,
            child: Container(
              width: double.infinity,
              decoration: const BoxDecoration(
                color: AppColors.surface,
                borderRadius: BorderRadius.vertical(top: Radius.circular(40)),
              ),
              padding: const EdgeInsets.fromLTRB(28, 28, 28, 40),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(_slides[_page].$2,
                      style: AppText.h4.copyWith(color: const Color(0xFF101828))),
                  const SizedBox(height: 10),
                  Text(_slides[_page].$3,
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
                  PrimaryButton(_page == _slides.length - 1 ? 'Get Started' : 'Continue', onTap: _next),
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
          // Status bar on top of photo
          const SafeArea(bottom: false, child: IOSStatusBar(color: Colors.white)),
        ],
      ),
    );
  }
}
