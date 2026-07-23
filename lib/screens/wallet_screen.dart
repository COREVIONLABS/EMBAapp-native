import 'package:flutter/material.dart';
import '../theme/app_theme.dart';
import '../widgets/app_widgets.dart';
import '../widgets/tab_scaffold.dart';
import 'wallet_detail_screens.dart';

/// Wallet — Free (Figma 2145:7678): fan wallet with bank connect, points/tickets,
/// virtual-card upsell and sponsor transactions.
class WalletScreen extends StatelessWidget {
  const WalletScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return TabScaffold(
      children: [
        // Header: logo + bell
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
        // Connect bank account card
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: SurfaceCard(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                Container(
                  width: 44,
                  height: 44,
                  decoration: BoxDecoration(color: AppColors.brandLightest, borderRadius: BorderRadius.circular(12)),
                  child: const Icon(Icons.account_balance_rounded, color: AppColors.brandPrimary),
                ),
                const SizedBox(height: 14),
                PrimaryButton('Connect Bank Account',
                    height: 50,
                    onTap: () => Navigator.of(context)
                        .push(MaterialPageRoute(builder: (_) => const BankAccountScreen()))),
                const SizedBox(height: 10),
                Text('Secure read-only access via Tink', style: AppText.body3Regular),
              ],
            ),
          ),
        ),
        const SizedBox(height: 16),
        // Points / tickets stats
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
        // Virtual card upsell
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            decoration: BoxDecoration(color: const Color(0xFFFFF3DC), borderRadius: BorderRadius.circular(AppRadii.tile)),
            child: Row(
              children: [
                const Icon(Icons.workspace_premium_rounded, color: AppColors.gold, size: 22),
                const SizedBox(width: 10),
                Expanded(
                  child: Text('Upgrade to Virtual Card',
                      style: AppText.body2.copyWith(color: AppColors.brandDarkest, fontWeight: FontWeight.w700)),
                ),
                Text('€4.99/mo', style: AppText.body3.copyWith(color: AppColors.textDark)),
                const SizedBox(width: 4),
                const Svg('arrow_right', size: 16),
              ],
            ),
          ),
        ),
        const SizedBox(height: 24),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Row(
            children: [
              Text('Recent Transactions', style: AppText.label2),
              const SizedBox(width: 6),
              Text('(Sponsors Only)', style: AppText.body3Regular),
            ],
          ),
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
  const _TxTile(
      {required this.brand, required this.date, required this.amount, required this.pts, required this.color});
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
            child: Text(brand.characters.first,
                style: const TextStyle(fontFamily: 'Urbanist', color: Colors.white, fontWeight: FontWeight.w800)),
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
