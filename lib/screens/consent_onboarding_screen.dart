import 'package:flutter/material.dart';
import '../theme/app_theme.dart';
import '../widgets/app_widgets.dart';
import '../main_shell.dart';
import '../model/consent.dart';
import '../l10n/strings.dart';

/// First-run consent step, shown right after sign-up — collecting consent at the
/// point of data collection (GDPR), not buried in settings. Three separate
/// opt-ins the fan can accept or decline before entering the app; all are
/// changeable later under Profile → Privacy & data.
class ConsentOnboardingScreen extends StatefulWidget {
  const ConsentOnboardingScreen({super.key});
  @override
  State<ConsentOnboardingScreen> createState() => _ConsentOnboardingScreenState();
}

class _ConsentOnboardingScreenState extends State<ConsentOnboardingScreen> {
  bool _personalization = true;
  bool _ads = true;
  bool _location = true;

  void _continue() {
    personalizationConsent.value = _personalization;
    adsConsent.value = _ads;
    locationConsent.value = _location;
    Navigator.of(context).pushAndRemoveUntil(
      MaterialPageRoute(builder: (_) => const MainShell()),
      (r) => false,
    );
  }

  void _essentialsOnly() {
    setState(() {
      _personalization = false;
      _ads = false;
      _location = false;
    });
    _continue();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.surface,
      body: SafeArea(
        child: Column(children: [
          Expanded(
            child: ListView(
              padding: const EdgeInsets.fromLTRB(20, 24, 20, 8),
              children: [
                Container(
                  width: 56, height: 56,
                  decoration: BoxDecoration(color: AppColors.brandLightest, borderRadius: BorderRadius.circular(16)),
                  child: const Icon(Icons.shield_rounded, color: AppColors.brandPrimary, size: 30),
                ),
                const SizedBox(height: 18),
                Text(tr('Your privacy choices'), style: AppText.h2),
                const SizedBox(height: 8),
                Text(tr('Choose what we may use to improve your experience. Each is a separate choice — and you can change any of them later under Profile.'),
                    style: AppText.body1.copyWith(color: AppColors.textLight, height: 1.5, fontSize: 15)),
                const SizedBox(height: 24),
                _row(
                  icon: Icons.auto_awesome_rounded,
                  title: tr('Personalisation'),
                  sub: tr('Tailor rewards & offers to what you like'),
                  value: _personalization,
                  onChanged: (v) => setState(() => _personalization = v),
                ),
                _row(
                  icon: Icons.campaign_rounded,
                  title: tr('Advertising'),
                  sub: tr('Show sponsored partner offers, always labelled “Ad”'),
                  value: _ads,
                  onChanged: (v) => setState(() => _ads = v),
                ),
                _row(
                  icon: Icons.location_on_rounded,
                  title: tr('Location'),
                  sub: tr('Show partners near you and matchday offers'),
                  value: _location,
                  onChanged: (v) => setState(() => _location = v),
                ),
                const SizedBox(height: 8),
                Row(children: [
                  Icon(Icons.lock_outline_rounded, size: 14, color: AppColors.textLight),
                  const SizedBox(width: 6),
                  Expanded(child: Text(tr('Partners only ever see aggregated numbers — never your personal data.'), style: AppText.caption1.copyWith(color: AppColors.textLight))),
                ]),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 8, 20, 16),
            child: Column(children: [
              PrimaryButton(tr('Continue'), onTap: _continue),
              const SizedBox(height: 8),
              TextButton(
                onPressed: _essentialsOnly,
                child: Text(tr('Continue with essentials only'), style: AppText.body2.copyWith(color: AppColors.textNormal, fontWeight: FontWeight.w700)),
              ),
            ]),
          ),
        ]),
      ),
    );
  }

  Widget _row({required IconData icon, required String title, required String sub, required bool value, required ValueChanged<bool> onChanged}) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(color: AppColors.surface, borderRadius: BorderRadius.circular(AppRadii.card), border: Border.all(color: AppColors.borderLightest)),
      child: Row(children: [
        Container(width: 42, height: 42, decoration: BoxDecoration(color: AppColors.brandLightest, borderRadius: BorderRadius.circular(12)), child: Icon(icon, color: AppColors.brandPrimary, size: 22)),
        const SizedBox(width: 14),
        Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text(title, style: AppText.body2.copyWith(color: AppColors.textDarker, fontWeight: FontWeight.w800)),
          const SizedBox(height: 2),
          Text(sub, style: AppText.body3Regular),
        ])),
        Switch(
          value: value,
          activeThumbColor: Colors.white,
          activeTrackColor: AppColors.brandPrimary,
          onChanged: onChanged,
        ),
      ]),
    );
  }
}
