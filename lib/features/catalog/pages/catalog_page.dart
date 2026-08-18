import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/router/route_names.dart';
import '../../../shared/widgets/empty_view.dart';
import '../../../shared/widgets/error_view.dart';
import '../providers/filter_provider.dart';
import '../providers/product_providers.dart';
import '../widgets/category_chips.dart';
import '../widgets/product_card.dart';
import '../widgets/product_card_skeleton.dart';
import '../widgets/search_field.dart';
import '../widgets/sort_bottom_sheet.dart';

class CatalogPage extends ConsumerWidget {
  const CatalogPage({super.key});

  static const int _gridCrossAxisCount = 2;
  static const double _horizontalPadding = 20;
  static const double _gridGutter = 16;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final filteredAsync = ref.watch(filteredProductsProvider);
    final text = Theme.of(context).textTheme;

    return Scaffold(
      body: SafeArea(
        bottom: false,
        child: RefreshIndicator(
          onRefresh: () async => ref.invalidate(productsProvider),
          child: CustomScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            slivers: [
              // Header — "Catalogue" title + product count.
              SliverPadding(
                padding: const EdgeInsets.fromLTRB(_horizontalPadding, 16,
                    _horizontalPadding, 8),
                sliver: SliverToBoxAdapter(
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('Catalogue', style: text.headlineLarge),
                            const SizedBox(height: 4),
                            Text(
                              _countLabel(filteredAsync.value?.length),
                              style: text.bodySmall,
                            ),
                          ],
                        ),
                      ),
                      IconButton.filledTonal(
                        onPressed: () => SortBottomSheet.show(context),
                        icon: const Icon(Icons.swap_vert_rounded),
                        tooltip: 'Trier',
                      ),
                    ],
                  ),
                ),
              ),

              // Search field.
              const SliverPadding(
                padding: EdgeInsets.fromLTRB(_horizontalPadding, 12,
                    _horizontalPadding, 12),
                sliver: SliverToBoxAdapter(child: SearchField()),
              ),

              // Category chips (own their padding).
              const SliverToBoxAdapter(child: CategoryChips()),

              const SliverToBoxAdapter(child: SizedBox(height: 16)),

              // Grid / states.
              SliverPadding(
                padding: const EdgeInsets.fromLTRB(_horizontalPadding, 0,
                    _horizontalPadding, 100), // bottom room for floating nav
                sliver: filteredAsync.when(
                  loading: () => _buildSkeletonGrid(),
                  error: (err, _) => SliverFillRemaining(
                    hasScrollBody: false,
                    child: ErrorView(
                      message: '$err',
                      onRetry: () => ref.invalidate(productsProvider),
                    ),
                  ),
                  data: (products) {
                    if (products.isEmpty) {
                      return SliverFillRemaining(
                        hasScrollBody: false,
                        child: EmptyView(
                          icon: Icons.search_off_rounded,
                          title: 'Aucun produit trouvé',
                          subtitle:
                              'Essayez d\'ajuster vos filtres ou votre recherche.',
                          actionLabel: 'Réinitialiser',
                          onAction: () =>
                              ref.read(filterProvider.notifier).reset(),
                        ),
                      );
                    }
                    return _buildProductGrid(context, products);
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildProductGrid(BuildContext context, List<dynamic> products) {
    return SliverGrid(
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: _gridCrossAxisCount,
        crossAxisSpacing: _gridGutter,
        mainAxisSpacing: _gridGutter,
        childAspectRatio: 0.52,
      ),
      delegate: SliverChildBuilderDelegate(
        (context, index) {
          final product = products[index];
          return ProductCard(
            product: product,
            onTap: () =>
                context.push(RouteNames.productDetail(product.id)),
          );
        },
        childCount: products.length,
      ),
    );
  }

  Widget _buildSkeletonGrid() {
    return const SliverGrid(
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: _gridCrossAxisCount,
        crossAxisSpacing: _gridGutter,
        mainAxisSpacing: _gridGutter,
        childAspectRatio: 0.52,
      ),
      delegate: SliverChildListDelegate.fixed([
        ProductCardSkeleton(),
        ProductCardSkeleton(),
        ProductCardSkeleton(),
        ProductCardSkeleton(),
        ProductCardSkeleton(),
        ProductCardSkeleton(),
      ]),
    );
  }

  static String _countLabel(int? count) {
    if (count == null) return 'Chargement…';
    if (count == 0) return 'Aucun produit';
    if (count == 1) return '1 produit';
    return '$count produits';
  }
}
