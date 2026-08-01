import 'package:flutter/material.dart';
import '../theme/app_theme.dart';
import '../widgets/app_widgets.dart';
import '../widgets/sub_scaffold.dart';
import '../widgets/action_sheets.dart';
import '../l10n/strings.dart';

/// Voucher detail — a redeemed reward shown as a scannable QR + short code,
/// with an expiry, sponsor attribution, and a staff-side "Entertainer" PIN
/// that a kiosk/steward enters to mark it used (prevents screenshot reuse).
class VoucherScreen extends StatelessWidget {
  final String title;
  final String sponsor;
  final String code;
  final String expiry;
  const VoucherScreen({
    super.key,
    this.title = 'Free Veltins 0.5L',
    this.sponsor = 'Veltins',
    this.code = 'S04-VEL-9F3K',
    this.expiry = 'Valid until 30 Apr 2026',
  });

  @override
  Widget build(BuildContext context) {
    return SubScaffold(
      title: tr('Your Voucher'),
      bottomBar: SecondaryButton(tr('Mark as used'), onTap: () async {
        final ok = await showConfirmDialog(context, title: 'Mark voucher as used?', message: 'This can\'t be undone — only do this at the counter.', confirmLabel: 'Mark used');
        if (ok && context.mounted) {
          await showSuccessSheet(context, title: 'Voucher redeemed', message: 'Enjoy! This voucher is now marked as used.');
          if (context.mounted) Navigator.of(context).pop();
        }
      }),
      children: [
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(color: AppColors.surface, borderRadius: BorderRadius.circular(AppRadii.card), border: Border.all(color: AppColors.borderLightest)),
          child: Column(children: [
            Pill(color: AppColors.brandLightest, child: Text('${tr('Powered by')} $sponsor', style: AppText.caption1.copyWith(color: AppColors.brandPrimary, fontWeight: FontWeight.w700))),
            const SizedBox(height: 16),
            Text(tr(title), textAlign: TextAlign.center, style: AppText.h4.copyWith(color: AppColors.textDarker)),
            const SizedBox(height: 20),
            // QR placeholder
            Container(
              width: 180, height: 180,
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16), border: Border.all(color: AppColors.borderLightest)),
              child: CustomPaint(painter: _QrPainter(), size: const Size.square(156)),
            ),
            const SizedBox(height: 16),
            Text(tr('Scan at the kiosk'), style: AppText.body3Regular),
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 10),
              decoration: BoxDecoration(color: AppColors.surfaceMinimal, borderRadius: BorderRadius.circular(999)),
              child: Text(code, style: TextStyle(fontFamily: 'Urbanist', fontSize: 18, fontWeight: FontWeight.w800, letterSpacing: 2, color: AppColors.textDarker)),
            ),
            const SizedBox(height: 12),
            Row(mainAxisAlignment: MainAxisAlignment.center, children: [
              Icon(Icons.schedule_rounded, size: 15, color: AppColors.textLight),
              const SizedBox(width: 6),
              Text(tr(expiry), style: AppText.body3Regular),
            ]),
          ]),
        ),
        const SizedBox(height: 16),
        // Staff redemption (Entertainer PIN)
        SurfaceCard(
          child: Row(children: [
            Container(
              width: 44, height: 44,
              decoration: BoxDecoration(color: AppColors.brandDarkest, borderRadius: BorderRadius.circular(12)),
              child: const Icon(Icons.lock_outline_rounded, color: Colors.white, size: 22),
            ),
            const SizedBox(width: 14),
            Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text(tr('Staff redemption'), style: AppText.body2.copyWith(color: AppColors.textDarker)),
              Text(tr('Kiosk staff enter the Entertainer PIN to confirm'), style: AppText.body3Regular),
            ])),
          ]),
        ),
        const SizedBox(height: 12),
        Row(children: [
          Icon(Icons.info_outline_rounded, size: 14, color: AppColors.textLight),
          const SizedBox(width: 6),
          Expanded(child: Text(tr('Screenshots won\'t work — the code is single-use and confirmed by staff PIN.'),
              style: AppText.caption1.copyWith(color: AppColors.textLight))),
        ]),
      ],
    );
  }
}

/// Deterministic faux-QR so the screen renders without a QR dependency.
class _QrPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..color = AppColors.brandDarkest;
    const n = 21;
    final cell = size.width / n;
    // Fixed pattern (no randomness) — looks like a QR without encoding data.
    for (var y = 0; y < n; y++) {
      for (var x = 0; x < n; x++) {
        final finder = (x < 7 && y < 7) || (x >= n - 7 && y < 7) || (x < 7 && y >= n - 7);
        final on = finder ? _finderCell(x, y, n) : ((x * 7 + y * 13 + x * y) % 3 == 0);
        if (on) {
          canvas.drawRect(Rect.fromLTWH(x * cell, y * cell, cell, cell), paint);
        }
      }
    }
  }

  bool _finderCell(int x, int y, int n) {
    int lx = x >= n - 7 ? x - (n - 7) : x;
    int ly = y >= n - 7 ? y - (n - 7) : y;
    final edge = lx == 0 || lx == 6 || ly == 0 || ly == 6;
    final core = lx >= 2 && lx <= 4 && ly >= 2 && ly <= 4;
    return edge || core;
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
