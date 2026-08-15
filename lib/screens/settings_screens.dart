import 'package:flutter/material.dart';
import '../theme/app_theme.dart';
import '../widgets/app_widgets.dart';
import '../widgets/settings_widgets.dart';
import '../widgets/sub_scaffold.dart';
import '../widgets/text_field.dart';
import '../widgets/action_sheets.dart';
import '../model/consent.dart';
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
/// Privacy & data consent — three separate, individually withdrawable opt-ins
/// (personalisation, advertising, location) as required by GDPR and the EU
/// ranking-transparency rules that the sponsored placements depend on. Each is
/// bound to a live [ValueNotifier], so switching one off takes effect instantly
/// across the app (e.g. ads off → sponsored placements disappear).
class ConsentScreen extends StatelessWidget {
  final String title;
  const ConsentScreen({super.key, required this.title});

  Future<void> _withdrawAll(BuildContext context) async {
    final ok = await showConfirmDialog(
      context,
      title: 'Withdraw all consent?',
      message: 'This turns off personalisation, advertising and location. You’ll still get the core app — just nothing tailored.',
      confirmLabel: 'Withdraw all',
      destructive: true,
    );
    if (!ok) return;
    personalizationConsent.value = false;
    adsConsent.value = false;
    locationConsent.value = false;
  }

  @override
  Widget build(BuildContext context) {
    return SubScaffold(
      title: tr('Privacy & data'),
      children: [
        // Intro — the value exchange, stated plainly.
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(color: AppColors.brandLightest, borderRadius: BorderRadius.circular(AppRadii.card)),
          child: Row(children: [
            Container(width: 44, height: 44, decoration: BoxDecoration(color: AppColors.surface, borderRadius: BorderRadius.circular(12)), child: const Icon(Icons.shield_rounded, color: AppColors.brandPrimary, size: 24)),
            const SizedBox(width: 14),
            Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text(tr('You’re in control'), style: AppText.body2.copyWith(color: AppColors.onAccent, fontWeight: FontWeight.w800)),
              Text(tr('Each purpose is a separate choice — turn any of them off at any time.'), style: AppText.body3.copyWith(color: AppColors.onAccent)),
            ])),
          ]),
        ),
        const SizedBox(height: 16),

        _ConsentCard(
          flag: personalizationConsent,
          icon: Icons.auto_awesome_rounded,
          title: 'Personalisation',
          purpose: 'Use my activity to tailor rewards, offers and challenges to what I actually like.',
          off: 'Off: you’ll see the same offers as everyone else.',
        ),
        const SizedBox(height: 12),
        _ConsentCard(
          flag: adsConsent,
          icon: Icons.campaign_rounded,
          title: 'Advertising',
          purpose: 'Show sponsored partner placements — always clearly labelled “Ad”.',
          off: 'Off: sponsored placements are hidden across the app.',
        ),
        const SizedBox(height: 12),
        _ConsentCard(
          flag: locationConsent,
          icon: Icons.location_on_rounded,
          title: 'Location',
          purpose: 'Use my location to show partners near me, distances and matchday offers around the stadium.',
          off: 'Off: the partner map and “near me” distances are hidden.',
        ),
        const SizedBox(height: 16),

        // Transparency block.
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(color: AppColors.surface, borderRadius: BorderRadius.circular(AppRadii.card), border: Border.all(color: AppColors.borderLightest)),
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text(tr('How we handle your data'), style: AppText.label2),
            const SizedBox(height: 10),
            for (final s in const [
              'Partners and sponsors only ever see aggregated numbers — never your personal data.',
              'Payment and card data is kept separate and never used for advertising.',
              'You can withdraw any consent here at any time, with immediate effect.',
            ]) ...[
              Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Icon(Icons.check_circle_rounded, size: 16, color: AppColors.success),
                const SizedBox(width: 10),
                Expanded(child: Padding(padding: const EdgeInsets.only(bottom: 8), child: Text(tr(s), style: AppText.body3.copyWith(color: AppColors.textNormal)))),
              ]),
            ],
          ]),
        ),
        const SizedBox(height: 16),
        SecondaryButton(tr('Withdraw all consent'), onTap: () => _withdrawAll(context)),
        const SizedBox(height: 12),
        Text(tr('See our Privacy Policy for the full detail on how your data is processed.'), style: AppText.body3Regular),
      ],
    );
  }
}

/// A single consent card: icon, purpose, a live switch bound to a notifier, and
/// a plain-language note on what turning it off means.
class _ConsentCard extends StatelessWidget {
  final ValueNotifier<bool> flag;
  final IconData icon;
  final String title;
  final String purpose;
  final String off;
  const _ConsentCard({required this.flag, required this.icon, required this.title, required this.purpose, required this.off});

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<bool>(
      valueListenable: flag,
      builder: (context, on, __) => Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(color: AppColors.surface, borderRadius: BorderRadius.circular(AppRadii.card), border: Border.all(color: AppColors.borderLightest)),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Row(children: [
            Container(width: 40, height: 40, decoration: BoxDecoration(color: AppColors.brandLightest, borderRadius: BorderRadius.circular(11)), child: Icon(icon, color: AppColors.brandPrimary, size: 21)),
            const SizedBox(width: 12),
            Expanded(child: Text(tr(title), style: AppText.label2)),
            Switch(
              value: on,
              activeThumbColor: Colors.white,
              activeTrackColor: AppColors.brandPrimary,
              onChanged: (v) => flag.value = v,
            ),
          ]),
          const SizedBox(height: 8),
          Text(tr(purpose), style: AppText.body3.copyWith(color: AppColors.textNormal, height: 1.5)),
          const SizedBox(height: 8),
          Row(children: [
            Icon(on ? Icons.check_circle_outline_rounded : Icons.remove_circle_outline_rounded, size: 14, color: on ? AppColors.success : AppColors.textLight),
            const SizedBox(width: 6),
            Expanded(child: Text(on ? tr('On') : tr(off), style: AppText.caption1.copyWith(color: on ? AppColors.success : AppColors.textLight, fontWeight: FontWeight.w700))),
          ]),
        ]),
      ),
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
