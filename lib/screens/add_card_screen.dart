import 'package:flutter/material.dart';
import '../widgets/app_widgets.dart';
import '../widgets/sub_scaffold.dart';
import '../widgets/text_field.dart';

/// Add New Card (Figma 2162:5704).
class AddCardScreen extends StatelessWidget {
  const AddCardScreen({super.key});
  @override
  Widget build(BuildContext context) {
    return SubScaffold(
      title: 'Add New Card',
      bottomBar: PrimaryButton('Save Card', onTap: () => Navigator.of(context).maybePop()),
      children: const [
        AppTextField(label: 'Card Number', hint: '1234 5678 9012 3456'),
        SizedBox(height: 18),
        AppTextField(label: 'Cardholder Name', hint: 'Max Mustermann'),
        SizedBox(height: 18),
        Row(children: [
          Expanded(child: AppTextField(label: 'Expiry', hint: 'MM/YY')),
          SizedBox(width: 16),
          Expanded(child: AppTextField(label: 'CVV', hint: '123')),
        ]),
      ],
    );
  }
}
