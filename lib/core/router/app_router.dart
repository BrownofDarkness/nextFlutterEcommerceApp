import 'package:go_router/go_router.dart';

import '../../features/cart/pages/cart_page.dart';
import '../../features/catalog/pages/catalog_page.dart';
import '../../features/catalog/pages/product_detail_page.dart';
import '../../features/favorites/pages/favorites_page.dart';
import '../../features/profile/pages/profile_page.dart';
import '../../shared/widgets/main_scaffold.dart';
import 'route_names.dart';

/// Application router.
///
/// Uses `StatefulShellRoute.indexedStack` so each tab has its own Navigator
/// (state and back-stack preserved across tab switches). The product detail
/// page is nested inside the catalog branch → the bottom nav stays visible
/// while browsing a product, and pressing back returns to the catalog list.
final GoRouter appRouter = GoRouter(
  initialLocation: RouteNames.catalog,
  routes: [
    StatefulShellRoute.indexedStack(
      builder: (context, state, navigationShell) => MainScaffold(
        navigationShell: navigationShell,
      ),
      branches: [
        // Branch 0 — Catalog + nested product detail.
        StatefulShellBranch(
          routes: [
            GoRoute(
              path: RouteNames.catalog,
              builder: (context, state) => const CatalogPage(),
              routes: [
                GoRoute(
                  path: RouteNames.productDetailSubPath,
                  builder: (context, state) => ProductDetailPage(
                    productId: state.pathParameters['id']!,
                  ),
                ),
              ],
            ),
          ],
        ),
        // Branch 1 — Cart.
        StatefulShellBranch(
          routes: [
            GoRoute(
              path: RouteNames.cart,
              builder: (context, state) => const CartPage(),
            ),
          ],
        ),
        // Branch 2 — Favorites + nested product detail (same page as catalog,
        // just reachable within the favorites branch so navigation stays put).
        StatefulShellBranch(
          routes: [
            GoRoute(
              path: RouteNames.favorites,
              builder: (context, state) => const FavoritesPage(),
              routes: [
                GoRoute(
                  path: RouteNames.productDetailSubPath,
                  builder: (context, state) => ProductDetailPage(
                    productId: state.pathParameters['id']!,
                  ),
                ),
              ],
            ),
          ],
        ),
        // Branch 3 — Profile.
        StatefulShellBranch(
          routes: [
            GoRoute(
              path: RouteNames.profile,
              builder: (context, state) => const ProfilePage(),
            ),
          ],
        ),
      ],
    ),
  ],
);
