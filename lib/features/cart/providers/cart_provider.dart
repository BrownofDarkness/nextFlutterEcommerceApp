import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../data/models/cart_item.dart';
import '../../../data/models/product.dart';

/// Cart notifier — pure in-memory state (no persistence for this scope).
///
/// Uses `Notifier<List<CartItem>>` (not `AsyncNotifier`) because the starting
/// state is trivially `[]` — no async work required. All mutations produce a
/// **new list** (never `state.add(...)`) so Riverpod's `==` check detects the
/// change and notifies listeners.
class CartNotifier extends Notifier<List<CartItem>> {
  @override
  List<CartItem> build() => const [];

  /// Adds a product. If already in cart, increments its quantity by [quantity]
  /// (default 1). Otherwise inserts a new line with the requested quantity.
  void add(Product product, {int quantity = 1}) {
    assert(quantity > 0, 'quantity must be positive');
    final idx = state.indexWhere((i) => i.product.id == product.id);
    if (idx >= 0) {
      state = [
        for (int i = 0; i < state.length; i++)
          if (i == idx)
            state[i].copyWith(quantity: state[i].quantity + quantity)
          else
            state[i],
      ];
    } else {
      state = [...state, CartItem(product: product, quantity: quantity)];
    }
  }

  void remove(String productId) {
    state = state.where((i) => i.product.id != productId).toList();
  }

  void setQuantity(String productId, int quantity) {
    if (quantity <= 0) {
      remove(productId);
      return;
    }
    state = [
      for (final item in state)
        if (item.product.id == productId)
          item.copyWith(quantity: quantity)
        else
          item,
    ];
  }

  void increment(String productId) {
    final item = state.firstWhere((i) => i.product.id == productId);
    setQuantity(productId, item.quantity + 1);
  }

  void decrement(String productId) {
    final item = state.firstWhere((i) => i.product.id == productId);
    setQuantity(productId, item.quantity - 1);
  }

  void clear() => state = const [];
}

final cartProvider = NotifierProvider<CartNotifier, List<CartItem>>(
  CartNotifier.new,
);

/// Derived: total price of the cart. Zero local state.
final cartTotalProvider = Provider<double>((ref) {
  final items = ref.watch(cartProvider);
  return items.fold(0.0, (sum, item) => sum + item.subtotal);
});

/// Derived: total item count (sum of quantities). Used by the badge on the
/// cart icon in the bottom navigation.
final cartItemCountProvider = Provider<int>((ref) {
  final items = ref.watch(cartProvider);
  return items.fold(0, (sum, item) => sum + item.quantity);
});
