import 'package:shared_preferences/shared_preferences.dart';

/// Thin wrapper around [SharedPreferences] for the favorites set.
///
/// The instance is injected (not fetched globally) so tests can pass a
/// `SharedPreferences.setMockInitialValues({})` instance without touching
/// production code.
class FavoritesStorage {
  const FavoritesStorage(this._prefs);

  final SharedPreferences _prefs;

  static const _key = 'favorites_product_ids';

  Set<String> load() {
    final list = _prefs.getStringList(_key) ?? const <String>[];
    return list.toSet();
  }

  Future<void> save(Set<String> ids) async {
    await _prefs.setStringList(_key, ids.toList(growable: false));
  }
}
