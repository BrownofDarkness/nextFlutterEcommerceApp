# Changelog

Toutes les modifications notables de ce projet sont documentées dans ce fichier.
Format basé sur [Keep a Changelog](https://keepachangelog.com/fr/1.0.0/).

---

## [1.2.0] — 2026-09-24

### Ajouté
- **Internationalisation (FR/EN)** — infrastructure `AppLocalizations` avec ARB files ; locale FR forcée par défaut, EN disponible.
- **Tests de widgets** (×13) — `EmptyView`, `CartPage`, `ProductCard`, `CartItemTile`, `FavoritesPage` couverts.
- **Tests d'intégration** (×2) — démarrage de l'app et navigation vers l'onglet Panier.
- **CI/CD GitHub Actions** — pipeline en deux jobs : `Analyze & Test` (lint + tests) puis `Build APK`.
- **CHANGELOG** — ce fichier.

### Modifié
- `MainScaffold` : labels des onglets de navigation passés par `AppLocalizations`.
- `CartPage` : titre, sous-titre de l'en-tête et état vide localisés.
- `FavoritesPage` : titre, compteur et état vide localisés ; suppression de `_countLabel` remplacé par `l10n.savedProducts`.

---

## [1.1.0] — 2026-08-25

### Ajouté
- **Tests unitaires** (×30) — `CartNotifier`, `FavoritesNotifier`, `FilterNotifier` + providers dérivés (`cartTotalProvider`, `filteredProductsProvider`, `isFavoriteProvider`).
- **Skeleton shimmer** maison (sans dépendance externe) via `ShaderMask` + `AnimationController.repeat()`.
- **Pull-to-refresh** via `ref.invalidate(productsProvider)` sur la page Catalogue.
- **SnackBar réactif** via `ref.listen(cartItemCountProvider)` sur la page Détail produit.
- **Swipe-to-delete** (`Dismissible`) sur les lignes du Panier.
- `CHANGELOG.md` — ce fichier.

### Modifié
- `FavoritesNotifier` : toggle optimiste (state mis à jour avant l'écriture disque).
- `ProductCard` : utilise `isFavoriteProvider.family` pour éviter les rebuilds inutiles en grille.

---

## [1.0.0] — 2026-08-18

### Ajouté
- **Application initiale** next_shop — e-commerce Flutter / Riverpod.
- 5 écrans : Catalogue, Détail produit, Panier, Favoris, Profil.
- 14 providers Riverpod couvrant tous les types : `Provider`, `Provider.family`, `FutureProvider`, `FutureProvider.family`, `NotifierProvider`, `AsyncNotifierProvider`.
- Architecture **feature-first** (`catalog / cart / favorites / profile`) + couche `data/` isolée.
- Navigation déclarative `go_router` avec `StatefulShellRoute.indexedStack` (état de chaque onglet préservé).
- Persistance des favoris via `SharedPreferences` + pattern bootstrap synchrone.
- JSON local (`assets/products.json` — 12 produits, 4 catégories).
- Thème **Studio Noir** dark premium (Material 3, accent violet `#7C5CFF`, hairline borders).
- Filtrage full-text + tri (4 options) + filtrage par catégorie.
