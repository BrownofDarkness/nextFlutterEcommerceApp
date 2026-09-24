# next_shop

Application e-commerce Flutter développée pour la **certification nextFlutter — Riverpod**.
Valide la maîtrise de la gestion d'état Riverpod à travers une application réelle : catalogue, panier, favoris persistés, filtrage/tri, profil utilisateur.

---

## Aperçu

| Catalogue | Détail produit | Panier |
|---|---|---|
| ![Catalogue](docs/screenshots/01_catalog.png) | ![Détail](docs/screenshots/02_product_detail.png) | ![Panier](docs/screenshots/03_cart.png) |

| Panier vide | Favoris | Profil |
|---|---|---|
| ![Panier vide](docs/screenshots/04_cart_empty.png) | ![Favoris](docs/screenshots/05_favorites.png) | ![Profil](docs/screenshots/06_profile.png) |

Direction artistique **Studio Noir** — dark premium éditorial, hairline borders, accent violet `#7C5CFF`.

---

## Stack technique

| Package | Version | Rôle |
|---|---|---|
| `flutter_riverpod` | `^3.4.2` | State management (Notifier / AsyncNotifier / FutureProvider) |
| `go_router` | `^17.5.0` | Navigation déclarative avec `StatefulShellRoute.indexedStack` |
| `shared_preferences` | `^2.5.5` | Persistance locale des favoris |
| `intl` | `^0.20.2` | Formatage devise + dates (FR et EN) |
| `equatable` | `^2.1.0` | Égalité par valeur (critique pour Riverpod) |
| `cached_network_image` | `^3.4.1` | Cache disque + lazy loading des images réseau |

Style Riverpod : **manuel classique** (Notifier / AsyncNotifier — les remplaçants modernes des `StateNotifier` dépréciés). Pas de code generation.

---

## Architecture

Structure **feature-first** avec séparation stricte des couches :

```
lib/
├── main.dart                            Bootstrap (SharedPreferences + intl fr_FR + ProviderScope)
│
├── core/                                Utilitaires transverses
│   ├── constants/app_assets.dart        Chemins d'assets centralisés
│   ├── router/                          go_router + RouteNames
│   ├── theme/app_theme.dart             Tokens Studio Noir
│   └── utils/formatters.dart            Formatters.euros / monthYear / categoryLabel
│
├── data/                                Couche données
│   ├── models/                          Product, CartItem, UserProfile, ProductFilter
│   ├── sources/                         ProductLocalSource (JSON), FavoritesStorage (prefs)
│   └── repositories/                    ProductRepository (façade métier)
│
├── features/                            Une feature = un dossier autonome
│   ├── catalog/
│   │   ├── providers/                   product_providers, filter_provider
│   │   ├── widgets/                     ProductCard, CategoryChips, SearchField, SortBottomSheet…
│   │   └── pages/                       CatalogPage, ProductDetailPage
│   ├── cart/
│   │   ├── providers/cart_provider.dart
│   │   ├── widgets/                     CartItemTile, CartSummary
│   │   └── pages/cart_page.dart
│   ├── favorites/
│   │   ├── providers/favorites_provider.dart
│   │   └── pages/favorites_page.dart
│   └── profile/
│       ├── providers/user_provider.dart
│       └── pages/profile_page.dart
│
└── shared/widgets/                      Widgets réutilisables (LoadingView, Skeleton, ErrorView…)

assets/
└── products.json                        12 produits sur 4 catégories

test/
├── helpers/product_fixtures.dart
├── providers/                           30 tests unitaires providers
└── widget_test.dart                     Smoke test
```

### Principe de séparation

- **`data/`** ne connaît pas Riverpod. Modèles + I/O purs et testables sans framework.
- **`features/**/providers/`** est la seule couche qui dépend de Riverpod.
- **`features/**/pages/` + `widgets/`** consomment les providers, ne les créent pas.

Aucun widget ne fait d'appel réseau, ne lit un fichier, ne parse du JSON. Toute logique métier vit dans les providers ou les repositories.

---

## Les 14 providers

L'exigence minimale est **5 providers distincts**. Le projet en expose **14**, couvrant tous les types Riverpod.

