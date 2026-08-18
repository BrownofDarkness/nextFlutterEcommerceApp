import 'package:equatable/equatable.dart';

import 'product.dart';

/// A line in the shopping cart.
///
/// Immutable — updates go through [copyWith]. The [subtotal] getter is derived,
/// which means a widget watching a cart item automatically gets the right total
/// without any manual sync.
class CartItem extends Equatable {
  const CartItem({required this.product, required this.quantity});

  final Product product;
  final int quantity;

  double get subtotal => product.price * quantity;

  CartItem copyWith({Product? product, int? quantity}) {
    return CartItem(
      product: product ?? this.product,
      quantity: quantity ?? this.quantity,
    );
  }

  @override
  List<Object?> get props => [product, quantity];
}
