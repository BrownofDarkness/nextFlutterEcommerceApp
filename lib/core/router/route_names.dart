/// Centralized route paths. Never hard-code a route string elsewhere —
/// reference `RouteNames.xxx` instead so refactors touch a single file.
abstract final class RouteNames {
  // Bottom navigation branches (each is the initial location of its shell branch).
  static const String catalog = '/catalog';
  static const String cart = '/cart';
  static const String favorites = '/favorites';
  static const String profile = '/profile';

  // Product detail is nested BOTH under `/catalog` and `/favorites` so a
  // card push stays within the currently active shell branch (no unwanted
  // tab switch when opening a product from the favorites tab).
  static String productDetail(String id) => '/catalog/product/$id';
  static String favoritesProductDetail(String id) => '/favorites/product/$id';

  /// Shared nested path fragment (no leading slash → relative to parent).
  static const String productDetailSubPath = 'product/:id';
}
