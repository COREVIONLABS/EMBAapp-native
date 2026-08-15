import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../theme/app_theme.dart';
import '../widgets/app_widgets.dart';
import '../widgets/sub_scaffold.dart';
import '../widgets/voucher_flow.dart';
import '../model/partners.dart';
import '../model/fan_model.dart';
import '../l10n/strings.dart';

/// Local partner marketplace — the "Händler in deiner Nähe" hub. Fans browse
/// nearby cafés, restaurants, gyms … as a list or on a map, and swap points for
/// partner vouchers (% off, 1+1, € value). Free listings + paid, labelled
/// "Anzeige" Top-Partner slots (the paid-placement revenue stream).
class PartnersScreen extends StatefulWidget {
  const PartnersScreen({super.key});
  @override
  State<PartnersScreen> createState() => _PartnersScreenState();
}

class _PartnersScreenState extends State<PartnersScreen> {
  bool _map = false;

  void _open(Partner p) => Navigator.of(context).push(MaterialPageRoute(builder: (_) => PartnerDetailScreen(id: p.id)));

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: partnerStore,
      builder: (context, _) {
        final partners = partnerStore.all;
        return SubScaffold(
          title: tr('Partners near you'),
          children: [
            // ── Hero ──
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(18),
              decoration: BoxDecoration(
                gradient: const LinearGradient(begin: Alignment.topLeft, end: Alignment.bottomRight, colors: AppColors.pointsGradient),
                borderRadius: BorderRadius.circular(AppRadii.card),
              ),
              child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Row(children: [
                  const Icon(Icons.location_on_rounded, color: AppColors.gold, size: 22),
                  const SizedBox(width: 8),
                  Expanded(child: Text(tr('Local partner deals'), style: AppText.label1.copyWith(color: Colors.white))),
                ]),
                const SizedBox(height: 6),
                Text(tr('Swap points for vouchers at cafés, restaurants & shops around you.'),
                    style: AppText.body3.copyWith(color: Colors.white70)),
                const SizedBox(height: 12),
                Row(children: [
                  Pill(color: Colors.white24, child: Text(trp('{n} partners', n: '${partnerStore.partnerCount}'), style: AppText.caption1.copyWith(color: Colors.white, fontWeight: FontWeight.w700))),
                  const SizedBox(width: 8),
                  Pill(color: Colors.white24, child: Text(trp('{n} live offers', n: '${partnerStore.offerCount}'), style: AppText.caption1.copyWith(color: Colors.white, fontWeight: FontWeight.w700))),
                ]),
              ]),
            ),
            const SizedBox(height: 14),

            // ── List / Map toggle ──
            Container(
              padding: const EdgeInsets.all(4),
              decoration: BoxDecoration(color: AppColors.surfaceMinimal, borderRadius: BorderRadius.circular(AppRadii.pill)),
              child: Row(children: [
                Expanded(child: _segment(tr('List'), Icons.view_list_rounded, !_map, () => setState(() => _map = false))),
                Expanded(child: _segment(tr('Map'), Icons.map_rounded, _map, () => setState(() => _map = true))),
              ]),
            ),
            const SizedBox(height: 14),

