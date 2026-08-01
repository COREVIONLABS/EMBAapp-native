import 'package:flutter/material.dart';
import '../theme/app_theme.dart';
import '../widgets/app_widgets.dart';
import '../widgets/sub_scaffold.dart';
import 'add_card_screen.dart';
import '../l10n/strings.dart';

/// Manage Cards (Figma 417:1626).
class ManageCardsScreen extends StatelessWidget {
  const ManageCardsScreen({super.key});
  @override
  Widget build(BuildContext context) {
    return SubScaffold(
      title: tr('Manage Cards'),
      bottomBar: PrimaryButton(tr('Add New Card'), trailing: const Icon(Icons.add_rounded, color: Colors.white, size: 20), onTap: () => Navigator.of(context).push(MaterialPageRoute(builder: (_) => const AddCardScreen()))),
      children: [
        for (final c in const [
          ('Visa', '•••• 4921', '08/27', true),
          ('Mastercard', '•••• 7788', '11/25', false),
        ])
          Padding(
            padding: const EdgeInsets.only(bottom: 14),
            child: Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: c.$4 ? AppColors.pointsGradient : const [Color(0xFF344054), Color(0xFF1D2939)],
                ),
                borderRadius: BorderRadius.circular(AppRadii.card),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Icon(Icons.contactless_rounded, color: Colors.white70),
                      Text(c.$1, style: AppText.label2.copyWith(color: Colors.white)),
                    ],
                  ),
                  const SizedBox(height: 24),
                  Text(c.$2, style: AppText.h4.copyWith(color: Colors.white, letterSpacing: 2)),
                  const SizedBox(height: 12),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(tr('Max Mustermann'), style: AppText.body2.copyWith(color: Colors.white70)),
                      Text('Exp ${c.$3}', style: AppText.body2.copyWith(color: Colors.white70)),
                    ],
                  ),
                ],
              ),
            ),
          ),
      ],
    );
  }
}

/// Bank Account — connect / connected (Figma 417:1151 / 417:1346).
class BankAccountScreen extends StatefulWidget {
  const BankAccountScreen({super.key});
  @override
  State<BankAccountScreen> createState() => _BankAccountScreenState();
}

class _BankAccountScreenState extends State<BankAccountScreen> {
  bool _connected = false;
  @override
  Widget build(BuildContext context) {
    return SubScaffold(
      title: tr('Bank Account'),
      bottomBar: _connected
          ? null
          : PrimaryButton(tr('Connect Bank Account'), onTap: () => setState(() => _connected = true)),
      children: [
        const SizedBox(height: 12),
        Center(
          child: Container(
            width: 100,
            height: 100,
            decoration: BoxDecoration(color: AppColors.brandLightest, shape: BoxShape.circle),
            child: Icon(_connected ? Icons.check_circle_rounded : Icons.account_balance_rounded,
                size: 52, color: _connected ? AppColors.success : AppColors.brandPrimary),
          ),
        ),
        const SizedBox(height: 24),
        Text(_connected ? 'Bank account connected' : 'Connect your bank account',
            textAlign: TextAlign.center, style: AppText.h4),
        const SizedBox(height: 8),
        Text(
          _connected
              ? 'Sparkasse ••• 3021 is linked. You now auto-earn Fan Points on every purchase.'
              : 'Securely link your account to auto-earn Fan Points on every eligible purchase. Powered by bank-grade encryption.',
          textAlign: TextAlign.center,
          style: AppText.body1.copyWith(color: AppColors.textLight),
        ),
        const SizedBox(height: 20),
        if (!_connected)
          SurfaceCard(
            color: AppColors.brandLightest,
            child: Row(
              children: [
                const Icon(Icons.lock_rounded, color: AppColors.brandPrimary, size: 20),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(tr('We never store your bank login. Connection is read-only.'),
                      style: TextStyle(fontFamily: 'Urbanist', fontSize: 13, color: AppColors.textNormal)),
                ),
              ],
            ),
          ),
      ],
    );
  }
}
