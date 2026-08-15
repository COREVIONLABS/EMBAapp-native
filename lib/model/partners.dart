import 'package:flutter/material.dart';

/// How a partner offer discounts — drives the badge style and copy.
enum OfferKind { percent, bogo, fixed }

/// One redeemable offer from a local partner. The fan spends points to issue a
/// voucher code, then shows it at the shop where the merchant scans it (handled
/// by the neutral Merchant app). % off, 1+1, or a fixed € voucher.
class PartnerOffer {
  final String title; // e.g. "20% auf alles", "1+1 Kaffee gratis"
  final String detail; // terms / what's included
  final OfferKind kind;
  final String badge; // "-20%", "1+1", "€5"
  final int points; // points to unlock the voucher
  const PartnerOffer(this.title, this.detail, this.kind, this.badge, this.points);
}

/// A local partner (café, restaurant, gym …) listed in the marketplace. Free to
/// list (they pay with vouchers, not budget); paid [sponsored] placement lifts
/// them to the top and is legally labelled "Anzeige" (EU 2019/1150).
class Partner {
  final String id;
  final String name;
  final String category;
  final String emoji;
  final Color color;
  final double distanceKm;
  final double rating;
  final bool verified; // "Offizieller Vereinspartner" badge
  final bool sponsored; // paid Top-Partner slot → shown as "Anzeige"
  final Offset mapPos; // 0..1 position on the mock map
  final List<PartnerOffer> offers;

  const Partner({
    required this.id,
    required this.name,
    required this.category,
    required this.emoji,
    required this.color,
    required this.distanceKm,
    required this.rating,
    required this.offers,
    required this.mapPos,
    this.verified = false,
    this.sponsored = false,
  });

  String get distanceLabel => distanceKm < 1 ? '${(distanceKm * 1000).round()} m' : '${distanceKm.toStringAsFixed(1)} km';
}

/// Partner categories for the filter chips (label + emoji).
const kPartnerCategories = <(String, String)>[
  ('All', '📍'),
  ('Café', '☕'),
  ('Restaurant', '🍽️'),
  ('Bakery', '🥐'),
  ('Fitness', '🏋️'),
  ('Barber', '✂️'),
  ('Leisure', '🎳'),
];

/// In-memory partner marketplace (prototype state). Handles the category filter
/// and favourites, and always sorts sponsored partners first (labelled), then by
/// distance — the exact model behind the paid-placement revenue stream.
class PartnerStore extends ChangeNotifier {
  String category = 'All';
  final Set<String> favorites = {};