            // ── Category filter chips ──
            SizedBox(
              height: 36,
              child: ListView.separated(
                scrollDirection: Axis.horizontal,
                itemCount: kPartnerCategories.length,
                separatorBuilder: (_, __) => const SizedBox(width: 8),
                itemBuilder: (_, i) {
                  final c = kPartnerCategories[i];
                  final on = partnerStore.category == c.$1;
                  return Tappable(
                    onTap: () => partnerStore.setCategory(c.$1),
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 14),
                      alignment: Alignment.center,
                      decoration: BoxDecoration(
                        color: on ? AppColors.brandPrimary : AppColors.surfaceMinimal,
                        borderRadius: BorderRadius.circular(AppRadii.pill),
                      ),
                      child: Text('${c.$2} ${tr(c.$1)}', style: AppText.body3.copyWith(color: on ? Colors.white : AppColors.textNormal, fontWeight: FontWeight.w700)),
                    ),
                  );
                },
              ),
            ),
            const SizedBox(height: 16),

            if (_map) ...[
              _MockMap(partners: partners, onTap: _open),
              const SizedBox(height: 8),
              Row(children: [
                Icon(Icons.info_outline_rounded, size: 14, color: AppColors.textLight),
                const SizedBox(width: 6),
                Expanded(child: Text(tr('Tap a pin to see the partner’s offers.'), style: AppText.caption1.copyWith(color: AppColors.textLight))),
              ]),
            ] else ...[
              for (final p in partners) ...[
                _PartnerRow(partner: p, onTap: () => _open(p)),
                const SizedBox(height: 12),
              ],
              const SizedBox(height: 2),
              Row(children: [
                Icon(Icons.storefront_rounded, size: 14, color: AppColors.textLight),
                const SizedBox(width: 6),
                Expanded(child: Text(tr('Partners join free and reward you with vouchers — no ads, real value.'), style: AppText.caption1.copyWith(color: AppColors.textLight))),
              ]),
            ],
          ],
        );
      },
    );
  }

  Widget _segment(String label, IconData icon, bool on, VoidCallback onTap) => Tappable(
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 10),
          alignment: Alignment.center,
          decoration: BoxDecoration(color: on ? AppColors.surface : Colors.transparent, borderRadius: BorderRadius.circular(AppRadii.pill), boxShadow: on ? [BoxShadow(color: Colors.black.withValues(alpha: 0.08), blurRadius: 6, offset: const Offset(0, 2))] : null),
          child: Row(mainAxisSize: MainAxisSize.min, children: [
            Icon(icon, size: 16, color: on ? AppColors.brandPrimary : AppColors.textLight),
            const SizedBox(width: 6),
            Text(label, style: AppText.body3.copyWith(color: on ? AppColors.textDarker : AppColors.textLight, fontWeight: FontWeight.w800)),
          ]),
        ),
      );
}

/// A partner list row: emoji mark, name, distance + active offers, verified /
/// "Anzeige" tags, and the best badge on the right.
class _PartnerRow extends StatelessWidget {
  final Partner partner;
  final VoidCallback onTap;
  const _PartnerRow({required this.partner, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final p = partner;
    return Tappable(
      scale: 0.98,
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(AppRadii.card),
          border: Border.all(color: p.sponsored ? AppColors.gold.withValues(alpha: 0.5) : AppColors.borderLightest),
        ),
        child: Row(children: [
          Container(
            width: 52, height: 52,
            decoration: BoxDecoration(color: p.color.withValues(alpha: 0.14), borderRadius: BorderRadius.circular(14)),
            alignment: Alignment.center,
            child: Text(p.emoji, style: const TextStyle(fontSize: 26)),
          ),
          const SizedBox(width: 14),
          Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Row(children: [
              Flexible(child: Text(p.name, maxLines: 1, overflow: TextOverflow.ellipsis, style: AppText.body2.copyWith(color: AppColors.textDarker, fontWeight: FontWeight.w800))),
              if (p.verified) ...[
                const SizedBox(width: 5),
                const Icon(Icons.verified_rounded, size: 15, color: AppColors.brandPrimary),
              ],
              if (p.sponsored) ...[
                const SizedBox(width: 6),
                Container(padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2), decoration: BoxDecoration(color: AppColors.gold, borderRadius: BorderRadius.circular(5)), child: Text(tr('Ad'), style: AppText.caption1.copyWith(color: AppColors.brandDarkest, fontWeight: FontWeight.w800, fontSize: 9))),
              ],
            ]),
            const SizedBox(height: 3),
            Row(children: [
              Icon(Icons.near_me_rounded, size: 12, color: AppColors.textLight),
              const SizedBox(width: 3),
              Text(p.distanceLabel, style: AppText.caption1.copyWith(color: AppColors.textLight)),
              const SizedBox(width: 8),
              Icon(Icons.star_rounded, size: 12, color: AppColors.gold),
              const SizedBox(width: 2),
              Text(p.rating.toStringAsFixed(1), style: AppText.caption1.copyWith(color: AppColors.textLight)),
              const SizedBox(width: 8),
              Text('· ${trp('{n} offers', n: '${p.offers.length}')}', style: AppText.caption1.copyWith(color: AppColors.textLight)),
            ]),
          ])),
          const SizedBox(width: 8),
          Column(crossAxisAlignment: CrossAxisAlignment.end, children: [
            Pill(color: AppColors.brandLightest, child: Text(p.offers.first.badge, style: AppText.caption1.copyWith(color: AppColors.brandPrimary, fontWeight: FontWeight.w800))),
            const SizedBox(height: 6),
            Icon(Icons.chevron_right_rounded, color: AppColors.textLight, size: 20),
          ]),
        ]),
      ),
    );
  }
}

