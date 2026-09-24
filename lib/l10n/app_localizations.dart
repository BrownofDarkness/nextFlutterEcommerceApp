import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

class AppLocalizations {
  const AppLocalizations(this.locale);

  final Locale locale;

  static AppLocalizations of(BuildContext context) =>
      Localizations.of<AppLocalizations>(context, AppLocalizations)!;

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  bool get _fr => locale.languageCode == 'fr';

  // ── Bottom nav ──────────────────────────────────────────────────────────────
  String get tabCatalog => _fr ? 'Catalogue' : 'Catalog';
  String get tabCart => _fr ? 'Panier' : 'Cart';
  String get tabFavorites => _fr ? 'Favoris' : 'Favorites';
  String get tabProfile => _fr ? 'Profil' : 'Profile';

  // ── Cart ────────────────────────────────────────────────────────────────────
  String get cartTitle => _fr ? 'Panier' : 'Cart';
  String get cartNoItems => _fr ? 'Aucun article' : 'No items';
  String get cartOneItem => _fr ? '1 article' : '1 item';
  String cartItems(int count) => _fr ? '$count articles' : '$count items';
  String get cartEmpty => _fr ? 'Votre panier est vide' : 'Your cart is empty';
  String get cartEmptySubtitle => _fr
      ? 'Découvrez notre catalogue et ajoutez vos premiers produits.'
      : 'Browse our catalog and add your first products.';
  String get discoverCatalog =>
      _fr ? 'Découvrir le catalogue' : 'Discover catalog';

  // ── Favorites ────────────────────────────────────────────────────────────────
  String get favoritesTitle => _fr ? 'Favoris' : 'Favorites';
  String get favoritesEmpty =>
      _fr ? 'Aucun favori pour le moment' : 'No favorites yet';
  String get favoritesEmptySubtitle => _fr
      ? 'Ajoutez des produits à vos favoris depuis le catalogue.'
      : 'Add products to your favorites from the catalog.';
  String get favoritesLoading => _fr ? 'Chargement…' : 'Loading…';
  String savedProducts(int? count) {
    if (count == null) return favoritesLoading;
    if (count == 0) return _fr ? 'Aucun produit sauvegardé' : 'No saved products';
    if (count == 1) return _fr ? '1 produit sauvegardé' : '1 saved product';
    return _fr ? '$count produits sauvegardés' : '$count saved products';
  }

  // ── Common ───────────────────────────────────────────────────────────────────
  String get retry => _fr ? 'Réessayer' : 'Retry';
  String get remove => _fr ? 'Retirer' : 'Remove';
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  bool isSupported(Locale locale) =>
      ['fr', 'en'].contains(locale.languageCode);

  @override
  Future<AppLocalizations> load(Locale locale) =>
      SynchronousFuture(AppLocalizations(locale));

  @override
  bool shouldReload(covariant LocalizationsDelegate<AppLocalizations> old) =>
      false;
}