| # | Provider | Type | Rôle |
|---|---|---|---|
| 1 | `sharedPreferencesProvider` | `Provider<SharedPreferences>` | Overridé au bootstrap dans `ProviderScope` |
| 2 | `favoritesStorageProvider` | `Provider<FavoritesStorage>` | Wrapper typé sur prefs |
| 3 | `productRepositoryProvider` | `Provider<ProductRepository>` | Injection du repository |
| 4 | `productsProvider` | `FutureProvider<List<Product>>` | Chargement de la liste depuis JSON |
| 5 | `productByIdProvider` | `FutureProvider.family<Product, String>` | Fiche produit paramétrée par id, cache par id |
| 6 | `filterProvider` | `NotifierProvider<FilterNotifier, ProductFilter>` | Catégorie + tri + recherche |
| 7 | `filteredProductsProvider` | `Provider<AsyncValue<List<Product>>>` | **Dérivé** — combine products + filter |
| 8 | `categoriesProvider` | `Provider<AsyncValue<List<String>>>` | **Dérivé** — catégories uniques depuis JSON |
| 9 | `cartProvider` | `NotifierProvider<CartNotifier, List<CartItem>>` | Panier avec add/remove/qty |
| 10 | `cartTotalProvider` | `Provider<double>` | **Dérivé** — somme des subtotals |
| 11 | `cartItemCountProvider` | `Provider<int>` | **Dérivé** — somme des quantités (badge nav) |
| 12 | `favoritesProvider` | `AsyncNotifierProvider<FavoritesNotifier, Set<String>>` | Init async depuis prefs + toggle + persist |
| 13 | `isFavoriteProvider` | `Provider.family<bool, String>` | **Dérivé** — un bool par produit (heart isolé) |
| 14 | `favoriteProductsProvider` | `Provider<AsyncValue<List<Product>>>` | **Dérivé** — join favorites × products |
| — | `userProvider` | `FutureProvider<UserProfile>` | Profil mocké |

**Types de providers couverts** : `Provider`, `Provider.family`, `FutureProvider`, `FutureProvider.family`, `NotifierProvider`, `AsyncNotifierProvider`, providers dérivés. C'est un panorama complet de l'API Riverpod.

### Graphe de dépendances

```
sharedPreferencesProvider (overridden)
    └── favoritesStorageProvider
            └── favoritesProvider (AsyncNotifier)
                    ├── isFavoriteProvider.family(id)
                    └── favoriteProductsProvider ◄── productsProvider

productRepositoryProvider
    └── productsProvider ─┬── productByIdProvider.family(id)
                          └── filteredProductsProvider ◄── filterProvider (Notifier)
                              categoriesProvider

cartProvider (Notifier) ─┬── cartTotalProvider
                         └── cartItemCountProvider

userProvider
```

Aucune circularité. Chaque provider dérivé recompute automatiquement quand ses dépendances changent — c'est la propagation Riverpod.

---

## Fonctionnalités

### Catalogue
- Liste 2 colonnes avec `ProductCard` (image + catégorie + nom + prix + rating + cœur)
- Barre de filtres par catégorie via `ChoiceChip`
- Tri via `SortBottomSheet` (4 options)
- Recherche full-text (nom + description)
- **Pull-to-refresh** via `ref.invalidate(productsProvider)`
- Skeleton **shimmer** pendant le chargement (aucune dépendance externe)
- Empty state avec bouton "Réinitialiser" les filtres

### Détail produit
- Hero image plein écran (400px)
- Overlays back + cœur (semi-transparent noir)
- Quantity stepper local (`setState`)
- Bouton sticky `Ajouter au panier · [total]`
- **SnackBar via `ref.listen`** quand le compteur panier augmente

### Panier
- **Empty state conditionnel** via un simple `if (items.isEmpty)`
- Cartes larges avec image paysage (16:9)
- Stepper compact par ligne (`+` / `-`)
- **Swipe-to-delete** (`Dismissible`)
- Summary sticky : sous-total / livraison gratuite / total violet
- Checkout mock : dialog de confirmation → clear cart → SnackBar

