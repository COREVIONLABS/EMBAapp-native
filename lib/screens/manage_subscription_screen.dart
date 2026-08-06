import 'package:flutter/material.dart';
import '../theme/app_theme.dart';
import '../widgets/app_widgets.dart';
import '../widgets/sub_scaffold.dart';
import '../widgets/action_sheets.dart';
import '../model/fan_model.dart';
import 'subscription_screen.dart';
import '../l10n/strings.dart';

/// Manage Fan+ — a real, transparent management surface: see your plan and
/// renewal, change plan, pause, or cancel in one tap. Backs the "cancel anytime"
/// promise (German §312k one-tap cancel). Prototype: cancelling downgrades the
/// live tier to Free Fan; a real build would hit the store/billing API.
class ManageSubscriptionScreen extends StatelessWidget {
  const ManageSubscriptionScreen({super.key});

  void _push(BuildContext context, Widget s) =>
      Navigator.of(context).push(MaterialPageRoute(builder: (_) => s));

  Future<void> _cancel(BuildContext context) async {
    final ok = await showConfirmDialog(
      context,
      title: 'Cancel Fan+?',
      message: tr('You\'ll keep your benefits until the end of the paid period, then move to Free Fan. No further charges.'),
      confirmLabel: 'Cancel Fan+',
    );
    if (!ok || !context.mounted) return;
    tierNotifier.value = 'Free Fan';
    memberPreviewNotifier.value = false;
    if (!context.mounted) return;
    await showSuccessSheet(context,
        title: 'Subscription cancelled',
        message: 'You won\'t be charged again. Your Fan+ benefits stay active until the period ends.');
    if (context.mounted) Navigator.of(context).maybePop();
  }

  Future<void> _pause(BuildContext context) async {
    final ok = await showConfirmDialog(
      context,
      title: 'Pause for 1 month?',
      message: tr('Your membership and billing pause for one month, then resume automatically.'),
      confirmLabel: 'Pause',
    );
    if (!ok || !context.mounted) return;
    await showSuccessSheet(context, title: 'Membership paused', message: 'We\'ve paused your Fan+ for one month — nothing to do, it resumes on its own.');
  }

  @override
  Widget build(BuildContext context) {
    return SubScaffold(
      title: tr('Manage subscription'),
      children: [
        // Current plan + renewal.
        ValueListenableBuilder<String>(
          valueListenable: tierNotifier,
          builder: (context, tier, __) {
            final p = perksFor(tier);
            final isMember = p.monthlyPoints > 0;
            return Container(
              padding: const EdgeInsets.all(18),
              decoration: BoxDecoration(gradient: const LinearGradient(colors: AppColors.pointsGradient), borderRadius: BorderRadius.circular(AppRadii.card)),
              child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Row(children: [
                  const Icon(Icons.workspace_premium_rounded, color: AppColors.gold, size: 24),
                  const SizedBox(width: 10),
                  Text(tr(tier), style: AppText.h4.copyWith(color: Colors.white)),
                  const Spacer(),
                  Pill(color: Colors.white24, child: Text(isMember ? tr('Active') : tr('Free'), style: AppText.caption1.copyWith(color: Colors.white, fontWeight: FontWeight.w800))),
                ]),
                const SizedBox(height: 12),
                Text(isMember
                    ? '${p.freeLots} ${tr('free lots')} + ${FanModel.fmtPublic(p.monthlyPoints)} ${tr('pts / month')}'
                    : tr('No paid benefits — upgrade any time.'),
                    style: AppText.body3.copyWith(color: Colors.white70)),
                if (isMember) ...[
                  const SizedBox(height: 6),
                  Text(tr('Renews 28 May 2026 · auto-renews · cancel anytime'), style: AppText.caption1.copyWith(color: Colors.white60)),
                ],
              ]),
            );
          },
        ),
        const SizedBox(height: 16),
        _row(context, Icons.swap_horiz_rounded, 'Change plan', 'Upgrade, downgrade or switch to annual', () => _push(context, const SubscriptionScreen())),
        const SizedBox(height: 10),
        _row(context, Icons.pause_circle_outline_rounded, 'Pause for 1 month', 'Take a break — resumes automatically', () => _pause(context)),
        const SizedBox(height: 10),
        _row(context, Icons.receipt_long_rounded, 'Billing history', 'See past payments & invoices', () => showSuccessSheet(context, title: 'Billing history', message: 'Your invoices would open here in the full app.')),
        const SizedBox(height: 20),
        // One-tap cancel (§312k).
        Tappable(
          onTap: () => _cancel(context),
          child: Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(vertical: 15),
            alignment: Alignment.center,
            decoration: BoxDecoration(color: AppColors.dangerBg, borderRadius: BorderRadius.circular(AppRadii.pill)),
            child: Text(tr('Cancel subscription'), style: AppText.label2.copyWith(color: AppColors.danger)),
          ),
        ),
        const SizedBox(height: 10),
        Center(child: Text(tr('Cancel in one tap — no phone call, no hoops.'), style: AppText.caption1.copyWith(color: AppColors.textLight))),
      ],
    );
  }

  Widget _row(BuildContext context, IconData icon, String title, String sub, VoidCallback onTap) => SurfaceCard(
        onTap: onTap,
        child: Row(children: [
          Container(width: 46, height: 46, decoration: BoxDecoration(color: AppColors.brandLightest, borderRadius: BorderRadius.circular(13)), child: Icon(icon, color: AppColors.brandPrimary, size: 22)),
          const SizedBox(width: 14),
          Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text(tr(title), style: AppText.body1.copyWith(color: AppColors.textDarker, fontSize: 15)),
            const SizedBox(height: 2),
            Text(tr(sub), style: AppText.body3Regular),
          ])),
          Icon(Icons.chevron_right_rounded, color: AppColors.textLight),
        ]),
      );
}
