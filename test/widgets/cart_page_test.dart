import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:next_shop/features/cart/pages/cart_page.dart';
import 'package:next_shop/features/cart/providers/cart_provider.dart';
import 'package:next_shop/shared/widgets/empty_view.dart';

import '../helpers/product_fixtures.dart';
import '../helpers/test_wrapper.dart';

void main() {
  group('CartPage — état vide', () {
    testWidgets('affiche le titre "Panier"', (tester) async {
      await tester.pumpWidget(testWrapper(const CartPage()));
      await tester.pump();

      expect(find.text('Panier'), findsWidgets);
    });

    testWidgets('affiche "Aucun article" dans le sous-titre', (tester) async {
      await tester.pumpWidget(testWrapper(const CartPage()));
      await tester.pump();

      expect(find.text('Aucun article'), findsOneWidget);
    });

    testWidgets('affiche le message vide localisé', (tester) async {
      await tester.pumpWidget(testWrapper(const CartPage()));
      await tester.pump();

      expect(find.text('Votre panier est vide'), findsOneWidget);
    });

    testWidgets('affiche EmptyView avec un CTA vers le catalogue',
        (tester) async {
      await tester.pumpWidget(testWrapper(const CartPage()));
      await tester.pump();

      expect(find.byType(EmptyView), findsOneWidget);
      expect(find.text('Découvrir le catalogue'), findsOneWidget);
    });
  });

  group('CartPage — état rempli', () {
    testWidgets('affiche "1 article" et masque EmptyView', (tester) async {
      await tester.pumpWidget(testWrapper(const CartPage()));
      await tester.pump();

      // Accède au ProviderContainer via le contexte du widget monté
      final ctx = tester.element(find.byType(CartPage));
      ProviderScope.containerOf(ctx)
          .read(cartProvider.notifier)
          .add(testProduct('p001'));
      await tester.pump();

      expect(find.text('1 article'), findsOneWidget);
      expect(find.byType(EmptyView), findsNothing);
    });

    testWidgets('affiche le bon compte quand plusieurs produits',
        (tester) async {
      await tester.pumpWidget(testWrapper(const CartPage()));
      await tester.pump();

      final ctx = tester.element(find.byType(CartPage));
      final notifier =
          ProviderScope.containerOf(ctx).read(cartProvider.notifier);
      notifier.add(testProduct('p001'), quantity: 2);
      notifier.add(testProduct('p002'), quantity: 3);
      await tester.pump();

      expect(find.text('5 articles'), findsOneWidget);
    });
  });
}
