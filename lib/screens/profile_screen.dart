import 'package:flutter/material.dart';
import '../theme/app_theme.dart';
import '../widgets/app_widgets.dart';
import '../widgets/tab_scaffold.dart';
import '../widgets/skeleton.dart';
import '../widgets/action_sheets.dart';
import 'login_screen.dart';
import 'settings_screens.dart';
import 'password_reset_screen.dart';
import 'wallet_detail_screens.dart';
import 'wallet_screen.dart';
import 'subscription_screen.dart';
import 'loyalty_tiers_screen.dart';
import 'fan_profile_screen.dart';
import 'payment_methods_screen.dart';
import 'points_history_screen.dart';
import '../widgets/sub_scaffold.dart';
import '../model/fan_model.dart';
import '../l10n/strings.dart';

/// Profile (Figma 2145:11608) — user card + grouped settings menu.
class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return TabScaffold(
      onRefresh: () => Future<void>.delayed(const Duration(milliseconds: 900)),
      skeleton: const HubSkeleton(),
      children: [
        // Centered identity header (Figma 2194:15393)
        Column(children: [
          Tappable(
            scale: 0.94,
            onTap: () => Navigator.of(context).push(MaterialPageRoute(builder: (_) => const FanProfileScreen())),
            child: Container(
              width: 84,
              height: 84,
              decoration: BoxDecoration(shape: BoxShape.circle, gradient: const LinearGradient(colors: AppColors.pointsGradient)),
              alignment: Alignment.center,
              child: Text(tr('MM'), style: const TextStyle(fontFamily: 'Urbanist', color: Colors.white, fontSize: 28, fontWeight: FontWeight.w800)),
            ),
          ),
          const SizedBox(height: 12),
          Row(mainAxisAlignment: MainAxisAlignment.center, children: [
            Text(tr('Max Mustermann'), style: AppText.h4.copyWith(color: AppColors.textDarker)),
            const SizedBox(width: 6),
            const Icon(Icons.verified_rounded, size: 18, color: Color(0xFF4DA3FF)),
          ]),
          const SizedBox(height: 2),
          Text(tr('@maxmuster · Member #0042'), style: AppText.body2.copyWith(color: AppColors.textLight)),
        ]),
        const SizedBox(height: 18),
        // Points-forward wallet: balance + history, plus everything the fan holds.
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Tappable(
            scale: 0.98,
            onTap: () => Navigator.of(context).push(MaterialPageRoute(builder: (_) => const WalletScreen())),
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.all(18),
              decoration: BoxDecoration(gradient: const LinearGradient(colors: AppColors.pointsGradient), borderRadius: BorderRadius.circular(AppRadii.card)),
              child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Row(children: [
                  const Icon(Icons.account_balance_wallet_rounded, color: Colors.white, size: 18),
                  const SizedBox(width: 8),
                  Text(tr('My Wallet'), style: AppText.body3.copyWith(color: Colors.white70)),
                  const Spacer(),
                  const Icon(Icons.chevron_right_rounded, color: Colors.white70, size: 18),
                ]),
                const SizedBox(height: 12),
                Row(crossAxisAlignment: CrossAxisAlignment.center, children: [
                  const Icon(Icons.hexagon_rounded, color: AppColors.gold, size: 24),
                  const SizedBox(width: 8),
                  Text(FanModel.pointsFormatted, style: AppText.h2.copyWith(color: Colors.white, fontWeight: FontWeight.w800)),
                ]),
                const SizedBox(height: 4),
                Text(tr('View history'), style: AppText.body3.copyWith(color: Colors.white70)),
                const SizedBox(height: 12),
                Row(children: [
                  for (final c in const ['Tickets', 'Vouchers', 'Bookings', 'Collection']) ...[
                    Pill(color: Colors.white24, child: Text(tr(c), style: AppText.caption1.copyWith(color: Colors.white, fontWeight: FontWeight.w700))),
                    const SizedBox(width: 6),
                  ],
                ]),
              ]),
            ),
          ),
        ),
        const SizedBox(height: 12),
        // Two quick boxes: membership plan + invite friends
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Row(children: [
            Expanded(
              child: _ProfileBox(
                icon: Icons.card_membership_rounded,
                label: FanModel.membershipTier,
                sub: 'Your plan',
                onTap: () => Navigator.of(context).push(MaterialPageRoute(builder: (_) => const SubscriptionScreen())),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _ProfileBox(
                icon: Icons.person_add_alt_1_rounded,
                label: 'Invite friends',
                sub: 'Earn +200 pts each',
                highlight: true,
                onTap: () => Navigator.of(context).push(MaterialPageRoute(builder: (_) => const _InviteFriendsScreen())),
              ),
            ),
          ]),
        ),
        const SizedBox(height: 22),
        _group(context, 'Account', const [
          (Icons.person_outline_rounded, 'Edit Profile', ''),
          (Icons.military_tech_outlined, 'Fan Level', 'Schalker'),
          (Icons.history_rounded, 'Points History', ''),
          (Icons.account_balance_outlined, 'Bank Account', ''),
          (Icons.credit_card_rounded, 'Payment Methods', ''),
          (Icons.style_rounded, 'Fan+ Pay card', 'Season 2'),
        ]),
        const SizedBox(height: 16),
        _group(context, 'Settings', const [
          (Icons.notifications_none_rounded, 'Notification Preferences', ''),
          (Icons.lock_outline_rounded, 'Update Password', ''),
          (Icons.fingerprint_rounded, 'Biometric Login', 'toggle'),
          (Icons.dark_mode_outlined, 'Dark Mode', 'darktoggle'),
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
        _group(context, 'Demo / Preview', const [
          (Icons.sports_soccer_rounded, 'Matchday state', 'matchdaytoggle'),
          (Icons.workspace_premium_outlined, 'Fan+ member (preview)', 'membertoggle'),
          (Icons.credit_card_rounded, 'Fan+ Pay card (Phase 2)', 'cardtoggle'),
          (Icons.rocket_launch_outlined, 'New-fan starter tasks', 'startertoggle'),
        ]),
        const SizedBox(height: 16),
        const Padding(padding: EdgeInsets.symmetric(horizontal: 20), child: _LogoutTile()),
        const SizedBox(height: 20),
        Center(
          child: Column(children: [
            Text('FC Schalke 04 · v1.0.0', style: AppText.caption1.copyWith(color: AppColors.textLight)),
            const SizedBox(height: 4),
            Text(tr('Powered by Fan+'), style: AppText.caption1.copyWith(color: AppColors.textLight, fontWeight: FontWeight.w700, letterSpacing: 0.3)),
          ]),
        ),
      ],
    );
  }

  Widget _group(BuildContext context, String title, List<(IconData, String, String)> items) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(padding: const EdgeInsets.symmetric(horizontal: 20), child: Text(tr(title), style: AppText.body3.copyWith(color: AppColors.textLight))),
        const SizedBox(height: 8),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: SurfaceCard(
            padding: EdgeInsets.zero,
            child: Column(
              children: [
                for (var i = 0; i < items.length; i++) ...[
                  _MenuRow(icon: items[i].$1, label: items[i].$2, value: items[i].$3),
                  if (i != items.length - 1) Divider(height: 1, indent: 52, color: AppColors.borderLightest),
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
    case 'Fan Level':
      return const LoyaltyTiersScreen();
    case 'Points History':
      return const PointsHistoryScreen();
    case 'Membership':
      return const SubscriptionScreen();
    case 'Payment Methods':
      return const PaymentMethodsScreen();
    case 'Subscription':
      return const SubscriptionScreen();
    case 'Bank Account':
      return const BankAccountScreen();
    case 'Manage Card':
      return const ManageCardsScreen();
    // 'Fan+ Pay card' is intentionally not routed here — it's a Season-2
    // teaser handled with an info sheet in _MenuRow (no card exists in V1).
    case 'Notification Preferences':
      return const NotificationPrefsScreen();
    case 'Device Management':
      return const DeviceManagementScreen();
    case 'Language':
      return const LanguageScreen();
    case 'Data Sharing Preferences':
      return ConsentScreen(title: tr('Data Sharing'));
    case 'Marketing Consent':
      return ConsentScreen(title: tr('Marketing Consent'));
    case 'Privacy Policy':
      return const PrivacyPolicyScreen();
    case 'Update Password':
      return const PasswordResetScreen();
    case 'About Us':
      return const AboutUsScreen();
    case 'Terms & Conditions':
      return const TermsScreen();
  }
  return null;
}

/// Season-2 teaser for the Fan+ Pay card (no card exists in V1). Explains it's
/// coming and can be previewed via the Demo toggle — instead of dead-ending in
/// a card-management screen with nothing to manage.
void _showSeason2Teaser(BuildContext context) {
  showModalBottomSheet(
    context: context,
    backgroundColor: Colors.transparent,
    builder: (_) => Container(
      padding: const EdgeInsets.fromLTRB(24, 28, 24, 32),
      decoration: BoxDecoration(color: AppColors.surface, borderRadius: BorderRadius.vertical(top: Radius.circular(28))),
      child: Column(mainAxisSize: MainAxisSize.min, children: [
        Container(
          width: 72, height: 72,
          decoration: BoxDecoration(gradient: const LinearGradient(colors: [Color(0xFF0055AA), Color(0xFF000D22)]), shape: BoxShape.circle),
          child: const Icon(Icons.credit_card_rounded, color: AppColors.gold, size: 34),
        ),
        const SizedBox(height: 18),
        Text(tr('Fan+ Pay — coming in Season 2'), textAlign: TextAlign.center, style: AppText.h4),
        const SizedBox(height: 8),
        Text(tr('A co-branded S04 card that earns real cashback at club partners. Preview it now via Profile → Demo / Preview.'),
            textAlign: TextAlign.center, style: AppText.body1.copyWith(color: AppColors.textLight)),
        const SizedBox(height: 24),
        PrimaryButton(tr('Got it'), onTap: () => Navigator.of(context).pop()),
      ]),
    ),
  );
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
    final isDarkToggle = widget.value == 'darktoggle';
    final isMatchdayToggle = widget.value == 'matchdaytoggle';
    final isMemberToggle = widget.value == 'membertoggle';
    final isCardToggle = widget.value == 'cardtoggle';
    final isStarterToggle = widget.value == 'startertoggle';
    final anyToggle = isToggle || isDarkToggle || isMatchdayToggle || isMemberToggle || isCardToggle || isStarterToggle;
    return InkWell(
      onTap: anyToggle
          ? null
          : () {
              if (widget.label == 'Fan+ Pay card') {
                _showSeason2Teaser(context);
                return;
              }
              final s = _screenFor(widget.label);
              if (s != null) Navigator.of(context).push(MaterialPageRoute(builder: (_) => s));
            },
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 13),
        child: Row(
          children: [
            Icon(widget.icon, size: 20, color: AppColors.textNormal),
            const SizedBox(width: 12),
            Expanded(child: Text(tr(widget.label), style: AppText.body1.copyWith(color: AppColors.textDarker, fontSize: 14.5))),
            if (isDarkToggle)
              Switch(
                value: darkModeNotifier.value,
                activeThumbColor: Colors.white,
                activeTrackColor: AppColors.brandPrimary,
                onChanged: (v) => darkModeNotifier.value = v,
              )
            else if (isToggle)
              Switch(
                value: _bio,
                activeThumbColor: Colors.white,
                activeTrackColor: AppColors.brandPrimary,
                onChanged: (v) => setState(() => _bio = v),
              )
            else if (isMatchdayToggle)
              Switch(
                value: matchdayNotifier.value,
                activeThumbColor: Colors.white,
                activeTrackColor: AppColors.brandPrimary,
                onChanged: (v) => setState(() => matchdayNotifier.value = v),
              )
            else if (isMemberToggle)
              Switch(
                value: memberPreviewNotifier.value,
                activeThumbColor: Colors.white,
                activeTrackColor: AppColors.brandPrimary,
                onChanged: (v) => setState(() => memberPreviewNotifier.value = v),
              )
            else if (isCardToggle)
              Switch(
                value: cardActiveNotifier.value,
                activeThumbColor: Colors.white,
                activeTrackColor: AppColors.brandPrimary,
                onChanged: (v) => setState(() => cardActiveNotifier.value = v),
              )
            else if (isStarterToggle)
              Switch(
                value: starterNotifier.value,
                activeThumbColor: Colors.white,
                activeTrackColor: AppColors.brandPrimary,
                onChanged: (v) => setState(() => starterNotifier.value = v),
              )
            else ...[
              if (widget.value.isNotEmpty)
                Text(tr(widget.value), style: AppText.body3.copyWith(color: AppColors.textLight)),
              const SizedBox(width: 6),
              Icon(Icons.chevron_right_rounded, color: AppColors.textLight, size: 20),
            ],
          ],
        ),
      ),
    );
  }
}

