import 'package:flutter/material.dart';
import '../theme/app_theme.dart';
import '../widgets/app_widgets.dart';
import '../widgets/tab_scaffold.dart';
import 'wallet_detail_screens.dart';

/// Wallet tab (Figma: Wallet — Free / Supporter / Superfan, 360:1274 …).
class WalletScreen extends StatelessWidget {
  const WalletScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return TabScaffold(
      children: [
        const TabHeader('Wallet', subtitle: 'S04 Fan Wallet'),
        const SizedBox(height: 20),
        const Padding(padding: EdgeInsets.symmetric(horizontal: 20), child: _BalanceCard()),
        const SizedBox(height: 20),
        const _WalletActions(),
        const SizedBox(height: 24),
        const Padding(
          padding: EdgeInsets.symmetric(horizontal: 20),
          child: _ConnectBankCard(),
        ),
        const SizedBox(height: 24),
        const Padding(
          padding: EdgeInsets.symmetric(horizontal: 20),
          child: SectionHeader('Recent Activity', action: 'See All'),
        ),
        const SizedBox(height: 12),
        ...[
          ('Ticket purchase', '-€45.00', 'vs Bayern · Sec. 12', false),
          ('Fan Points cashback', '+€3.20', 'Weekly reward', true),
          ('Club shop', '-€89.90', 'Home jersey 24/25', false),
        ].map((t) => Padding(
              padding: const EdgeInsets.fromLTRB(20, 0, 20, 8),
              child: _TxTile(title: t.$1, amount: t.$2, sub: t.$3, credit: t.$4),
            )),
      ],
    );
  }
}

class _BalanceCard extends StatelessWidget {
  const _BalanceCard();
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      clipBehavior: Clip.antiAlias,
      decoration: BoxDecoration(
        gradient: const LinearGradient(colors: AppColors.pointsGradient),
        borderRadius: BorderRadius.circular(AppRadii.card),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('Available balance', style: AppText.body2.copyWith(color: Colors.white70)),
              Pill(
                color: AppColors.brandDark,
                child: Text('FREE PLAN', style: AppText.caption1.copyWith(color: AppColors.textLightest)),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Text('€128.40', style: AppText.h1.copyWith(color: Colors.white)),
          const SizedBox(height: 14),
          Row(
            children: [
              const Icon(Icons.credit_card_rounded, color: Colors.white70, size: 18),
              const SizedBox(width: 8),
              Text('•••• 4921', style: AppText.body2.copyWith(color: Colors.white)),
              const Spacer(),
              Text('Exp 08/27', style: AppText.body3.copyWith(color: Colors.white70)),
            ],
          ),
        ],
      ),
    );
  }
}

class _WalletActions extends StatelessWidget {
  const _WalletActions();
  @override
  Widget build(BuildContext context) {
    const items = [
      (Icons.add_rounded, 'Add money'),
      (Icons.north_east_rounded, 'Send'),
      (Icons.qr_code_rounded, 'Pay'),
      (Icons.redeem_rounded, 'Redeem'),
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
                    width: 56,
                    height: 56,
                    decoration: BoxDecoration(
                      color: AppColors.brandLightest,
                      borderRadius: BorderRadius.circular(AppRadii.tile),
                    ),
                    child: Icon(it.$1, color: AppColors.brandPrimary),
                  ),
                  const SizedBox(height: 8),
                  Text(it.$2, style: AppText.body3),
                ],
              ),
            ),
        ],
      ),
    );
  }
}

class _ConnectBankCard extends StatelessWidget {
  const _ConnectBankCard();
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => Navigator.of(context).push(MaterialPageRoute(builder: (_) => const BankAccountScreen())),
      child: SurfaceCard(
      color: AppColors.brandLightest,
      border: Border.all(color: AppColors.brandLightest),
      padding: const EdgeInsets.all(16),
      child: Row(
        children: [
          const Icon(Icons.account_balance_rounded, color: AppColors.brandPrimary),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Connect your bank account', style: AppText.body2.copyWith(color: AppColors.textDarker)),
                const SizedBox(height: 2),
                Text('Auto-earn points on every purchase', style: AppText.body3Regular),
              ],
            ),
          ),
          const Svg('arrow_right', size: 16),
        ],
      ),
      ),
    );
  }
}

class _TxTile extends StatelessWidget {
  final String title;
  final String amount;
  final String sub;
  final bool credit;
  const _TxTile({required this.title, required this.amount, required this.sub, required this.credit});
  @override
  Widget build(BuildContext context) {
    return SurfaceCard(
      padding: const EdgeInsets.all(14),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(color: AppColors.surfaceMinimal, borderRadius: BorderRadius.circular(12)),
            child: Icon(credit ? Icons.savings_rounded : Icons.shopping_bag_rounded,
                color: AppColors.textNormal, size: 20),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: AppText.body2.copyWith(color: AppColors.textDarker)),
                const SizedBox(height: 2),
                Text(sub, style: AppText.body3Regular),
              ],
            ),
          ),
          Text(amount,
              style: AppText.body2.copyWith(
                  color: credit ? AppColors.success : AppColors.textDarker, fontWeight: FontWeight.w700)),
        ],
      ),
    );
  }
}
