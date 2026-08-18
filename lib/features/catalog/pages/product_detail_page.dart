import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/theme/app_theme.dart';
import '../../../core/utils/formatters.dart';
import '../../../data/models/product.dart';
import '../../../shared/widgets/error_view.dart';
import '../../../shared/widgets/skeleton.dart';
import '../../cart/providers/cart_provider.dart';
import '../../favorites/providers/favorites_provider.dart';
import '../providers/product_providers.dart';

class ProductDetailPage extends ConsumerWidget {
  const ProductDetailPage({required this.productId, super.key});

  final String productId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final productAsync = ref.watch(productByIdProvider(productId));

    // React to cart changes (from this page OR elsewhere): if the total
    // item count increased, show a SnackBar. `ref.listen` fires on state
    // changes without triggering a rebuild of this widget.
    ref.listen<int>(cartItemCountProvider, (previous, next) {
      if (previous != null && next > previous) {
        ScaffoldMessenger.of(context)
          ..hideCurrentSnackBar()
          ..showSnackBar(
            const SnackBar(
              content: Text('Ajouté au panier'),
              duration: Duration(seconds: 2),
              behavior: SnackBarBehavior.floating,
            ),
          );
      }
    });

    return Scaffold(
      body: productAsync.when(
        loading: () => const _DetailSkeleton(),
        error: (err, _) => Padding(
          padding: EdgeInsets.only(top: MediaQuery.paddingOf(context).top),
          child: ErrorView(
            message: '$err',
            onRetry: () => ref.invalidate(productByIdProvider(productId)),
          ),
        ),
        data: (product) => _DetailContent(product: product),
      ),
    );
  }
}

/// Actual detail layout — separated as a [ConsumerStatefulWidget] because
/// the [_quantity] counter is transient UI state, not something that belongs
/// in a global provider.
class _DetailContent extends ConsumerStatefulWidget {
  const _DetailContent({required this.product});

  final Product product;

  @override
  ConsumerState<_DetailContent> createState() => _DetailContentState();
}

class _DetailContentState extends ConsumerState<_DetailContent> {
  int _quantity = 1;

  @override
  Widget build(BuildContext context) {
    final product = widget.product;
    final isFavorite = ref.watch(isFavoriteProvider(product.id));
    final text = Theme.of(context).textTheme;
    final scheme = Theme.of(context).colorScheme;

    return Stack(
      children: [
        // Scrollable content: hero image + info sheet.
        CustomScrollView(
          slivers: [
            SliverToBoxAdapter(
              child: _HeroImage(imageUrl: product.imageUrl),
            ),
            SliverToBoxAdapter(
              child: Transform.translate(
                offset: const Offset(0, -24),
                child: Container(
                  padding: const EdgeInsets.fromLTRB(20, 24, 20, 32),
                  decoration: const BoxDecoration(
                    color: AppTheme.background,
                    borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        Formatters.categoryLabel(product.category)
                            .toUpperCase(),
                        style: text.labelSmall
                            ?.copyWith(color: scheme.primary),
                      ),
                      const SizedBox(height: 8),
                      Text(product.name, style: text.headlineMedium),
                      const SizedBox(height: 16),
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Text(
                            Formatters.euros(product.price),
                            style: text.headlineLarge?.copyWith(
                              fontSize: 28,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                          const Spacer(),
                          const Icon(Icons.star_rounded,
                              size: 18, color: Color(0xFFFFB780)),
                          const SizedBox(width: 4),
                          Text(
                            '${product.rating.toStringAsFixed(1)} (128 avis)',
                            style: text.bodySmall,
                          ),
                        ],
                      ),
                      const SizedBox(height: 24),
                      const Divider(height: 1),
                      const SizedBox(height: 24),
                      Text('DESCRIPTION', style: text.labelSmall),
                      const SizedBox(height: 8),
                      Text(product.description, style: text.bodyMedium),
                      const SizedBox(height: 24),
                      Text('QUANTITÉ', style: text.labelSmall),
                      const SizedBox(height: 12),
                      _QuantityStepper(
                        value: _quantity,
                        onChanged: (v) => setState(() => _quantity = v),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            // Bottom room so content isn't hidden by the sticky button + nav.
            const SliverToBoxAdapter(child: SizedBox(height: 140)),
          ],
        ),

        // Top overlay: back + favorite buttons.
        Positioned(
          top: 0,
          left: 0,
          right: 0,
          child: SafeArea(
            bottom: false,
            child: Padding(
              padding: const EdgeInsets.all(12),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  _GhostCircleButton(
                    icon: Icons.arrow_back_rounded,
                    onTap: () => context.pop(),
                  ),
                  _GhostCircleButton(
                    icon: isFavorite
                        ? Icons.favorite
                        : Icons.favorite_border_rounded,
                    iconColor: isFavorite ? scheme.primary : Colors.white,
                    onTap: () => ref
                        .read(favoritesProvider.notifier)
                        .toggle(product.id),
                  ),
                ],
              ),
            ),
          ),
        ),

        // Sticky bottom "add to cart" bar.
        Positioned(
          left: 0,
          right: 0,
          bottom: 0,
          child: _AddToCartBar(
            product: product,
            quantity: _quantity,
            onAdd: () => ref
                .read(cartProvider.notifier)
                .add(product, quantity: _quantity),
          ),
        ),
      ],
    );
  }
}

class _HeroImage extends StatelessWidget {
  const _HeroImage({required this.imageUrl});

  final String imageUrl;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 400,
      width: double.infinity,
      child: Image.network(
        imageUrl,
        fit: BoxFit.cover,
        loadingBuilder: (_, child, progress) => progress == null
            ? child
            : const ColoredBox(color: AppTheme.surfaceSubtle),
        errorBuilder: (_, _, _) => const ColoredBox(
          color: AppTheme.surfaceSubtle,
          child: Icon(Icons.broken_image_outlined,
              color: AppTheme.textTertiary, size: 48),
        ),
      ),
    );
  }
}

