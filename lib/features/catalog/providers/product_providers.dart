import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../data/models/product.dart';
import '../../../data/repositories/product_repository.dart';
import '../../../data/sources/product_local_source.dart';

/// Injects the repository. Wired to the local JSON source by default; a test
/// can override this provider to substitute a fake repository.
final productRepositoryProvider = Provider<ProductRepository>((ref) {
  return const ProductRepository(ProductLocalSource());
});

/// Loads the full product list from the repository.
///
/// A `FutureProvider` exposes the result as an `AsyncValue`, so the UI can
/// `.when(data / loading / error)` without ever writing a `FutureBuilder`.
final productsProvider = FutureProvider<List<Product>>((ref) async {
  final repo = ref.watch(productRepositoryProvider);
  return repo.getAll();
});

/// Loads a single product by id.
///
/// `.family` turns a provider into a factory: `productByIdProvider('p001')` is
/// a different provider instance from `productByIdProvider('p002')`, each with
/// its own cached state. Perfect for detail pages.
final productByIdProvider =
    FutureProvider.family<Product, String>((ref, id) async {
  final repo = ref.watch(productRepositoryProvider);
  return repo.getById(id);
});
