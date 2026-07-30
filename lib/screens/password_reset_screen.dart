import 'package:flutter/material.dart';
import '../theme/app_theme.dart';
import '../widgets/app_widgets.dart';
import '../widgets/ios_chrome.dart';
import '../widgets/text_field.dart';

/// Password Reset (Figma 2145:11512).
class PasswordResetScreen extends StatelessWidget {
  const PasswordResetScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.surface,
      body: SafeArea(
        child: Column(
          children: [
            const IOSStatusBar(),
            Expanded(
              child: ListView(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                children: [
                  const SizedBox(height: 12),
                  const Svg('logo_s04', size: 56),
                  const SizedBox(height: 24),
                  Text('Reset your password', style: AppText.h2),
                  const SizedBox(height: 6),
                  Text("Enter the email associated with your account and we'll send a reset link",
                      style: AppText.body1.copyWith(color: AppColors.textLight)),
                  const SizedBox(height: 28),
                  const AppTextField(
                    label: 'Email',
                    hint: 'max@schalke04.de',
                    keyboardType: TextInputType.emailAddress,
                    prefix: Icon(Icons.mail_outline_rounded, color: AppColors.textLight, size: 20),
                  ),
                  const SizedBox(height: 24),
                  PrimaryButton('Send Reset Link', onTap: () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Reset link sent — check your inbox.')),
                    );
                    Navigator.of(context).maybePop();
                  }),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 8),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text('Remember your password? ', style: AppText.body2.copyWith(color: AppColors.textLight)),
                  GestureDetector(
                    onTap: () => Navigator.of(context).maybePop(),
                    child: Text('Log In',
                        style: AppText.body2.copyWith(color: AppColors.brandPrimary, fontWeight: FontWeight.w700)),
                  ),
                ],
              ),
            ),
            const HomeIndicator(),
          ],
        ),
      ),
    );
  }
}