/// Compact tappable box under the profile header (plan / invite), Figma 2194:15393.
class _ProfileBox extends StatelessWidget {
  final IconData icon;
  final String label;
  final String sub;
  final bool highlight;
  final VoidCallback onTap;
  const _ProfileBox({required this.icon, required this.label, required this.sub, this.highlight = false, required this.onTap});
  @override
  Widget build(BuildContext context) {
    return Tappable(
      scale: 0.97,
      onTap: onTap,
      child: Container(
        height: 108,
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: highlight ? AppColors.brandLightest : AppColors.surface,
          borderRadius: BorderRadius.circular(AppRadii.card),
          border: Border.all(color: highlight ? AppColors.brandLightest : AppColors.borderLightest),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Icon(icon, size: 24, color: AppColors.brandPrimary),
            Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text(tr(label), maxLines: 1, overflow: TextOverflow.ellipsis, style: AppText.body2.copyWith(color: AppColors.textDarker, fontWeight: FontWeight.w700)),
              const SizedBox(height: 2),
              Text(tr(sub), maxLines: 1, overflow: TextOverflow.ellipsis, style: AppText.body3.copyWith(color: highlight ? AppColors.brandPrimary : AppColors.textLight)),
            ]),
          ],
        ),
      ),
    );
  }
}

