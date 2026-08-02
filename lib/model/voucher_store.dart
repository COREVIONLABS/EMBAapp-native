import 'package:flutter/foundation.dart';

/// A voucher the fan has redeemed points for. The app never sells the product,
/// ticket or seat itself — it only issues this code, which is then redeemed in
/// the club's real Fanshop / ticket shop / at the counter. Keeps the backend
/// simple: one voucher-out, one redeem-confirmation, no payments or inventory.
class IssuedVoucher {
  final String title;
  final String category; // Fanshop / Tickets / Sponsor / Food & Drink …
  final String? sponsor;
  final int points; // points spent to get it
  final String code;
  final String date; // issued-on label, e.g. "2 Aug 2026"
  final String? detail; // e.g. size, match — shown under the title
  bool redeemed;
  IssuedVoucher({
    required this.title,
    required this.category,
    required this.points,
    required this.code,
    required this.date,
    this.sponsor,
    this.detail,
    this.redeemed = false,
  });
}

/// In-memory store of issued vouchers, shared across the app (prototype state).
class VoucherStore extends ChangeNotifier {
  final List<IssuedVoucher> vouchers = [];
  int _seq = 4815;

  IssuedVoucher issue({
    required String title,
    required String category,
    required int points,
    String? sponsor,
    String? detail,
  }) {
    _seq = (_seq * 33 + 7) % 100000;
    final v = IssuedVoucher(
      title: title,
      category: category,
      points: points,
      sponsor: sponsor,
      detail: detail,
      code: _code(category, _seq),
      date: _today(),
    );
    vouchers.insert(0, v);
    notifyListeners();
    return v;
  }

  void markRedeemed(IssuedVoucher v) {
    if (!v.redeemed) {
      v.redeemed = true;
      notifyListeners();
    }
  }

  int get openCount => vouchers.where((v) => !v.redeemed).length;

  static const _letters = 'ABCDEFGHJKLMNPQRSTUVWXYZ';
  static String _code(String category, int seq) {
    final base = category.replaceAll(RegExp('[^A-Za-z]'), '');
    final tag = (base.length >= 3 ? base.substring(0, 3) : base.padRight(3, 'X')).toUpperCase();
    final a = _letters[seq % _letters.length];
    final b = _letters[(seq ~/ 7) % _letters.length];
    final n = (seq % 9000) + 1000;
    return 'S04-$tag-$a$b$n';
  }

  static const _months = ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'];
  static String _today() {
    final t = DateTime.now();
    return '${t.day} ${_months[t.month - 1]} ${t.year}';
  }
}

final voucherStore = VoucherStore();