  final List<Partner> _all = const [
    Partner(
      id: 'mueller', name: 'Bäckerei Müller', category: 'Bakery', emoji: '🥐',
      color: Color(0xFFB8860B), distanceKm: 0.4, rating: 4.8, verified: true, sponsored: true,
      mapPos: Offset(0.58, 0.30),
      offers: [
        PartnerOffer('Frühstück 1+1 gratis', 'Zwei Frühstück bestellen, eins zahlen. Mo–Fr bis 11 Uhr.', OfferKind.bogo, '1+1', 300),
        PartnerOffer('20% auf alle Backwaren', 'Gilt auf das gesamte Sortiment, einmal pro Tag.', OfferKind.percent, '-20%', 200),
      ],
    ),
    Partner(
      id: 'davinci', name: 'Pizzeria da Vinci', category: 'Restaurant', emoji: '🍕',
      color: Color(0xFFC8102E), distanceKm: 0.9, rating: 4.5, verified: true, sponsored: true,
      mapPos: Offset(0.72, 0.62),
      offers: [
        PartnerOffer('Jede 2. Pizza gratis', 'Bei zwei Pizzen ist die günstigere gratis.', OfferKind.bogo, '1+1', 400),
        PartnerOffer('€5 Gutschein ab €25', 'Ab €25 Bestellwert, dine-in & Abholung.', OfferKind.fixed, '€5', 500),
      ],
    ),
    Partner(
      id: 'kaffeeklatsch', name: 'Café Kaffeeklatsch', category: 'Café', emoji: '☕',
      color: Color(0xFF6F4E37), distanceKm: 0.6, rating: 4.7, verified: true,
      mapPos: Offset(0.40, 0.44),
      offers: [
        PartnerOffer('1+1 Kaffee gratis', 'Zweiter Kaffee für dich oder einen Freund.', OfferKind.bogo, '1+1', 250),
        PartnerOffer('15% auf Kuchen', 'Auf die gesamte Kuchentheke.', OfferKind.percent, '-15%', 150),
      ],
    ),
    Partner(
      id: 'barber7', name: 'Barbershop Nr. 7', category: 'Barber', emoji: '✂️',
      color: Color(0xFF1D2939), distanceKm: 1.4, rating: 4.6,
      mapPos: Offset(0.20, 0.72),
      offers: [
        PartnerOffer('20% auf den Haarschnitt', 'Für Neukunden aus der Fan+ App.', OfferKind.percent, '-20%', 300),
      ],
    ),
    Partner(
      id: 'fitnord', name: 'Fitnessstudio Nord', category: 'Fitness', emoji: '🏋️',
      color: Color(0xFFEF6C00), distanceKm: 2.1, rating: 4.4,
      mapPos: Offset(0.30, 0.20),
      offers: [
        PartnerOffer('1 Monat gratis testen', 'Kostenloser Probemonat, keine Kündigung nötig.', OfferKind.fixed, 'Gratis', 600),
        PartnerOffer('25% auf die Jahreskarte', 'Einmalig beim Abschluss einlösbar.', OfferKind.percent, '-25%', 800),
        PartnerOffer('1+1 Tagespass', 'Bring einen Freund kostenlos mit.', OfferKind.bogo, '1+1', 200),
      ],
    ),
    Partner(
      id: 'burger', name: 'Glückauf Burger', category: 'Restaurant', emoji: '🍔',
      color: Color(0xFFB54708), distanceKm: 1.1, rating: 4.3,
      mapPos: Offset(0.62, 0.78),
      offers: [
        PartnerOffer('Menü für €7', 'Burger + Pommes + Getränk am Matchday.', OfferKind.fixed, '€7', 350),
      ],
    ),
    Partner(
      id: 'eiscafe', name: 'Eiscafé Venezia', category: 'Café', emoji: '🍨',
      color: Color(0xFF00838F), distanceKm: 0.8, rating: 4.9,
      mapPos: Offset(0.50, 0.58),
      offers: [
        PartnerOffer('1+1 Eisbecher', 'Zweiter Becher gratis, So & Feiertage.', OfferKind.bogo, '1+1', 200),
      ],
    ),
    Partner(
      id: 'bowling', name: 'Knappen Bowling', category: 'Leisure', emoji: '🎳',
      color: Color(0xFF5E35B1), distanceKm: 3.2, rating: 4.2,
      mapPos: Offset(0.82, 0.40),
      offers: [
        PartnerOffer('30% auf die Bahn', 'Pro Stunde, Mo–Do.', OfferKind.percent, '-30%', 400),
      ],
    ),
  ];

  List<Partner> get filtered {
    final list = category == 'All' ? [..._all] : _all.where((p) => p.category == category).toList();
    list.sort((a, b) {
      if (a.sponsored != b.sponsored) return a.sponsored ? -1 : 1; // Anzeige first
      return a.distanceKm.compareTo(b.distanceKm);
    });
    return list;
  }

  List<Partner> get all => filtered;
  List<Partner> get nearest {
    final l = [..._all]..sort((a, b) => a.distanceKm.compareTo(b.distanceKm));
    return l;
  }

  int get partnerCount => _all.length;
  int get offerCount => _all.fold(0, (s, p) => s + p.offers.length);

  void setCategory(String c) {
    if (category == c) return;
    category = c;
    notifyListeners();
  }

  bool isFavorite(Partner p) => favorites.contains(p.id);
  void toggleFavorite(Partner p) {
    favorites.contains(p.id) ? favorites.remove(p.id) : favorites.add(p.id);
    notifyListeners();
  }

  Partner byId(String id) => _all.firstWhere((p) => p.id == id);
}

final partnerStore = PartnerStore();
