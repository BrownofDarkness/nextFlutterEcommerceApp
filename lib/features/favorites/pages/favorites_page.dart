import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/router/route_names.dart';
import '../../../shared/widgets/empty_view.dart';
import '../../../shared/widgets/error_view.dart';
import '../../catalog/widgets/product_card.dart';
import '../../catalog/widgets/product_card_skeleton.dart';
import '../providers/favorites_provider.dart';

/// Favorites tab.
///
/// Watches [favoriteProductsProvider] — a derived provider that joins the
/// favorites set (IDs) with the full catalog. When the user unfavorites a
/// card from this page, the derived provider recomputes, the grid shrinks,
/// and the empty state kicks in automatically once the last item is removed.
class FavoritesPage extends ConsumerWidget {
  const FavoritesPage({super.key});

  static const int _crossAxisCount = 2;
  static const double _hPadding = 20;
  static const double _gutter = 16;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final favoritesAsync = ref.watch(favoriteProductsProvider);
    final text = Theme.of(context).textTheme;

    return Scaffold(
      body: SafeArea(
        bottom: false,
        child: CustomScrollView(
          slivers: [
            SliverPadding(
              padding: const EdgeInsets.fromLTRB(_hPadding, 16, _hPadding, 16),
              sliver: SliverToBoxAdapter(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Favoris', style: text.headlineLarge),
                    const SizedBox(height: 4),
                    Text(
                      _countLabel(favoritesAsync.value?.length),
                      style: text.bodySmall,
                    ),
                  ],
                ),
              ),
            ),
            SliverPadding(
              padding: const EdgeInsets.fromLTRB(_hPadding, 0, _hPadding, 100),
              sliver: favoritesAsync.when(
                loading: _buildSkeletonGrid,
                error: (err, _) => SliverFillRemaining(
                  hasScrollBody: false,
                  child: ErrorView(
                    message: '$err',
                    onRetry: () => ref.invalidate(favoritesProvider),
                  ),
                ),
                data: (products) {
                  if (products.isEmpty) {
                    return SliverFillRemaining(
                      hasScrollBody: false,
                      child: EmptyView(
                        icon: Icons.favorite_border_rounded,
                        title: 'Aucun favori pour le moment',
                        subtitle:
                            'Ajoutez des produits à vos favoris depuis le catalogue.',
                        actionLabel: 'Découvrir le catalogue',
                        onAction: () => context.go(RouteNames.catalog),
                      ),
                    );
                  }
                  return SliverGrid(
                    gridDelegate:
                        const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: _crossAxisCount,
                      crossAxisSpacing: _gutter,
                      mainAxisSpacing: _gutter,
                      childAspectRatio: 0.52,
                    ),
                    delegate: SliverChildBuilderDelegate(
                      (context, i) {
                        final product = products[i];
                        return ProductCard(
                          product: product,
                          onTap: () => context.push(
                            RouteNames.favoritesProductDetail(product.id),
                          ),
                        );
                      },
                      childCount: products.length,
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSkeletonGrid() {
    return const SliverGrid(
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: _crossAxisCount,
        crossAxisSpacing: _gutter,
        mainAxisSpacing: _gutter,
        childAspectRatio: 0.52,
      ),
      delegate: SliverChildListDelegate.fixed([
        ProductCardSkeleton(),
        ProductCardSkeleton(),
        ProductCardSkeleton(),
        ProductCardSkeleton(),
      ]),
    );
  }

  static String _countLabel(int? count) {
    if (count == null) return 'Chargement…';
    if (count == 0) return 'Aucun produit sauvegardé';
    if (count == 1) return '1 produit sauvegardé';
    return '$count produits sauvegardés';
  }
}
