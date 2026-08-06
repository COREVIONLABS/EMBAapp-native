import 'package:flutter/material.dart';
import '../theme/app_theme.dart';
import '../widgets/app_widgets.dart';
import '../widgets/settings_widgets.dart';
import '../widgets/sub_scaffold.dart';
import '../widgets/text_field.dart';
import '../l10n/strings.dart';

/// Edit Profile (Figma 385:4414).
class EditProfileScreen extends StatelessWidget {
  const EditProfileScreen({super.key});
  @override
  Widget build(BuildContext context) {
    return SubScaffold(
      title: tr('Edit Profile'),
      bottomBar: PrimaryButton(tr('Save Changes'), onTap: () => Navigator.of(context).maybePop()),
      children: [
        Center(
          child: Stack(
            children: [
              Container(
                width: 96,
                height: 96,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: const LinearGradient(colors: AppColors.pointsGradient),
                ),
                child: const Center(
                  child: Text('MM',
                      style: TextStyle(
                          fontFamily: 'Urbanist', fontSize: 32, fontWeight: FontWeight.w800, color: Colors.white)),
                ),
              ),
              Positioned(
                right: 0,
                bottom: 0,
                child: Container(
                  padding: const EdgeInsets.all(6),
                  decoration: const BoxDecoration(shape: BoxShape.circle, color: AppColors.brandPrimary),
                  child: const Icon(Icons.camera_alt_rounded, color: Colors.white, size: 16),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 28),
        AppTextField(label: tr('Full name'), hint: tr('Max Mustermann')),
        const SizedBox(height: 18),
        AppTextField(label: tr('Email'), hint: tr('max@example.com'), keyboardType: TextInputType.emailAddress),
        const SizedBox(height: 18),
        AppTextField(label: tr('Phone'), hint: '+49 170 0000000', keyboardType: TextInputType.phone),
        const SizedBox(height: 18),
        AppTextField(label: tr('Favourite section'), hint: tr('Nordkurve')),
      ],
    );
  }
}

/// Notifications Preferences (Figma 385:5090).
class NotificationPrefsScreen extends StatelessWidget {
  const NotificationPrefsScreen({super.key});
  @override
  Widget build(BuildContext context) {
    return SubScaffold(
      title: tr('Notifications'),
      children: [
        Padding(padding: const EdgeInsets.only(bottom: 8), child: Text(tr('Push notifications'), style: AppText.body3)),
        SettingsGroup([
          ToggleRow(tr('Matchday reminders'), subtitle: tr('Kickoff & lineup alerts'), initial: true),
          ToggleRow(tr('Points & rewards'), subtitle: tr('When you earn or can redeem'), initial: true),
          ToggleRow(tr('Predictions'), subtitle: tr('Deadlines and results'), initial: true),
          ToggleRow(tr('Daily games'), subtitle: tr('Spin & scratch reminders')),
        ]),
        SizedBox(height: 20),
        Padding(padding: EdgeInsets.only(bottom: 8), child: Text(tr('Email'), style: AppText.body3)),
        SettingsGroup([
          ToggleRow(tr('Newsletter')),
          ToggleRow(tr('Exclusive offers')),
        ]),
      ],
    );
  }
}

/// Language (Figma 416:2181).
class LanguageScreen extends StatefulWidget {
  const LanguageScreen({super.key});
  @override
  State<LanguageScreen> createState() => _LanguageScreenState();
}

class _LanguageScreenState extends State<LanguageScreen> {
  @override
  Widget build(BuildContext context) {
    final isDe = localeNotifier.value == AppLocale.de;
    return SubScaffold(
      title: tr('Language'),
      children: [
        SettingsGroup([
          SelectRow('Deutsch', selected: isDe, onTap: () => setState(() => localeNotifier.value = AppLocale.de)),
          SelectRow('English', selected: !isDe, onTap: () => setState(() => localeNotifier.value = AppLocale.en)),
        ]),
      ],
    );
  }
}

/// Data Sharing / Marketing Consent (Figma 416:2249 / 416:2317).
class ConsentScreen extends StatelessWidget {
  final String title;
  const ConsentScreen({super.key, required this.title});
  @override
  Widget build(BuildContext context) {
    return SubScaffold(
      title: title,
      children: [
        SettingsGroup([
          ToggleRow(tr('Personalised offers'), subtitle: tr('Use my activity to tailor rewards'), initial: false),
          ToggleRow(tr('Share with club partners'), subtitle: tr('Sponsors & official partners')),
          ToggleRow(tr('Analytics'), subtitle: tr('Help improve the app'), initial: false),
          ToggleRow(tr('Third-party marketing')),
        ]),
        const SizedBox(height: 16),
        Text(tr('You can change these choices at any time. See our Privacy Policy for details on how your data is processed.'),
            style: AppText.body3Regular),
      ],
    );
  }
}

/// Device Management (Figma 415:2171).
class DeviceManagementScreen extends StatelessWidget {
  const DeviceManagementScreen({super.key});
  @override
  Widget build(BuildContext context) {
    return SubScaffold(
      title: tr('Devices'),
      children: [
        for (final d in const [
          ('iPhone 15 Pro', 'This device · Gelsenkirchen', true),
          ('iPad Air', 'Last active 2 days ago', false),
          ('Chrome · Windows', 'Last active 1 week ago', false),
        ])
          Padding(
            padding: const EdgeInsets.only(bottom: 10),
            child: SurfaceCard(
              child: Row(
                children: [
                  Icon(Icons.devices_rounded, color: AppColors.textNormal),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(d.$1, style: AppText.body2.copyWith(color: AppColors.textDarker)),
                        const SizedBox(height: 2),
                        Text(d.$2, style: AppText.body3Regular),
                      ],
                    ),
                  ),
                  if (d.$3)
                    Pill(color: AppColors.successBg, child: Text(tr('Active'), style: AppText.caption1.copyWith(color: AppColors.success)))
                  else
                    const Icon(Icons.logout_rounded, color: AppColors.danger, size: 20),
                ],
              ),
            ),
          ),
      ],
    );
  }
}

