import 'package:equatable/equatable.dart';

/// Sort options for the product catalog.
///
/// Each enum value carries its own display label — enums with fields keep
/// presentation data close to the domain and avoid switch statements in the UI.
enum SortOption {
  nameAsc('Nom (A→Z)'),
  priceAsc('Prix croissant'),
  priceDesc('Prix décroissant'),
  ratingDesc('Mieux notés');

  const SortOption(this.label);
  final String label;
}

/// Immutable filter state for the catalog.
///
/// `category == null` means "toutes catégories". To reset the category via
/// [copyWith], pass `resetCategory: true` — a common Dart pattern to
/// distinguish "leave unchanged" from "set to null".
class ProductFilter extends Equatable {
  const ProductFilter({
    this.category,
    this.sort = SortOption.nameAsc,
    this.searchQuery = '',
  });

  final String? category;
  final SortOption sort;
  final String searchQuery;

  ProductFilter copyWith({
    String? category,
    bool resetCategory = false,
    SortOption? sort,
    String? searchQuery,
  }) {
    return ProductFilter(
      category: resetCategory ? null : (category ?? this.category),
      sort: sort ?? this.sort,
      searchQuery: searchQuery ?? this.searchQuery,
    );
  }

  @override
  List<Object?> get props => [category, sort, searchQuery];
}
