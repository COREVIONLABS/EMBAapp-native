import 'package:flutter/material.dart';
import '../theme/app_theme.dart';
import '../widgets/app_widgets.dart';
import '../widgets/ios_chrome.dart';
import 'onboarding_screen.dart';

/// Splash Screen (Figma node 385:3448) — Schalke blue with centered crest.
class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});
  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    Future.delayed(const Duration(milliseconds: 1900), () {
      if (!mounted) return;
      Navigator.of(context).pushReplacement(
        PageRouteBuilder(
          transitionDuration: const Duration(milliseconds: 400),
          pageBuilder: (_, a, _) => FadeTransition(opacity: a, child: const OnboardingScreen()),
        ),
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [AppColors.brandPrimary, AppColors.brandDarkest],
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              const IOSStatusBar(color: Colors.white),
              const Spacer(),
              Container(
                width: 112,
                height: 112,
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.08),
                  shape: BoxShape.circle,
                ),
                padding: const EdgeInsets.all(14),
                child: const Svg('logo_s04', size: 84),
              ),
              const SizedBox(height: 24),
              Text('FC SCHALKE 04',
                  style: AppText.h4.copyWith(
                      color: Colors.white, letterSpacing: 2, fontWeight: FontWeight.w800)),
              const SizedBox(height: 8),
              Text('Club App',
                  style: AppText.body1.copyWith(color: Colors.white.withValues(alpha: 0.7))),
              const Spacer(),
              const SizedBox(
                width: 26,
                height: 26,
                child: CircularProgressIndicator(strokeWidth: 2.4, color: Colors.white70),
              ),
              const SizedBox(height: 40),
              const HomeIndicator(color: Colors.white),
            ],
          ),
        ),
      ),
    );
  }
}
