import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../theme/app_theme.dart';
import 'app_widgets.dart';
import '../l10n/strings.dart';

Widget _handle() => Container(
      width: 40,
      height: 4,
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(color: AppColors.borderLightest, borderRadius: BorderRadius.circular(2)),
    );

/// Share bottom sheet with the usual targets. This is a prototype — picking a
/// target closes the sheet and confirms with a snackbar rather than opening a
/// real OS share flow.
Future<void> showShareSheet(BuildContext context, {required String subject}) {
  const targets = <(IconData, String, Color)>[
    (Icons.link_rounded, 'Copy link', Color(0xFF0A2A5E)),
    (Icons.chat_rounded, 'WhatsApp', Color(0xFF25D366)),
    (Icons.send_rounded, 'Telegram', Color(0xFF2AABEE)),
    (Icons.alternate_email_rounded, 'Email', Color(0xFFEA4335)),
    (Icons.photo_camera_rounded, 'Instagram', Color(0xFFC13584)),
    (Icons.more_horiz_rounded, 'More', Color(0xFF6A1B9A)),
  ];
  return showModalBottomSheet<void>(
    context: context,
    backgroundColor: AppColors.surface,
    shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(28))),
    builder: (sheetCtx) => Padding(
      padding: const EdgeInsets.fromLTRB(20, 12, 20, 28),
      child: Column(mainAxisSize: MainAxisSize.min, crossAxisAlignment: CrossAxisAlignment.center, children: [
        _handle(),
        Align(alignment: Alignment.centerLeft, child: Text(tr('Share'), style: AppText.label1)),
        const SizedBox(height: 4),
        Align(alignment: Alignment.centerLeft, child: Text(subject, maxLines: 1, overflow: TextOverflow.ellipsis, style: AppText.body3Regular)),
        const SizedBox(height: 18),
        GridView.count(
          crossAxisCount: 4,
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          mainAxisSpacing: 18,
          crossAxisSpacing: 12,
          childAspectRatio: 0.82,
          children: [
            for (final t in targets)
              Tappable(
                scale: 0.92,
                onTap: () {
                  Navigator.of(sheetCtx).pop();
                  final msg = t.$2 == 'Copy link' ? tr('Link copied') : '${tr('Shared via')} ${t.$2}';
                  ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg), behavior: SnackBarBehavior.floating));
                },
                child: Column(children: [
                  Container(
                    width: 54, height: 54,
                    decoration: BoxDecoration(color: t.$3.withValues(alpha: 0.12), borderRadius: BorderRadius.circular(16)),
                    child: Icon(t.$1, color: t.$3, size: 24),
                  ),
                  const SizedBox(height: 6),
                  Text(tr(t.$2), maxLines: 1, overflow: TextOverflow.ellipsis, style: AppText.caption1.copyWith(color: AppColors.textNormal, fontSize: 11)),
                ]),
              ),
          ],
        ),
      ]),
    ),
  );
}

/// Success confirmation sheet — a green check, a title and a message, with a
/// single dismiss button. Used after actions like entering a raffle.
Future<void> showSuccessSheet(BuildContext context, {required String title, required String message, String cta = 'Done'}) {
  return showModalBottomSheet<void>(
    context: context,
    backgroundColor: AppColors.surface,
    isDismissible: true,
    shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(28))),
    builder: (sheetCtx) => Padding(
      padding: const EdgeInsets.fromLTRB(24, 12, 24, 28),
      child: Column(mainAxisSize: MainAxisSize.min, children: [
        _handle(),
        Container(
          width: 64, height: 64,
          decoration: BoxDecoration(color: AppColors.successBg, shape: BoxShape.circle),
          child: const Icon(Icons.check_rounded, color: AppColors.success, size: 34),
        ),
        const SizedBox(height: 16),
        Text(tr(title), textAlign: TextAlign.center, style: AppText.h4.copyWith(color: AppColors.textDarker)),
        const SizedBox(height: 8),
        Text(tr(message), textAlign: TextAlign.center, style: AppText.body2.copyWith(color: AppColors.textLight)),
        const SizedBox(height: 22),
        PrimaryButton(tr(cta), onTap: () => Navigator.of(sheetCtx).pop()),
      ]),
    ),
  );
}

/// Confirmation dialog with an optional destructive style (e.g. Log Out).
Future<bool> showConfirmDialog(
  BuildContext context, {
  required String title,
  required String message,
  String confirmLabel = 'Confirm',
  String cancelLabel = 'Cancel',
  bool destructive = false,
}) async {
  HapticFeedback.mediumImpact();
  final ok = await showDialog<bool>(
    context: context,
    builder: (dctx) => AlertDialog(
      backgroundColor: AppColors.surface,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      title: Text(tr(title), style: AppText.label1),
      content: Text(tr(message), style: AppText.body2.copyWith(color: AppColors.textLight)),
      actions: [
        TextButton(onPressed: () => Navigator.of(dctx).pop(false), child: Text(tr(cancelLabel), style: AppText.body2.copyWith(color: AppColors.textNormal))),
        TextButton(
          onPressed: () => Navigator.of(dctx).pop(true),
          child: Text(tr(confirmLabel), style: AppText.body2.copyWith(color: destructive ? AppColors.danger : AppColors.brandPrimary, fontWeight: FontWeight.w700)),
        ),
      ],
    ),
  );
  return ok ?? false;
}