/// A stylised mock map (no external maps SDK): a gridded surface with tappable
/// partner pins positioned by their [Partner.mapPos].
class _MockMap extends StatelessWidget {
  final List<Partner> partners;
  final void Function(Partner) onTap;
  const _MockMap({required this.partners, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(AppRadii.card),
      child: Container(
        height: 360,
        decoration: BoxDecoration(
          color: AppColors.surfaceMinimal,
          border: Border.all(color: AppColors.borderLightest),
        ),
        child: LayoutBuilder(builder: (context, box) {
          return Stack(children: [
            // Grid "streets".
            Positioned.fill(child: CustomPaint(painter: _GridPainter(AppColors.borderLightest))),
            // You (center-ish).
            Positioned(
              left: box.maxWidth * 0.5 - 12, top: box.maxHeight * 0.5 - 12,
              child: Container(
                width: 24, height: 24,
                decoration: BoxDecoration(color: AppColors.brandPrimary, shape: BoxShape.circle, border: Border.all(color: Colors.white, width: 3), boxShadow: [BoxShadow(color: AppColors.brandPrimary.withValues(alpha: 0.4), blurRadius: 10)]),
              ),
            ),
            // Partner pins.
            for (final p in partners)
              Positioned(
                left: (box.maxWidth - 44) * p.mapPos.dx,
                top: (box.maxHeight - 52) * p.mapPos.dy,
                child: Tappable(
                  scale: 0.9,
                  onTap: () => onTap(p),
                  child: Column(mainAxisSize: MainAxisSize.min, children: [
                    Container(
                      padding: const EdgeInsets.all(7),
                      decoration: BoxDecoration(
                        color: p.sponsored ? AppColors.gold : AppColors.surface,
                        shape: BoxShape.circle,
                        border: Border.all(color: p.sponsored ? AppColors.gold : AppColors.borderLightest, width: 2),
                        boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.15), blurRadius: 6, offset: const Offset(0, 2))],
                      ),
                      child: Text(p.emoji, style: const TextStyle(fontSize: 16)),
                    ),
                    Container(width: 2, height: 6, color: p.sponsored ? AppColors.gold : AppColors.textLight),
                  ]),
                ),
              ),
          ]);
        }),
      ),
    );
  }
}

class _GridPainter extends CustomPainter {
  final Color color;
  _GridPainter(this.color);
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..color = color..strokeWidth = 1;
    for (double x = 0; x < size.width; x += 34) {
      canvas.drawLine(Offset(x, 0), Offset(x, size.height), paint);
    }
    for (double y = 0; y < size.height; y += 30) {
      canvas.drawLine(Offset(0, y), Offset(size.width, y), paint);
    }
  }

  @override
  bool shouldRepaint(covariant _GridPainter old) => old.color != color;
}

