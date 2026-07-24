import 'package:flutter/material.dart';
import '../theme/app_theme.dart';
import '../widgets/app_widgets.dart';
import '../widgets/asset_img.dart';
import '../widgets/tab_scaffold.dart';
import 'subscription_screen.dart';

/// Fan+ — Non-Subscriber (Figma 2145:8198): VIP experiences teaser.
class FanPlusScreen extends StatelessWidget {
  const FanPlusScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return TabScaffold(
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
                Text('Unlock VIP Fan Experiences',
                    textAlign: TextAlign.center, style: AppText.label1.copyWith(color: Colors.white)),
                const SizedBox(height: 6),
                Text('Exclusive raffles, boosts, and rewards',
                    textAlign: TextAlign.center, style: AppText.body3.copyWith(color: Colors.white70)),
                const SizedBox(height: 10),
                Pill(
                  color: Colors.white24,
                  child: Text('Paid membership · separate from your points tier',
                      style: AppText.caption1.copyWith(color: Colors.white)),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 16),
        // Two locked cards
        const Padding(
          padding: EdgeInsets.symmetric(horizontal: 20),
          child: Row(
            children: [
              Expanded(child: _LockedCard(icon: 'ic_daily_spin', label: 'Extra Spin')),
              SizedBox(width: 12),
              Expanded(child: _LockedCard(icon: 'ic_scratch', label: 'Extra Scratch Card')),
            ],
          ),
        ),
        const SizedBox(height: 24),
        const Padding(
          padding: EdgeInsets.symmetric(horizontal: 20),
          child: Align(alignment: Alignment.centerLeft, child: Text('VIP Experiences', style: AppText.label1)),
        ),
        const SizedBox(height: 12),
        for (final t in const [
          'Virtual and Physical Cards',
          'Chances to Win a Signed Jersey',
          'Meet the Players',
          'Points Multiplier',
        ])
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 0, 20, 12),
            child: Row(
              children: [
                const Icon(Icons.workspace_premium_rounded, color: AppColors.gold, size: 22),
                const SizedBox(width: 12),
                Expanded(child: Text(t, style: AppText.body1.copyWith(color: AppColors.textDarker, fontSize: 15))),
                Pill(
                  gradient: const LinearGradient(colors: AppColors.goldGradient),
                  child: Text('Exclusive', style: AppText.caption1.copyWith(color: AppColors.brandDarkest)),
                ),
              ],
            ),
          ),
        const Padding(
          padding: EdgeInsets.fromLTRB(20, 0, 20, 8),
          child: Text('…and much more!', style: AppText.body2),
        ),
        const SizedBox(height: 12),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: PrimaryButton('Upgrade to Fan+ Now',
              onTap: () => Navigator.of(context).push(
                    MaterialPageRoute(builder: (_) => const SubscriptionScreen()),
                  )),
        ),
      ],
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
                Text('Locked', style: AppText.caption1.copyWith(color: AppColors.brandDarkest)),
              ]),
            ),
          ),
          const SizedBox(height: 4),
          AssetImg(icon, width: 44, height: 44, fallbackIcon: Icons.lock_rounded),
          const SizedBox(height: 8),
          Text(label, textAlign: TextAlign.center, style: AppText.body3),
        ],
      ),
    );
  }
}
