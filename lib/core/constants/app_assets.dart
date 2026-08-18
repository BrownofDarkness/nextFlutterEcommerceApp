/// Centralized asset paths.
///
/// All files under `assets/` (declared in `pubspec.yaml`) must be referenced
/// here — never hard-code a path elsewhere in the codebase. If a file moves,
/// only this class changes.
abstract final class AppAssets {
  static const String _base = 'assets';

  // JSON data sources
  static const String productsJson = '$_base/products.json';
}
