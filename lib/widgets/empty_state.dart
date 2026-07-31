import 'package:flutter/material.dart';
import '../theme/app_theme.dart';
import 'app_widgets.dart';
import '../l10n/strings.dart';

/// Friendly empty-state placeholder: icon, title, one line of guidance and an
/// optional call-to-action. Used wherever a list can legitimately be empty
/// (cart, notifications, first-run history …).
class EmptyState extends StatelessWidget {
  final IconData icon;
  final String title;
  final String message;
  final String? ctaLabel;
  final VoidCallback? onCta;
  const EmptyState({
    super.key,
    required this.icon,
    required this.title,
    required this.message,
    this.ctaLabel,
    this.onCta,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(32, 56, 32, 32),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 84,
            height: 84,
            decoration: const BoxDecoration(color: AppColors.brandLightest, shape: BoxShape.circle),
            child: Icon(icon, color: AppColors.brandPrimary, size: 38),
          ),
          const SizedBox(height: 20),
          Text(tr(title), textAlign: TextAlign.center, style: AppText.label1.copyWith(color: AppColors.textDarker)),
          const SizedBox(height: 8),
          Text(tr(message), textAlign: TextAlign.center, style: AppText.body2.copyWith(color: AppColors.textLight, height: 1.5)),
          if (ctaLabel != null) ...[
            const SizedBox(height: 24),
            SizedBox(width: 220, child: PrimaryButton(tr(ctaLabel!), onTap: onCta ?? () {})),
          ],
        ],
      ),
    );
  }
}
