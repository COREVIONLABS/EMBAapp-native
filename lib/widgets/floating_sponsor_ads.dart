import 'package:flutter/material.dart';
import '../theme/app_theme.dart';
import '../model/consent.dart';
import '../model/voucher_store.dart';
import '../screens/voucher_screen.dart';
import 'action_sheets.dart';
import '../l10n/strings.dart';

/// Premium, separately-sellable sponsor ad slots that live in the navigation
/// area (noon style): a branded button docked at the centre of the bottom bar,
/// and a round sponsor badge that floats diagonally above it, hovering over the
/// menu. Both are paid placements — labelled "Anzeige" (EU 2019/1150) and shown
/// only while the fan consents to advertising ([adsConsent]).
///
/// This is overlay inventory: it sits on top of the tab content without taking
/// a functional tab, so every real destination stays reachable.
class FloatingSponsorAds extends StatelessWidget {
  const FloatingSponsorAds({super.key});

  Future<void> _claim(BuildContext context, {required String partner, required String discount, required String detail}) async {
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

  @override
  Widget build(BuildContext context) {
    final bottomInset = MediaQuery.of(context).padding.bottom;
    // Clearance above the floating bottom nav (bar height + its bottom padding).
    final navClear = 74.0 + bottomInset;

    return ValueListenableBuilder<bool>(
      valueListenable: adsConsent,
      builder: (context, ads, __) {
        if (!ads) return const SizedBox.shrink();
        return Stack(children: [
          // ── Pizza Hut — sponsored button, centre of the bottom bar ──
          Positioned(
            left: 0, right: 0, bottom: navClear + 6,
            child: Center(
              child: _PizzaHutButton(onTap: () => _claim(context,
                  partner: 'Pizza Hut', discount: '30% off', detail: tr('Large pizzas, home delivery'))),
            ),
          ),
          // ── McDonald's — round badge floating diagonally up-right ──
          Positioned(
            right: 26, bottom: navClear + 52,
            child: McDonaldsAdBadge(onTap: () => _claim(context,
                partner: "McDonald's", discount: '20% off', detail: tr('On every matchday menu'))),
          ),
        ]);
      },
    );
  }
}

/// Centre-docked Pizza Hut placement: a red pill with the logo, the offer and a
/// small "Anzeige" tag.
class _PizzaHutButton extends StatelessWidget {
  final VoidCallback onTap;
  const _PizzaHutButton({required this.onTap});
  static const _red = Color(0xFFE3000B);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: Container(
        padding: const EdgeInsets.fromLTRB(8, 6, 14, 6),
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
        ]),
      ),
    );
  }
}

/// Floating McDonald's badge: a red circle with a golden "M", a tiny "Anzeige"
/// tag underneath. Hovers above the nav, over the menu. Public so pages with
/// their own nav (e.g. the discounts marketplace) can float it too.
class McDonaldsAdBadge extends StatelessWidget {
  final VoidCallback onTap;
  const McDonaldsAdBadge({super.key, required this.onTap});
  static const _red = Color(0xFFDA291C);
  static const _gold = Color(0xFFFFC72C);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: Column(mainAxisSize: MainAxisSize.min, children: [
        Container(
          width: 56, height: 56,
          decoration: BoxDecoration(
            color: _red, shape: BoxShape.circle,
            border: Border.all(color: Colors.white, width: 2.5),
            boxShadow: [BoxShadow(color: _red.withValues(alpha: 0.45), blurRadius: 14, offset: const Offset(0, 5))],
          ),
          alignment: Alignment.center,
          child: Text('M', style: AppText.h2.copyWith(color: _gold, fontWeight: FontWeight.w900, fontSize: 30, height: 1)),
        ),
        const SizedBox(height: 3),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 1),
          decoration: BoxDecoration(color: Colors.black.withValues(alpha: 0.55), borderRadius: BorderRadius.circular(4)),
          child: Text(tr('Ad'), style: AppText.caption1.copyWith(color: Colors.white, fontWeight: FontWeight.w800, fontSize: 8)),
        ),
      ]),
    );
  }
}
