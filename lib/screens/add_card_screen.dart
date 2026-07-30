import 'package:flutter/material.dart';
import '../widgets/app_widgets.dart';
import '../widgets/sub_scaffold.dart';
import '../widgets/text_field.dart';
import '../l10n/strings.dart';

/// Add New Card (Figma 2162:5704).
class AddCardScreen extends StatelessWidget {
  const AddCardScreen({super.key});
  @override
  Widget build(BuildContext context) {
    return SubScaffold(
      title: tr('Add New Card'),
      bottomBar: PrimaryButton(tr('Save Card'), onTap: () => Navigator.of(context).maybePop()),
      children: [
        AppTextField(label: tr('Card Number'), hint: '1234 5678 9012 3456'),
        const SizedBox(height: 18),
        AppTextField(label: tr('Cardholder Name'), hint: tr('Max Mustermann')),
        const SizedBox(height: 18),
        Row(children: [
          Expanded(child: AppTextField(label: tr('Expiry'), hint: tr('MM/YY'))),
          const SizedBox(width: 16),
          Expanded(child: AppTextField(label: tr('CVV'), hint: '123')),
        ]),
      ],
    );
  }
}