/// Biometric Login (Figma 414:2161).
class BiometricScreen extends StatelessWidget {
  const BiometricScreen({super.key});
  @override
  Widget build(BuildContext context) {
    return SubScaffold(
      title: tr('Biometric Login'),
      children: [
        const SizedBox(height: 24),
        Center(
          child: Container(
            width: 120,
            height: 120,
            decoration: BoxDecoration(color: AppColors.brandLightest, shape: BoxShape.circle),
            child: const Icon(Icons.fingerprint_rounded, size: 64, color: AppColors.brandPrimary),
          ),
        ),
        const SizedBox(height: 28),
        Text(tr('Enable Face ID / Fingerprint'), textAlign: TextAlign.center, style: AppText.h4),
        const SizedBox(height: 8),
        Text(tr('Log in securely without typing your password every time.'),
            textAlign: TextAlign.center, style: AppText.body1.copyWith(color: AppColors.textLight)),
        const SizedBox(height: 28),
        SettingsGroup([ToggleRow(tr('Use biometric login'), initial: true)]),
      ],
    );
  }
}

/// Privacy Policy (Figma 385:3940).
class PrivacyPolicyScreen extends StatelessWidget {
  const PrivacyPolicyScreen({super.key});
  @override
  Widget build(BuildContext context) {
    final p = TextStyle(fontFamily: 'Urbanist', fontSize: 14, height: 1.6, color: AppColors.textNormal);
    return SubScaffold(
      title: tr('Privacy Policy'),
      children: [
        Text(tr('Last updated: 22 July 2026'), style: AppText.body3Regular),
        const SizedBox(height: 16),
        for (final s in const [
          ('1. Data we collect',
              'We process the data you provide when creating an account, using Fan Points, making predictions and redeeming rewards.'),
          ('2. How we use it',
              'Your data powers your Fan Points balance, personalised rewards and matchday features. We never sell your personal data.'),
          ('3. Sharing',
              'We share limited data with official club partners only where you have consented under Data Sharing settings.'),
          ('4. Your rights',
              'You can access, correct or delete your data at any time from Profile → Account, or by contacting the club.'),
        ]) ...[
          Text(s.$1, style: AppText.label2),
          const SizedBox(height: 6),
          Text(s.$2, style: p),
          const SizedBox(height: 18),
        ],
      ],
    );
  }
}

/// About Us — club/app intro (replaces the Privacy-Policy placeholder route).
class AboutUsScreen extends StatelessWidget {
  const AboutUsScreen({super.key});
  @override
  Widget build(BuildContext context) {
    final p = TextStyle(fontFamily: 'Urbanist', fontSize: 14, height: 1.6, color: AppColors.textNormal);
    return SubScaffold(
      title: tr('About Us'),
      children: [
        for (final s in const [
          ('The FC Schalke 04 Club App',
              'Your matchday companion and fan-rewards home — tickets, experiences, exclusive content and Fan Points, all in one place.'),
          ('Fan Points & Fan+',
              'Earn points for everything you do as a fan and get them back as real rewards. Fan+ members unlock priority access, exclusive drops and more.'),
          ('Built for Schalkers',
              'Powered by EMBA SYSTEMS together with the club and its official partners.'),
        ]) ...[
          Text(tr(s.$1), style: AppText.label2),
          const SizedBox(height: 6),
          Text(tr(s.$2), style: p),
          const SizedBox(height: 18),
        ],
        Text('FC Schalke 04 · v1.0.0', style: AppText.caption1.copyWith(color: AppColors.textLight)),
      ],
    );
  }
}

/// Terms & Conditions — short prototype terms (replaces the placeholder route).
class TermsScreen extends StatelessWidget {
  const TermsScreen({super.key});
  @override
  Widget build(BuildContext context) {
    final p = TextStyle(fontFamily: 'Urbanist', fontSize: 14, height: 1.6, color: AppColors.textNormal);
    return SubScaffold(
      title: tr('Terms & Conditions'),
      children: [
        Text(tr('Last updated: 22 July 2026'), style: AppText.body3Regular),
        const SizedBox(height: 16),
        for (final s in const [
          ('1. Using the app',
              'By using the FC Schalke 04 Club App you agree to these terms and to fair, personal use of your account and rewards.'),
          ('2. Fan Points',
              'Fan Points have no cash value, cannot be transferred or sold, and may expire or be adjusted in line with the rewards programme rules.'),
          ('3. Rewards & vouchers',
              'Rewards, drops and vouchers are subject to availability and partner terms. Redeemed vouchers cannot be reversed.'),
          ('4. Memberships',
              'Fan+ memberships renew until cancelled. You can manage or cancel your plan any time under Profile → Membership.'),
        ]) ...[
          Text(tr(s.$1), style: AppText.label2),
          const SizedBox(height: 6),
          Text(tr(s.$2), style: p),
          const SizedBox(height: 18),
        ],
      ],
    );
  }
}