class _GhostCircleButton extends StatelessWidget {
  const _GhostCircleButton({
    required this.icon,
    required this.onTap,
    this.iconColor = Colors.white,
  });

  final IconData icon;
  final VoidCallback onTap;
  final Color iconColor;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.black.withValues(alpha: 0.45),
      shape: const CircleBorder(),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(10),
          child: Icon(icon, size: 22, color: iconColor),
        ),
      ),
    );
  }
}

class _QuantityStepper extends StatelessWidget {
  const _QuantityStepper({required this.value, required this.onChanged});

  final int value;
  final ValueChanged<int> onChanged;

  @override
  Widget build(BuildContext context) {
    final text = Theme.of(context).textTheme;
    return Container(
      decoration: BoxDecoration(
        color: AppTheme.surface,
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: AppTheme.borderHairline),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 4),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          IconButton(
            icon: const Icon(Icons.remove_rounded, size: 20),
            onPressed: value > 1 ? () => onChanged(value - 1) : null,
          ),
          SizedBox(
            width: 32,
            child: Text(
              '$value',
              textAlign: TextAlign.center,
              style: text.titleMedium,
            ),
          ),
          IconButton(
            icon: const Icon(Icons.add_rounded, size: 20),
            onPressed: () => onChanged(value + 1),
          ),
        ],
      ),
    );
  }
}

class _AddToCartBar extends StatelessWidget {
  const _AddToCartBar({
    required this.product,
    required this.quantity,
    required this.onAdd,
  });

  final Product product;
  final int quantity;
  final VoidCallback onAdd;

  @override
  Widget build(BuildContext context) {
    final total = product.price * quantity;
    return Container(
      decoration: BoxDecoration(
        color: AppTheme.background.withValues(alpha: 0.85),
        border: const Border(
          top: BorderSide(color: AppTheme.borderHairline),
        ),
      ),
      child: SafeArea(
        top: false,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 12, 20, 12),
          child: FilledButton(
            onPressed: onAdd,
            child: Text(
              'Ajouter au panier · ${Formatters.euros(total)}',
            ),
          ),
        ),
      ),
    );
  }
}

/// Shimmer skeleton mirroring the detail layout — a hero image block plus
/// stacked text placeholders. Fired inside `productAsync.when(loading: ...)`.
class _DetailSkeleton extends StatelessWidget {
  const _DetailSkeleton();

  @override
  Widget build(BuildContext context) {
    return const Shimmer(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          SizedBox(
            height: 400,
            child: SkeletonBox(borderRadius: 0),
          ),
          SizedBox(height: 24),
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SkeletonBox(width: 80, height: 12, borderRadius: 4),
                SizedBox(height: 12),
                SkeletonBox(
                    width: double.infinity, height: 24, borderRadius: 6),
                SizedBox(height: 8),
                SkeletonBox(width: 220, height: 24, borderRadius: 6),
                SizedBox(height: 20),
                SkeletonBox(width: 140, height: 28, borderRadius: 6),
                SizedBox(height: 24),
                SkeletonBox(
                    width: double.infinity, height: 14, borderRadius: 4),
                SizedBox(height: 6),
                SkeletonBox(
                    width: double.infinity, height: 14, borderRadius: 4),
                SizedBox(height: 6),
                SkeletonBox(width: 260, height: 14, borderRadius: 4),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
