import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/theme/app_theme.dart';
import '../../../core/utils/formatters.dart';
import '../../../data/models/product.dart';
import '../../favorites/providers/favorites_provider.dart';

/// Product card used in the catalog grid AND the favorites grid.
///
/// [ConsumerWidget] because we watch `isFavoriteProvider(product.id)` — the
/// `.family` variant ensures a single card only rebuilds when ITS OWN
/// favorite status changes (not when other cards' hearts toggle).
class ProductCard extends ConsumerWidget {
  const ProductCard({required this.product, this.onTap, super.key});

  final Product product;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isFavorite = ref.watch(isFavoriteProvider(product.id));
    final text = Theme.of(context).textTheme;
    final scheme = Theme.of(context).colorScheme;

    return Material(
      color: AppTheme.surface,
      borderRadius: BorderRadius.circular(16),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: DecoratedBox(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: AppTheme.borderHairline),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Stack(
                children: [
                  AspectRatio(
                    aspectRatio: 1,
                    child: Image.network(
                      product.imageUrl,
                      fit: BoxFit.cover,
                      loadingBuilder: (_, child, progress) => progress == null
                          ? child
                          : const ColoredBox(color: AppTheme.surfaceSubtle),
                      errorBuilder: (_, _, _) => const ColoredBox(
                        color: AppTheme.surfaceSubtle,
                        child: Icon(Icons.broken_image_outlined,
                            color: AppTheme.textTertiary),
                      ),
                    ),
                  ),
                  Positioned(
                    top: 8,
                    right: 8,
                    child: _FavoriteToggle(
                      productId: product.id,
                      isFavorite: isFavorite,
                    ),
                  ),
                ],
              ),
              Padding(
                padding: const EdgeInsets.all(12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      Formatters.categoryLabel(product.category).toUpperCase(),
                      style: text.labelSmall?.copyWith(color: scheme.primary),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      product.name,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: text.titleSmall,
                    ),
                    const SizedBox(height: 10),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          Formatters.euros(product.price),
                          style: text.titleMedium?.copyWith(
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(Icons.star_rounded,
                                size: 14, color: Color(0xFFFFB780)),
                            const SizedBox(width: 2),
                            Text(product.rating.toStringAsFixed(1),
                                style: text.bodySmall),
                          ],
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Circular semi-transparent button overlaid on the product image.
class _FavoriteToggle extends ConsumerWidget {
  const _FavoriteToggle({required this.productId, required this.isFavorite});

  final String productId;
  final bool isFavorite;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Material(
      color: Colors.black.withValues(alpha: 0.45),
      shape: const CircleBorder(),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: () => ref.read(favoritesProvider.notifier).toggle(productId),
        child: Padding(
          padding: const EdgeInsets.all(6),
          child: Icon(
            isFavorite ? Icons.favorite : Icons.favorite_border,
            size: 20,
            color: isFavorite
                ? AppTheme.seed
                : Colors.white.withValues(alpha: 0.9),
          ),
        ),
      ),
    );
  }
}