/// Referral screen reached from the "Invite friends" box.
class _InviteFriendsScreen extends StatelessWidget {
  const _InviteFriendsScreen();
  @override
  Widget build(BuildContext context) {
    return SubScaffold(
      title: tr('Invite friends'),
      bottomBar: PrimaryButton(tr('Share invite link'), onTap: () => showShareSheet(context, subject: tr('Join me on the S04 Fan App'))),
      children: [
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(gradient: const LinearGradient(colors: AppColors.pointsGradient), borderRadius: BorderRadius.circular(AppRadii.card)),
          child: Column(children: [
            const Icon(Icons.card_giftcard_rounded, color: AppColors.gold, size: 40),
            const SizedBox(height: 12),
            Text(tr('Give 200, get 200'), style: AppText.h4.copyWith(color: Colors.white)),
            const SizedBox(height: 6),
            Text(tr('You both earn 200 Fan Points when a friend joins with your code.'),
                textAlign: TextAlign.center, style: AppText.body3.copyWith(color: Colors.white70)),
          ]),
        ),
        const SizedBox(height: 16),
        Text(tr('Your invite code'), style: AppText.label2),
        const SizedBox(height: 10),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 16),
          decoration: BoxDecoration(color: AppColors.surfaceMinimal, borderRadius: BorderRadius.circular(AppRadii.tile)),
          child: Row(children: [
            Expanded(child: Text('MAX-S04-0042', style: TextStyle(fontFamily: 'Urbanist', fontSize: 18, fontWeight: FontWeight.w800, letterSpacing: 2, color: AppColors.textDarker))),
            Icon(Icons.copy_rounded, size: 20, color: AppColors.brandPrimary),
          ]),
        ),
        const SizedBox(height: 20),
        Text(tr('How it works'), style: AppText.label2),
        const SizedBox(height: 12),
        for (final s in const [
          (Icons.share_rounded, 'Share your code', 'Send your invite link to friends'),
          (Icons.person_add_alt_1_rounded, 'They join S04', 'Your friend signs up with your code'),
          (Icons.savings_rounded, 'You both earn', '+200 Fan Points each, instantly'),
        ])
          Padding(
            padding: const EdgeInsets.only(bottom: 10),
            child: SurfaceCard(child: Row(children: [
              Container(width: 40, height: 40, decoration: BoxDecoration(color: AppColors.brandLightest, borderRadius: BorderRadius.circular(11)), child: Icon(s.$1, color: AppColors.brandPrimary, size: 20)),
              const SizedBox(width: 12),
              Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Text(tr(s.$2), style: AppText.body2.copyWith(color: AppColors.textDarker)),
                Text(tr(s.$3), style: AppText.body3Regular),
              ])),
            ])),
          ),
      ],
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
        onTap: () async {
          final ok = await showConfirmDialog(
            context,
            title: 'Log out?',
            message: 'You can sign back in any time with your account.',
            confirmLabel: 'Log Out',
            destructive: true,
          );
          if (ok && context.mounted) {
            Navigator.of(context).pushAndRemoveUntil(
              MaterialPageRoute(builder: (_) => const LoginScreen()),
              (route) => false,
            );
          }
        },
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 15),
          child: Row(children: [
            const Icon(Icons.logout_rounded, size: 20, color: AppColors.danger),
            const SizedBox(width: 12),
            Text(tr('Log Out'), style: const TextStyle(fontFamily: 'Urbanist', fontSize: 14.5, fontWeight: FontWeight.w600, color: AppColors.danger)),
          ]),
        ),
      ),
    );
  }
}
