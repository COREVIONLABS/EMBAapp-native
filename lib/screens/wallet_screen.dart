import 'package:flutter/material.dart';
import '../theme/app_theme.dart';
import '../widgets/app_widgets.dart';
import '../widgets/tab_scaffold.dart';

/// Wallet — Supporter/Superfan (Figma 2145:7873/8022): virtual card, card
/// actions, points/tickets, physical-card upsell, sponsor transactions.
class WalletScreen extends StatelessWidget {
  const WalletScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return TabScaffold(
      children: [
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
        const Padding(padding: EdgeInsets.symmetric(horizontal: 20), child: _VirtualCard()),
        const SizedBox(height: 16),
        const _CardActions(),
        const SizedBox(height: 16),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Row(
            children: const [
              Expanded(child: _StatCard(icon: Icons.monetization_on_rounded, value: '850', label: 'Points')),
              SizedBox(width: 12),
              Expanded(child: _StatCard(icon: Icons.confirmation_number_rounded, value: '12', label: 'Tickets')),
            ],
          ),
        ),
        const SizedBox(height: 16),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            decoration: BoxDecoration(color: const Color(0xFFFFF3DC), borderRadius: BorderRadius.circular(AppRadii.tile)),
            child: Row(
              children: [
                const Icon(Icons.workspace_premium_rounded, color: AppColors.gold, size: 22),
                const SizedBox(width: 10),
                Expanded(child: Text('Upgrade to Physical Card', style: AppText.body2.copyWith(color: AppColors.brandDarkest, fontWeight: FontWeight.w700))),
                Text('€9.99/mo', style: AppText.body3.copyWith(color: AppColors.textDark)),
                const SizedBox(width: 4),
                const Svg('arrow_right', size: 16),
              ],
            ),
          ),
        ),
        const SizedBox(height: 24),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Row(children: [
            Text('Recent Transactions', style: AppText.label2),
            const SizedBox(width: 6),
            Text('(Sponsors Only)', style: AppText.body3Regular),
          ]),
        ),
        const SizedBox(height: 12),
        ...[
          ('Nike Store', 'Today · 14:30', '-€84.00', '+252 pts', Color(0xFF111111)),
          ("Macy's Shop", 'Yesterday', '-€45.00', '+90 pts', Color(0xFFE21836)),
          ('Starbucks', 'Mon 12 Feb', '-€12.50', '+25 pts', Color(0xFF00704A)),
          ('Puma', 'Sun 11 Feb', '-€12.50', '+25 pts', Color(0xFF1A2432)),
        ].map((t) => Padding(
              padding: const EdgeInsets.fromLTRB(20, 0, 20, 8),
              child: _TxTile(brand: t.$1, date: t.$2, amount: t.$3, pts: t.$4, color: t.$5),
            )),
      ],
    );
  }
}

class _VirtualCard extends StatelessWidget {
  const _VirtualCard();
  @override
  Widget build(BuildContext context) {
    return Container(
      height: 180,
      clipBehavior: Clip.antiAlias,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: const LinearGradient(colors: [Color(0xFF0A2A5E), Color(0xFF002F63)], begin: Alignment.topLeft, end: Alignment.bottomRight),
        borderRadius: BorderRadius.circular(AppRadii.card),
      ),
      child: Stack(
        children: [
          Positioned(
            right: -30,
            bottom: -40,
            child: Container(width: 160, height: 160, decoration: BoxDecoration(shape: BoxShape.circle, color: Colors.white.withValues(alpha: 0.04))),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text('S04 FAN VIRTUAL CARD', style: AppText.caption1.copyWith(color: Colors.white70, letterSpacing: 1)),
                  Text('VISA', style: AppText.label2.copyWith(color: Colors.white, fontStyle: FontStyle.italic, fontWeight: FontWeight.w800)),
                ],
              ),
              const SizedBox(height: 8),
              Pill(
                gradient: const LinearGradient(colors: AppColors.goldGradient),
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                child: Text('Virtual', style: AppText.caption1.copyWith(color: AppColors.brandDarkest)),
              ),
              const Spacer(),
              Text('••••   ••••   ••••   4821',
                  style: AppText.label1.copyWith(color: Colors.white, letterSpacing: 2, fontWeight: FontWeight.w700)),
              const Spacer(),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text('MAX MUSTERMANN', style: AppText.body3.copyWith(color: Colors.white)),
                  Text('03/28', style: AppText.body3.copyWith(color: Colors.white70)),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _CardActions extends StatelessWidget {
  const _CardActions();
  @override
  Widget build(BuildContext context) {
    const items = [
      (Icons.ac_unit_rounded, 'Freeze'),
      (Icons.visibility_outlined, 'Reveal'),
      (Icons.tune_rounded, 'Limits'),
      (Icons.more_horiz_rounded, 'More'),
    ];
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Row(
        children: [
          for (final it in items)
            Expanded(
              child: Column(
                children: [
                  Container(
                    width: 48,
                    height: 48,
                    decoration: BoxDecoration(color: AppColors.brandLightest, borderRadius: BorderRadius.circular(14)),
                    child: Icon(it.$1, color: AppColors.brandPrimary, size: 22),
                  ),
                  const SizedBox(height: 6),
                  Text(it.$2, style: AppText.body3),
                ],
              ),
            ),
        ],
      ),
    );
  }
}

class _StatCard extends StatelessWidget {
  final IconData icon;
  final String value;
  final String label;
  const _StatCard({required this.icon, required this.value, required this.label});
  @override
  Widget build(BuildContext context) {
    return SurfaceCard(
      padding: const EdgeInsets.all(16),
      child: Row(
        children: [
          Icon(icon, color: AppColors.gold, size: 28),
          const SizedBox(width: 12),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(value, style: AppText.label1.copyWith(color: AppColors.textDarker)),
              Text(label, style: AppText.body3Regular),
            ],
          ),
        ],
      ),
    );
  }
}

class _TxTile extends StatelessWidget {
  final String brand;
  final String date;
  final String amount;
  final String pts;
  final Color color;
  const _TxTile({required this.brand, required this.date, required this.amount, required this.pts, required this.color});
  @override
  Widget build(BuildContext context) {
    return SurfaceCard(
      padding: const EdgeInsets.all(14),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(color: color, shape: BoxShape.circle),
            alignment: Alignment.center,
            child: Text(brand.characters.first, style: const TextStyle(fontFamily: 'Urbanist', color: Colors.white, fontWeight: FontWeight.w800)),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(brand, style: AppText.body2.copyWith(color: AppColors.textDarker)),
                const SizedBox(height: 2),
                Text(date, style: AppText.body3Regular),
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(amount, style: AppText.body2.copyWith(color: AppColors.textDarker, fontWeight: FontWeight.w700)),
              const SizedBox(height: 2),
              Text(pts, style: AppText.caption1.copyWith(color: AppColors.success, fontSize: 11)),
            ],
          ),
        ],
      ),
    );
  }
}
