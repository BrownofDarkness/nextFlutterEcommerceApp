import 'package:equatable/equatable.dart';

/// Immutable product model.
///
/// Uses [Equatable] so two products with the same field values are considered
/// equal. This matters for Riverpod: the framework calls `oldState == newState`
/// before notifying listeners, so proper equality prevents useless rebuilds.
class Product extends Equatable {
  const Product({
    required this.id,
    required this.name,
    required this.description,
    required this.price,
    required this.imageUrl,
    required this.category,
    required this.rating,
  });

  final String id;
  final String name;
  final String description;
  final double price;
  final String imageUrl;
  final String category;
  final double rating;

  factory Product.fromJson(Map<String, dynamic> json) {
    return Product(
      id: json['id'] as String,
      name: json['name'] as String,
      description: json['description'] as String,
      price: (json['price'] as num).toDouble(),
      imageUrl: json['imageUrl'] as String,
      category: json['category'] as String,
      rating: (json['rating'] as num).toDouble(),
    );
  }

  @override
  List<Object?> get props =>
      [id, name, description, price, imageUrl, category, rating];
}
