import 'package:flutter/foundation.dart';
import 'fan_model.dart';

class CartItem {
  final FanProduct product;
  final String size;
  int qty;
  CartItem(this.product, this.size, [this.qty = 1]);
}

/// Simple in-memory cart shared across the Fanshop flow.
class CartStore extends ChangeNotifier {
  final List<CartItem> items = [];

  void add(FanProduct p, String size) {
    final existing = items.where((i) => i.product.name == p.name && i.size == size);
    if (existing.isNotEmpty) {
      existing.first.qty++;
    } else {
      items.add(CartItem(p, size));
    }
    notifyListeners();
  }

  void changeQty(CartItem item, int delta) {
    item.qty += delta;
    if (item.qty <= 0) items.remove(item);
    notifyListeners();
  }

  void clear() {
    items.clear();
    notifyListeners();
  }

  int get count => items.fold(0, (s, i) => s + i.qty);
  double get subtotal => items.fold(0.0, (s, i) => s + i.product.price * i.qty);
  int get earnPoints => (subtotal * 5).round();
}

final cartStore = CartStore();
