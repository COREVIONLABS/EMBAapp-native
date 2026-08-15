import 'package:flutter/material.dart';
import 'fan_model.dart';

/// A live points auction — bid Fan Points on money-can't-buy items and
/// experiences (Socios-style, but in the club's own points currency, no crypto).
///
/// Points economy stays honest: placing a bid *commits* points (debits your
/// balance). Your commitment is tracked as [myMaxBid]; raising your own leading
/// bid only tops up the difference. If a rival outbids you, your committed
/// points are refunded (see [AuctionStore.simulateRivalBid]) — so you never lose
/// points you didn't win with.
class Auction {
  final String id;
  final String title;
  final String item; // short item descriptor line
  final String? sponsor; // co-branded auction ("powered by")
  final String category;
  final IconData glyph;
  final Color color;
  final String? image; // assets/images/<image>.png
  final int startBid;
  final int minIncrement;
  final String endsInLabel;
  final DateTime? endsAt; // live end time for a ticking countdown (null if ended)
  final bool ended;

  int currentBid;
  int bidCount;
  bool leadingByMe; // you currently hold the top bid
  int myMaxBid; // points you've committed (0 once refunded after an outbid)
  bool outbid; // you bid before, someone tops you now
  bool won; // ended auction you won

  Auction({
    required this.id,
    required this.title,
    required this.item,
    required this.category,
    required this.glyph,
    required this.color,
    required this.startBid,
    required this.endsInLabel,
    Duration? endsIn,
    this.sponsor,
    this.image,
    this.minIncrement = 500,
    this.ended = false,
    int? currentBid,
    this.bidCount = 0,
    this.leadingByMe = false,
    this.myMaxBid = 0,
    this.outbid = false,
    this.won = false,
  })  : currentBid = currentBid ?? startBid,
        endsAt = endsIn == null ? null : DateTime.now().add(endsIn);

  /// The smallest valid next bid.
  int get nextMinBid => currentBid + minIncrement;

  /// Has the fan ever bid on this lot (leading now or outbid earlier)?
  bool get hasBid => leadingByMe || outbid || won;
}

/// In-memory auction house (prototype state). Shared app-wide so the Gewinnen
/// hub, the auctions list and the detail screen all read one live truth.
class AuctionStore extends ChangeNotifier {
  final List<Auction> auctions = [
    Auction(
      id: 'jersey',
      title: 'Signed home jersey 25/26',
      item: 'Match-issued, signed by the full squad',
      sponsor: 'Veltins',
      category: 'Memorabilia',
      glyph: Icons.checkroom_rounded,
      color: const Color(0xFF004B9C),
      image: 'product_home_jersey',
      startBid: 6000,
      minIncrement: 500,
      currentBid: 8500,
      bidCount: 23,
      endsInLabel: 'Ends in 2d 4h',
      endsIn: const Duration(days: 2, hours: 4),
    ),
    Auction(
      id: 'vip',
      title: 'VIP matchday for two',
      item: 'Business seats + players’ tunnel walk vs Dortmund',
      category: 'Experience',
      glyph: Icons.stadium_rounded,
      color: const Color(0xFF6A1B9A),
      image: 'img_experiences',
      startBid: 12000,
      minIncrement: 1000,
      currentBid: 24000,
      bidCount: 51,
      endsInLabel: 'Ends in 6h 12m',
      endsIn: const Duration(hours: 6, minutes: 12),
      // Premium, hotly-contested lot led by other fans (a stretch goal).
    ),
    Auction(
      id: 'boots',
      title: 'Match-worn derby boots',
      item: 'Worn & signed — with certificate',
      sponsor: 'adidas',
      category: 'Memorabilia',
      glyph: Icons.sports_soccer_rounded,
      color: const Color(0xFF111111),
      startBid: 4000,
      minIncrement: 500,
      currentBid: 6000,
      bidCount: 14,
      endsInLabel: 'Ends in 1d 9h',
      endsIn: const Duration(days: 1, hours: 9),
      // You bid earlier and got outbid — shows the "Outbid" state.
      outbid: true,
    ),
    Auction(
      id: 'dinner',
      title: 'Legends dinner — one seat',
      item: 'Dine with S04 legends at the VIP lounge',
      category: 'Experience',
      glyph: Icons.restaurant_rounded,
      color: const Color(0xFF0A2A5E),
      startBid: 3000,
      minIncrement: 1000,
      currentBid: 5000,
      bidCount: 33,
      endsInLabel: 'Ends in 3d 1h',
      endsIn: const Duration(days: 3, hours: 1),
      // You currently lead this lot — shows the "You’re winning" state and a
      // believable refund when the presenter demos being outbid.
      leadingByMe: true,
      myMaxBid: 5000,
    ),
    Auction(
      id: 'ball',
      title: 'Signed matchball',
      item: 'From the derby win — whole team signed',
      sponsor: 'Veltins',
      category: 'Memorabilia',
      glyph: Icons.sports_volleyball_rounded,
      color: const Color(0xFF00623A),
      startBid: 4000,
      minIncrement: 500,
      currentBid: 7000,
      bidCount: 19,
      endsInLabel: 'Won — last month',
      ended: true,
      won: true,
      leadingByMe: true,
      myMaxBid: 7000,
    ),
  ];

  List<Auction> get live => auctions.where((a) => !a.ended).toList();
  List<Auction> get past => auctions.where((a) => a.ended).toList();
  int get leadingCount => auctions.where((a) => a.leadingByMe && !a.ended).length;

  Auction byId(String id) => auctions.firstWhere((a) => a.id == id);

  /// Place a bid of [amount] points. Commits the *net* new points (tops up your
  /// own leading bid, or the full amount to take the lead). Returns false if the
  /// bid is too low or your balance can’t cover the commitment.
  bool placeBid(Auction a, int amount) {
    if (a.ended) return false;
    if (amount < a.nextMinBid) return false;
    final commit = a.leadingByMe ? (amount - a.myMaxBid) : amount;
    if (commit <= 0 || !FanModel.spendPoints(commit)) return false;
    a.currentBid = amount;
    a.myMaxBid = amount;
    a.leadingByMe = true;
    a.outbid = false;
    a.bidCount += 1;
    notifyListeners();
    return true;
  }

  /// Demo hook: a rival tops your leading bid. Refunds your committed points
  /// (honest: you only ever spend what you win with) and flips you to "outbid".
  void simulateRivalBid(Auction a) {
    if (a.ended || !a.leadingByMe) return;
    FanModel.addPoints(a.myMaxBid); // refund
    a.currentBid = a.currentBid + a.minIncrement;
    a.myMaxBid = 0;
    a.leadingByMe = false;
    a.outbid = true;
    a.bidCount += 1;
    notifyListeners();
  }
}

final auctionStore = AuctionStore();
