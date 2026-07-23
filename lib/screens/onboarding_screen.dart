import 'package:flutter/material.dart';
import '../theme/app_theme.dart';
import '../widgets/app_widgets.dart';
import '../widgets/asset_img.dart';
import '../widgets/ios_chrome.dart';
import 'login_screen.dart';

/// Welcome 1–3 (Figma nodes 385:3473 / 385:3489 / 385:3504).
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
      'Earn Points',
      'Collect S04 Fan Points for match attendance, purchases and predictions — every action counts.',
      Icons.stadium_rounded,
    ),
    (
      'onboarding_redeem',
      'Redeem Rewards',
      'Turn your points into tickets, exclusive merch and once-in-a-lifetime club experiences.',
      Icons.redeem_rounded,
    ),
    (
      'onboarding_experiences',
      'Exclusive Experiences',
      'Meet the players, get stadium tours and unlock money-can’t-buy Superfan moments.',
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
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(builder: (_) => const LoginScreen()),
    );
  }

  @override
  Widget build(BuildContext context) {
    final last = _page == _slides.length - 1;
    return Scaffold(
      backgroundColor: AppColors.surface,
      body: SafeArea(
        child: Column(
          children: [
            const IOSStatusBar(),
            Align(
              alignment: Alignment.centerRight,
              child: Padding(
                padding: const EdgeInsets.only(right: 16, top: 4),
                child: TextButton(
                  onPressed: _goLogin,
                  child: Text('Skip', style: AppText.body2.copyWith(color: AppColors.textLight)),
                ),
              ),
            ),
            Expanded(
              child: PageView.builder(
                controller: _controller,
                onPageChanged: (i) => setState(() => _page = i),
                itemCount: _slides.length,
                itemBuilder: (_, i) {
                  final s = _slides[i];
                  return Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 32),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Container(
                          width: 240,
                          height: 240,
                          decoration: BoxDecoration(
                            color: AppColors.brandLightest,
                            borderRadius: BorderRadius.circular(40),
                          ),
                          padding: const EdgeInsets.all(28),
                          child: AssetImg(s.$1, fallbackIcon: s.$4),
                        ),
                        const SizedBox(height: 48),
                        Text(s.$2, textAlign: TextAlign.center, style: AppText.h2),
                        const SizedBox(height: 12),
                        Text(s.$3,
                            textAlign: TextAlign.center,
                            style: AppText.body1.copyWith(color: AppColors.textLight)),
                      ],
                    ),
                  );
                },
              ),
            ),
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
            const SizedBox(height: 28),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: PrimaryButton(last ? 'Get Started' : 'Next', onTap: _next),
            ),
            const SizedBox(height: 8),
            const HomeIndicator(),
          ],
        ),
      ),
    );
  }
}