### Favoris
- Grille identique au catalogue (réutilise `ProductCard`)
- **Empty state** avec CTA vers catalog
- Provider dérivé qui **combine** favoritesProvider + productsProvider

### Profil
- Avatar circulaire avec ring gradient violet
- Chip "Membre depuis mars 2024" (via `intl` locale-aware)
- 3 stat cards **indépendantes** (chacune watch un provider différent)
- Menu groupé (Compte / Préférences / Aide) avec section "Se déconnecter" destructive

---

## États UI systématiques

Tout provider async utilise `AsyncValue.when(...)` pour couvrir les 3 états :

- **Loading** → skeleton shimmer (grille pour catalog, layout mimetic pour détail)
- **Error** → `ErrorView` avec bouton "Réessayer" qui appelle `ref.invalidate(...)`
- **Data** → contenu réel, ou `EmptyView` si liste vide

Zéro `FutureBuilder`. Zéro if/else sur "en cours de chargement". Tout passe par `.when`.

---

## Tests

**54 tests — 100% passent.**

```bash
flutter test
```

### Tests unitaires (32)

| Fichier | Tests | Couverture |
|---|---|---|
| `cart_notifier_test.dart` | 12 | add / remove / quantities / clear + providers dérivés |
| `favorites_notifier_test.dart` | 9 | init async / toggle / persistance / isFavorite / join |
| `filter_notifier_test.dart` | 10 | mutations + filteredProductsProvider (catégorie / search / sort) |
| `widget_test.dart` | 1 | smoke test boot de l'app |

### Tests widget (20)

| Fichier | Tests | Couverture |
|---|---|---|
| `product_card_test.dart` | 4 | nom, prix, cœur vide, cœur plein |
| `cart_item_tile_test.dart` | 4 | nom, sous-total, décrement désactivé à qty=1, incrément actif |
| `cart_page_test.dart` | 6 | titre, empty state, ajout d'items, total |
| `favorites_page_test.dart` | 3 | titre, EmptyView, ProductCards |
| `empty_view_test.dart` | 3 | titre, subtitle, bouton CTA |

### Tests d'intégration (2)

Fichier : `integration_test/app_test.dart`
- Boot complet de l'app → onglet Catalogue visible
- Navigation vers l'onglet Panier

**Techniques Riverpod démontrées** :
- `ProviderContainer` isolé par test (pas de widget tree)
- `overrideWithValue(prefs)` pour SharedPreferences mocké
- `overrideWith((ref) async => ...)` pour FutureProvider fake
- `container.read(asyncProvider.future)` pour attendre l'init d'un AsyncNotifier
- `ProviderScope(overrides: [...], child: testMaterialApp(...))` dans les tests widget

---

## Getting started

Prérequis : **Flutter ≥ 3.32**, **Dart ≥ 3.9**.

```bash
# 1. Cloner
git clone https://github.com/BrownofDarkness/nextFlutterEcommerceApp.git
cd nextFlutterEcommerceApp

# 2. Dépendances
flutter pub get

# 3. Lancer (choisir la cible)
flutter run                    # Android (émulateur ou device USB)
flutter run -d ios             # iOS Simulator / device
flutter run -d chrome          # Web (rapide pour itérer)
flutter run -d windows         # Desktop Windows

# 4. Tests unitaires + widget
flutter test

# 5. Tests d'intégration (requiert un device/émulateur connecté)
flutter test integration_test/app_test.dart

# 6. Analyse statique
flutter analyze
```

### Build Android (APK)

```bash
flutter build apk --debug        # APK debug rapide
flutter build apk --release      # APK release (nécessite une keystore)
# → build/app/outputs/flutter-apk/app-debug.apk
```

### Build iOS (IPA)

```bash
flutter build ios --release       # requiert Xcode + compte développeur Apple
```

### APK de démonstration

L'APK debug est produit automatiquement par le CI GitHub Actions à chaque push sur `main`.
Téléchargeable depuis l'onglet **Actions → Build APK → Artifacts → next-shop-debug-apk**.

---

## Design system — Studio Noir

Direction artistique générée via **Google Stitch** avec un prompt sur-mesure (voir `docs/screenshots/`).

