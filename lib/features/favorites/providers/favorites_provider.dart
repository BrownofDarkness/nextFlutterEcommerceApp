import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../data/models/product.dart';
import '../../../data/sources/favorites_storage.dart';
import '../../catalog/providers/product_providers.dart';

/// Placeholder for the [SharedPreferences] instance. MUST be overridden in the
/// root `ProviderScope` via `overrideWithValue(prefs)` after `getInstance()`
/// resolves in `main()`.
///
/// This pattern lets every downstream provider access prefs **synchronously**,
/// avoiding the pain of chaining `.future` everywhere.
final sharedPreferencesProvider = Provider<SharedPreferences>((ref) {
  throw UnimplementedError(
    'sharedPreferencesProvider must be overridden in the root ProviderScope',
  );
});

/// Wraps prefs into our typed storage. Trivial `Provider` — no async work.
final favoritesStorageProvider = Provider<FavoritesStorage>((ref) {
  return FavoritesStorage(ref.watch(sharedPreferencesProvider));
});

/// Favorites notifier: initial state loaded async from storage, then kept in
/// memory. Every mutation writes back to disk.
///
/// `AsyncNotifier<Set<String>>` because [build] is async (reads from
/// SharedPreferences). The UI observes `AsyncValue<Set<String>>` and treats
/// the first load like any other async data (`.when(...)`).
class FavoritesNotifier extends AsyncNotifier<Set<String>> {
  @override
  Future<Set<String>> build() async {
    final storage = ref.watch(favoritesStorageProvider);
    return storage.load();
  }

  /// Toggles the favorite state and persists to disk.
  ///
  /// Optimistic update: state is set first (UI reacts instantly), then the
  /// write happens. If the write fails we could roll back; here we keep it
  /// simple and let the exception propagate.
  Future<void> toggle(String productId) async {
    final current = state.value ?? const <String>{};
    final updated = <String>{...current};
    if (updated.contains(productId)) {
      updated.remove(productId);
    } else {
      updated.add(productId);
    }

    state = AsyncData(updated);

    final storage = ref.read(favoritesStorageProvider);
    await storage.save(updated);
  }
}

final favoritesProvider =
    AsyncNotifierProvider<FavoritesNotifier, Set<String>>(
  FavoritesNotifier.new,
);

/// Derived family: is this specific product currently favorited?
///
/// Using `.family` here means widgets showing a heart icon can watch just
/// their own product's boolean, not the full favorites set → they won't
/// rebuild when *another* product is favorited.
final isFavoriteProvider = Provider.family<bool, String>((ref, productId) {
  final favoritesAsync = ref.watch(favoritesProvider);
  return favoritesAsync.value?.contains(productId) ?? false;
});

/// Joins the favorites set (IDs) with the full catalog (Product objects).
///
/// Combining two async sources by hand:
/// - if EITHER has errored → surface the error;
/// - if EITHER is still loading → we stay loading;
/// - only when BOTH are `data` do we compute the filtered product list.
///
/// This provider is what the Favorites page watches — a single `AsyncValue`
/// with a clean `.when()` at the widget level, no nested pattern matching.
final favoriteProductsProvider =
    Provider<AsyncValue<List<Product>>>((ref) {
  final favoritesAsync = ref.watch(favoritesProvider);
  final productsAsync = ref.watch(productsProvider);

  if (favoritesAsync.hasError) {
    return AsyncValue<List<Product>>.error(
      favoritesAsync.error!,
      favoritesAsync.stackTrace ?? StackTrace.empty,
    );
  }
  if (productsAsync.hasError) {
    return AsyncValue<List<Product>>.error(
      productsAsync.error!,
      productsAsync.stackTrace ?? StackTrace.empty,
    );
  }

  final ids = favoritesAsync.value;
  final all = productsAsync.value;
  if (ids == null || all == null) {
    return const AsyncValue<List<Product>>.loading();
  }

  return AsyncValue<List<Product>>.data(
    all.where((p) => ids.contains(p.id)).toList(),
  );
});
