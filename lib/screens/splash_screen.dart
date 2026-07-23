import 'package:flutter/material.dart';
import '../theme/app_theme.dart';
import '../widgets/app_widgets.dart';
import '../widgets/ios_chrome.dart';
import 'onboarding_screen.dart';

/// Splash Screen (Figma 2145:11344) — solid Schalke blue, crest, wordmark, dots.
class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});
  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    Future.delayed(const Duration(milliseconds: 2000), () {
      if (!mounted) return;
      Navigator.of(context).pushReplacement(PageRouteBuilder(
        transitionDuration: const Duration(milliseconds: 400),
        pageBuilder: (_, a, _) => FadeTransition(opacity: a, child: const OnboardingScreen()),
      ));
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.brandPrimary,
      body: SafeArea(
        child: Column(
          children: [
            const IOSStatusBar(color: Colors.white),
            const Spacer(),
            Container(
              width: 96,
              height: 96,
              decoration: const BoxDecoration(color: Colors.white, shape: BoxShape.circle),
              padding: const EdgeInsets.all(6),
              child: const Svg('logo_s04', size: 84),
            ),
            const SizedBox(height: 20),
            Text('FC Schalke 04',
                style: AppText.h2.copyWith(color: Colors.white, fontWeight: FontWeight.w800)),
            const SizedBox(height: 8),
            Text('Your loyalty. Your rewards.',
                style: AppText.body1.copyWith(color: Colors.white.withValues(alpha: 0.75))),
            const Spacer(),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                for (var i = 0; i < 3; i++)
                  Container(
                    margin: const EdgeInsets.symmetric(horizontal: 3),
                    width: i == 0 ? 22 : 8,
                    height: 8,
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: i == 0 ? 1 : 0.4),
                      borderRadius: BorderRadius.circular(999),
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 24),
            const HomeIndicator(color: Colors.white),
          ],
        ),
      ),
    );
  }
}
