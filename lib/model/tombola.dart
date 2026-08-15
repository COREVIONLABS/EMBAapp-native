import 'package:flutter/material.dart';
import '../l10n/strings.dart';
import 'fan_model.dart';

/// Localised current month name — used to label the monthly draw everywhere
/// ("August Monatsverlosung" / "August monthly raffle").
String raffleMonthName() {
  const en = ['January', 'February', 'March', 'April', 'May', 'June', 'July', 'August', 'September', 'October', 'November', 'December'];
  const de = ['Januar', 'Februar', 'März', 'April', 'Mai', 'Juni', 'Juli', 'August', 'September', 'Oktober', 'November', 'Dezember'];
  final m = localeNotifier.value == AppLocale.de ? de : en;
  return m[DateTime.now().month - 1];
}

/// One prize inside a raffle. A single draw can hold many prizes, each with a
/// [quantity] — so one monthly draw has many prizes AND many winners.
class RafflePrize {
  final String title; // English key (localised via tr)
  final IconData glyph;
  final Color color;
  final int quantity;
  const RafflePrize(this.title, this.glyph, this.color, this.quantity);
}

/// A raffle: the recurring monthly draw, or an occasional special. The model is
/// deliberately API-ready — swap the prize list each month, add specials as
/// needed. There is no "enter" action: your lots auto-participate.
class Raffle {
  final String id;
  final String title; // e.g. "Monthly raffle" (month is prefixed in the UI)
  final bool isSpecial;
  final Duration drawIn;
  final List<RafflePrize> prizes;
  final List<Color> gradient;
  final IconData heroGlyph;
  const Raffle({
    required this.id,
    required this.title,
    required this.drawIn,
    required this.prizes,
    required this.gradient,
    required this.heroGlyph,
    this.isSpecial = false,
  });

  /// Total number of prizes = total winners (sum of every prize's quantity).
  int get totalPrizes => prizes.fold(0, (s, p) => s + p.quantity);
}

/// The recurring monthly draw — one big draw with many prizes & winners.
const kMonthlyRaffle = Raffle(
  id: 'monthly',
  title: 'Monthly raffle',
  drawIn: Duration(days: 3, hours: 6, minutes: 12),
  gradient: [Color(0xFF0A2A5E), Color(0xFF000D22)],
  heroGlyph: Icons.emoji_events_rounded,
  prizes: [
    RafflePrize('2× VIP tickets vs Dortmund', Icons.confirmation_number_rounded, Color(0xFF0A2A5E), 2),
    RafflePrize('Signed home shirt 25/26', Icons.checkroom_rounded, Color(0xFFB54708), 5),
    RafflePrize('S04 fan box', Icons.card_giftcard_rounded, Color(0xFF6A1B9A), 10),
    RafflePrize('€25 Fanshop voucher', Icons.storefront_rounded, Color(0xFF00695C), 20),
    RafflePrize('Meet & greet with a player', Icons.groups_rounded, Color(0xFFC62828), 5),
  ],
);

/// Occasional special draws (empty ⇒ only the monthly draw is shown).
const kSpecialRaffles = <Raffle>[
  Raffle(
    id: 'ucl_final',
    title: 'Champions League final',
    isSpecial: true,
    drawIn: Duration(days: 26, hours: 4),
    gradient: [Color(0xFF4A148C), Color(0xFF12005E)],
    heroGlyph: Icons.stadium_rounded,
    prizes: [
      RafflePrize('2× tickets to the final incl. travel', Icons.flight_takeoff_rounded, Color(0xFF4A148C), 1),
    ],
  ),
];

/// A buy-more-lots pack: extra lots for points (more lots ⇒ higher chance).
class LotPack {
  final int lots;
  final int points;
  const LotPack(this.lots, this.points);
}

const kLotPacks = <LotPack>[
  LotPack(1, 500),
  LotPack(5, 2500),
  LotPack(10, 5000),
];

/// Single app-start instant so every countdown ticks smoothly (instead of
/// resetting each build) and all screens agree on the draw time.
final DateTime _tombolaEpoch = DateTime.now();
DateTime raffleDrawEnd(Raffle r) => _tombolaEpoch.add(r.drawIn);

/// Shared lot state — extra lots bought per raffle id. Free lots come from
/// membership and auto-enter every draw; extra lots are bought with points.
class RaffleStore extends ChangeNotifier {
  final Map<String, int> _extra = {};
  int extraFor(String id) => _extra[id] ?? 0;
  void addLots(String id, int n) {
    _extra[id] = extraFor(id) + n;
    notifyListeners();
  }
}

final raffleStore = RaffleStore();

/// Free lots from the membership tier — these auto-participate.
int raffleFreeLots() => FanModel.perks.freeLots;

/// Your lots in a given draw = free (membership) + extra (bought).
int raffleMyLots(String id) => raffleFreeLots() + raffleStore.extraFor(id);
