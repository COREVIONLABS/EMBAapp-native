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
  static const int fanPoints = 12450;
  static const int raffleTickets = 12;

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
    FanProduct('Home Jersey 25/26', 89.99, 4500, 'Jerseys', Color(0xFF0A2A5E)),
    FanProduct('Away Jersey 25/26', 89.99, 4500, 'Jerseys', Color(0xFFEDEFF3)),
    FanProduct('Windbreaker', 24.99, 1200, 'Jackets', Color(0xFF0A2A5E)),
    FanProduct('Kapuzen-Jacke', 49.99, 2800, 'Jackets', Color(0xFFEDEFF3)),
    FanProduct('Home Scarf 25/26', 19.99, 900, 'Scarves', Color(0xFF0A2A5E)),
    FanProduct('Cap Royal Blue', 22.99, 1100, 'Accessories', Color(0xFF002F63)),
  ];
}

class FanProduct {
  final String name;
  final double price;
  final int points;
  final String category;
  final Color color;
  const FanProduct(this.name, this.price, this.points, this.category, this.color);
  String get priceEur => '€${price.toStringAsFixed(2)}';
  String get pointsLabel => '${FanModel._fmt(points)} pts';
}