/// Partner detail — header, verified / Anzeige badges, distance + directions,
/// favourite, and the list of offers (each redeemable for points → voucher QR).
class PartnerDetailScreen extends StatelessWidget {
  final String id;
  const PartnerDetailScreen({super.key, required this.id});

  void _directions(BuildContext context, Partner p) {
    HapticFeedback.selectionClick();
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text('${tr('Opening directions to')} ${p.name}…'),
      behavior: SnackBarBehavior.floating,
    ));
  }

  void _redeem(BuildContext context, Partner p, PartnerOffer o) {
    redeemForVoucher(context, title: '${p.name} · ${tr(o.title)}', category: 'Partner', points: o.points, sponsor: p.name, detail: p.category);
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: partnerStore,
      builder: (context, _) {
        final p = partnerStore.byId(id);
        final fav = partnerStore.isFavorite(p);
        return SubScaffold(
          title: tr('Partner'),
          children: [
            // Header
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(18),
              decoration: BoxDecoration(
                gradient: LinearGradient(begin: Alignment.topLeft, end: Alignment.bottomRight, colors: [p.color, Color.lerp(p.color, Colors.black, 0.45)!]),
                borderRadius: BorderRadius.circular(AppRadii.card),
              ),
              child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Row(children: [
                  Container(width: 60, height: 60, decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16)), alignment: Alignment.center, child: Text(p.emoji, style: const TextStyle(fontSize: 30))),
                  const SizedBox(width: 14),
                  Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                    Text(p.name, style: AppText.h4.copyWith(color: Colors.white, fontSize: 22)),
                    const SizedBox(height: 3),
                    Row(children: [
                      Icon(Icons.near_me_rounded, size: 13, color: Colors.white70),
                      const SizedBox(width: 4),
                      Text('${p.distanceLabel} · ${tr(p.category)}', style: AppText.body3.copyWith(color: Colors.white70)),
                      const SizedBox(width: 8),
                      Icon(Icons.star_rounded, size: 13, color: AppColors.gold),
                      const SizedBox(width: 2),
                      Text(p.rating.toStringAsFixed(1), style: AppText.body3.copyWith(color: Colors.white70)),
                    ]),
                  ])),
                ]),
                const SizedBox(height: 14),
                Row(children: [
                  if (p.verified)
                    Pill(color: Colors.white24, child: Row(mainAxisSize: MainAxisSize.min, children: [
                      const Icon(Icons.verified_rounded, size: 13, color: Colors.white),
                      const SizedBox(width: 4),
                      Text(tr('Official partner'), style: AppText.caption1.copyWith(color: Colors.white, fontWeight: FontWeight.w700)),
                    ])),
                  if (p.sponsored) ...[
                    const SizedBox(width: 8),
                    Container(padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4), decoration: BoxDecoration(color: AppColors.gold, borderRadius: BorderRadius.circular(6)), child: Text(tr('Ad'), style: AppText.caption1.copyWith(color: AppColors.brandDarkest, fontWeight: FontWeight.w800))),
                  ],
                ]),
              ]),
            ),
            const SizedBox(height: 14),

            // Actions: directions + favourite
            Row(children: [
              Expanded(child: Tappable(
                onTap: () => _directions(context, p),
                child: Container(
                  padding: const EdgeInsets.symmetric(vertical: 13),
                  alignment: Alignment.center,
                  decoration: BoxDecoration(color: AppColors.brandPrimary, borderRadius: BorderRadius.circular(AppRadii.pill)),
                  child: Row(mainAxisSize: MainAxisSize.min, children: [
                    const Icon(Icons.directions_rounded, size: 18, color: Colors.white),
                    const SizedBox(width: 8),
                    Text(tr('Directions'), style: AppText.body2.copyWith(color: Colors.white, fontWeight: FontWeight.w800)),
                  ]),
                ),
              )),
              const SizedBox(width: 12),
              Tappable(
                onTap: () => partnerStore.toggleFavorite(p),
                child: Container(
                  width: 50, height: 48,
                  decoration: BoxDecoration(color: AppColors.surfaceMinimal, borderRadius: BorderRadius.circular(AppRadii.pill)),
                  child: Icon(fav ? Icons.favorite_rounded : Icons.favorite_border_rounded, color: fav ? AppColors.danger : AppColors.textNormal, size: 22),
                ),
              ),
            ]),
            if (fav) ...[
              const SizedBox(height: 8),
              Row(children: [
                Icon(Icons.notifications_active_rounded, size: 13, color: AppColors.brandPrimary),
                const SizedBox(width: 6),
                Expanded(child: Text(tr('Saved — we’ll notify you when they add a new offer.'), style: AppText.caption1.copyWith(color: AppColors.brandPrimary, fontWeight: FontWeight.w600))),
              ]),
            ],
            const SizedBox(height: 20),

            // Offers
            Align(alignment: Alignment.centerLeft, child: Text(tr('Offers'), style: AppText.label1)),
            const SizedBox(height: 12),
            for (final o in p.offers) ...[
              _OfferTile(offer: o, onRedeem: () => _redeem(context, p, o)),
              const SizedBox(height: 12),
            ],

            const SizedBox(height: 4),
            Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(color: AppColors.brandLightest, borderRadius: BorderRadius.circular(AppRadii.tile)),
              child: Row(children: [
                Icon(Icons.qr_code_2_rounded, size: 20, color: AppColors.brandPrimary),
                const SizedBox(width: 10),
                Expanded(child: Text(tr('Redeem points for a voucher, then show its QR code at the shop.'), style: AppText.body3.copyWith(color: AppColors.onAccent))),
              ]),
            ),
          ],
        );
      },
    );
  }
}

