import 'package:flutter/material.dart';

/// Single source of truth for the unified Fan Points + Loyalty model
/// (Figma "Loyalty Tiers" / Home — Complete). Used everywhere so the numbers
/// and tier are consistent across the whole app.
class FanTier {
  final String name;
  final int minPoints;
  const FanTier(this.name, this.minPoints);
}

class FanModel {
  static const int fanPoints = 4820;
  static const int raffleTickets = 3;

  /// Points earned in the *current season only* — the metric behind the
  /// "Road to Gold" season journey. Kept separate from [fanPoints] (the
  /// lifetime balance) and from the lifetime loyalty levels, so the season
  /// journey and the loyalty ladder are clearly two different things.
  static const int seasonPoints = 2140;

  // Schalke-culture loyalty ladder (ascending).
  static const tiers = [
    FanTier('Nordkurve', 0),
    FanTier('Knappenschmiede', 1000),
    FanTier('Schalker', 3000),
    FanTier('Ehrenmitglied', 15000),
    FanTier('Legende', 25000),
  ];

  static const String currentTier = 'Schalker';
  static const int nextTierPoints = 15000; // Ehrenmitglied

  static String get pointsFormatted => _fmt(fanPoints);
  static String get nextTierFormatted => _fmt(nextTierPoints);
  static double get tierProgress => fanPoints / nextTierPoints;

  static String fmtPublic(int n) => _fmt(n);

  // ── Transparent points economy: 100 points = €1 (1 point = 1 cent) ──
  /// Euro value of a points amount, e.g. euroValue(12450) → "€124.50".
  static String euroValue(int points) {
    final euros = points / 100;
    final s = euros.toStringAsFixed(2);
    return '€$s';
  }

  static String get balanceEuro => euroValue(fanPoints);

  // Subscription tiers (final concept: Free Fan / Fan Member / Super Fan).
  static const String membershipTier = 'Super Fan';

  /// Current member's monthly perks, tied to the core loop.
  static MembershipPerks get perks => perksFor(membershipTier);

  static String _fmt(int n) {
    final s = n.toString();
    final b = StringBuffer();
    for (var i = 0; i < s.length; i++) {
      if (i > 0 && (s.length - i) % 3 == 0) b.write(',');
      b.write(s[i]);
    }
    return b.toString();
  }

  /// Product catalogue for the Fanshop (Figma 2162:6193).
  static const products = [
    FanProduct('Home Jersey 25/26', 89.99, 4500, 'Jerseys', Color(0xFF0A2A5E), imageKey: 'product_home_jersey'),
    FanProduct('Away Jersey 25/26', 89.99, 4500, 'Jerseys', Color(0xFFEDEFF3), imageKey: 'product_away_jersey'),
    FanProduct('Windbreaker', 24.99, 1200, 'Jackets', Color(0xFF0A2A5E), imageKey: 'product_windbreaker'),
    FanProduct('Kapuzen-Jacke', 49.99, 2800, 'Jackets', Color(0xFFEDEFF3), imageKey: 'product_kapuzenjacke'),
    FanProduct('Home Scarf 25/26', 19.99, 900, 'Scarves', Color(0xFF0A2A5E)),
    FanProduct('Cap Royal Blue', 22.99, 1100, 'Accessories', Color(0xFF002F63)),
  ];
}

/// Membership value tied to the core loop: free tombola lots + monthly bonus
/// points, scaling by subscription tier. This is the concrete "why upgrade".
class MembershipPerks {
  final int freeLots;      // free tombola lots per month
  final int monthlyPoints; // bonus points credited to your balance monthly
  const MembershipPerks(this.freeLots, this.monthlyPoints);
}

const Map<String, MembershipPerks> kMembershipPerks = {
  'Free Fan': MembershipPerks(0, 0),
  'Fan Member': MembershipPerks(3, 500),
  'Super Fan': MembershipPerks(8, 1200),
  'Ultra': MembershipPerks(20, 3000),
};

MembershipPerks perksFor(String tier) => kMembershipPerks[tier] ?? const MembershipPerks(0, 0);

/// Live-selected membership tier (prototype state). Set when a fan "becomes" a
/// tier on the Membership screen; the Home membership chip and the Fan+ hub
/// listen to it so the choice is reflected instantly across the app.
final ValueNotifier<String> tierNotifier = ValueNotifier<String>(FanModel.membershipTier);

/// Demo/preview switches (moved out of the app headers into Profile → Demo).
/// Let a presenter show both states without a control living in the shipping UI.
final ValueNotifier<bool> matchdayNotifier = ValueNotifier<bool>(true);
final ValueNotifier<bool> memberPreviewNotifier = ValueNotifier<bool>(true);

/// Home: show the dismissible "How Fan+ works" explainer. Once a fan confirms
/// dismissal it hides (it still lives permanently on the Points tab).
final ValueNotifier<bool> howToNotifier = ValueNotifier<bool>(true);

