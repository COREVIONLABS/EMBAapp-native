import 'package:flutter/material.dart';
import '../theme/app_theme.dart';
import '../widgets/app_widgets.dart';
import '../widgets/ios_chrome.dart';
import '../widgets/text_field.dart';
import '../main_shell.dart';
import 'signup_screen.dart';
import 'password_reset_screen.dart';
import '../l10n/strings.dart';

/// Log In (Figma node 385:3569).
class LoginScreen extends StatelessWidget {
  const LoginScreen({super.key});

  void _enter(BuildContext context) {
    Navigator.of(context).pushAndRemoveUntil(
      MaterialPageRoute(builder: (_) => const MainShell()),
      (r) => false,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.surface,
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: ListView(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                children: [
                  const SizedBox(height: 12),
                  const Svg('logo_s04', size: 56),
                  const SizedBox(height: 24),
                  Text(tr('Welcome back'), style: AppText.h2),
                  const SizedBox(height: 6),
                  Text(tr('Log in to your S04 fan account'),
                      style: AppText.body1.copyWith(color: AppColors.textLight)),
                  const SizedBox(height: 28),
                  AppTextField(label: tr('Email'), hint: tr('you@example.com'), keyboardType: TextInputType.emailAddress),
                  const SizedBox(height: 18),
                  AppTextField(
                    label: tr('Password'),
                    hint: '••••••••',
                    obscure: true,
                    suffix: Icon(Icons.visibility_off_outlined, color: AppColors.textLight, size: 20),
                  ),
                  const SizedBox(height: 12),
                  Align(
                    alignment: Alignment.centerRight,
                    child: GestureDetector(
                      onTap: () => Navigator.of(context).push(MaterialPageRoute(builder: (_) => const PasswordResetScreen())),
                      child: Text(tr('Forgot password?'),
                          style: AppText.body2.copyWith(color: AppColors.brandPrimary, fontWeight: FontWeight.w600)),
                    ),
                  ),
                  const SizedBox(height: 24),
                  PrimaryButton(tr('Log In'), onTap: () => _enter(context)),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      Expanded(child: Divider(color: AppColors.borderLightest)),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 12),
                        child: Text(tr('or'), style: AppText.body3Regular),
                      ),
                      Expanded(child: Divider(color: AppColors.borderLightest)),
                    ],
                  ),
                  const SizedBox(height: 16),
                  SecondaryButton(tr('Continue with Face ID'), onTap: () => _enter(context)),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 8),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(tr("Don't have an account? "), style: AppText.body2.copyWith(color: AppColors.textLight)),
                  GestureDetector(
                    onTap: () => Navigator.of(context).push(MaterialPageRoute(builder: (_) => const SignupScreen())),
                    child: Text(tr('Sign Up'),
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
