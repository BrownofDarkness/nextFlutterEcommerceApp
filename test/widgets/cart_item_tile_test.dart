import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:next_shop/data/models/cart_item.dart';
import 'package:next_shop/features/cart/widgets/cart_item_tile.dart';

import '../helpers/product_fixtures.dart';
import '../helpers/test_wrapper.dart';

void main() {
  group('CartItemTile', () {
    testWidgets('affiche le nom du produit', (tester) async {
      final item = CartItem(
        product: testProduct('p001', name: 'Montre connectée'),
        quantity: 1,
      );

      await tester.pumpWidget(
        testWrapper(Scaffold(body: CartItemTile(item: item))),
      );
      await tester.pump();

      expect(find.text('Montre connectée'), findsOneWidget);
    });

    testWidgets('affiche le sous-total du produit', (tester) async {
      final item = CartItem(
        product: testProduct('p001', price: 100.0),
        quantity: 3,
      );

      await tester.pumpWidget(
        testWrapper(Scaffold(body: CartItemTile(item: item))),
      );
      await tester.pump();

      // subtotal = 300 €
      expect(find.textContaining('300'), findsOneWidget);
    });

    testWidgets('le bouton décrément est désactivé quand quantité = 1',
        (tester) async {
      final item = CartItem(
        product: testProduct('p001'),
        quantity: 1,
      );

      await tester.pumpWidget(
        testWrapper(Scaffold(body: CartItemTile(item: item))),
      );
      await tester.pump();

      // onDecrement=null → InkWell de l'icône remove_rounded sans callback
      final removeInkWell = tester
          .widgetList<InkWell>(find.ancestor(
            of: find.byIcon(Icons.remove_rounded),
            matching: find.byType(InkWell),
          ))
          .first;
      expect(removeInkWell.onTap, isNull);
    });

    testWidgets('le bouton incrément est toujours actif', (tester) async {
      final item = CartItem(
        product: testProduct('p001'),
        quantity: 1,
      );

      await tester.pumpWidget(
        testWrapper(Scaffold(body: CartItemTile(item: item))),
      );
      await tester.pump();

      final addInkWell = tester
          .widgetList<InkWell>(find.ancestor(
            of: find.byIcon(Icons.add_rounded),
            matching: find.byType(InkWell),
          ))
          .first;
      expect(addInkWell.onTap, isNotNull);
    });
  });
}
