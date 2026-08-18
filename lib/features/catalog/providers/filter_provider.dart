import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../data/models/product.dart';
import '../../../data/models/product_filter.dart';
import 'product_providers.dart';

/// Notifier holding the current filter state (category, sort, search).
///
/// Sync `Notifier` because the initial state is trivially available (a default
/// `ProductFilter()`); no async work needed.
class FilterNotifier extends Notifier<ProductFilter> {
  @override
  ProductFilter build() => const ProductFilter();

  void setCategory(String? category) {
    if (category == null) {
      state = state.copyWith(resetCategory: true);
    } else {
      state = state.copyWith(category: category);
    }
  }

  void setSort(SortOption sort) {
    state = state.copyWith(sort: sort);
  }

  void setSearch(String query) {
    state = state.copyWith(searchQuery: query);
  }

  void reset() => state = const ProductFilter();
}

final filterProvider = NotifierProvider<FilterNotifier, ProductFilter>(
  FilterNotifier.new,
);

/// Derived provider that combines the raw product list with the filter state.
///
/// Returns `AsyncValue<List<Product>>` because [productsProvider] is async —
/// we forward the loading/error states via `whenData`, so the UI keeps a
/// single `.when()` code path regardless of whether the filtering is applied.
///
/// No local state, no fetch — it just recomputes when either dependency
/// changes. This is the "composition superpower" of Riverpod.
final filteredProductsProvider = Provider<AsyncValue<List<Product>>>((ref) {
  final productsAsync = ref.watch(productsProvider);
  final filter = ref.watch(filterProvider);

  return productsAsync.whenData((products) {
    Iterable<Product> result = products;

    if (filter.category != null) {
      result = result.where((p) => p.category == filter.category);
    }

    if (filter.searchQuery.isNotEmpty) {
      final q = filter.searchQuery.toLowerCase();
      result = result.where((p) =>
          p.name.toLowerCase().contains(q) ||
          p.description.toLowerCase().contains(q));
    }

    final list = result.toList();
    switch (filter.sort) {
      case SortOption.nameAsc:
        list.sort((a, b) => a.name.compareTo(b.name));
      case SortOption.priceAsc:
        list.sort((a, b) => a.price.compareTo(b.price));
      case SortOption.priceDesc:
        list.sort((a, b) => b.price.compareTo(a.price));
      case SortOption.ratingDesc:
        list.sort((a, b) => b.rating.compareTo(a.rating));
    }
    return list;
  });
});

/// Derived: unique list of categories present in the catalog.
///
/// Computed from the product list so adding a new category in the JSON is
/// enough — the filter UI updates automatically, no code change.
final categoriesProvider = Provider<AsyncValue<List<String>>>((ref) {
  final productsAsync = ref.watch(productsProvider);
  return productsAsync.whenData((products) {
    final set = <String>{for (final p in products) p.category};
    return set.toList()..sort();
  });
});
