import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:next_shop/features/catalog/widgets/product_card.dart';
import 'package:next_shop/features/favorites/providers/favorites_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../helpers/product_fixtures.dart';
import '../helpers/test_wrapper.dart';

void main() {
  group('ProductCard', () {
    Future<SharedPreferences> makePrefs({bool isFavorite = false}) async {
      SharedPreferences.setMockInitialValues(
        isFavorite ? {'favorites_product_ids': ['p001']} : {},
      );
      return SharedPreferences.getInstance();
    }

    // ProductCard utilise AspectRatio(1:1) pour l'image : avec un écran large
    // (800px), la colonne interne overflow. On réduit la surface à 320×800 pour
    // que l'image fasse 320×320 et la carte totale ~440px < 800px.
    Future<void> setSurface(WidgetTester tester) async {
      await tester.binding.setSurfaceSize(const Size(320, 800));
      addTearDown(() async => tester.binding.setSurfaceSize(null));
    }

    testWidgets('affiche le nom du produit', (tester) async {
      await setSurface(tester);
      final prefs = await makePrefs();
      final product = testProduct('p001', name: 'Casque Pro');

      await tester.pumpWidget(
        ProviderScope(
          overrides: [sharedPreferencesProvider.overrideWithValue(prefs)],
          child: testMaterialApp(ProductCard(product: product)),
        ),
      );
      await tester.pump();

      expect(find.text('Casque Pro'), findsOneWidget);
    });

    testWidgets('affiche le prix formaté', (tester) async {
      await setSurface(tester);
      final prefs = await makePrefs();
      final product = testProduct('p001', price: 249.99);

      await tester.pumpWidget(
        ProviderScope(
          overrides: [sharedPreferencesProvider.overrideWithValue(prefs)],
          child: testMaterialApp(ProductCard(product: product)),
        ),
      );
      await tester.pump();

      expect(find.textContaining('249'), findsOneWidget);
    });

    testWidgets('affiche un cœur vide quand non favori', (tester) async {
      await setSurface(tester);
      final prefs = await makePrefs(isFavorite: false);
      final product = testProduct('p001');

      await tester.pumpWidget(
        ProviderScope(
          overrides: [sharedPreferencesProvider.overrideWithValue(prefs)],
          child: testMaterialApp(ProductCard(product: product)),
        ),
      );
      await tester.pump();

      expect(find.byIcon(Icons.favorite_border), findsOneWidget);
    });

    testWidgets('affiche un cœur plein quand favori', (tester) async {
      await setSurface(tester);
      final prefs = await makePrefs(isFavorite: true);
      final product = testProduct('p001');

      await tester.pumpWidget(
        ProviderScope(
          overrides: [sharedPreferencesProvider.overrideWithValue(prefs)],
          child: testMaterialApp(ProductCard(product: product)),
        ),
      );
      // Deux passes : frame initial + résolution de l'AsyncNotifier
      await tester.pump();
      await tester.pump();

      expect(find.byIcon(Icons.favorite), findsOneWidget);
    });
  });
}
