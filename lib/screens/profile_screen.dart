import 'package:flutter/material.dart';
import '../theme/app_theme.dart';
import '../widgets/app_widgets.dart';
import '../widgets/tab_scaffold.dart';
import 'settings_screens.dart';
import 'wallet_detail_screens.dart';
import 'subscription_screen.dart';

/// Profile (Figma 2145:11608) — user card + grouped settings menu.
class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return TabScaffold(
      children: [
        // User card
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: SurfaceCard(
            child: Row(
              children: [
                Container(
                  width: 52,
                  height: 52,
                  decoration: BoxDecoration(shape: BoxShape.circle, gradient: const LinearGradient(colors: AppColors.pointsGradient)),
                  alignment: Alignment.center,
                  child: const Text('MM', style: TextStyle(fontFamily: 'Urbanist', color: Colors.white, fontSize: 18, fontWeight: FontWeight.w800)),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Max Mustermann', style: AppText.label2.copyWith(color: AppColors.textDarker)),
                      const SizedBox(height: 4),
                      Pill(
                        gradient: const LinearGradient(colors: AppColors.goldGradient),
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                        child: Row(mainAxisSize: MainAxisSize.min, children: [
                          const Icon(Icons.star_rounded, size: 11, color: AppColors.brandDarkest),
                          const SizedBox(width: 4),
                          Text('Superfan · 2850 pts', style: AppText.caption1.copyWith(color: AppColors.brandDarkest)),
                        ]),
                      ),
                    ],
                  ),
                ),
                const Icon(Icons.chevron_right_rounded, color: AppColors.textLight),
              ],
            ),
          ),
        ),
        const SizedBox(height: 20),
        _group(context, 'Account', const [
          (Icons.person_outline_rounded, 'Edit Profile', ''),
          (Icons.workspace_premium_outlined, 'Subscription', 'Superfan · €9.99/mo'),
          (Icons.account_balance_outlined, 'Bank Account', 'Connected'),
          (Icons.credit_card_rounded, 'Manage Card', 'Physical + Virtual'),
        ]),
        const SizedBox(height: 16),
        _group(context, 'Settings', const [
          (Icons.notifications_none_rounded, 'Notification Preferences', ''),
          (Icons.lock_outline_rounded, 'Update Password', ''),
          (Icons.fingerprint_rounded, 'Biometric Login', 'toggle'),
          (Icons.devices_other_rounded, 'Device Management', ''),
          (Icons.language_rounded, 'Language', 'English'),
        ]),
        const SizedBox(height: 16),
        _group(context, 'Privacy', const [
          (Icons.shield_outlined, 'Data Sharing Preferences', ''),
          (Icons.campaign_outlined, 'Marketing Consent', ''),
          (Icons.policy_outlined, 'Privacy Policy', ''),
        ]),
        const SizedBox(height: 16),
        _group(context, 'App', const [
          (Icons.info_outline_rounded, 'About Us', ''),
          (Icons.description_outlined, 'Terms & Conditions', ''),
        ]),
        const SizedBox(height: 16),
        const Padding(padding: EdgeInsets.symmetric(horizontal: 20), child: _LogoutTile()),
      ],
    );
  }

  Widget _group(BuildContext context, String title, List<(IconData, String, String)> items) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(padding: const EdgeInsets.symmetric(horizontal: 20), child: Text(title, style: AppText.body3.copyWith(color: AppColors.textLight))),
        const SizedBox(height: 8),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: SurfaceCard(
            padding: EdgeInsets.zero,
            child: Column(
              children: [
                for (var i = 0; i < items.length; i++) ...[
                  _MenuRow(icon: items[i].$1, label: items[i].$2, value: items[i].$3),
                  if (i != items.length - 1) const Divider(height: 1, indent: 52, color: AppColors.borderLightest),
                ],
              ],
            ),
          ),
        ),
      ],
    );
  }
}

Widget? _screenFor(String label) {
  switch (label) {
    case 'Edit Profile':
      return const EditProfileScreen();
    case 'Subscription':
      return const SubscriptionScreen();
    case 'Bank Account':
      return const BankAccountScreen();
    case 'Manage Card':
      return const ManageCardsScreen();
    case 'Notification Preferences':
      return const NotificationPrefsScreen();
    case 'Device Management':
      return const DeviceManagementScreen();
    case 'Language':
      return const LanguageScreen();
    case 'Data Sharing Preferences':
      return const ConsentScreen(title: 'Data Sharing');
    case 'Marketing Consent':
      return const ConsentScreen(title: 'Marketing Consent');
    case 'Privacy Policy':
      return const PrivacyPolicyScreen();
    case 'Update Password':
    case 'About Us':
    case 'Terms & Conditions':
      return const PrivacyPolicyScreen();
  }
  return null;
}

class _MenuRow extends StatefulWidget {
  final IconData icon;
  final String label;
  final String value;
  const _MenuRow({required this.icon, required this.label, required this.value});
  @override
  State<_MenuRow> createState() => _MenuRowState();
}

class _MenuRowState extends State<_MenuRow> {
  bool _bio = true;
  @override
  Widget build(BuildContext context) {
    final isToggle = widget.value == 'toggle';
    return InkWell(
      onTap: isToggle
          ? null
          : () {
              final s = _screenFor(widget.label);
              if (s != null) Navigator.of(context).push(MaterialPageRoute(builder: (_) => s));
            },
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 13),
        child: Row(
          children: [
            Icon(widget.icon, size: 20, color: AppColors.textNormal),
            const SizedBox(width: 12),
            Expanded(child: Text(widget.label, style: AppText.body1.copyWith(color: AppColors.textDarker, fontSize: 14.5))),
            if (isToggle)
              Switch(
                value: _bio,
                activeThumbColor: Colors.white,
                activeTrackColor: AppColors.brandPrimary,
                onChanged: (v) => setState(() => _bio = v),
              )
            else ...[
              if (widget.value.isNotEmpty)
                Text(widget.value, style: AppText.body3.copyWith(color: AppColors.textLight)),
              const SizedBox(width: 6),
              const Icon(Icons.chevron_right_rounded, color: AppColors.textLight, size: 20),
            ],
          ],
        ),
      ),
    );
  }
}

class _LogoutTile extends StatelessWidget {
  const _LogoutTile();
  @override
  Widget build(BuildContext context) {
    return SurfaceCard(
      padding: EdgeInsets.zero,
      child: InkWell(
        onTap: () {},
        child: const Padding(
          padding: EdgeInsets.symmetric(horizontal: 16, vertical: 15),
          child: Row(children: [
            Icon(Icons.logout_rounded, size: 20, color: AppColors.danger),
            SizedBox(width: 12),
            Text('Log Out', style: TextStyle(fontFamily: 'Urbanist', fontSize: 14.5, fontWeight: FontWeight.w600, color: AppColors.danger)),
          ]),
        ),
      ),
    );
  }
}
