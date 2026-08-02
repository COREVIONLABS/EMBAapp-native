import 'package:flutter/material.dart';
import '../theme/app_theme.dart';
import '../widgets/app_widgets.dart';
import '../widgets/asset_img.dart';
import '../widgets/tab_scaffold.dart';
import '../widgets/skeleton.dart';
import '../widgets/hub_widgets.dart';
import 'subscription_screen.dart';
import 'fomo_drop_screen.dart';
import 'exclusive_content_screen.dart';
import 'fanshop_screen.dart';
import 'raffles_screen.dart';
import '../model/fan_model.dart';
import '../l10n/strings.dart';

/// Fan+ (Figma 2145:8198 Non-Subscriber / 2145:8275 Subscriber).
class FanPlusScreen extends StatefulWidget {
  final bool subscribed;
  const FanPlusScreen({super.key, this.subscribed = false});
  @override
  State<FanPlusScreen> createState() => _FanPlusScreenState();
}

class _FanPlusScreenState extends State<FanPlusScreen> {
  late bool _member = widget.subscribed;

  void _push(BuildContext context, Widget s) => Navigator.of(context).push(MaterialPageRoute(builder: (_) => s));

  // Member deals — real Fanshop products at a members-only price.
  static const _drops = <(String, String, int, int, String, IconData, Color)>[
    ('Home Jersey 25/26', 'Members', 4500, 3800, '-15%', Icons.checkroom_rounded, Color(0xFF0A2A5E)),
    ('Home Scarf 25/26', 'Members', 900, 720, '-20%', Icons.style_rounded, Color(0xFF1565C0)),
    ('Cap Royal Blue', 'Members', 1100, 950, '-15%', Icons.sports_baseball_rounded, Color(0xFF002F63)),
  ];

  // Member content (title, subtitle, category, glyph, gradient)
  static const _content = <(String, String, String, IconData, List<Color>)>[
    ('Locker-room after the derby', 'Exclusive clip · 6:20', 'Video', Icons.play_circle_rounded, [Color(0xFF2A2440), Color(0xFF0B0616)]),
    ('Training-ground access', 'Behind the scenes', 'Video', Icons.videocam_rounded, [Color(0xFF00695C), Color(0xFF003D33)]),
    ('Captain’s matchday vlog', 'Members only', 'Vlog', Icons.movie_rounded, [Color(0xFF4A148C), Color(0xFF1A0033)]),
  ];

  @override
  Widget build(BuildContext context) => _member ? _lounge(context) : _pitch(context);