/// Onboarding: show the first-run "starter tasks" activation card on Home.
/// ON by default so a new fan is guided into the core loop; a returning fan
/// (or a presenter) can switch it off to see the clean Home.
final ValueNotifier<bool> starterNotifier = ValueNotifier<bool>(true);

/// Phase-2 feature flag: the co-branded "Fan+ Pay" card programme. OFF by
/// default so the shipping app tells the current, focused loyalty story; a
/// presenter can flip it on (Profile → Demo) to show the roadmap state where
/// fans hold a Fan+ Pay card and earn cashback at partners.
final ValueNotifier<bool> cardActiveNotifier = ValueNotifier<bool>(false);

/// A Fan+ Pay partner: where the card earns real-money cashback, with a
/// playful, on-brand line (Club Brugge "Club Pay" style). Real S04 partners.
class PayPartner {
  final String name;
  final IconData icon;
  final Color color;
  final String cashback; // e.g. "5%"
  final String tagline; // playful German line
  const PayPartner(this.name, this.icon, this.color, this.cashback, this.tagline);
}

const kPayPartners = [
  PayPartner('Veltins', Icons.sports_bar_rounded, Color(0xFF00623A), '5%', 'Aufs Bier nach dem Sieg.'),
  PayPartner('REWE', Icons.shopping_cart_rounded, Color(0xFFC8102E), '3%', 'Der Wocheneinkauf zahlt sich aus.'),
  PayPartner('adidas', Icons.sports_soccer_rounded, Color(0xFF111111), '5%', 'Neues Trikot, echtes Geld zurück.'),
  PayPartner('Vivawest', Icons.apartment_rounded, Color(0xFF6A1B9A), '2.5%', 'Sogar die Miete bringt was.'),
  PayPartner("Ernsting's family", Icons.checkroom_rounded, Color(0xFFE30613), '4%', 'Für die ganze Knappen-Familie.'),
  PayPartner('VELTINS-Arena', Icons.stadium_rounded, Color(0xFF004B9C), '10%', 'Am Spieltag am meisten zurück.'),
];

class FanProduct {
  final String name;
  final double price;
  final int points;
  final String category;
  final Color color;
  final String? imageKey;
  const FanProduct(this.name, this.price, this.points, this.category, this.color, {this.imageKey});
  String get priceEur => '€${price.toStringAsFixed(2)}';
  String get pointsLabel => '${FanModel._fmt(points)} pts';
}


class FanExperience {
  final String title;
  final String date;
  final String venue;
  final int points;
  final String category;
  final bool featured;
  final bool raffle;
  const FanExperience(this.title, this.date, this.venue, this.points, this.category, {this.featured = false, this.raffle = false});
  String get pointsLabel => raffle ? '${FanModel.fmtPublic(points)} pts entry' : '${FanModel.fmtPublic(points)} pts';
}

/// Club sponsor with a *symbolic* category icon (no real logos bundled) so a
/// fan can tell at a glance what the partner is about.
class Sponsor {
  final String name;
  final IconData icon; // category symbol
  final Color color;
  final String perk;
  const Sponsor(this.name, this.icon, this.color, this.perk);
}

const kSponsors = [
  Sponsor('Veltins', Icons.sports_bar_rounded, Color(0xFF00623A), '2× pts'), // beverages
  Sponsor('Vivawest', Icons.apartment_rounded, Color(0xFF6A1B9A), '10% off'), // housing
  Sponsor('adidas', Icons.sports_soccer_rounded, Color(0xFF111111), '5% back'), // sportswear
  Sponsor("Ernsting's", Icons.checkroom_rounded, Color(0xFFE30613), '€5 voucher'), // fashion
  Sponsor('REWE', Icons.shopping_cart_rounded, Color(0xFFC8102E), '3× pts'), // groceries
];

Sponsor? sponsorByName(String name) {
  for (final s in kSponsors) {
    if (s.name == name) return s;
  }
  return null;
}

const kExperiences = [
  FanExperience('Stadium Tour VIP', 'Apr 15, 2026', 'VELTINS-Arena', 2500, 'Stadium', featured: true),
  FanExperience('Player Meet & Greet', 'Apr 22', 'Fan Zone', 5000, 'Players'),
  FanExperience('Train with the Pros', 'Apr 26', 'Berger Feld', 8000, 'Players'),
  FanExperience('Fans vs Pros Match', 'May 1', 'VELTINS-Arena', 12000, 'VIP'),
  FanExperience('On the Team Photo', 'May 6', 'VELTINS-Arena', 15000, 'VIP'),
  FanExperience('Training Session Visit', 'Apr 28', 'Berger Feld', 3000, 'Players'),
  FanExperience('Museum Tour', 'May 3', 'VELTINS-Arena', 1000, 'Stadium'),
  FanExperience('Youth Academy Day', 'May 10', 'Knappenschmiede', 2000, 'Family'),
  FanExperience('Legends Dinner', 'May 18', 'VIP Lounge', 10000, 'VIP'),
  // Ticket & prize draws now live in their own Tombola hub (raffles_screen.dart).
];
