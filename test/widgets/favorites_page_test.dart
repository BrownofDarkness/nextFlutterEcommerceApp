import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:next_shop/features/catalog/providers/product_providers.dart';
import 'package:next_shop/features/favorites/pages/favorites_page.dart';
import 'package:next_shop/features/favorites/providers/favorites_provider.dart';
import 'package:next_shop/shared/widgets/empty_view.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../helpers/product_fixtures.dart';
import '../helpers/test_wrapper.dart';

void main() {
  group('FavoritesPage', () {
    testWidgets('affiche le titre "Favoris"', (tester) async {
      SharedPreferences.setMockInitialValues({});
      final prefs = await SharedPreferences.getInstance();

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            sharedPreferencesProvider.overrideWithValue(prefs),
            productsProvider.overrideWith((ref) async => []),
          ],
          child: testMaterialApp(const FavoritesPage()),
        ),
      );
      await tester.pump();
      await tester.pump();

      expect(find.text('Favoris'), findsOneWidget);
    });

    testWidgets('affiche EmptyView quand aucun favori', (tester) async {
      SharedPreferences.setMockInitialValues({});
      final prefs = await SharedPreferences.getInstance();

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            sharedPreferencesProvider.overrideWithValue(prefs),
            productsProvider.overrideWith((ref) async => []),
          ],
          child: testMaterialApp(const FavoritesPage()),
        ),
      );

      await tester.pump();
      await tester.pump(const Duration(milliseconds: 50));

      expect(find.byType(EmptyView), findsOneWidget);
      expect(find.text('Aucun favori pour le moment'), findsOneWidget);
    });

    testWidgets('affiche les ProductCard quand des favoris existent',
        (tester) async {
      SharedPreferences.setMockInitialValues({
        'favorites_product_ids': ['p001', 'p002'],
      });
      final prefs = await SharedPreferences.getInstance();
      final products = [
        testProduct('p001', name: 'Casque'),
        testProduct('p002', name: 'Montre'),
      ];

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            sharedPreferencesProvider.overrideWithValue(prefs),
            productsProvider.overrideWith((ref) async => products),
          ],
          child: testMaterialApp(const FavoritesPage()),
        ),
      );

      await tester.pump();
      await tester.pump(const Duration(milliseconds: 50));

      expect(find.text('Casque'), findsOneWidget);
      expect(find.text('Montre'), findsOneWidget);
    });
  });
}
