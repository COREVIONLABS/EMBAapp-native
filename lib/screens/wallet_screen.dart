import 'package:flutter/material.dart';
import '../theme/app_theme.dart';
import '../widgets/app_widgets.dart';
import '../widgets/tab_scaffold.dart';
import '../l10n/strings.dart';

/// Wallet — season 1: a Fan Points wallet. The branded VISA card rolls out
/// from season 2, so it is shown here as a "coming soon" teaser rather than
/// an active card.
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
        // Fan Points / Raffle Tickets — the live wallet in season 1
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Row(
            children: [
              Expanded(child: _StatCard(icon: Icons.monetization_on_rounded, value: '12,450', label: tr('Fan Points'))),
              const SizedBox(width: 12),
              Expanded(child: _StatCard(icon: Icons.confirmation_number_rounded, value: '12', label: tr('Raffle Tickets'))),
            ],
          ),
        ),
        const SizedBox(height: 16),
        const Padding(padding: EdgeInsets.symmetric(horizontal: 20), child: _CardTeaser()),
        const SizedBox(height: 24),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Align(alignment: Alignment.centerLeft, child: Text(tr('Points Activity'), style: AppText.label2)),
        ),
        const SizedBox(height: 12),
        ...[
          ('Home Jersey 25/26', 'Today · 14:30', '€84.00', '+252 pts', Color(0xFF004B9C)),
          ('Veltins matchday combo', 'Yesterday', '€18.00', '+90 pts', Color(0xFF00693C)),
          ('Museum Tour ticket', 'Mon 12 Feb', '€12.50', '+25 pts', Color(0xFF002F63)),
          ('Daily Spin reward', 'Sun 11 Feb', '—', '+50 pts', Color(0xFFFFB800)),
        ].map((t) => Padding(
              padding: const EdgeInsets.fromLTRB(20, 0, 20, 8),
              child: _TxTile(brand: t.$1, date: t.$2, amount: t.$3, pts: t.$4, color: t.$5),
            )),
      ],
    );
  }
}

/// The branded VISA card — a preview positioned as "coming in season 2".
class _CardTeaser extends StatelessWidget {
  const _CardTeaser();
  @override
  Widget build(BuildContext context) {
    return Column(children: [
      Stack(children: [
        Container(
          height: 180,
          clipBehavior: Clip.antiAlias,
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            gradient: const LinearGradient(colors: [Color(0xFF0A2A5E), Color(0xFF002F63)], begin: Alignment.topLeft, end: Alignment.bottomRight),
            borderRadius: BorderRadius.circular(AppRadii.card),
          ),
          child: Stack(children: [
            Positioned(
              right: -30, bottom: -40,
              child: Container(width: 160, height: 160, decoration: BoxDecoration(shape: BoxShape.circle, color: Colors.white.withValues(alpha: 0.04))),
            ),
            Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                Text(tr('S04 FAN CARD'), style: AppText.caption1.copyWith(color: Colors.white70, letterSpacing: 1)),
                Text('VISA', style: AppText.label2.copyWith(color: Colors.white, fontStyle: FontStyle.italic, fontWeight: FontWeight.w800)),
              ]),
              const Spacer(),
              Text('••••   ••••   ••••   ••••',
                  style: AppText.label1.copyWith(color: Colors.white38, letterSpacing: 2, fontWeight: FontWeight.w700)),
              const Spacer(),
              Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                Text(tr('YOUR NAME'), style: AppText.body3.copyWith(color: Colors.white38)),
                Text('––/––', style: AppText.body3.copyWith(color: Colors.white38)),
              ]),
            ]),
          ]),
        ),
        Positioned(
          left: 16, top: 16,
          child: Pill(
            gradient: const LinearGradient(colors: AppColors.goldGradient),
            child: Text(tr('Coming Season 2'), style: AppText.caption1.copyWith(color: AppColors.brandDarkest, fontWeight: FontWeight.w700)),
          ),
        ),
      ]),
      const SizedBox(height: 12),
      SurfaceCard(
        child: Row(children: [
          const Icon(Icons.info_outline_rounded, size: 20, color: AppColors.brandPrimary),
          const SizedBox(width: 12),
          Expanded(child: Text(tr('Earn points on every spend with the branded S04 fan card — launching next season.'),
              style: AppText.body3Regular.copyWith(fontSize: 13))),
        ]),
      ),
      const SizedBox(height: 10),
      SecondaryButton(tr('Join the waitlist'), onTap: () {}),
    ]);
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
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(value, style: AppText.label1.copyWith(color: AppColors.textDarker)),
                Text(label, maxLines: 1, overflow: TextOverflow.ellipsis, style: AppText.body3Regular),
              ],
            ),
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
                Text(tr(brand), style: AppText.body2.copyWith(color: AppColors.textDarker)),
                const SizedBox(height: 2),
                Text(tr(date), style: AppText.body3Regular),
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              if (amount != '—') Text(amount, style: AppText.body2.copyWith(color: AppColors.textDarker, fontWeight: FontWeight.w700)),
              const SizedBox(height: 2),
              Text(pts, style: AppText.caption1.copyWith(color: AppColors.success, fontSize: 11)),
            ],
          ),
        ],
      ),
    );
  }
}
