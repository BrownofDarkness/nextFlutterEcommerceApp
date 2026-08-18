import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/theme/app_theme.dart';
import '../../../core/utils/formatters.dart';
import '../../../data/models/cart_item.dart';
import '../providers/cart_provider.dart';

/// One row in the cart list.
///
/// Wrapped in a [Dismissible] so a horizontal swipe (right-to-left) removes
/// the line. The [Dismissible.key] MUST be stable per item (we use the
/// product id) so Flutter tracks the animation across list rebuilds.
class CartItemTile extends ConsumerWidget {
  const CartItemTile({required this.item, super.key});

  final CartItem item;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final cart = ref.read(cartProvider.notifier);
    final text = Theme.of(context).textTheme;

    return Dismissible(
      key: ValueKey('cart-${item.product.id}'),
      direction: DismissDirection.endToStart,
      onDismissed: (_) => cart.remove(item.product.id),
      background: Container(
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: 24),
        decoration: BoxDecoration(
          color: const Color(0xFFEF4444).withValues(alpha: 0.15),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: const Color(0xFFEF4444).withValues(alpha: 0.4),
          ),
        ),
        child: const Icon(Icons.delete_outline_rounded,
            color: Color(0xFFEF4444), size: 24),
      ),
      child: DecoratedBox(
        decoration: BoxDecoration(
          color: AppTheme.surface,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: AppTheme.borderHairline),
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Landscape image (16:9)
              AspectRatio(
                aspectRatio: 16 / 9,
                child: Image.network(
                  item.product.imageUrl,
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
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 14, 16, 14),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          child: Text(
                            item.product.name,
                            style: text.titleMedium,
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Text(
                          Formatters.euros(item.subtotal),
                          style: text.titleMedium?.copyWith(
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        _CompactStepper(
                          value: item.quantity,
                          onDecrement: item.quantity > 1
                              ? () => cart.decrement(item.product.id)
                              : null,
                          onIncrement: () => cart.increment(item.product.id),
                        ),
                        const Spacer(),
                        IconButton(
                          icon: const Icon(Icons.delete_outline_rounded,
                              size: 22),
                          color: AppTheme.textSecondary,
                          onPressed: () => cart.remove(item.product.id),
                          tooltip: 'Retirer',
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

class _CompactStepper extends StatelessWidget {
  const _CompactStepper({
    required this.value,
    required this.onIncrement,
    this.onDecrement,
  });

  final int value;
  final VoidCallback onIncrement;
  final VoidCallback? onDecrement;

  @override
  Widget build(BuildContext context) {
    final text = Theme.of(context).textTheme;
    return Container(
      decoration: BoxDecoration(
        color: AppTheme.surfaceSubtle,
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: AppTheme.borderHairline),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          _StepperButton(
            icon: Icons.remove_rounded,
            onTap: onDecrement,
          ),
          SizedBox(
            width: 28,
            child: Text(
              '$value',
              textAlign: TextAlign.center,
              style: text.titleSmall,
            ),
          ),
          _StepperButton(
            icon: Icons.add_rounded,
            onTap: onIncrement,
          ),
        ],
      ),
    );
  }
}

class _StepperButton extends StatelessWidget {
  const _StepperButton({required this.icon, required this.onTap});

  final IconData icon;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final enabled = onTap != null;
    return Material(
      color: Colors.transparent,
      shape: const CircleBorder(),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(6),
          child: Icon(
            icon,
            size: 18,
            color: enabled ? AppTheme.textPrimary : AppTheme.textTertiary,
          ),
        ),
      ),
    );
  }
}