### Tokens de couleur

| Token | Valeur | Usage |
|---|---|---|
| `background` | `#0B0B10` | Fond de scaffold |
| `surface` | `#16161E` | Cards, sheets |
| `surfaceSubtle` | `#1D1D28` | Hover, skeleton base |
| `borderHairline` | `#2A2A38` | Séparateurs 1px (pas d'ombres) |
| `seed` (primary) | `#7C5CFF` | Accents, CTA, active state |
| `textPrimary` | `#F5F5F7` | Corps de texte |
| `textSecondary` | `#A0A0AD` | Captions, labels |

### Principes

- **Elevation par teinte** (jamais d'ombre)
- **Hairline borders** partout (1px `#2A2A38`)
- **Radius** 12–20px selon élément
- **Typographie Inter** (system fallback), tight tracking sur headlines
- **Icônes outlined** exclusivement

---

## Requirements matrix

| Exigence certification | Où c'est prouvé |
|---|---|
| Catalogue produits (liste + détail) | `catalog_page.dart`, `product_detail_page.dart` |
| Panier (ajout / suppression / quantité) | `cart_provider.dart` + `cart_page.dart` |
| Favoris persistés localement | `favorites_provider.dart` (AsyncNotifier + SharedPreferences) |
| Filtrage et tri des produits | `filter_provider.dart` + `filteredProductsProvider` |
| Écran profil utilisateur (mock) | `profile_page.dart` + `user_provider.dart` |
| Utiliser exclusivement Riverpod | Aucune ligne `setState` métier — uniquement UI local (quantité fiche produit) |
| Au moins 5 providers distincts | **14 providers** implémentés |
| Séparer logique métier / widgets | `data/` + `providers/` isolés, widgets = consommateurs purs |
| Gérer états loading / error dans l'UI | `AsyncValue.when` sur toutes les pages async |
| Utiliser `AsyncValue` pour l'async | Systématique — voir tableau des providers |
| Données mockées (JSON / fake API) | `assets/products.json` + `ProductLocalSource` |
| Bonus : animation sur ajout panier | SnackBar flottant via `ref.listen(cartItemCountProvider)` |
| **Tests unitaires (≥ 10)** | 32 tests — `test/providers/` |
| **Tests widget (≥ 5)** | 20 tests — `test/widgets/` (ProductCard, CartItemTile, CartPage, FavoritesPage, EmptyView) |
| **Tests d'intégration (≥ 2)** | 2 tests — `integration_test/app_test.dart` |
| **Accessibilité** | `Semantics` + `tooltip` sur tous les éléments interactifs sans label visible |
| **Internationalisation FR + EN** | `AppLocalizations` + ARB files, locale résolue depuis la langue de l'appareil |
| **Images lazy-loading + cache** | `CachedNetworkImage` sur toutes les images réseau |
| **CI/CD** | GitHub Actions : analyze → test → build APK (`.github/workflows/ci.yml`) |
| **CHANGELOG.md** | 3 versions documentées (v1.0.0, v1.1.0, v1.2.0) |

---

## Décisions techniques notables

1. **`StatefulShellRoute.indexedStack`** — chaque onglet préserve son état (scroll, filtres) grâce à un Navigator par branche.
2. **Product detail nested dans catalog ET favorites** — évite un changement d'onglet involontaire lors d'un push depuis les favoris.
3. **`SharedPreferences` bootstrap async → provider synchrone via `overrideWithValue`** — pattern officiel Riverpod pour rendre du code async accessible synchrone après init.
4. **Shimmer maison sans package** — `ShaderMask` + `AnimationController.repeat()` + `SkeletonBox`, ~50 lignes. Une seule animation partagée par écran.
5. **`intl` pour dates et prix** — plutôt que hardcoder les mois français ou concaténer les euros à la main.
6. **`ref.listen` sur `cartItemCountProvider`** pour le SnackBar — pattern réactif propre, fonctionne même si l'ajout vient d'un autre écran.
7. **Provider dérivés `.family` (`isFavoriteProvider`)** — un cœur ne rebuild pas quand un autre cœur change. Optimisation critique en grille.
