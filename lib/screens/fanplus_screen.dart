import 'package:flutter/material.dart';
import '../theme/app_theme.dart';
import '../widgets/app_widgets.dart';
import '../widgets/asset_img.dart';
import '../widgets/tab_scaffold.dart';
import '../widgets/skeleton.dart';
import '../widgets/action_sheets.dart';
import 'subscription_screen.dart';
import '../l10n/strings.dart';

/// Fan+ (Figma 2145:8198 Non-Subscriber / 2145:8275 Subscriber).
class FanPlusScreen extends StatelessWidget {
  final bool subscribed;
  const FanPlusScreen({super.key, this.subscribed = false});

  @override
  Widget build(BuildContext context) {
    if (subscribed) return _subscribed(context);
    return TabScaffold(
      onRefresh: () => Future<void>.delayed(const Duration(milliseconds: 900)),
      skeleton: const HubSkeleton(),
      children: [
        // Header: logo + bell (matches Home)
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Svg('logo_s04', size: 36),
              Container(
                width: 36,
                height: 36,
                decoration: BoxDecoration(color: AppColors.surfaceMinimal, borderRadius: BorderRadius.circular(36)),
                child: const Center(child: Svg('bell_dot', size: 20)),
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),
        // Hero card
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Container(
            width: double.infinity,
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              gradient: const LinearGradient(colors: AppColors.pointsGradient),
              borderRadius: BorderRadius.circular(AppRadii.card),
            ),
            child: Column(
              children: [
                const Icon(Icons.workspace_premium_rounded, color: AppColors.gold, size: 40),
                const SizedBox(height: 12),
                Text(tr('Priority access to what fans want most'),
                    textAlign: TextAlign.center, style: AppText.label1.copyWith(color: Colors.white)),
                const SizedBox(height: 6),
                Text(tr('Best seats first, exclusive drops, and rewards that pay you back'),
                    textAlign: TextAlign.center, style: AppText.body3.copyWith(color: Colors.white70)),
                const SizedBox(height: 10),
                Pill(
                  color: Colors.white24,
                  child: Text(tr('Membership · unlocks priority, access & perks'),
                      style: AppText.caption1.copyWith(color: Colors.white)),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 12),
        // Value-back framing — the core "why fans pay" argument from the pitch
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: SurfaceCard(
            color: AppColors.brandLightest,
            child: Row(children: [
              const Icon(Icons.savings_rounded, color: AppColors.gold),
              const SizedBox(width: 12),
              Expanded(child: Text(tr('Your membership pays for itself — Fan Member gets €6+ back a month, Super Fan €14+.'),
                  style: AppText.body2.copyWith(color: AppColors.onAccent, fontWeight: FontWeight.w600))),
            ]),
          ),
        ),
        const SizedBox(height: 16),
        // Two locked cards
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Row(
            children: [
              Expanded(child: _LockedCard(icon: 'ic_daily_spin', label: tr('Extra Spin'))),
              const SizedBox(width: 12),
              Expanded(child: _LockedCard(icon: 'ic_scratch', label: tr('Extra Scratch Card'))),
            ],
          ),
        ),
        const SizedBox(height: 24),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Align(alignment: Alignment.centerLeft, child: Text(tr('VIP Experiences'), style: AppText.label1)),
        ),
        const SizedBox(height: 12),
        for (final t in const [
          'Priority ticket access to top matches (48–72h)',
          'Best seats first + matchday upgrades',
          'Monthly exclusive FOMO drop',
          'Exclusive content & locker-room clips',
          'Branded VISA fan card (from Season 2)',
        ])
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 0, 20, 12),
            child: Row(
              children: [
                const Icon(Icons.workspace_premium_rounded, color: AppColors.gold, size: 22),
                const SizedBox(width: 12),
                Expanded(child: Text(tr(t), style: AppText.body1.copyWith(color: AppColors.textDarker, fontSize: 15))),
                Pill(
                  gradient: const LinearGradient(colors: AppColors.goldGradient),
                  child: Text(tr('Exclusive'), style: AppText.caption1.copyWith(color: AppColors.brandDarkest)),
                ),
              ],
            ),
          ),
        Padding(
          padding: const EdgeInsets.fromLTRB(20, 0, 20, 8),
          child: Text(tr('…and much more!'), style: AppText.body2),
        ),
        const SizedBox(height: 12),
        // Free-trial trigger — try Super Fan free for the next big match
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: SurfaceCard(
            color: AppColors.successBg,
            child: Row(children: [
              const Icon(Icons.lock_open_rounded, color: AppColors.success),
              const SizedBox(width: 12),
              Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Text(tr('Try Super Fan free'), style: AppText.body2.copyWith(color: AppColors.textDarker, fontWeight: FontWeight.w700)),
                Text(tr('Free for the next top match — priority seats included'), style: AppText.body3Regular),
              ])),
            ]),
          ),
        ),
        const SizedBox(height: 12),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: PrimaryButton(tr('See membership plans'),
              onTap: () => Navigator.of(context).push(
                    MaterialPageRoute(builder: (_) => const SubscriptionScreen()),
                  )),
        ),
      ],
    );
  }

  Widget _subscribed(BuildContext context) {
    return TabScaffold(
      onRefresh: () => Future<void>.delayed(const Duration(milliseconds: 900)),
      skeleton: const HubSkeleton(),
      children: [
        // Header
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Svg('logo_s04', size: 36),
              Container(
                width: 36,
                height: 36,
                decoration: BoxDecoration(color: AppColors.surfaceMinimal, borderRadius: BorderRadius.circular(36)),
                child: const Center(child: Svg('bell_dot', size: 20)),
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),
        // Active membership card
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Container(
            width: double.infinity,
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              gradient: const LinearGradient(colors: AppColors.pointsGradient),
              borderRadius: BorderRadius.circular(AppRadii.card),
            ),
            child: Column(children: [
              Align(
                alignment: Alignment.topRight,
                child: Pill(
                  gradient: const LinearGradient(colors: AppColors.goldGradient),
                  child: Text(tr('Active'), style: AppText.caption1.copyWith(color: AppColors.brandDarkest, fontWeight: FontWeight.w700)),
                ),
              ),
              const Icon(Icons.workspace_premium_rounded, color: AppColors.gold, size: 36),
              const SizedBox(height: 8),
              Text(tr('Super Fan'), style: AppText.h4.copyWith(color: Colors.white)),
              const SizedBox(height: 12),
              Wrap(spacing: 8, runSpacing: 8, alignment: WrapAlignment.center, children: [
                for (final b in const ['Priority Access', 'Best Seats', '+3 VIP Draws'])
                  Pill(color: Colors.white24, child: Text(b, style: AppText.caption1.copyWith(color: Colors.white))),
              ]),
              const SizedBox(height: 16),
              Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                Text(tr('Renews: 28 May 2026'), style: AppText.body3.copyWith(color: Colors.white70)),
                Tappable(
                  onTap: () => Navigator.of(context).push(MaterialPageRoute(builder: (_) => const SubscriptionScreen())),
                  child: Row(mainAxisSize: MainAxisSize.min, children: [
                    Text(tr('Manage Subscription'), style: AppText.body3.copyWith(color: Colors.white, fontWeight: FontWeight.w600)),
                    const Icon(Icons.chevron_right_rounded, size: 16, color: Colors.white),
                  ]),
                ),
              ]),
            ]),
          ),
        ),
        const SizedBox(height: 16),
        // Unlocked perks
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Row(children: [
            Expanded(child: _UnlockedCard(icon: 'ic_daily_spin', label: tr('Extra Spin'))),
            const SizedBox(width: 12),
            Expanded(child: _UnlockedCard(icon: 'ic_scratch', label: tr('Extra Scratch Card'))),
          ]),
        ),
        const SizedBox(height: 24),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Align(alignment: Alignment.centerLeft, child: Text(tr('VIP Experiences'), style: AppText.label1)),
        ),
        const SizedBox(height: 12),
        for (final r in const [
          ('Meet the Players', 'Exclusive post-match meet & greet with the team', 'Exclusive Reward', 'Ends in 4:12:30', 'Gazprom'),
          ('Signed Match Ball', 'Exclusive signed ball by our super stars', 'Limited', '3 Left', 'Veltins'),
        ])
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 0, 20, 12),
            child: Container(
              clipBehavior: Clip.antiAlias,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                gradient: const LinearGradient(colors: AppColors.pointsGradient),
                borderRadius: BorderRadius.circular(AppRadii.card),
              ),
              child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                  Pill(gradient: const LinearGradient(colors: AppColors.goldGradient), child: Text(r.$3, style: AppText.caption1.copyWith(color: AppColors.brandDarkest, fontWeight: FontWeight.w700))),
                  Pill(color: Colors.white24, child: Text(r.$4, style: AppText.caption1.copyWith(color: Colors.white))),
                ]),
                const SizedBox(height: 12),
                Text(r.$1, style: AppText.label1.copyWith(color: Colors.white)),
                const SizedBox(height: 4),
                Text(r.$2, style: AppText.body3.copyWith(color: Colors.white70)),
                const SizedBox(height: 6),
                Text('${tr('Powered by')} ${r.$5}', style: AppText.caption1.copyWith(color: AppColors.gold, fontWeight: FontWeight.w700)),
                const SizedBox(height: 12),
                SizedBox(
                  width: double.infinity,
                  child: Tappable(
                    onTap: () async {
                      final ok = await showConfirmDialog(
                        context,
                        title: 'Enter this raffle?',
                        message: 'We’ll use one Super Fan raffle entry — you’ll be notified if you win.',
                        confirmLabel: 'Enter',
                      );
                      if (ok && context.mounted) {
                        await showSuccessSheet(
                          context,
                          title: 'You’re entered!',
                          message: 'Good luck — winners are announced after the match.',
                        );
                      }
                    },
                    child: Container(
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      alignment: Alignment.center,
                      decoration: BoxDecoration(color: AppColors.brandDarkest, borderRadius: BorderRadius.circular(999)),
                      child: Row(mainAxisSize: MainAxisSize.min, mainAxisAlignment: MainAxisAlignment.center, children: [
                        Text(tr('Enter Raffle'), style: AppText.body2.copyWith(color: Colors.white, fontWeight: FontWeight.w600)),
                        const SizedBox(width: 4),
                        const Icon(Icons.chevron_right_rounded, size: 18, color: Colors.white),
                      ]),
                    ),
                  ),
                ),
              ]),
            ),
          ),
      ],
    );
  }
}

