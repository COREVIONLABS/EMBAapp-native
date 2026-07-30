import 'package:flutter/material.dart';
import '../theme/app_theme.dart';
import '../widgets/app_widgets.dart';
import '../widgets/sub_scaffold.dart';
import 'add_card_screen.dart';
import '../l10n/strings.dart';

/// Payment Methods (Figma 2162:5563).
class PaymentMethodsScreen extends StatelessWidget {
  const PaymentMethodsScreen({super.key});
  @override
  Widget build(BuildContext context) {
    return SubScaffold(
      title: tr('Payment Methods'),
      bottomBar: PrimaryButton(tr('Add New Card'), trailing: const Icon(Icons.add_rounded, color: Colors.white, size: 20), onTap: () {
        // handled below via Builder context
      }),
      children: [
        for (final c in const [
          ('Visa', '•••• 4242', '08/27', true),
          ('Mastercard', '•••• 7788', '11/25', false),
        ])
          Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: SurfaceCard(
              child: Row(children: [
                const Icon(Icons.credit_card_rounded, color: AppColors.brandPrimary),
                const SizedBox(width: 14),
                Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  Text('${c.$1} ${c.$2}', style: AppText.body2.copyWith(color: AppColors.textDarker)),
                  const SizedBox(height: 2),
                  Text('Expires ${c.$3}', style: AppText.body3Regular),
                ])),
                if (c.$4) Pill(color: AppColors.brandLightest, child: Text(tr('Default'), style: AppText.caption1.copyWith(color: AppColors.brandPrimary))),
              ]),
            ),
          ),
        Builder(builder: (context) => TextButton(
          onPressed: () => Navigator.of(context).push(MaterialPageRoute(builder: (_) => const AddCardScreen())),
          child: Text(tr('+ Add New Card'), style: AppText.body2.copyWith(color: AppColors.brandPrimary, fontWeight: FontWeight.w700)),
        )),
      ],
    );
  }
}