/// A partner-offer tile: badge, title, terms and the points price with a
/// "Für X Punkte" redeem button.
class _OfferTile extends StatelessWidget {
  final PartnerOffer offer;
  final VoidCallback onRedeem;
  const _OfferTile({required this.offer, required this.onRedeem});

  Color get _badgeColor => switch (offer.kind) {
        OfferKind.bogo => const Color(0xFF6A1B9A),
        OfferKind.fixed => const Color(0xFF9A6B00),
        OfferKind.percent => AppColors.brandPrimary,
      };

  @override
  Widget build(BuildContext context) {
    final o = offer;
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(color: AppColors.surface, borderRadius: BorderRadius.circular(AppRadii.card), border: Border.all(color: AppColors.borderLightest)),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Row(children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
            decoration: BoxDecoration(color: _badgeColor.withValues(alpha: 0.14), borderRadius: BorderRadius.circular(AppRadii.chip)),
            child: Text(o.badge, style: AppText.label2.copyWith(color: _badgeColor, fontWeight: FontWeight.w800, fontSize: 15)),
          ),
          const SizedBox(width: 12),
          Expanded(child: Text(tr(o.title), style: AppText.body2.copyWith(color: AppColors.textDarker, fontWeight: FontWeight.w800))),
        ]),
        const SizedBox(height: 10),
        Text(tr(o.detail), style: AppText.body3.copyWith(color: AppColors.textNormal)),
        const SizedBox(height: 14),
        Row(children: [
          const Icon(Icons.hexagon_rounded, size: 15, color: AppColors.brandPrimary),
          const SizedBox(width: 5),
          Text('${FanModel.fmtPublic(o.points)} ${tr('pts')}', style: AppText.body2.copyWith(color: AppColors.textDarker, fontWeight: FontWeight.w800)),
          const Spacer(),
          Tappable(
            onTap: onRedeem,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
              decoration: BoxDecoration(color: AppColors.brandPrimary, borderRadius: BorderRadius.circular(AppRadii.pill)),
              child: Text(tr('Get voucher'), style: AppText.body3.copyWith(color: Colors.white, fontWeight: FontWeight.w800)),
            ),
          ),
        ]),
      ]),
    );
  }
}
