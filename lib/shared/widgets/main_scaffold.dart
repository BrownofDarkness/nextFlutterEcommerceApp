import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../features/cart/providers/cart_provider.dart';

/// Root shell containing the bottom navigation and hosting the current tab's
/// navigator via [navigationShell].
///
/// [ConsumerWidget] is used (instead of [StatelessWidget]) so we can watch
/// [cartItemCountProvider] to display a live badge on the cart icon.
class MainScaffold extends ConsumerWidget {
  const MainScaffold({required this.navigationShell, super.key});

  final StatefulNavigationShell navigationShell;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final cartCount = ref.watch(cartItemCountProvider);

    return Scaffold(
      body: navigationShell,
      bottomNavigationBar: NavigationBar(
        selectedIndex: navigationShell.currentIndex,
        onDestinationSelected: (index) => navigationShell.goBranch(
          index,
          // Tapping the currently active tab resets it to its initial location.
          initialLocation: index == navigationShell.currentIndex,
        ),
        destinations: [
          const NavigationDestination(
            icon: Icon(Icons.storefront_outlined),
            selectedIcon: Icon(Icons.storefront),
            label: 'Catalogue',
          ),
          NavigationDestination(
            icon: _CartIcon(count: cartCount, filled: false),
            selectedIcon: _CartIcon(count: cartCount, filled: true),
            label: 'Panier',
          ),
          const NavigationDestination(
            icon: Icon(Icons.favorite_border),
            selectedIcon: Icon(Icons.favorite),
            label: 'Favoris',
          ),
          const NavigationDestination(
            icon: Icon(Icons.person_outline),
            selectedIcon: Icon(Icons.person),
            label: 'Profil',
          ),
        ],
      ),
    );
  }
}

/// Cart icon with an optional Material 3 [Badge] showing the item count.
class _CartIcon extends StatelessWidget {
  const _CartIcon({required this.count, required this.filled});

  final int count;
  final bool filled;

  @override
  Widget build(BuildContext context) {
    final icon = Icon(filled ? Icons.shopping_cart : Icons.shopping_cart_outlined);
    if (count <= 0) return icon;
    return Badge(label: Text('$count'), child: icon);
  }
}
