import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:next_shop/data/models/product.dart';
import 'package:next_shop/features/catalog/providers/product_providers.dart';
import 'package:next_shop/features/favorites/providers/favorites_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../helpers/product_fixtures.dart';

void main() {
  Future<(ProviderContainer, SharedPreferences)> makeContainer({
    Map<String, Object> initialPrefs = const {},
    List<Product>? productsOverride,
  }) async {
    SharedPreferences.setMockInitialValues(initialPrefs);
    final prefs = await SharedPreferences.getInstance();
    final container = ProviderContainer(
      overrides: [
        sharedPreferencesProvider.overrideWithValue(prefs),
        if (productsOverride != null)
          productsProvider.overrideWith((ref) async => productsOverride),
      ],
    );
    addTearDown(container.dispose);
    return (container, prefs);
  }

  group('FavoritesNotifier — initial load', () {
    test('is empty when SharedPreferences has no entry', () async {
      final (container, _) = await makeContainer();
      final favorites = await container.read(favoritesProvider.future);
      expect(favorites, isEmpty);
    });

    test('rehydrates the persisted set', () async {
      final (container, _) = await makeContainer(
        initialPrefs: {
          'favorites_product_ids': ['p001', 'p003'],
        },
      );
      final favorites = await container.read(favoritesProvider.future);
      expect(favorites, {'p001', 'p003'});
    });
  });

  group('FavoritesNotifier — toggle', () {
    test('adds an id when absent', () async {
      final (container, _) = await makeContainer();
      await container.read(favoritesProvider.future);
      await container.read(favoritesProvider.notifier).toggle('p001');

      expect(container.read(favoritesProvider).value, {'p001'});
    });

    test('removes an id when present', () async {
      final (container, _) = await makeContainer(
        initialPrefs: {
          'favorites_product_ids': ['p001'],
        },
      );
      await container.read(favoritesProvider.future);
      await container.read(favoritesProvider.notifier).toggle('p001');

      expect(container.read(favoritesProvider).value, isEmpty);
    });

    test('persists the new set to SharedPreferences', () async {
      final (container, prefs) = await makeContainer();
      await container.read(favoritesProvider.future);
      await container.read(favoritesProvider.notifier).toggle('p001');
      await container.read(favoritesProvider.notifier).toggle('p002');

      expect(prefs.getStringList('favorites_product_ids'),
          containsAll(['p001', 'p002']));
    });
  });

  group('isFavoriteProvider (derived family)', () {
    test('returns true only for ids in the set', () async {
      final (container, _) = await makeContainer(
        initialPrefs: {
          'favorites_product_ids': ['p001'],
        },
      );
      await container.read(favoritesProvider.future);

      expect(container.read(isFavoriteProvider('p001')), isTrue);
      expect(container.read(isFavoriteProvider('p999')), isFalse);
    });

    test('reflects toggles reactively', () async {
      final (container, _) = await makeContainer();
      await container.read(favoritesProvider.future);
      expect(container.read(isFavoriteProvider('p001')), isFalse);

      await container.read(favoritesProvider.notifier).toggle('p001');
      expect(container.read(isFavoriteProvider('p001')), isTrue);
    });
  });

  group('favoriteProductsProvider (async join)', () {
    test('joins persisted ids with the product catalog', () async {
      final (container, _) = await makeContainer(
        initialPrefs: {
          'favorites_product_ids': ['p001', 'p003'],
        },
        productsOverride: [
          testProduct('p001'),
          testProduct('p002'),
          testProduct('p003'),
        ],
      );
      // Ensure both async sources have resolved before reading the derived.
      await container.read(favoritesProvider.future);
      await container.read(productsProvider.future);

      final joined = container.read(favoriteProductsProvider).value!;
      expect(joined.map((p) => p.id), ['p001', 'p003']);
    });

    test('returns an empty list when no id is favorited', () async {
      final (container, _) = await makeContainer(
        productsOverride: [testProduct('p001'), testProduct('p002')],
      );
      await container.read(favoritesProvider.future);
      await container.read(productsProvider.future);

      expect(container.read(favoriteProductsProvider).value, isEmpty);
    });
  });
}
