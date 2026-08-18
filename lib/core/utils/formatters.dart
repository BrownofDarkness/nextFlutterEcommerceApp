import 'package:intl/intl.dart';

/// Locale-aware formatting helpers.
///
/// Backed by the `intl` package. French date & currency data must be loaded
/// once at app startup via `initializeDateFormatting('fr_FR', null)` — see
/// `main.dart`. Calling any DateFormat with `fr_FR` before initialization
/// throws `LocaleDataException`.
abstract final class Formatters {
  static const String _locale = 'fr_FR';

  /// Formats an amount as `"249,99 €"` (or `"1 249,99 €"` with thousand
  /// separator when applicable). Uses [NumberFormat.currency] so we get
  /// proper French conventions for free (comma decimal, non-breaking space
  /// before the euro symbol, thousand separator).
  static String euros(double amount) {
    return NumberFormat.currency(
      locale: _locale,
      symbol: '€',
      decimalDigits: 2,
    ).format(amount);
  }

  /// Formats a date as `"mars 2024"` — month name in French + year.
  /// Used by the "Membre depuis" chip on the profile page.
  static String monthYear(DateTime date) {
    return DateFormat.yMMMM(_locale).format(date);
  }

  /// Maps the raw category slug from the JSON to its French display label.
  ///
  /// Kept as a plain switch because categories are a closed enum shipped in
  /// the JSON — no i18n runtime lookup needed.
  static String categoryLabel(String category) {
    switch (category) {
      case 'electronics':
        return 'Électronique';
      case 'clothing':
        return 'Vêtements';
      case 'books':
        return 'Livres';
      case 'home':
        return 'Maison';
      default:
        if (category.isEmpty) return category;
        return category[0].toUpperCase() + category.substring(1);
    }
  }
}
