import 'package:flutter/material.dart';
import '../model/voucher_store.dart';
import '../model/fan_model.dart';
import '../screens/voucher_screen.dart';
import 'action_sheets.dart';
import '../l10n/strings.dart';

/// The single "redeem points → get a voucher" flow used everywhere (Fanshop,
/// Tickets, Sponsors …). Confirms the spend, issues a code, and drops the fan
/// straight onto the voucher (QR + code) they take to the real shop/counter.
Future<void> redeemForVoucher(
  BuildContext context, {
  required String title,
  required String category,
  required int points,
  String? sponsor,
  String? detail,
}) async {
  // Guard: a paid voucher can only be issued if the balance covers it.
  if (points > 0 && FanModel.fanPoints < points) {
    await showConfirmDialog(
      context,
      title: 'Not enough points',
      message: '${tr('This costs')} ${FanModel.fmtPublic(points)} ${tr('points')} · ${tr('you have')} ${FanModel.pointsFormatted}. ${tr('Earn or top up to unlock it.')}',
      confirmLabel: 'OK',
    );
    return;
  }
  final ok = await showConfirmDialog(
    context,
    title: 'Get this voucher?',
    message: points > 0
        ? '${FanModel.fmtPublic(points)} ${tr('points')} (${FanModel.euroValue(points)}) · ${tr('redeem in the official shop or at the counter.')}'
        : tr('redeem in the official shop or at the counter.'),
    confirmLabel: 'Get voucher',
  );
  if (!ok || !context.mounted) return;
  FanModel.spendPoints(points);
  final v = voucherStore.issue(title: title, category: category, points: points, sponsor: sponsor, detail: detail);
  if (!context.mounted) return;
  await Navigator.of(context).push(MaterialPageRoute(builder: (_) => VoucherScreen.fromIssued(v)));
}
