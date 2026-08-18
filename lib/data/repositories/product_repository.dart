import '../models/product.dart';
import '../sources/product_local_source.dart';

/// Business-facing API for products.
///
/// Widgets and providers depend on [ProductRepository], never on the source.
/// This lets us swap the JSON asset for a real HTTP API later without touching
/// anything upstream.
class ProductRepository {
  const ProductRepository(this._source);

  final ProductLocalSource _source;

  Future<List<Product>> getAll() => _source.loadAll();

  Future<Product> getById(String id) async {
    final all = await _source.loadAll();
    for (final p in all) {
      if (p.id == id) return p;
    }
    throw ProductNotFoundException(id);
  }
}

/// Thrown when [ProductRepository.getById] cannot find a product.
///
/// Custom exception (not a raw `Exception`) so the UI can pattern-match on the
/// type and show a specific message.
class ProductNotFoundException implements Exception {
  const ProductNotFoundException(this.id);

  final String id;

  @override
  String toString() => 'Product with id "$id" not found';
}
