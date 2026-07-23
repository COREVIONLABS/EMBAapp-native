import 'package:flutter/material.dart';
import '../theme/app_theme.dart';
import '../widgets/app_widgets.dart';
import '../widgets/ios_chrome.dart';
import '../widgets/text_field.dart';
import '../main_shell.dart';

/// Sign Up (Figma node 385:3518).
class SignupScreen extends StatelessWidget {
  const SignupScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.surface,
      body: SafeArea(
        child: Column(
          children: [
            const IOSStatusBar(),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8),
              child: Row(
                children: [
                  IconButton(
                    onPressed: () => Navigator.of(context).maybePop(),
                    icon: const Icon(Icons.arrow_back_ios_new_rounded, size: 18, color: AppColors.textDarker),
                  ),
                ],
              ),
            ),
            Expanded(
              child: ListView(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                children: [
                  Text('Create account', style: AppText.h2),
                  const SizedBox(height: 6),
                  Text('Join the S04 fan community',
                      style: AppText.body1.copyWith(color: AppColors.textLight)),
                  const SizedBox(height: 28),
                  const AppTextField(label: 'Full name', hint: 'Max Mustermann'),
                  const SizedBox(height: 18),
                  const AppTextField(
                      label: 'Email', hint: 'you@example.com', keyboardType: TextInputType.emailAddress),
                  const SizedBox(height: 18),
                  const AppTextField(label: 'Password', hint: '••••••••', obscure: true),
                  const SizedBox(height: 20),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Icon(Icons.check_box_rounded, color: AppColors.brandPrimary, size: 22),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Text('I agree to the Terms of Service and Privacy Policy',
                            style: AppText.body2.copyWith(color: AppColors.textLight)),
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),
                  PrimaryButton('Create Account',
                      onTap: () => Navigator.of(context).pushAndRemoveUntil(
                            MaterialPageRoute(builder: (_) => const MainShell()),
                            (r) => false,
                          )),
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
