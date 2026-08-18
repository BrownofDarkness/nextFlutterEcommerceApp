import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:next_shop/features/cart/providers/cart_provider.dart';

import '../helpers/product_fixtures.dart';

void main() {
  ProviderContainer makeContainer() {
    final container = ProviderContainer();
    addTearDown(container.dispose);
    return container;
  }

  group('CartNotifier — mutations', () {
    test('initial state is an empty list', () {
      final container = makeContainer();
      expect(container.read(cartProvider), isEmpty);
    });

    test('add() inserts a new item with default quantity 1', () {
      final container = makeContainer();
      container.read(cartProvider.notifier).add(testProduct('p001'));

      final items = container.read(cartProvider);
      expect(items, hasLength(1));
      expect(items.first.product.id, 'p001');
      expect(items.first.quantity, 1);
    });

    test('add() on an existing product increments its quantity', () {
      final container = makeContainer();
      final product = testProduct('p001');
      container.read(cartProvider.notifier)
        ..add(product)
        ..add(product);

      final items = container.read(cartProvider);
      expect(items, hasLength(1));
      expect(items.first.quantity, 2);
    });

    test('add() with quantity param adds the requested amount at once', () {
      final container = makeContainer();
      container.read(cartProvider.notifier).add(testProduct('p001'), quantity: 3);
      expect(container.read(cartProvider).first.quantity, 3);
    });

    test('remove() drops the item entirely without touching others', () {
      final container = makeContainer();
      container.read(cartProvider.notifier)
        ..add(testProduct('p001'))
        ..add(testProduct('p002'));

      container.read(cartProvider.notifier).remove('p001');

      final items = container.read(cartProvider);
      expect(items, hasLength(1));
      expect(items.first.product.id, 'p002');
    });

    test('setQuantity(0) removes the item', () {
      final container = makeContainer();
      container.read(cartProvider.notifier).add(testProduct('p001'));
      container.read(cartProvider.notifier).setQuantity('p001', 0);

      expect(container.read(cartProvider), isEmpty);
    });

    test('setQuantity(n) updates the existing quantity', () {
      final container = makeContainer();
      container.read(cartProvider.notifier).add(testProduct('p001'));
      container.read(cartProvider.notifier).setQuantity('p001', 5);

      expect(container.read(cartProvider).first.quantity, 5);
    });

    test('increment/decrement adjust the quantity by 1', () {
      final container = makeContainer();
      container.read(cartProvider.notifier).add(testProduct('p001'));
      container.read(cartProvider.notifier)
        ..increment('p001')
        ..increment('p001')
        ..decrement('p001');

      expect(container.read(cartProvider).first.quantity, 2);
    });

    test('clear() empties the whole cart', () {
      final container = makeContainer();
      container.read(cartProvider.notifier)
        ..add(testProduct('p001'))
        ..add(testProduct('p002'))
        ..clear();

      expect(container.read(cartProvider), isEmpty);
    });
  });

  group('CartNotifier — derived providers', () {
    test('cartTotalProvider sums the subtotals of every line', () {
      final container = makeContainer();
      container.read(cartProvider.notifier)
        ..add(testProduct('p001', price: 100.0), quantity: 2)
        ..add(testProduct('p002', price: 49.99));

      expect(container.read(cartTotalProvider), 249.99);
    });

    test('cartItemCountProvider sums the individual quantities', () {
      final container = makeContainer();
      container.read(cartProvider.notifier)
        ..add(testProduct('p001'), quantity: 3)
        ..add(testProduct('p002'), quantity: 2);

      expect(container.read(cartItemCountProvider), 5);
    });

    test('derived providers return 0 for an empty cart', () {
      final container = makeContainer();
      expect(container.read(cartTotalProvider), 0);
      expect(container.read(cartItemCountProvider), 0);
    });
  });
}