  // Shared header with a Guest ↔ Member preview toggle.
  Widget _header() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
        const Svg('logo_s04', size: 36),
        GestureDetector(
          onTap: () => setState(() => _member = !_member),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
            decoration: BoxDecoration(color: _member ? AppColors.brandLightest : AppColors.surfaceMinimal, borderRadius: BorderRadius.circular(AppRadii.pill)),
            child: Row(mainAxisSize: MainAxisSize.min, children: [
              Icon(_member ? Icons.workspace_premium_rounded : Icons.person_outline_rounded, size: 14, color: _member ? AppColors.brandPrimary : AppColors.textLight),
              const SizedBox(width: 6),
              Text(_member ? tr('Member') : tr('Guest'), style: AppText.caption1.copyWith(color: _member ? AppColors.brandPrimary : AppColors.textLight, fontWeight: FontWeight.w700)),
            ]),
          ),
        ),
        Container(width: 36, height: 36, decoration: BoxDecoration(color: AppColors.surfaceMinimal, borderRadius: BorderRadius.circular(36)), child: const Center(child: Svg('bell_dot', size: 20))),
      ]),
    );
  }

  Widget _pitch(BuildContext context) {
    return TabScaffold(
      onRefresh: () => Future<void>.delayed(const Duration(milliseconds: 900)),
      skeleton: const HubSkeleton(),
      children: [
        _header(),
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

  Widget _lounge(BuildContext context) {
    return TabScaffold(
      onRefresh: () => Future<void>.delayed(const Duration(milliseconds: 900)),
      skeleton: const HubSkeleton(),
      children: [
        _header(),
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
              ValueListenableBuilder<String>(
                valueListenable: tierNotifier,
                builder: (context, tier, __) => Text(tr(tier), style: AppText.h4.copyWith(color: Colors.white)),
              ),
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
        const SizedBox(height: 14),
        // Value-back — your membership already paid for itself
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: SurfaceCard(
            color: AppColors.successBg,
            child: Row(children: [
              const Icon(Icons.savings_rounded, color: AppColors.success),
              const SizedBox(width: 12),
              Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Text(tr('€14 back this month'), style: AppText.body2.copyWith(color: AppColors.textDarker, fontWeight: FontWeight.w800)),
                Text(tr('Your Super Fan membership already paid for itself'), style: AppText.body3Regular),
              ])),
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
        // The one real monthly drop (Super Fan exclusive)
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: SectionHeader('This month’s drop', onAction: () => _push(context, const FomoDropScreen(subscribed: true))),
        ),
        const SizedBox(height: 12),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Tappable(
            scale: 0.98,
            onTap: () => _push(context, const FomoDropScreen(subscribed: true)),
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(gradient: const LinearGradient(colors: AppColors.pointsGradient), borderRadius: BorderRadius.circular(AppRadii.card)),
              child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Row(children: [
                  Pill(gradient: const LinearGradient(colors: AppColors.goldGradient), child: Text(tr('Super Fan only'), style: AppText.caption1.copyWith(color: AppColors.brandDarkest, fontWeight: FontWeight.w700))),
                  const Spacer(),
                  Pill(color: Colors.white24, child: Text(tr('Only 50 made'), style: AppText.caption1.copyWith(color: Colors.white))),
                ]),
                const SizedBox(height: 14),
                const Icon(Icons.local_fire_department_rounded, color: AppColors.gold, size: 36),
                const SizedBox(height: 10),
                Text(tr('Signed Retro Shirt — April Drop'), style: AppText.h4.copyWith(color: Colors.white)),
                const SizedBox(height: 6),
                Text(tr('A limited signed 1997 UEFA Cup retro shirt — dropped once, never restocked.'), style: AppText.body3.copyWith(color: Colors.white70)),
                const SizedBox(height: 14),
                Row(children: [
                  Text(tr('View this month\'s drop'), style: AppText.body2.copyWith(color: Colors.white, fontWeight: FontWeight.w700)),
                  const Icon(Icons.chevron_right_rounded, color: Colors.white, size: 18),
                ]),
              ]),
            ),
          ),
        ),
        const SizedBox(height: 24),
        // Member deals — real Fanshop products at a members-only price
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: SectionHeader('Member deals', onAction: () => _push(context, const FanshopScreen())),
        ),
        const SizedBox(height: 12),
        SizedBox(
          height: 194,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 20),
            itemCount: _drops.length,
            separatorBuilder: (_, __) => const SizedBox(width: 12),
            itemBuilder: (_, i) {
              final d = _drops[i];
              return DealCard(title: d.$1, category: d.$2, oldPts: d.$3, newPts: d.$4, badge: d.$5, glyph: d.$6, color: d.$7, onTap: () => _push(context, const FanshopScreen()));
            },
          ),
        ),
        const SizedBox(height: 24),
        // Member content
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: SectionHeader('Member content', onAction: () => _push(context, const ExclusiveContentScreen())),
        ),
        const SizedBox(height: 12),
        SizedBox(
          height: 194,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 20),
            itemCount: _content.length,
            separatorBuilder: (_, __) => const SizedBox(width: 12),
            itemBuilder: (_, i) {
              final c = _content[i];
              return FeaturedImageCard(title: c.$1, subtitle: c.$2, category: c.$3, glyph: c.$4, gradient: c.$5, badge: 'Members only', onTap: () => _push(context, const ExclusiveContentScreen()));
            },
          ),
        ),
        const SizedBox(height: 24),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Align(alignment: Alignment.centerLeft, child: Text(tr('Your Tombola perk'), style: AppText.label1)),
        ),
        const SizedBox(height: 12),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Container(
            clipBehavior: Clip.antiAlias,
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(gradient: const LinearGradient(colors: AppColors.pointsGradient), borderRadius: BorderRadius.circular(AppRadii.card)),
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Row(children: [
                Pill(gradient: const LinearGradient(colors: AppColors.goldGradient), child: Text(tr('Super Fan perk'), style: AppText.caption1.copyWith(color: AppColors.brandDarkest, fontWeight: FontWeight.w700))),
                const Spacer(),
                const Icon(Icons.local_activity_rounded, color: AppColors.gold, size: 24),
              ]),
              const SizedBox(height: 14),
              Text(tr('3 free tombola entries every month'), style: AppText.label1.copyWith(color: Colors.white)),
              const SizedBox(height: 4),
              Text(tr('Win VIP tickets, signed gear and more — winners drawn each month.'), style: AppText.body3.copyWith(color: Colors.white70)),
              const SizedBox(height: 14),
              SizedBox(
                width: double.infinity,
                child: Tappable(
                  onTap: () => _push(context, const RafflesScreen()),
                  child: Container(
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    alignment: Alignment.center,
                    decoration: BoxDecoration(color: AppColors.brandDarkest, borderRadius: BorderRadius.circular(999)),
                    child: Row(mainAxisSize: MainAxisSize.min, mainAxisAlignment: MainAxisAlignment.center, children: [
                      Text(tr('Open Tombola'), style: AppText.body2.copyWith(color: Colors.white, fontWeight: FontWeight.w600)),
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
