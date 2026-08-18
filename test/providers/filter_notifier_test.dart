import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:next_shop/data/models/product.dart';
import 'package:next_shop/data/models/product_filter.dart';
import 'package:next_shop/features/catalog/providers/filter_provider.dart';
import 'package:next_shop/features/catalog/providers/product_providers.dart';

import '../helpers/product_fixtures.dart';

void main() {
  ProviderContainer makeContainer({List<Product>? products}) {
    final container = ProviderContainer(
      overrides: [
        if (products != null)
          productsProvider.overrideWith((ref) async => products),
      ],
    );
    addTearDown(container.dispose);
    return container;
  }

  group('FilterNotifier — state mutations', () {
    test('initial state has no filter and sorts by name ascending', () {
      final container = makeContainer();
      final filter = container.read(filterProvider);
      expect(filter.category, isNull);
      expect(filter.sort, SortOption.nameAsc);
      expect(filter.searchQuery, isEmpty);
    });

    test('setCategory("electronics") updates the category', () {
      final container = makeContainer();
      container.read(filterProvider.notifier).setCategory('electronics');
      expect(container.read(filterProvider).category, 'electronics');
    });

    test('setCategory(null) resets the category to "all"', () {
      final container = makeContainer();
      container.read(filterProvider.notifier).setCategory('electronics');
      container.read(filterProvider.notifier).setCategory(null);
      expect(container.read(filterProvider).category, isNull);
    });

    test('setSort and setSearch update independently', () {
      final container = makeContainer();
      container.read(filterProvider.notifier)
        ..setSort(SortOption.priceDesc)
        ..setSearch('casque');

      final filter = container.read(filterProvider);
      expect(filter.sort, SortOption.priceDesc);
      expect(filter.searchQuery, 'casque');
      expect(filter.category, isNull);
    });

    test('reset() returns to the default filter', () {
      final container = makeContainer();
      container.read(filterProvider.notifier)
        ..setCategory('books')
        ..setSort(SortOption.priceAsc)
        ..setSearch('foo')
        ..reset();

      final filter = container.read(filterProvider);
      expect(filter.category, isNull);
      expect(filter.sort, SortOption.nameAsc);
      expect(filter.searchQuery, isEmpty);
    });
  });

  group('filteredProductsProvider — derived from filter × products', () {
    test('filters by category', () async {
      final container = makeContainer(products: [
        testProduct('p001', category: 'electronics'),
        testProduct('p002', category: 'books'),
        testProduct('p003', category: 'electronics'),
      ]);
      await container.read(productsProvider.future);
      container.read(filterProvider.notifier).setCategory('electronics');

      final result = container.read(filteredProductsProvider).value!;
      expect(result.map((p) => p.id), containsAll(['p001', 'p003']));
      expect(result, hasLength(2));
    });

    test('filters by search query in name or description', () async {
      final container = makeContainer(products: [
        testProduct('p001', name: 'Casque audio sans fil'),
        testProduct('p002', name: 'Montre connectée'),
      ]);
      await container.read(productsProvider.future);
      container.read(filterProvider.notifier).setSearch('casque');

      final result = container.read(filteredProductsProvider).value!;
      expect(result.map((p) => p.id), ['p001']);
    });

    test('sorts by price ascending', () async {
      final container = makeContainer(products: [
        testProduct('p001', price: 300),
        testProduct('p002', price: 100),
        testProduct('p003', price: 200),
      ]);
      await container.read(productsProvider.future);
      container.read(filterProvider.notifier).setSort(SortOption.priceAsc);

      final result = container.read(filteredProductsProvider).value!;
      expect(result.map((p) => p.price), [100, 200, 300]);
    });

    test('sorts by rating descending', () async {
      final container = makeContainer(products: [
        testProduct('p001', rating: 3.0),
        testProduct('p002', rating: 4.5),
        testProduct('p003', rating: 4.0),
      ]);
      await container.read(productsProvider.future);
      container.read(filterProvider.notifier).setSort(SortOption.ratingDesc);

      final result = container.read(filteredProductsProvider).value!;
      expect(result.map((p) => p.rating), [4.5, 4.0, 3.0]);
    });

    test('combines category + search + sort', () async {
      final container = makeContainer(products: [
        testProduct('p001', category: 'books', name: 'Roman', price: 20),
        testProduct('p002', category: 'books', name: 'Guide Flutter', price: 40),
        testProduct('p003', category: 'electronics', name: 'Guide radio', price: 30),
      ]);
      await container.read(productsProvider.future);
      container.read(filterProvider.notifier)
        ..setCategory('books')
        ..setSearch('guide')
        ..setSort(SortOption.priceDesc);

      final result = container.read(filteredProductsProvider).value!;
      expect(result.map((p) => p.id), ['p002']);
    });
  });
}
