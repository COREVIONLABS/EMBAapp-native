import 'package:flutter/material.dart';
import '../theme/app_theme.dart';
import '../model/consent.dart';
import '../model/voucher_store.dart';
import '../screens/voucher_screen.dart';
import 'action_sheets.dart';
import '../l10n/strings.dart';

/// Claim a sponsor's member voucher (shared by both floating placements).
Future<void> claimSponsorVoucher(BuildContext context, {required String partner, required String discount, required String detail}) async {
  final ok = await showConfirmDialog(
    context,
    title: 'Get this member voucher?',
    message: '$discount ${tr('at')} $partner · $detail',
    confirmLabel: 'Get voucher',
  );
  if (!ok || !context.mounted) return;
  final v = voucherStore.issue(title: '$partner · $discount', category: 'Sponsor', points: 0, sponsor: partner);
  if (!context.mounted) return;
  await Navigator.of(context).push(MaterialPageRoute(builder: (_) => VoucherScreen.fromIssued(v)));
}

/// Confirm-then-hide a floating ad (so it can't be dismissed by accident).
Future<void> confirmHideAd(BuildContext context, ValueNotifier<bool> flag) async {
  final ok = await showConfirmDialog(
    context,
    title: 'Hide this ad?',
    message: 'This sponsored placement will be hidden.',
    confirmLabel: 'Hide',
  );
  if (ok) flag.value = false;
}

/// The floating **Pizza Hut** placement — a sponsored button docked at the
/// centre, just above the bottom nav. Home screen only (kept off the other tabs
/// so it doesn't feel like too much). Labelled "Anzeige", gated on ad consent,
/// and dismissible with a confirm.
class FloatingSponsorAds extends StatelessWidget {
  const FloatingSponsorAds({super.key});

  @override
  Widget build(BuildContext context) {
    final bottomInset = MediaQuery.of(context).padding.bottom;
    final navClear = 74.0 + bottomInset;

    return AnimatedBuilder(
      animation: Listenable.merge([adsConsent, pizzaHutAdVisible]),
      builder: (context, __) {
        if (!adsConsent.value || !pizzaHutAdVisible.value) return const SizedBox.shrink();
        return Stack(children: [
          Positioned(
            left: 0, right: 0, bottom: navClear + 6,
            child: Center(
              child: _PizzaHutButton(
                onTap: () => claimSponsorVoucher(context, partner: 'Pizza Hut', discount: '30% off', detail: tr('Large pizzas, home delivery')),
                onDismiss: () => confirmHideAd(context, pizzaHutAdVisible),
              ),
            ),
          ),
        ]);
      },
    );
  }
}

/// Centre-docked Pizza Hut placement: a red pill with the logo, the offer, a
/// small "Anzeige" tag and a dismiss "×".
class _PizzaHutButton extends StatelessWidget {
  final VoidCallback onTap;
  final VoidCallback onDismiss;
  const _PizzaHutButton({required this.onTap, required this.onDismiss});
  static const _red = Color(0xFFE3000B);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: Container(
        padding: const EdgeInsets.fromLTRB(8, 6, 6, 6),
        decoration: BoxDecoration(
          color: _red,
          borderRadius: BorderRadius.circular(999),
          boxShadow: [BoxShadow(color: _red.withValues(alpha: 0.4), blurRadius: 14, offset: const Offset(0, 4))],
        ),
        child: Row(mainAxisSize: MainAxisSize.min, children: [
          Container(width: 30, height: 30, decoration: const BoxDecoration(color: Colors.white, shape: BoxShape.circle), alignment: Alignment.center, child: const Icon(Icons.local_pizza_rounded, color: _red, size: 18)),
          const SizedBox(width: 8),
          Column(mainAxisSize: MainAxisSize.min, crossAxisAlignment: CrossAxisAlignment.start, children: [
            Row(mainAxisSize: MainAxisSize.min, children: [
              Text('Pizza Hut', style: AppText.caption1.copyWith(color: Colors.white, fontWeight: FontWeight.w800, fontSize: 12)),
              const SizedBox(width: 5),
              Container(padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 1), decoration: BoxDecoration(color: Colors.white.withValues(alpha: 0.22), borderRadius: BorderRadius.circular(3)), child: Text(tr('Ad'), style: AppText.caption1.copyWith(color: Colors.white, fontWeight: FontWeight.w800, fontSize: 8))),
            ]),
            Text('-30%', style: AppText.caption1.copyWith(color: Colors.white, fontWeight: FontWeight.w800, fontSize: 11)),
          ]),
          const SizedBox(width: 10),
          GestureDetector(
            onTap: onDismiss,
            behavior: HitTestBehavior.opaque,
            child: Container(
              width: 26, height: 26,
              decoration: BoxDecoration(color: Colors.white.withValues(alpha: 0.22), shape: BoxShape.circle),
              child: const Icon(Icons.close_rounded, color: Colors.white, size: 16),
            ),
          ),
        ]),
      ),
    );
  }
}

/// Floating McDonald's badge: a red circle with a golden "M", a tiny "Anzeige"
/// tag underneath, and (when [onDismiss] is given) a small "×" to hide it.
/// Public so pages with their own nav (the discounts marketplace) can float it.
class McDonaldsAdBadge extends StatelessWidget {
  final VoidCallback onTap;
  final VoidCallback? onDismiss;
  const McDonaldsAdBadge({super.key, required this.onTap, this.onDismiss});
  static const _red = Color(0xFFDA291C);
  static const _gold = Color(0xFFFFC72C);

  @override
  Widget build(BuildContext context) {
    return Column(mainAxisSize: MainAxisSize.min, children: [
      Stack(clipBehavior: Clip.none, children: [
        GestureDetector(
          onTap: onTap,
          behavior: HitTestBehavior.opaque,
          child: Container(
            width: 56, height: 56,
            decoration: BoxDecoration(
              color: _red, shape: BoxShape.circle,
              border: Border.all(color: Colors.white, width: 2.5),
              boxShadow: [BoxShadow(color: _red.withValues(alpha: 0.45), blurRadius: 14, offset: const Offset(0, 5))],
            ),
            alignment: Alignment.center,
            child: Text('M', style: AppText.h2.copyWith(color: _gold, fontWeight: FontWeight.w900, fontSize: 30, height: 1)),
          ),
        ),
        if (onDismiss != null)
          Positioned(
            right: -4, top: -4,
            child: GestureDetector(
              onTap: onDismiss,
              behavior: HitTestBehavior.opaque,
              child: Container(
                width: 22, height: 22,
                decoration: BoxDecoration(color: AppColors.brandDarkest, shape: BoxShape.circle, border: Border.all(color: Colors.white, width: 1.5)),
                child: const Icon(Icons.close_rounded, color: Colors.white, size: 13),
              ),
            ),
          ),
      ]),
      const SizedBox(height: 3),
      Container(
        padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 1),
        decoration: BoxDecoration(color: Colors.black.withValues(alpha: 0.55), borderRadius: BorderRadius.circular(4)),
        child: Text(tr('Ad'), style: AppText.caption1.copyWith(color: Colors.white, fontWeight: FontWeight.w800, fontSize: 8)),
      ),
    ]);
  }
}
