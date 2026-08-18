import 'package:next_shop/data/models/product.dart';

/// Test-only [Product] factory. All fields have sensible defaults so each test
/// only overrides what it cares about. Keeps the assertion signal-to-noise
/// ratio high.
Product testProduct(
  String id, {
  String? name,
  double price = 100.0,
  String category = 'electronics',
  double rating = 4.0,
}) {
  return Product(
    id: id,
    name: name ?? 'Test $id',
    description: 'Description for $id',
    price: price,
    imageUrl: 'https://example.com/$id.png',
    category: category,
    rating: rating,
  );
}
