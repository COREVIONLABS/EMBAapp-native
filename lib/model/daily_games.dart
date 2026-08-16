import 'dart:math' as math;
import 'package:flutter/material.dart';

/// Tracks the once-a-day games (spin / scratch) and the fan's streak so the app
/// has a real "come back tomorrow" hook. Session-scoped in this prototype (no
/// persistence) — enough to demo the daily mechanic and streak.
class DailyGamesStore extends ChangeNotifier {
  bool spinDone = false;
  bool scratchDone = false;
  int streakDays = 5;

  void playSpin() {
    if (spinDone) return;
    spinDone = true;
    notifyListeners();
  }

  void playScratch() {
    if (scratchDone) return;
    scratchDone = true;
    notifyListeners();
  }
}

final dailyGames = DailyGamesStore();

// ── Sponsored daily games ────────────────────────────────────────────────
// The spin & scratch are sellable ad inventory: a "presented by <sponsor>"
// banner runs on every card (labelled "Anzeige"), and some prizes are branded
// sponsor rewards. Prizes are always one of: points, a ticket, or a sponsor
// reward — kept honest and easy to swap per campaign.

/// The presenting sponsor of the daily games (the banner ad slot).
class GameSponsor {
  final String name;
  final IconData icon;
  final Color color;
  const GameSponsor(this.name, this.icon, this.color);
}

const kDailyGamesSponsor = GameSponsor('Veltins', Icons.sports_bar_rounded, Color(0xFF00623A));

enum DailyPrizeType { points, ticket, sponsor }

/// One prize on the wheel / under the scratch card.
class DailyPrize {
  final DailyPrizeType type;
  final int points; // for points prizes
  final String label; // full label ("McDonald's Menü", "50 Punkte")
  final String short; // short label for the wheel segment
  final String? sponsor; // sponsor brand for sponsor prizes
  final IconData icon;
  final Color color;
  const DailyPrize(this.type, {this.points = 0, required this.label, required this.short, this.sponsor, required this.icon, required this.color});
}

// Spin wheel — 8 fixed segments (order matters: the pointer lands on the rolled
// index). Mostly points, with a rare ticket and two sponsor rewards.
const kSpinPrizes = <DailyPrize>[
  DailyPrize(DailyPrizeType.points, points: 20, label: '20 Punkte', short: '20', icon: Icons.hexagon_rounded, color: Color(0xFF004B9C)),
  DailyPrize(DailyPrizeType.sponsor, label: 'McDonald’s Menü', short: 'McD', sponsor: 'McDonald’s', icon: Icons.lunch_dining_rounded, color: Color(0xFFDA291C)),
  DailyPrize(DailyPrizeType.points, points: 50, label: '50 Punkte', short: '50', icon: Icons.hexagon_rounded, color: Color(0xFFE08600)),
  DailyPrize(DailyPrizeType.points, points: 30, label: '30 Punkte', short: '30', icon: Icons.hexagon_rounded, color: Color(0xFF004B9C)),
  DailyPrize(DailyPrizeType.ticket, label: 'Ticket-Gutschein', short: 'Ticket', icon: Icons.confirmation_number_rounded, color: Color(0xFF0A2A5E)),
  DailyPrize(DailyPrizeType.points, points: 100, label: '100 Punkte', short: '100', icon: Icons.hexagon_rounded, color: Color(0xFFE08600)),
  DailyPrize(DailyPrizeType.sponsor, label: 'Veltins Kiste', short: 'Veltins', sponsor: 'Veltins', icon: Icons.sports_bar_rounded, color: Color(0xFF00623A)),
  DailyPrize(DailyPrizeType.points, points: 25, label: '25 Punkte', short: '25', icon: Icons.hexagon_rounded, color: Color(0xFF004B9C)),
];
const kSpinWeights = <int>[24, 4, 12, 20, 3, 6, 5, 26]; // sums to 100

// Scratch card — same prize universe, weighted to small points.
const kScratchPrizes = <DailyPrize>[
  DailyPrize(DailyPrizeType.points, points: 20, label: '20 Punkte', short: '20', icon: Icons.hexagon_rounded, color: Color(0xFF004B9C)),
  DailyPrize(DailyPrizeType.points, points: 30, label: '30 Punkte', short: '30', icon: Icons.hexagon_rounded, color: Color(0xFF004B9C)),
  DailyPrize(DailyPrizeType.points, points: 50, label: '50 Punkte', short: '50', icon: Icons.hexagon_rounded, color: Color(0xFFE08600)),
  DailyPrize(DailyPrizeType.points, points: 100, label: '100 Punkte', short: '100', icon: Icons.hexagon_rounded, color: Color(0xFFE08600)),
  DailyPrize(DailyPrizeType.sponsor, label: 'McDonald’s Menü', short: 'McD', sponsor: 'McDonald’s', icon: Icons.lunch_dining_rounded, color: Color(0xFFDA291C)),
  DailyPrize(DailyPrizeType.ticket, label: 'Ticket-Gutschein', short: 'Ticket', icon: Icons.confirmation_number_rounded, color: Color(0xFF0A2A5E)),
];
const kScratchWeights = <int>[30, 24, 16, 8, 12, 10]; // sums to 100

/// Weighted roll → index into a prize list.
int rollPrizeIndex(List<int> weights) {
  var r = math.Random().nextInt(weights.fold(0, (a, b) => a + b));
  for (var i = 0; i < weights.length; i++) {
    if (r < weights[i]) return i;
    r -= weights[i];
  }
  return 0;
}