class _UnlockedCard extends StatelessWidget {
  final String icon;
  final String label;
  const _UnlockedCard({required this.icon, required this.label});
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(color: AppColors.brandLightest, borderRadius: BorderRadius.circular(AppRadii.tile)),
      child: Column(children: [
        Align(
          alignment: Alignment.topRight,
          child: Pill(
            gradient: const LinearGradient(colors: AppColors.goldGradient),
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
            child: Text(tr('1 Left'), style: AppText.caption1.copyWith(color: AppColors.brandDarkest, fontWeight: FontWeight.w700)),
          ),
        ),
        const SizedBox(height: 4),
        AssetImg(icon, width: 44, height: 44, fallbackIcon: Icons.card_giftcard_rounded),
        const SizedBox(height: 8),
        Text(label, textAlign: TextAlign.center, maxLines: 1, overflow: TextOverflow.ellipsis, style: AppText.body3),
      ]),
    );
  }
}

class _LockedCard extends StatelessWidget {
  final String icon;
  final String label;
  const _LockedCard({required this.icon, required this.label});
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(color: AppColors.brandLightest, borderRadius: BorderRadius.circular(AppRadii.tile)),
      child: Column(
        children: [
          Align(
            alignment: Alignment.topRight,
            child: Pill(
              gradient: const LinearGradient(colors: AppColors.goldGradient),
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
              child: Row(mainAxisSize: MainAxisSize.min, children: [
                const Icon(Icons.lock_rounded, size: 10, color: AppColors.brandDarkest),
                const SizedBox(width: 3),
                Text(tr('Locked'), style: AppText.caption1.copyWith(color: AppColors.brandDarkest)),
              ]),
            ),
          ),
          const SizedBox(height: 4),
          AssetImg(icon, width: 44, height: 44, fallbackIcon: Icons.lock_rounded),
          const SizedBox(height: 8),
          Text(label, textAlign: TextAlign.center, maxLines: 1, overflow: TextOverflow.ellipsis, style: AppText.body3),
        ],
      ),
    );
  }
}
