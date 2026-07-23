import 'package:flutter/material.dart';
import '../theme/app_theme.dart';
import '../widgets/app_widgets.dart';
import '../widgets/tab_scaffold.dart';
import 'settings_screens.dart';
import 'wallet_detail_screens.dart';

Widget? _screenForMenu(String label) {
  switch (label) {
    case 'Edit Profile':
      return const EditProfileScreen();
    case 'Manage Cards':
      return const ManageCardsScreen();
    case 'Notifications':
      return const NotificationPrefsScreen();
    case 'Biometric Login':
      return const BiometricScreen();
    case 'Language':
      return const LanguageScreen();
    case 'Data Sharing':
      return const ConsentScreen(title: 'Data Sharing');
    case 'Marketing Consent':
      return const ConsentScreen(title: 'Marketing Consent');
    case 'Device Management':
      return const DeviceManagementScreen();
    case 'Privacy Policy':
      return const PrivacyPolicyScreen();
  }
  return null;
}

/// Profile tab (Figma 385:4140) + settings entries.
class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return TabScaffold(
      children: [
        const TabHeader('Profile', showBell: false),
        const SizedBox(height: 16),
        const _ProfileHeader(),
        const SizedBox(height: 20),
        const Padding(padding: EdgeInsets.symmetric(horizontal: 20), child: _StatsRow()),
        const SizedBox(height: 24),
        _group(context, 'Account', const [
          (Icons.person_outline_rounded, 'Edit Profile'),
          (Icons.credit_card_rounded, 'Manage Cards'),
          (Icons.notifications_none_rounded, 'Notifications'),
          (Icons.fingerprint_rounded, 'Biometric Login'),
        ]),
        const SizedBox(height: 16),
        _group(context, 'Preferences', const [
          (Icons.language_rounded, 'Language'),
          (Icons.shield_outlined, 'Data Sharing'),
          (Icons.campaign_outlined, 'Marketing Consent'),
          (Icons.devices_other_rounded, 'Device Management'),
          (Icons.policy_outlined, 'Privacy Policy'),
        ]),
        const SizedBox(height: 16),
        const Padding(
          padding: EdgeInsets.symmetric(horizontal: 20),
          child: _LogoutTile(),
        ),
      ],
    );
  }

  Widget _group(BuildContext context, String title, List<(IconData, String)> items) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Text(title, style: AppText.body3.copyWith(color: AppColors.textLight)),
        ),
        const SizedBox(height: 8),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: SurfaceCard(
            padding: EdgeInsets.zero,
            child: Column(
              children: [
                for (var i = 0; i < items.length; i++) ...[
                  _MenuRow(icon: items[i].$1, label: items[i].$2),
                  if (i != items.length - 1)
                    const Divider(height: 1, indent: 56, color: AppColors.borderLightest),
                ],
              ],
            ),
          ),
        ),
      ],
    );
  }
}

class _ProfileHeader extends StatelessWidget {
  const _ProfileHeader();
  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          width: 88,
          height: 88,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            gradient: const LinearGradient(colors: AppColors.pointsGradient),
            border: Border.all(color: AppColors.brandLightest, width: 3),
          ),
          child: const Center(
            child: Text('MM',
                style: TextStyle(
                    fontFamily: 'Urbanist', fontSize: 30, fontWeight: FontWeight.w800, color: Colors.white)),
          ),
        ),
        const SizedBox(height: 12),
        Text('Max Mustermann', style: AppText.label1),
        const SizedBox(height: 4),
        Pill(
          gradient: const LinearGradient(colors: AppColors.goldGradient),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.star_rounded, size: 12, color: AppColors.brandDarkest),
              const SizedBox(width: 4),
              Text('Superfan · Member since 2019',
                  style: AppText.caption1.copyWith(color: AppColors.brandDarkest)),
            ],
          ),
        ),
      ],
    );
  }
}

class _StatsRow extends StatelessWidget {
  const _StatsRow();
  @override
  Widget build(BuildContext context) {
    const stats = [('2,850', 'Points'), ('47', 'Games'), ('12', 'Rewards')];
    return SurfaceCard(
      child: Row(
        children: [
          for (var i = 0; i < stats.length; i++) ...[
            Expanded(
              child: Column(
                children: [
                  Text(stats[i].$1, style: AppText.label1.copyWith(color: AppColors.brandPrimary)),
                  const SizedBox(height: 2),
                  Text(stats[i].$2, style: AppText.body3Regular),
                ],
              ),
            ),
            if (i != stats.length - 1)
              Container(width: 1, height: 32, color: AppColors.borderLightest),
          ],
        ],
      ),
    );
  }
}

class _MenuRow extends StatelessWidget {
  final IconData icon;
  final String label;
  const _MenuRow({required this.icon, required this.label});
  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () {
        final screen = _screenForMenu(label);
        if (screen != null) {
          Navigator.of(context).push(MaterialPageRoute(builder: (_) => screen));
        }
      },
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        child: Row(
          children: [
            Icon(icon, size: 22, color: AppColors.textNormal),
            const SizedBox(width: 14),
            Expanded(child: Text(label, style: AppText.body1.copyWith(color: AppColors.textDarker, fontSize: 15))),
            const Icon(Icons.chevron_right_rounded, color: AppColors.textLight),
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
          padding: EdgeInsets.symmetric(horizontal: 16, vertical: 16),
          child: Row(
            children: [
              Icon(Icons.logout_rounded, size: 22, color: AppColors.danger),
              SizedBox(width: 14),
              Text('Log Out',
                  style: TextStyle(
                      fontFamily: 'Urbanist', fontSize: 15, fontWeight: FontWeight.w600, color: AppColors.danger)),
            ],
          ),
        ),
      ),
    );
  }
}
